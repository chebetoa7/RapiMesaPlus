import { getMessaging } from 'firebase-admin/messaging';
import { randomUUID } from 'crypto';
import { adminDc } from '../firebase';
import {
  getPushDeviceByToken,
  listAllPushDevices,
  registerPushDevice,
  updatePushDevice,
  deactivatePushDevice,
  createPushMessage,
} from '@dataconnect/admin-generated';

export interface PushNotificationPayload {
  title?: string;
  body?: string;
  data?: Record<string, string>;
}

/** Quién originó la acción que genera el push (el admin que borró el platillo). */
export interface PushSender {
  userId?: string;
  role?: string;
}

/** Cómo se entrega el push. */
export type PushDeliveryMode = 'silent' | 'visible';

export interface DeviceTokenEntry {
  /** Id de la fila en la tabla PushDevice (DataConnect). */
  id?: string;
  token: string;
  /** Usuario que tiene el dispositivo abierto. */
  userId: string;
  role: 'admin' | 'kitchen' | 'waiter' | 'table';
  restaurantId?: string;
  /** web | ios | android */
  platform: string;
  deviceLabel?: string;
  isActive: boolean;
  lastSeenAt: string;
  updatedAt: string;
}

/**
 * Caché en memoria de los dispositivos registrados.
 *
 * La BASE DE DATOS es la fuente de verdad (tabla PushDevice): esta caché es
 * solo el camino caliente para no ir a la base en cada envío de push.
 * Al arrancar la API se hidrata con `hydrateDevicesFromDatabase()`.
 */
export const registeredDeviceTokens: DeviceTokenEntry[] = [];

/** Opciones que se aplican al envío y se guardan en el log de PushMessage. */
export interface PushSendOptions {
  /** Etiqueta de audiencia para el log: waiters | kitchen | admins | tables | all */
  audience?: string;
  /** Tipo de evento para el log: menu_updated | new_order | staff_call ... */
  eventType?: string;
  /** Modo de entrega: silent (data-only) o visible (con notificación). */
  deliveryMode?: PushDeliveryMode;
  /** Quién originó la acción. */
  sender?: PushSender;
  /** Si el push va dirigido a una persona concreta. */
  targetUserId?: string;
  /** Si es false, no se hace el envío directo a los tokens (solo el tópico). */
  multicast?: boolean;
  /** Tópico de FCM implicado (para el log). */
  topic?: string;
  /** Id que devuelve FCM (para correlacionar con la consola de Firebase). */
  providerMessageId?: string;
}

export function sanitizeTopicName(raw: string): string {
  return raw.replace(/[^a-zA-Z0-9-_.~%]/g, '_');
}

/** Traduce el rol interno al sucio de audiencia para el log. */
function audienceFromRole(role?: string): string {
  switch (role) {
    case 'waiter': return 'waiters';
    case 'kitchen': return 'kitchen';
    case 'table': return 'tables';
    case 'admin': return 'admins';
    default: return 'all';
  }
}

/**
 * Carga los dispositivos desde la base de datos a la caché en memoria.
 *
 * Se llama al arrancar la API. Antes esto no existía: los tokens vivían
 * solo en RAM y se perdían con cada reinicio del backend.
 */
export async function hydrateDevicesFromDatabase(): Promise<void> {
  try {
    const res = await listAllPushDevices(adminDc);
    const rows = res.data?.pushDevices ?? [];
    registeredDeviceTokens.length = 0;
    for (const row of rows as any[]) {
      registeredDeviceTokens.push({
        id: row.id,
        token: row.token,
        userId: row.userId,
        role: (row.role as any) ?? 'waiter',
        restaurantId: row.restaurantId ?? undefined,
        platform: row.platform ?? 'web',
        deviceLabel: row.deviceLabel ?? undefined,
        isActive: row.isActive !== false,
        lastSeenAt: String(row.lastSeenAt ?? ''),
        updatedAt: String(row.lastSeenAt ?? ''),
      });
    }
    console.log(`[FCM Registry] ${registeredDeviceTokens.length} dispositivo(s) cargados desde la base de datos`);
  } catch (e: any) {
    console.warn(`[FCM Registry Warning] No se pudieron cargar los dispositivos: ${e.message}`);
  }
}

/**
 * Registra un token de dispositivo y lo suscribe a sus tópicos oficiales en FCM.
 * Funciona de manera universal tanto para Web (Chrome) como para Android/iOS.
 */
export async function registerDeviceToken(entry: {
  token: string;
  userId?: string;
  role: 'admin' | 'kitchen' | 'waiter' | 'table';
  restaurantId?: string;
  platform?: string;
  deviceLabel?: string;
}) {
  const { token, role } = entry;
  const userId = entry.userId || 'desconocido';
  const platform = entry.platform || 'web';
  const existingIdx = registeredDeviceTokens.findIndex(d => d.token === token);

  // Un re-registro "en blanco" (sin restaurante) NO puede borrar el
  // restaurante que el dispositivo ya tenía: el filtro de envío es estricto
  // por restaurante, así que perderlo dejaba al dispositivo sin push.
  let restaurantId = entry.restaurantId;
  if ((!restaurantId || restaurantId === 'general') && existingIdx >= 0) {
    restaurantId = registeredDeviceTokens[existingIdx].restaurantId;
  }

  const now = new Date().toISOString();
  const record: DeviceTokenEntry = {
    id: existingIdx >= 0 ? registeredDeviceTokens[existingIdx].id : undefined,
    token,
    userId,
    role: role || 'waiter',
    restaurantId,
    platform,
    deviceLabel: entry.deviceLabel,
    isActive: true,
    lastSeenAt: now,
    updatedAt: now,
  };

  if (existingIdx >= 0) {
    registeredDeviceTokens[existingIdx] = record;
  } else {
    registeredDeviceTokens.push(record);
  }

  console.log(
    `[FCM Registry] Dispositivo registrado: Rol=${role}, Usuario=${userId}, Plataforma=${platform}, Restaurante=${restaurantId || 'general'}. Total dispositivos: ${registeredDeviceTokens.length}`,
  );

  // --- Persistencia (best effort: si la base falla, el push sigue saliendo)
  try {
    const found = await getPushDeviceByToken(adminDc, { token });
    const existing = found.data?.pushDevices?.[0];
    if (existing) {
      record.id = existing.id;
      await updatePushDevice(adminDc, {
        id: existing.id,
        token,
        userId,
        restaurantId: restaurantId ?? null,
        role,
        platform,
        deviceLabel: entry.deviceLabel ?? null,
        isActive: true,
        lastSeenAt: now,
      });
    } else {
      const id = randomUUID();
      record.id = id;
      await registerPushDevice(adminDc, {
        id,
        token,
        userId,
        restaurantId: restaurantId ?? null,
        role,
        platform,
        deviceLabel: entry.deviceLabel ?? null,
      });
    }
  } catch (e: any) {
    console.warn(`[FCM Registry Warning] No se pudo guardar el dispositivo en la base: ${e.message}`);
  }

  // Suscribir el token en el backend de Google FCM a los tópicos correspondientes
  if (restaurantId) {
    try {
      const messaging = getMessaging();
      const restKey = sanitizeTopicName(restaurantId);
      const specificTopic = `restaurant_${restKey}_${role === 'table' ? 'tables' : role === 'kitchen' ? 'kitchen' : role === 'waiter' ? 'waiters' : 'admins'}`;
      const generalTopic = `restaurant_${restKey}_all`;

      await messaging.subscribeToTopic([token], specificTopic);
      await messaging.subscribeToTopic([token], generalTopic);
      console.log(`[FCM Registry] Token suscrito en FCM a tópicos: ${specificTopic} y ${generalTopic}`);
    } catch (subErr: any) {
      console.warn(`[FCM Registry Warning]: No se pudo suscribir el token al tópico (${subErr.message})`);
    }
  }

  return { success: true, total: registeredDeviceTokens.length };
}

/** Da de baja un dispositivo (el usuario cerró sesión o la app lo pidió). */
export async function unregisterDeviceToken(token: string): Promise<void> {
  const idx = registeredDeviceTokens.findIndex(d => d.token === token);
  if (idx >= 0) {
    const entry = registeredDeviceTokens[idx];
    registeredDeviceTokens.splice(idx, 1);
    try {
      if (entry.id) {
        await deactivatePushDevice(adminDc, { id: entry.id, lastSeenAt: new Date().toISOString() });
      }
    } catch (e: any) {
      console.warn(`[FCM Registry Warning] No se pudo dar de baja el dispositivo: ${e.message}`);
    }
    console.log(`[FCM Registry] Dispositivo dado de baja (${token.slice(0, 12)}…)`);
  }
}

/** Elimina tokens que FCM ya no reconoce (dispositivo desinstalado, token rotado). */
function pruneInvalidTokens(tokens: string[], responses: any[]) {
  const invalid = new Set<string>();
  (responses || []).forEach((resp, i) => {
    const code = resp?.error?.code || '';
    if (
      code === 'messaging/registration-token-not-registered' ||
      code === 'messaging/invalid-registration-token' ||
      code === 'messaging/invalid-argument'
    ) {
      invalid.add(tokens[i]);
    }
  });
  if (invalid.size === 0) return;

  const before = registeredDeviceTokens.length;
  for (let i = registeredDeviceTokens.length - 1; i >= 0; i--) {
    if (invalid.has(registeredDeviceTokens[i].token)) {
      const entry = registeredDeviceTokens[i];
      registeredDeviceTokens.splice(i, 1);
      // Se da de baja también en la base, para que no vuelva a intentarlo.
      if (entry.id) {
        deactivatePushDevice(adminDc, { id: entry.id, lastSeenAt: new Date().toISOString() })
          .catch(() => {});
      }
    }
  }
  if (registeredDeviceTokens.length !== before) {
    console.log(`[FCM Registry] Se eliminaron ${before - registeredDeviceTokens.length} token(s) inválido(s)`);
  }
}

/**
 * Guarda el push enviado en la tabla PushMessage (auditoría y diagnóstico).
 *
 * NUNCA debe romper el envío: si la base falla, el push ya salió y solo se
 * pierde el registro.
 */
export async function recordPushMessage(params: {
  eventType: string;
  deliveryMode: PushDeliveryMode;
  restaurantId?: string;
  sender?: PushSender;
  audience: string;
  targetUserId?: string;
  topic?: string;
  title?: string;
  body?: string;
  payload: Record<string, string>;
  status: 'sent' | 'partial' | 'failed';
  targetCount: number;
  successCount: number;
  failureCount: number;
  providerMessageId?: string;
}): Promise<void> {
  try {
    await createPushMessage(adminDc, {
      id: randomUUID(),
      eventType: params.eventType,
      deliveryMode: params.deliveryMode,
      restaurantId: params.restaurantId ?? null,
      senderUserId: params.sender?.userId ?? null,
      senderRole: params.sender?.role ?? null,
      audience: params.audience,
      targetUserId: params.targetUserId ?? null,
      topic: params.topic ?? null,
      title: params.title ?? null,
      body: params.body ?? null,
      payload: JSON.stringify(params.payload),
      status: params.status,
      targetCount: params.targetCount,
      successCount: params.successCount,
      failureCount: params.failureCount,
      providerMessageId: params.providerMessageId ?? null,
    });
  } catch (e: any) {
    console.warn(`[FCM Log Warning] No se pudo registrar el push en el log: ${e.message}`);
  }
}

/** Calcula el estado global a partir de los contadores de FCM. */
function statusFromCounts(success: number, failure: number, target: number): 'sent' | 'partial' | 'failed' {
  if (target === 0) return 'failed';
  if (failure === 0 && success > 0) return 'sent';
  if (success === 0) return 'failed';
  return 'partial';
}

/**
 * Envía el push DIRECTAMENTE a los dispositivos registrados del filtro.
 *
 * Es la vía que garantiza la entrega en web (Chrome), donde el cliente no
 * puede suscribirse a tópicos por su cuenta.
 */
export async function sendPushToDevices(
  payload: PushNotificationPayload,
  filter?: { role?: string; restaurantId?: string },
  opts?: PushSendOptions,
) {
  const messaging = getMessaging();

  const message: any = {
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      wakeUp: 'true',
      timestamp: Date.now().toString(),
      ...(payload.data || {}),
    },
  };
  if (payload.title || payload.body) {
    message.notification = {
      title: payload.title || 'Actualización',
      body: payload.body || '',
    };
  }

  let successCount = 0;
  let failureCount = 0;
  let targetCount = 0;

  try {
    const matchingTokens = registeredDeviceTokens.filter(d => {
      if (!d.isActive) return false;
      // El restaurante es obligatorio: un dispositivo sin restaurante (o de otro
      // restaurante) NO debe recibir la push. Antes el filtro solo descartaba
      // los que tenían un restaurante DISTINTO, así que un dispositivo sin
      // restaurante recibía las push de todos los restaurantes del SaaS.
      if (filter?.restaurantId) {
        if (!d.restaurantId || d.restaurantId !== filter.restaurantId) return false;
      }
      if (filter?.role && filter.role !== 'all' && d.role !== filter.role) return false;
      if (opts?.targetUserId && d.userId !== opts.targetUserId) return false;
      return true;
    }).map(d => d.token);

    targetCount = matchingTokens.length;

    if (targetCount === 0) {
      console.log('[FCM Multicast] Sin dispositivos que coincidan con el filtro');
    } else {
      const multicastRes = await messaging.sendEachForMulticast({
        tokens: matchingTokens,
        data: message.data,
        ...(message.notification ? { notification: message.notification } : {}),
      });
      successCount = multicastRes.successCount;
      failureCount = multicastRes.failureCount;
      pruneInvalidTokens(matchingTokens, multicastRes.responses || []);
      console.log(`[FCM Multicast Directo] Enviado a ${targetCount} dispositivos: ${successCount} éxitos, ${failureCount} fallos`);
    }
  } catch (multicastErr: any) {
    console.warn(`[FCM Multicast Warning]:`, multicastErr.message);
    failureCount = targetCount || 1;
  }

  // Log de auditoría (no bloquea la respuesta).
  await recordPushMessage({
    eventType: opts?.eventType ?? 'desconocido',
    deliveryMode: opts?.deliveryMode ?? (payload.title || payload.body ? 'visible' : 'silent'),
    restaurantId: filter?.restaurantId,
    sender: opts?.sender,
    audience: opts?.audience ?? audienceFromRole(filter?.role),
    targetUserId: opts?.targetUserId,
    topic: opts?.topic,
    title: payload.title,
    body: payload.body,
    payload: message.data,
    status: statusFromCounts(successCount, failureCount, targetCount),
    targetCount,
    successCount,
    failureCount,
    providerMessageId: opts?.providerMessageId,
  });

  return { success: true, targetCount, successCount, failureCount };
}

/**
 * Envía un mensaje Push tanto a un Tópico de Firebase como directamente a los tokens registrados.
 *
 * `opts.multicast === false` omite el envío directo. Se usa cuando un mismo
 * evento se publica en varios tópicos: así el dispositivo recibe UNA sola
 * copia por multicast en lugar de una por tópico.
 */
export async function sendPushToTopic(
  topic: string,
  payload: PushNotificationPayload,
  filter?: { role?: string; restaurantId?: string },
  opts?: PushSendOptions,
) {
  const messaging = getMessaging();
  const cleanTopic = sanitizeTopicName(topic);

  const message: any = {
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      wakeUp: 'true',
      timestamp: Date.now().toString(),
      ...(payload.data || {}),
    },
  };

  if (payload.title || payload.body) {
    message.notification = {
      title: payload.title || 'Actualización',
      body: payload.body || '',
    };
  }

  let providerMessageId: string | undefined;
  let topicOk = false;

  // 1. Envío al Tópico de Firebase (para apps móviles/tabletas nativas)
  try {
    const topicMessage = { ...message, topic: cleanTopic };
    const response = await messaging.send(topicMessage);
    providerMessageId = response;
    topicOk = true;
    console.log(`[FCM Tópico: ${cleanTopic}] Entregado con ID: ${response}`);
  } catch (error: any) {
    console.warn(`[FCM Tópico Warning ${cleanTopic}]:`, error.message);
  }

  // 2. Multicast directo a tokens de dispositivos registrados (ideal para Web/Chrome y respaldo)
  //
  // Si `multicast === false` NO se envía el multicast NI se escribe en el log:
  // esa llamada es solo la publicación en un tópico. El log se escribe una
  // única vez, en el envío directo a dispositivos, para que el historial
  // tenga UNA fila por evento y no una por tópico.
  if (opts?.multicast === false) return { success: topicOk };

  const res = await sendPushToDevices(payload, filter, { ...opts, topic: cleanTopic, providerMessageId });
  return { ...res, topic: cleanTopic };
}

/**
 * Notifica a todas las tabletas de mesa del restaurante que el menú cambió
 * (se agregó, editó o eliminó un platillo o categoría).
 */
export async function notifyMenuUpdated(params: {
  restaurantId: string;
  action: 'add' | 'edit' | 'delete';
  targetType: 'item' | 'category';
  id?: string;
  name?: string;
  sender?: PushSender;
}) {
  const { restaurantId, action, targetType, id, name } = params;
  const restKey = sanitizeTopicName(restaurantId);
  const data = {
    type: 'menu_updated',
    action,
    targetType,
    targetId: id || '',
    targetName: name || '',
    restaurantId,
  };

  console.log(`🔥 [FCM Menu Event] Disparando Push de Menú (${action} ${targetType}: "${name || id || ''}") al Restaurante: ${restaurantId}`);

  // El cambio de menú le interesa a TRES tipos de dispositivo:
  //   - la tablet de mesa (role 'table'), donde el comensal se autosirve;
  //   - el teléfono/tablet del mesero (role 'waiter'), que también puede
  //     levantar comandas desde su dispositivo;
  //   - el teléfono/tablet del administrador (role 'admin'), que gestiona el
  //     menú y debe ver los cambios al instante.
  // Por eso se publica en los tres tópicos y el filtro del multicast no
  // restringe por rol (sí por restaurante).
  const topics = [
    `restaurant_${restKey}_tables`,
    `restaurant_${restKey}_waiters`,
    `restaurant_${restKey}_admins`,
  ];
  for (const topic of topics) {
    // El multicast se hace UNA sola vez (al final): si se hiciera por tópico,
    // el dispositivo recibiría el mismo aviso tantas veces como tópicos.
    await sendPushToTopic(topic, { data }, { role: 'all', restaurantId }, {
      multicast: false,
      eventType: 'menu_updated',
      deliveryMode: 'silent',
      audience: 'tables+waiters+admins',
      sender: params.sender,
    });
  }
  await sendPushToDevices({ data }, { role: 'all', restaurantId }, {
    eventType: 'menu_updated',
    deliveryMode: 'silent',
    audience: 'tables+waiters+admins',
    sender: params.sender,
  });
}

/**
 * Notifica a Cocina y Salón cuando entra una comanda nueva.
 */
export async function notifyNewOrderPush(params: {
  restaurantId?: string;
  orderId: string;
  tableIdentifier: string;
  totalAmount: number;
  itemCount: number;
  sender?: PushSender;
}) {
  const { restaurantId, orderId, tableIdentifier, totalAmount, itemCount } = params;
  const restKey = restaurantId || 'general';

  console.log(`🍽️ [FCM Order Event] Nueva comanda ${tableIdentifier} en Restaurante: ${restKey}`);

  await sendPushToTopic(`restaurant_${restKey}_kitchen`, {
    title: `🍽️ Nueva Comanda: ${tableIdentifier}`,
    body: `${itemCount} platillos - Total: $${totalAmount.toFixed(2)}`,
    data: {
      type: 'new_order',
      orderId,
      tableIdentifier,
      restaurantId: restKey,
    },
  }, { role: 'kitchen', restaurantId: restKey }, {
    eventType: 'new_order',
    deliveryMode: 'visible',
    audience: 'kitchen',
    sender: params.sender,
  });

  await sendPushToTopic(`restaurant_${restKey}_admins`, {
    title: `🍽️ Nueva Comanda: ${tableIdentifier}`,
    body: `${itemCount} platillos - Total: $${totalAmount.toFixed(2)}`,
    data: {
      type: 'new_order',
      orderId,
      tableIdentifier,
      restaurantId: restKey,
    },
  }, { role: 'admin', restaurantId: restKey }, {
    eventType: 'new_order',
    deliveryMode: 'visible',
    audience: 'admins',
    sender: params.sender,
  });
}

/**
 * Notifica a los meseros cuando una mesa llama o pide la cuenta.
 */
export async function notifyStaffCallPush(params: {
  restaurantId?: string;
  tableIdentifier: string;
  reason: 'call_waiter' | 'request_bill' | 'payment_receipt';
  customerName?: string | null;
  sender?: PushSender;
}) {
  const { restaurantId, tableIdentifier, reason, customerName } = params;
  const restKey = restaurantId || 'general';

  let title = `🔔 Llamado de ${tableIdentifier}`;
  let body = 'El comensal requiere asistencia en mesa';

  if (reason === 'request_bill') {
    title = `💵 Cuenta Solicitada: ${tableIdentifier}`;
    body = customerName ? `${customerName} solicitó la cuenta` : 'Solicitud de cobro en mesa';
  } else if (reason === 'payment_receipt') {
    title = `🧾 Comprobante Transferencia: ${tableIdentifier}`;
    body = 'El comensal envió comprobante de pago';
  }

  console.log(`🔔 [FCM Call Event] ${title} en Restaurante: ${restKey}`);

  return sendPushToTopic(`restaurant_${restKey}_waiters`, {
    title,
    body,
    data: {
      type: 'staff_call',
      reason,
      tableIdentifier,
      restaurantId: restKey,
    },
  }, { role: 'waiter', restaurantId: restKey }, {
    eventType: 'staff_call',
    deliveryMode: 'visible',
    audience: 'waiters',
    sender: params.sender,
  });
}
