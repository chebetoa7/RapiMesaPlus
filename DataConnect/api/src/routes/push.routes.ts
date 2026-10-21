import { Router } from 'express';
import { adminDc } from '../firebase';
import { requireAdmin } from '../middlewares/auth.middleware';
import {
  getUserById,
  listPushDevicesByRestaurant,
  listPushMessagesByRestaurant,
} from '@dataconnect/admin-generated';

const router = Router();

/**
 * Resuelve el restaurante del usuario que hace la petición.
 *
 * Se usa el `restaurantId` del token si viene; si no, el de su perfil en la
 * base. NUNCA se acepta el restaurante desde el cuerpo o la query: si no,
 * un administrador vería los pushes de otro restaurante.
 */
async function resolveRestaurantId(req: any): Promise<string | undefined> {
  const user = req.user;
  if (!user?.uid) return undefined;
  if (user.restaurantId) return String(user.restaurantId);

  try {
    const perfil = await getUserById(adminDc, { id: String(user.uid) });
    const rid = perfil.data?.user?.restaurantId;
    return rid ? String(rid) : undefined;
  } catch (_) {
    return undefined;
  }
}

/**
 * Dispositivos registrados de un restaurante.
 *
 * Sirve para el panel "Notificaciones" del admin: si un dispositivo no
 * aparece, o su `lastSeenAt` es antiguo, ese token está muerto y ese
 * dispositivo no va a recibir push.
 */
router.get('/devices', requireAdmin, async (req, res) => {
  try {
    const restaurantId = await resolveRestaurantId(req);
    if (!restaurantId) {
      return res.status(400).json({ error: 'No se pudo resolver el restaurante del usuario' });
    }

    const result = await listPushDevicesByRestaurant(adminDc, { restaurantId });
    const devices = result.data?.pushDevices ?? [];

    // Un dispositivo que no se ha registrado en más de 24 h probablemente
    // tiene un token muerto (la app no se ha abierto).
    const LIMITE_MS = 24 * 60 * 60 * 1000;
    const ahora = Date.now();

    res.json({
      success: true,
      total: devices.length,
      dispositivos: devices.map((d: any) => {
        const visto = d.lastSeenAt ? new Date(d.lastSeenAt).getTime() : 0;
        const minutos = visto ? Math.round((ahora - visto) / 60000) : null;
        return {
          id: d.id,
          token: `${String(d.token).slice(0, 12)}…${String(d.token).slice(-6)}`,
          userId: d.userId,
          role: d.role,
          platform: d.platform,
          deviceLabel: d.deviceLabel ?? null,
          activo: d.isActive !== false,
          minutosDesdeUltimoContacto: minutos,
          vencido: minutos !== null && minutos > 24 * 60,
          ultimoContacto: d.lastSeenAt ?? null,
          registradoEn: d.createdAt ?? null,
        };
      }),
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * Historial de pushes enviados (el más reciente primero).
 *
 * Cada fila dice QUIÉN lo mandó, a QUIÉN iba dirigido, si era silencioso o
 * visible, y cuántos dispositivos lo aceptaron.
 */
router.get('/history', requireAdmin, async (req, res) => {
  try {
    const restaurantId = await resolveRestaurantId(req);
    if (!restaurantId) {
      return res.status(400).json({ error: 'No se pudo resolver el restaurante del usuario' });
    }

    const limit = Math.min(Number(req.query.limit) || 50, 200);
    const result = await listPushMessagesByRestaurant(adminDc, { restaurantId, limit });

    res.json({
      success: true,
      total: result.data?.pushMessages?.length ?? 0,
      mensajes: result.data?.pushMessages ?? [],
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
