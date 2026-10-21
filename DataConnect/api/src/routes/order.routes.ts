import { Router } from 'express';
import { adminDc } from '../firebase';
import { verifyFirebaseToken, requireAdmin, requireKitchen } from '../middlewares/auth.middleware';
import { createOrder, updateOrderStatus, addOrderItem, listOrdersByRestaurant, getOrderById } from '@dataconnect/admin-generated';
import { notifyNewOrderPush, notifyStaffCallPush, registerDeviceToken, unregisterDeviceToken, registeredDeviceTokens, sendPushToDevices, sendPushToTopic, sanitizeTopicName } from '../services/push.service';

const router = Router();

// TODAS las rutas de este router exigen un token de Firebase válido.
// Antes esta protección estaba registrada DESPUÉS de las rutas /sync, por lo que
// los pedidos, los cobros, la CLABE bancaria y los comprobantes SPEI quedaban
// accesibles sin autenticación a cualquier persona que alcanzara la API.
router.use(verifyFirebaseToken);

// Almacén en memoria sincronizado en tiempo real para KDS y Salón
const activeOrdersStore: any[] = [];

// Endpoint para consultar pedidos activos en Cocina / Administración
router.get('/sync', (req, res) => {
  const { restaurantId } = req.query;
  if (restaurantId) {
    const filtered = activeOrdersStore.filter(o => !o.restaurantId || o.restaurantId === restaurantId);
    return res.json({ success: true, orders: filtered });
  }
  res.json({ success: true, orders: activeOrdersStore });
});

// Endpoint para enviar o sincronizar una nueva comanda
router.post('/sync', (req, res) => {
  const order = req.body;
  if (!order || !order.id) {
    return res.status(400).json({ error: 'Falta comanda válida con id' });
  }
  const existingIdx = activeOrdersStore.findIndex(o => o.id === order.id);
  if (existingIdx >= 0) {
    activeOrdersStore[existingIdx] = { ...activeOrdersStore[existingIdx], ...order };
  } else {
    activeOrdersStore.unshift(order);
    // Notificación Push inmediata al entrar una comanda nueva (despierta al Cocinero y Administrador)
    notifyNewOrderPush({
      restaurantId: order.restaurantId,
      orderId: order.id,
      tableIdentifier: order.tableIdentifier || 'Mesa',
      totalAmount: Number(order.totalAmount || 0),
      itemCount: order.items?.length || 0,
      sender: { userId: (req as any).user?.uid, role: (req as any).user?.role },
    }).catch(err => console.warn('[Push Order Topic Error]:', err.message));

    sendPushNotification({
      title: `🍽️ Nueva Comanda: ${order.tableIdentifier || 'Mesa'}`,
      body: `Total: \$${Number(order.totalAmount || 0).toFixed(2)} - ${order.items?.length || 0} platillos`,
      data: {
        type: 'new_order',
        orderId: order.id,
        tableIdentifier: order.tableIdentifier || '',
      },
      roleTarget: 'all',
      restaurantId: order.restaurantId,
    }, { userId: (req as any).user?.uid, role: (req as any).user?.role });
  }
  res.status(201).json({ success: true, order });
});

// Endpoint para actualizar estado de la orden desde Cocina (aceptar, preparar, listo)
router.patch('/sync/:id/status', requireKitchen, (req, res) => {
  const { id } = req.params;
  const { status, confirmedAt, cookingStartedAt, readyAt } = req.body;
  const order = activeOrdersStore.find(o => o.id === id);
  if (order) {
    order.status = status;
    if (confirmedAt) order.confirmedAt = confirmedAt;
    if (cookingStartedAt) order.cookingStartedAt = cookingStartedAt;
    if (readyAt) order.readyAt = readyAt;
    return res.json({ success: true, order });
  }
  res.status(404).json({ error: 'Orden no encontrada' });
});

// Almacén de configuración bancaria por restaurante (para transferencias directas SPEI de comensales)
interface BankingInfo {
  bankName: string;
  accountHolder: string;
  clabe: string;
  notes?: string;
  updatedAt?: string;
}

const restaurantBankingStore: Record<string, BankingInfo> = {
  default: {
    bankName: 'BBVA México',
    accountHolder: "Vianey Coffee S.A. de C.V.",
    clabe: '012180015482938475',
    notes: 'Concepto/Referencia: Número de tu mesa o nombre',
    updatedAt: new Date().toISOString()
  }
};

// Endpoint para consultar datos bancarios del restaurante
router.get('/sync/banking', (req, res) => {
  const { restaurantId } = req.query;
  const key = (restaurantId as string) || 'default';
  const info = restaurantBankingStore[key] || restaurantBankingStore['default'];
  res.json({ success: true, banking: info });
});

// Endpoint para actualizar datos bancarios del restaurante (Solo Administrador)
router.post('/sync/banking', requireAdmin, (req, res) => {
  const { restaurantId, bankName, accountHolder, clabe, notes } = req.body;
  if (!bankName || !accountHolder || !clabe) {
    return res.status(400).json({ error: 'Faltan campos obligatorios: bankName, accountHolder, clabe' });
  }

  // Validación básica de formato CLABE mexicana (18 dígitos)
  const cleanClabe = clabe.toString().replace(/\s+/g, '');
  if (!/^\d{18}$/.test(cleanClabe)) {
    return res.status(400).json({ error: 'La CLABE interbancaria debe contener exactamente 18 dígitos numéricos.' });
  }

  const key = restaurantId || 'default';
  restaurantBankingStore[key] = {
    bankName: bankName.trim(),
    accountHolder: accountHolder.trim(),
    clabe: cleanClabe,
    notes: notes ? notes.trim() : 'Concepto/Referencia: Número de mesa',
    updatedAt: new Date().toISOString()
  };

  res.json({ success: true, banking: restaurantBankingStore[key] });
});

// Almacén de llamadas de mesas (Llamar mesero / Pedir cuenta / Comprobantes)
export interface StaffCallItem {
  id: string;
  tableIdentifier: string;
  reason: 'call_waiter' | 'request_bill' | 'payment_receipt';
  customerName?: string | null;
  paymentPreference?: 'cash' | 'terminal' | 'transfer' | null;
  receiptImage?: string | null;
  amountToPay?: number | null;
  restaurantId?: string | null;
  requestedAt: string;
  isResolved: boolean;
  notes?: string | null;
}

const activeStaffCalls: StaffCallItem[] = [];

// Almacén de tokens de dispositivos (para Push Notifications hacia administradores y cocineros)
/**
 * Endpoint para registrar dispositivos (mesas, administradores, cocineros, meseros) para Push.
 *
 * El token FCM lo genera Firebase para el DISPOSITIVO; aquí se guarda junto
 * con el usuario que lo tiene abierto, su rol, la plataforma y el
 * restaurante, para poder dirigir las push y depurar cuando no llegan.
 */
router.post('/sync/register-device', async (req, res) => {
  const { token, role, restaurantId, platform, deviceLabel } = req.body;
  if (!token) {
    return res.status(400).json({ error: 'Falta token de dispositivo' });
  }

  const user = (req as any).user;

  const result = await registerDeviceToken({
    token,
    userId: user?.uid || req.body.userId || 'desconocido',
    role: (role as any) || 'table',
    restaurantId: restaurantId || undefined,
    platform: platform || 'web',
    deviceLabel: deviceLabel || undefined,
  });

  res.json({ success: true, registeredDevicesCount: result.total });
});

/**
 * Da de baja un dispositivo (el usuario cerró sesión).
 * El token se marca como inactivo y deja de recibir push.
 */
router.post('/sync/unregister-device', async (req, res) => {
  const { token } = req.body;
  if (!token) {
    return res.status(400).json({ error: 'Falta token de dispositivo' });
  }
  await unregisterDeviceToken(token);
  res.json({ success: true });
});

/**
 * Diagnóstico: lista los dispositivos que tienen token registrado.
 * Sirve para comprobar que la app está llegando al backend con su token FCM.
 */
router.get('/sync/devices', requireAdmin, (req, res) => {
  const { restaurantId } = req.query;
  const list = registeredDeviceTokens
    .filter((d) => !restaurantId || !d.restaurantId || d.restaurantId === restaurantId)
    .map((d) => ({
      token: `${d.token.slice(0, 12)}…${d.token.slice(-6)}`,
      tokenCompleto: d.token,
      userId: d.userId,
      role: d.role,
      platform: d.platform,
      deviceLabel: d.deviceLabel ?? null,
      restaurantId: d.restaurantId ?? null,
      activo: d.isActive,
      actualizado: d.updatedAt,
    }));
  res.json({
    success: true,
    total: list.length,
    dispositivos: list,
    aviso:
      'Los dispositivos se guardan en la tabla PushDevice de la base de datos y ' +
      'sobreviven a un reinicio del backend. Cada dispositivo se refresca con su ' +
      'token al abrir la app (lastSeenAt): si esa fecha es antigua, el token está muerto.',
  });
});

/**
 * Prueba de Push a demanda: envía una notificación a un tópico, a todos los
 * dispositivos de un restaurante, o a un token concreto.
 */
router.post('/sync/test-push', requireAdmin, async (req, res) => {
  const { restaurantId, tipo, token, title, body } = req.body ?? {};
  const restKey = restaurantId ? sanitizeTopicName(restaurantId) : null;

  const data: Record<string, string> =
    tipo === 'staff_call'
      ? {
          type: 'staff_call',
          reason: 'call_waiter',
          tableIdentifier: 'Mesa 4',
          restaurantId: String(restaurantId ?? 'general'),
        }
      : tipo === 'new_order'
        ? {
            type: 'new_order',
            orderId: 'ORD-PRUEBA',
            tableIdentifier: 'Mesa 4',
            restaurantId: String(restaurantId ?? 'general'),
          }
        : {
            type: 'menu_updated',
            action: 'add',
            targetType: 'item',
            targetId: 'prueba',
            targetName: 'Platillo de prueba',
            restaurantId: String(restaurantId ?? 'general'),
          };

  const notification = {
    title: title ?? '🧪 Prueba de push RapiMesa',
    body: body ?? 'Si ves esto, el push funciona correctamente.',
  };

  try {
    // 1) Envío directo a un token concreto
    if (token) {
      const { getMessaging } = await import('firebase-admin/messaging');
      const res1 = await getMessaging().send({
        token,
        notification,
        data: { click_action: 'FLUTTER_NOTIFICATION_CLICK', ...data },
      });
      return res.json({ success: true, via: 'token', messageId: res1 });
    }

    // 2) Envío al tópico del restaurante
    if (restKey) {
      const topic = `restaurant_${restKey}_${tipo === 'new_order' ? 'kitchen' : tipo === 'staff_call' ? 'waiters' : 'tables'}`;
      const r = await sendPushToTopic(topic, { title: notification.title, body: notification.body, data }, {
        role: 'all',
        restaurantId,
      });
      return res.json({ success: true, via: 'topic', topic, resultado: r });
    }

    return res.status(400).json({ error: 'Falta restaurantId o token' });
  } catch (e: any) {
    return res.status(500).json({ error: e.message });
  }
});

/**
 * Despacho de Notificación Push a través de Firebase Admin Messaging.
 *
 * Antes esta función tenía su propia lógica de envío (duplicada) y NO
 * escribía en el log de PushMessage. Ahora delega en el servicio, que además
 * filtra por restaurante, poda tokens inválidos y deja constancia del envío.
 */
async function sendPushNotification(
  payload: {
    title: string;
    body: string;
    data?: Record<string, string>;
    roleTarget?: 'admin' | 'kitchen' | 'all';
    restaurantId?: string;
  },
  sender?: { userId?: string; role?: string },
) {
  try {
    await sendPushToDevices(
      {
        title: payload.title,
        body: payload.body,
        data: payload.data,
      },
      { role: payload.roleTarget, restaurantId: payload.restaurantId },
      {
        eventType: payload.data?.type ?? 'desconocido',
        deliveryMode: 'visible',
        audience: payload.roleTarget === 'all' ? 'all' : payload.roleTarget,
        sender,
      },
    );
  } catch (err: any) {
    console.log(`[Push Note] Envío push omitido o no configurado en entorno local: ${err.message}`);
  }
}

// Endpoint para llamar a personal o pedir cuenta desde la mesa
router.post('/sync/call-staff', (req, res) => {
  const { tableIdentifier, reason, customerName, paymentPreference, receiptImage, amountToPay, restaurantId, notes } = req.body;
  if (!tableIdentifier) {
    return res.status(400).json({ error: 'Falta tableIdentifier' });
  }

  const call: StaffCallItem = {
    id: 'call-' + Date.now(),
    tableIdentifier,
    reason: (reason as any) || 'call_waiter', // 'call_waiter' | 'request_bill' | 'payment_receipt'
    customerName: customerName || null,
    paymentPreference: paymentPreference || null, // 'cash' | 'terminal' | 'transfer'
    receiptImage: receiptImage || null,
    amountToPay: amountToPay !== undefined ? Number(amountToPay) : null,
    restaurantId: restaurantId || null,
    notes: notes || null,
    requestedAt: new Date().toISOString(),
    isResolved: false,
  };

  const existingIdx = activeStaffCalls.findIndex(c => c.tableIdentifier === tableIdentifier && !c.isResolved);
  if (existingIdx >= 0) {
    activeStaffCalls[existingIdx] = call;
  } else {
    activeStaffCalls.unshift(call);
  }

  // Notificación Push para alertar y despertar el canal del Administrador
  let pushTitle = `🛎️ Llamada de ${tableIdentifier}`;
  let pushBody = 'Un cliente solicita atención en mesa';

  if (call.reason === 'request_bill') {
    const methodStr = call.paymentPreference === 'cash'
        ? 'en Efectivo 💵'
        : call.paymentPreference === 'terminal'
            ? 'con Terminal Bancaria 💳'
            : 'por Transferencia 📲';
    pushTitle = `💳 ${tableIdentifier}: Pide la Cuenta`;
    pushBody = `Pago solicitado ${methodStr}${call.amountToPay ? ' ($' + call.amountToPay.toFixed(2) + ')' : ''}`;
  } else if (call.reason === 'payment_receipt') {
    pushTitle = `📲 ${tableIdentifier}: Comprobante SPEI`;
    pushBody = `Subió comprobante por \$${(call.amountToPay || 0).toFixed(2)}. Requiere validación.`;
  }

  notifyStaffCallPush({
    restaurantId: restaurantId || undefined,
    tableIdentifier,
    reason: call.reason,
    customerName: call.customerName,
    sender: { userId: (req as any).user?.uid, role: (req as any).user?.role },
  }).catch(err => console.warn('[Push Staff Call Topic Error]:', err.message));

  sendPushNotification({
    title: pushTitle,
    body: pushBody,
    data: {
      type: 'staff_call',
      tableIdentifier,
      callId: call.id,
      reason: call.reason,
    },
    roleTarget: 'admin',
    restaurantId: restaurantId || undefined,
  }, { userId: (req as any).user?.uid, role: (req as any).user?.role });

  res.status(201).json({ success: true, call });
});

// Endpoint para consultar llamadas activas
router.get('/sync/calls', (req, res) => {
  const active = activeStaffCalls.filter(c => !c.isResolved);
  res.json({ success: true, calls: active });
});

// Endpoint para resolver/atender una llamada
router.post('/sync/calls/:id/resolve', (req, res) => {
  const { id } = req.params;
  const call = activeStaffCalls.find(c => c.id === id || c.tableIdentifier === id);
  if (call) {
    call.isResolved = true;
    return res.json({ success: true, call });
  }
  res.status(404).json({ error: 'Llamada no encontrada' });
});

// Endpoint para cobrar todas las comandas de una mesa completa
router.post('/sync/table/:tableId/pay', requireAdmin, (req, res) => {
  const { tableId } = req.params;
  const { paymentMethod, amountPaid, authorizationFolio, last4 } = req.body;
  const decodedTableId = decodeURIComponent(tableId);

  const tableOrders = activeOrdersStore.filter(
    o => (o.tableIdentifier === decodedTableId || o.tableIdentifier.toLowerCase() === decodedTableId.toLowerCase()) &&
         o.status !== 'paid'
  );

  if (tableOrders.length > 0) {
    const now = new Date().toISOString();
    tableOrders.forEach(order => {
      order.status = 'paid';
      order.paidAt = now;
      order.paymentMethod = paymentMethod || 'cash';
      order.amountPaid = order.totalAmount;
      if (authorizationFolio) order.authorizationFolio = authorizationFolio;
      if (last4) order.last4 = last4;
    });

    // Resolver llamadas activas de cobro o llamada de esa mesa
    const calls = activeStaffCalls.filter(
      c => (c.tableIdentifier === decodedTableId || c.tableIdentifier.toLowerCase() === decodedTableId.toLowerCase()) &&
           !c.isResolved
    );
    calls.forEach(c => c.isResolved = true);

    return res.json({ success: true, count: tableOrders.length, orders: tableOrders });
  }

  res.status(404).json({ error: 'No se encontraron órdenes activas para esta mesa' });
});

// Endpoint para cobrar y cerrar una comanda individual o por mesa
router.post('/sync/:id/pay', requireAdmin, (req, res) => {
  const { id } = req.params;
  const { paymentMethod, amountPaid } = req.body;
  const decodedId = decodeURIComponent(id);

  // Buscar por ID de orden
  const order = activeOrdersStore.find(o => o.id === decodedId);
  if (order) {
    order.status = 'paid';
    order.paidAt = new Date().toISOString();
    order.paymentMethod = paymentMethod || 'cash';
    order.amountPaid = amountPaid || order.totalAmount;

    // Resolver llamada pendiente de cobro de esa mesa
    const call = activeStaffCalls.find(c => c.tableIdentifier === order.tableIdentifier && !c.isResolved);
    if (call) call.isResolved = true;

    return res.json({ success: true, order });
  }

  // Fallback: verificar si pasaron el tableIdentifier
  const tableOrders = activeOrdersStore.filter(
    o => (o.tableIdentifier === decodedId || o.tableIdentifier.toLowerCase() === decodedId.toLowerCase()) &&
         o.status !== 'paid'
  );
  if (tableOrders.length > 0) {
    const now = new Date().toISOString();
    tableOrders.forEach(o => {
      o.status = 'paid';
      o.paidAt = now;
      o.paymentMethod = paymentMethod || 'cash';
      o.amountPaid = o.totalAmount;
    });
    const calls = activeStaffCalls.filter(
      c => (c.tableIdentifier === decodedId || c.tableIdentifier.toLowerCase() === decodedId.toLowerCase()) &&
           !c.isResolved
    );
    calls.forEach(c => c.isResolved = true);
    return res.json({ success: true, count: tableOrders.length, orders: tableOrders });
  }

  res.status(404).json({ error: 'Orden o mesa no encontrada' });
});

// Endpoint para eliminar o archivar orden
router.delete('/sync/:id', requireAdmin, (req, res) => {
  const { id } = req.params;
  const idx = activeOrdersStore.findIndex(o => o.id === id);
  if (idx >= 0) {
    activeOrdersStore.splice(idx, 1);
    return res.json({ success: true, message: 'Orden eliminada' });
  }
  res.status(404).json({ error: 'Orden no encontrada' });
});

router.delete('/sync', requireAdmin, (req, res) => {
  activeOrdersStore.length = 0;
  activeStaffCalls.length = 0;
  res.json({ success: true, message: 'Todas las órdenes han sido limpiadas' });
});

router.post('/', async (req, res) => {
  try {
    const { restaurantId, waiterId, tableId, orderType, customerName, customerPhone, totalAmount, comments } = req.body;
    const result = await createOrder(adminDc, {
      restaurantId,
      waiterId,
      tableId: tableId || null,
      orderType: orderType || 'TABLE',
      customerName: customerName || null,
      customerPhone: customerPhone || null,
      totalAmount,
      comments: comments || null
    });
    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.post('/item', async (req, res) => {
  try {
    const { orderId, productId, name, quantity, price, extras, kitchenNotes } = req.body;
    const result = await addOrderItem(adminDc, {
      orderId,
      productId,
      name,
      quantity,
      price,
      extras: extras || null,
      kitchenNotes: kitchenNotes || null
    });
    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.patch('/:id/status', async (req, res) => {
  try {
    const { status, confirmedAt, cookingStartedAt, readyAt } = req.body;
    const result = await updateOrderStatus(adminDc, {
      id: req.params.id,
      status,
      confirmedAt: confirmedAt || null,
      cookingStartedAt: cookingStartedAt || null,
      readyAt: readyAt || null
    });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/restaurant/:restaurantId', async (req, res) => {
  try {
    const result = await listOrdersByRestaurant(adminDc, { restaurantId: req.params.restaurantId });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const result = await getOrderById(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

export default router;
