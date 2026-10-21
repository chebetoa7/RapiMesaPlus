import { Router } from 'express';
import { verifyFirebaseToken, requireAdmin } from '../middlewares/auth.middleware';
import { adminDc } from '../firebase';
import dotenv from 'dotenv';
dotenv.config();

const router = Router();

// Endpoint EXCLUSIVO para testing en Swagger. (La app MAUI usará su propio SDK)
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const apiKey = process.env.FIREBASE_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ error: 'Falta FIREBASE_API_KEY en .env' });
  }

  try {
    const response = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, returnSecureToken: true })
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(401).json({ error: data.error.message });
    }

    // Devuelve el token JWT necesario para Swagger
    res.status(200).json({
      success: true,
      idToken: data.idToken,
      email: data.email,
      localId: data.localId
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/register-restaurant', async (req, res) => {
  try {
    const { restaurantName, managerName, email, password, phone, planName } = req.body;

    if (!restaurantName || !managerName || !email || !password) {
      return res.status(400).json({ error: 'Faltan campos obligatorios para el registro.' });
    }

    const { getAuth } = await import('firebase-admin/auth');
    const { createUser, createRestaurant, getSubscriptionPlanByName } = await import('@dataconnect/admin-generated');

    const auth = getAuth();

    // 1. Obtener el ID del Plan de Suscripción (por defecto 'express' o el elegido)
    let selectedPlanId: string | null = null;
    const planToSearch = (planName || 'express').toLowerCase();
    try {
      const planRes = await getSubscriptionPlanByName(adminDc, { name: planToSearch });
      if (planRes.data.subscriptionPlans && planRes.data.subscriptionPlans.length > 0) {
        selectedPlanId = planRes.data.subscriptionPlans[0].id;
      }
    } catch (_) {}

    // 2. Crear usuario en Firebase Auth (con fallback a Identity Toolkit REST API si no hay ADC)
    let uid: string;
    const apiKey = process.env.FIREBASE_API_KEY;

    try {
      const userRecord = await auth.createUser({
        email,
        password,
        displayName: managerName,
        phoneNumber: phone || undefined,
      });
      uid = userRecord.uid;
      try {
        await auth.setCustomUserClaims(uid, {
          role: 'restaurant_admin',
        });
      } catch (_) {}
    } catch (authErr: any) {
      if (!apiKey) throw authErr;
      const resp = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password, returnSecureToken: true })
      });
      const data = await resp.json();
      if (!resp.ok) {
        throw new Error(data.error?.message || 'Error al crear usuario en Firebase Auth');
      }
      uid = data.localId;
    }

    // 3. Guardar en Base de Datos Cloud SQL (Data Connect)
    let newRestaurantId = 'rest-' + Date.now();
    try {
      // 3.1 Guardar primero en tabla User (requerido por FK de Restaurant.adminId)
      await createUser(adminDc, {
        id: uid,
        name: managerName,
        email: email,
        role: 'restaurant_admin',
        phone: phone || null,
        restaurantId: 'pending',
        subscriptionPlanId: selectedPlanId,
        adminId: null,
      });

      // 3.2 Crear restaurante en tabla Restaurant
      const restRes = await createRestaurant(adminDc, {
        name: restaurantName,
        tableCount: 15,
        adminId: uid,
      });
      newRestaurantId = (restRes.data as any)?.restaurant_insert?.id || newRestaurantId;

      // 3.3 Actualizar restaurantId en User
      const { updateUser } = await import('@dataconnect/admin-generated');
      await updateUser(adminDc, {
        id: uid,
        restaurantId: newRestaurantId,
      });
    } catch (dcErr) {
      console.warn('[DataConnect warning]:', dcErr);
    }

    const isFreeTrial = planToSearch === 'free';
    const trialDaysRemaining = isFreeTrial ? 7 : null;
    const trialExpiresAt = isFreeTrial ? new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString() : null;

    res.status(201).json({
      success: true,
      message: '¡Restaurante registrado con éxito!',
      uid: uid,
      restaurantId: newRestaurantId,
      restaurantName,
      email,
      planName: planToSearch,
      isFreeTrial,
      trialDaysRemaining,
      trialExpiresAt,
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Error al registrar restaurante.' });
  }
});

router.post('/create-waiter', requireAdmin, async (req, res) => {
  try {
    const { name, email, password, tableAssigned, waiterType } = req.body;
    const apiKey = process.env.FIREBASE_API_KEY;

    // Identidad y permisos del solicitante, tomados de los Custom Claims del token
    // (fuente autoritativa). El cuerpo de la petición NO decide el rol ni el
    // restaurante: así se cierra la escalada de privilegios que permitía crear
    // un usuario con role 'super_admin' desde cualquier request sin token.
    const caller = (req as any).user || {};
    const callerRole = String(caller.role || '');
    const callerUid = String(caller.uid || '');
    const callerRestaurantId = caller.restaurantId ? String(caller.restaurantId) : '';

    const requestedRole = String(req.body.role || 'waiter');
    const rolesAllowedForCaller =
      callerRole === 'super_admin'
        ? ['waiter', 'kitchen', 'chef', 'restaurant_admin', 'super_admin']
        : ['waiter', 'kitchen', 'chef'];
    if (!rolesAllowedForCaller.includes(requestedRole)) {
      return res.status(403).json({
        error: `Tu rol (${callerRole}) no puede crear personal con rol '${requestedRole}'`,
      });
    }
    const staffRole = requestedRole;

    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Faltan campos obligatorios (name, email, password)' });
    }

    const { getAuth } = await import('firebase-admin/auth');
    const auth = getAuth();
    let uid = '';

    // 1. Crear u obtener en Firebase Auth
    try {
      const userRecord = await auth.createUser({
        email,
        password,
        displayName: name,
      });
      uid = userRecord.uid;
    } catch (authErr: any) {
      if (authErr.code === 'auth/email-already-exists') {
        const existing = await auth.getUserByEmail(email);
        uid = existing.uid;
      } else if (apiKey) {
        const resp = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password, returnSecureToken: true })
        });
        const data = await resp.json();
        if (resp.ok) {
          uid = data.localId;
        } else if (data.error?.message === 'EMAIL_EXISTS') {
          const existing = await auth.getUserByEmail(email);
          uid = existing.uid;
        } else {
          throw new Error(data.error?.message || 'Error al crear personal en Firebase Auth');
        }
      } else {
        throw authErr;
      }
    }

    // 1.1 Determinar el restaurante: SIEMPRE desde los claims del administrador
    // que está haciendo la llamada. Un restaurant_admin solo puede dar de alta
    // personal de SU restaurante; el super admin puede indicar uno explícito.
    let finalRestaurantId = callerRestaurantId;
    if (callerRole === 'super_admin' && req.body.restaurantId) {
      finalRestaurantId = String(req.body.restaurantId);
    }
    if (!finalRestaurantId && callerUid) {
      try {
        const { listRestaurants } = await import('@dataconnect/admin-generated');
        const restRes = await listRestaurants(adminDc);
        const myRest = restRes.data?.restaurants?.find(
          (r: any) => r.adminId === callerUid || r.admin?.id === callerUid
        );
        if (myRest) {
          finalRestaurantId = myRest.id;
        }
      } catch (findErr) {
        console.warn('[Auto-resolve restaurantId warning]:', findErr);
      }
    }
    if (!finalRestaurantId) {
      return res.status(400).json({
        error: 'No se pudo determinar el restaurante al que pertenece el administrador autenticado',
      });
    }
    const adminId = callerUid;

    // 1.2 Asignar rol autoritativo en Claims de Firebase Auth
    try {
      await auth.setCustomUserClaims(uid, {
        role: staffRole,
        restaurantId: finalRestaurantId || null,
      });
    } catch (claimErr) {
      console.warn('[setCustomUserClaims warning]:', claimErr);
    }

    // 2. Crear o actualizar en base de datos Cloud SQL (tabla User)
    try {
      const { createUser, updateUser } = await import('@dataconnect/admin-generated');
      try {
        await createUser(adminDc, {
          id: uid,
          name: name,
          email: email,
          role: staffRole,
          phone: null,
          restaurantId: finalRestaurantId || null,
          subscriptionPlanId: null,
          adminId: adminId || null,
        });
      } catch (_) {
        await updateUser(adminDc, {
          id: uid,
          restaurantId: finalRestaurantId || null,
        });
      }
    } catch (dcErr) {
      console.warn('[DataConnect create-waiter warning]:', dcErr);
    }

    res.status(201).json({
      success: true,
      message: `¡Personal (${staffRole}) creado con éxito en Firebase!`,
      uid,
      email,
      name,
      role: staffRole,
      restaurantId: finalRestaurantId,
      tableAssigned,
      waiterType
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'Error al registrar personal' });
  }
});

router.get('/profile/:uid', verifyFirebaseToken, async (req, res) => {
  try {
    const { uid } = req.params;
    const { getUserById, listRestaurants, getSubscriptionPlanById } = await import('@dataconnect/admin-generated');
    const userRes = await getUserById(adminDc, { id: uid });
    const user = userRes.data.user;

    if (!user) {
      return res.status(404).json({ error: 'Usuario no encontrado en la base de datos' });
    }

    let restaurantName = 'Mi Restaurante';
    if (user.restaurantId || user.id) {
      const rests = await listRestaurants(adminDc);
      const r = rests.data.restaurants.find(rest => rest.id === user.restaurantId || rest.adminId === user.id);
      if (r) restaurantName = r.name;
    }

    let planName = 'Prueba Gratuita (7 Días)';
    let maxWaiters = 3;
    if (user.subscriptionPlanId) {
      try {
        const planRes = await getSubscriptionPlanById(adminDc, { id: user.subscriptionPlanId });
        if (planRes.data.subscriptionPlan) {
          planName = planRes.data.subscriptionPlan.name.toUpperCase();
          maxWaiters = planRes.data.subscriptionPlan.maxWaiters || 3;
        }
      } catch (_) {}
    }

    res.status(200).json({
      success: true,
      uid: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      restaurantId: user.restaurantId,
      restaurantName,
      planName,
      maxWaiters,
      trialDaysRemaining: 7
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'Error al obtener perfil' });
  }
});

router.get('/staff/:identifier', requireAdmin, async (req, res) => {
  try {
    const { identifier } = req.params;
    const { getUsersByRestaurant, listRestaurants } = await import('@dataconnect/admin-generated');

    let resolvedRestaurantId = identifier;
    let restaurantName = 'Mi Restaurante';

    // 1. Resolver el restaurante por id o por adminId
    const rests = await listRestaurants(adminDc);
    const myRest = rests.data?.restaurants?.find((r: any) => r.id === identifier || r.admin?.id === identifier || r.adminId === identifier);
    if (myRest) {
      resolvedRestaurantId = myRest.id;
      restaurantName = myRest.name;
    }

    // 2. Obtener usuarios asociados al restaurante
    const usersRes = await getUsersByRestaurant(adminDc, { restaurantId: resolvedRestaurantId });
    const allUsers = usersRes.data?.users || [];

    // 3. Filtrar meseros y cocineros
    const staff = allUsers
      .filter((u: any) => u.role === 'waiter' || u.role === 'kitchen' || u.role === 'chef')
      .map((u: any) => ({
        id: u.id,
        name: u.name,
        email: u.email,
        role: u.role,
        tableAssigned: u.name && u.name.includes('Mesa') ? u.name : 'Mesa 1',
        type: u.role === 'kitchen' || u.role === 'chef' ? 'kitchenChef' : 'virtualTable',
      }));

    res.status(200).json({
      success: true,
      restaurantId: resolvedRestaurantId,
      restaurantName,
      staff,
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message || 'Error al obtener personal' });
  }
});

router.post('/verify-login', verifyFirebaseToken, (req, res) => {
  const user = (req as any).user;
  res.status(200).json({ 
    success: true, 
    message: 'Token válido',
    uid: user.uid,
    role: user.role,
    restaurantId: user.restaurantId
  });
});

export default router;
