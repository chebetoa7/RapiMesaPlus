import { Request, Response, NextFunction } from 'express';
import { getAuth } from 'firebase-admin/auth';
import { getUserById } from '@dataconnect/admin-generated';
import { adminDc } from '../firebase';

// Cache de roles resueltos desde Cloud SQL, para no consultar la base de
// datos en cada petición. TTL corto: si a un usuario se le corrige el rol,
// el cambio se refleja en menos de un minuto.
interface ResolvedRole {
  role: string;
  restaurantId?: string;
  ts: number;
}
const roleCache = new Map<string, ResolvedRole>();
const ROLE_CACHE_TTL_MS = 60_000;

/**
 * Resuelve el rol de un usuario desde la tabla `User` de Cloud SQL.
 *
 * Existe por un caso real: hay cuentas creadas antes de que el alta
 * asignara los Custom Claims (por ejemplo `sebastian0@gmail.com`, que tiene
 * `role = 'restaurant_admin'` en la base de datos pero ningún claim en
 * Firebase Auth). Sin claim, esas cuentas recibían 403 en todas las rutas de
 * administración aunque su rol en la base de datos fuera correcto.
 *
 * La fuente sigue siendo el servidor: el rol se lee de la base de datos, NUNCA
 * del cuerpo de la petición, así que el cliente no puede escalarlo.
 */
async function resolveRoleFromDatabase(
  uid: string
): Promise<{ role: string; restaurantId?: string } | null> {
  const cached = roleCache.get(uid);
  if (cached && Date.now() - cached.ts < ROLE_CACHE_TTL_MS) {
    return { role: cached.role, restaurantId: cached.restaurantId };
  }
  try {
    const res = await getUserById(adminDc, { id: uid });
    const user = res.data?.user;
    if (!user || !user.role) return null;
    const entry: ResolvedRole = {
      role: String(user.role),
      restaurantId: user.restaurantId ?? undefined,
      ts: Date.now(),
    };
    roleCache.set(uid, entry);
    return { role: entry.role, restaurantId: entry.restaurantId };
  } catch (_) {
    return null;
  }
}

// Middleware para verificar el JWT de Firebase.
// Es genérico sobre los parámetros de ruta (`P`) para no perder la inferencia
// de tipos de Express 5 al encadenarlo antes del handler final.
export const verifyFirebaseToken = async <P = Record<string, string | string[]>>(
  req: Request<P>,
  res: Response,
  next: NextFunction,
) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No autorizado, falta token' });
  }

  const token = authHeader.split('Bearer ')[1];

  try {
    const decodedToken = await getAuth().verifyIdToken(token);
    // Agregamos los datos del usuario a la request para usarlos en los controladores
    (req as any).user = decodedToken;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Token inválido o expirado' });
  }
};

/**
 * Exige que el usuario autenticado tenga uno de los roles indicados.
 *
 * El rol se determina en este orden:
 *   1. Custom Claims del token (fuente autoritativa cuando existen).
 *   2. Columna `User.role` de Cloud SQL (para cuentas con claims perdidos).
 * En ningún caso se toma del cuerpo de la petición.
 */
export const requireRole = (...allowedRoles: string[]) => {
  return async <P = Record<string, string | string[]>>(
    req: Request<P>,
    res: Response,
    next: NextFunction,
  ): Promise<void> => {
    let user = (req as any).user;

    // Este middleware puede ser el ÚNICO control de acceso de una ruta, así
    // que verifica el token si todavía no se ha verificado. Sin esto, las
    // rutas donde no había un `verifyFirebaseToken` previo (menú, alta de
    // personal) recibían 401 aunque el cliente enviara un token válido.
    if (!user) {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({ error: 'No autorizado, falta token' });
        return;
      }
      try {
        user = await getAuth().verifyIdToken(authHeader.split('Bearer ')[1]);
        (req as any).user = user;
      } catch (_) {
        res.status(401).json({ error: 'Token inválido o expirado' });
        return;
      }
    }

    let role = String(user.role || '');
    let restaurantId = user.restaurantId ? String(user.restaurantId) : undefined;

    // Sin claim de rol: se consulta la base de datos (misma fuente de verdad
    // que usa el resto del sistema para el negocio).
    if (!role && user.uid) {
      const fromDb = await resolveRoleFromDatabase(String(user.uid));
      if (fromDb) {
        role = fromDb.role;
        restaurantId = restaurantId ?? fromDb.restaurantId;
        (req as any).user = { ...user, role, restaurantId };
      }
    }

    if (!allowedRoles.includes(role)) {
      res.status(403).json({
        error: 'Permisos insuficientes',
        requiredRoles: allowedRoles,
        currentRole: role || 'desconocido',
      });
      return;
    }
    next();
  };
};

/** Solo administradores de restaurante (o el super admin del SaaS). */
export const requireAdmin = requireRole('restaurant_admin', 'super_admin', 'admin');

/** Administradores de restaurante, cocineros y meseros: personal operativo. */
export const requireStaff = requireRole(
  'restaurant_admin',
  'super_admin',
  'admin',
  'kitchen',
  'waiter'
);

/** Cocina y administración: pueden mover el ciclo de vida de una comanda. */
export const requireKitchen = requireRole(
  'kitchen',
  'chef',
  'restaurant_admin',
  'super_admin',
  'admin'
);
