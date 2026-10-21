import { Router } from 'express';
import { getAuth } from 'firebase-admin/auth';
import { createUser, getUserById, getUsersByRestaurant, listAllUsers, updateUser, deleteUser, getSubscriptionPlanByName, getSubscriptionPlanById, getWaitersByAdmin } from '@dataconnect/admin-generated';
import { adminDc } from '../firebase';
import { verifyFirebaseToken } from '../middlewares/auth.middleware';

const router = Router();
const auth = getAuth();

router.use(verifyFirebaseToken);

router.post('/', async (req, res) => {
  try {
    const caller = (req as any).user;
    const { name, email, password, role, phone, restaurantId } = req.body;
    let subscriptionPlanId = req.body.subscriptionPlanId;
    
    // Validar Permisos
    if (caller.role !== 'admin' && caller.role !== 'restaurant_admin') {
      return res.status(403).json({ error: 'No tienes permisos para crear usuarios.' });
    }

    if (caller.role === 'restaurant_admin') {
      if (role !== 'waiter') {
        return res.status(403).json({ error: 'Como gerente, solo puedes crear cuentas de meseros (waiter).' });
      }
      
      // CHECAR LIMITES DEL PLAN
      const adminProfile = await getUserById(adminDc, { id: caller.uid });
      const planId = (adminProfile.data.user as any)?.subscriptionPlanId;
      
      if (!planId) {
        return res.status(403).json({ error: 'Tu cuenta no tiene un plan activo. Contacta a soporte.' });
      }
      
      const planRes = await getSubscriptionPlanById(adminDc, { id: planId });
      const maxWaiters = planRes.data.subscriptionPlan?.maxWaiters || 0;
      
      const currentWaitersRes = await getWaitersByAdmin(adminDc, { adminId: caller.uid });
      const currentCount = currentWaitersRes.data.users.length;
      
      if (currentCount >= maxWaiters) {
        return res.status(403).json({ error: `Has superado el limite de meseros permitidos en tu paquete (${maxWaiters}). Contacta a ventas para un Upgrade.` });
      }
    }

    // Si Admin crea un Restaurant Admin, le asignamos el plan Free por defecto
    if (caller.role === 'admin' && role === 'restaurant_admin' && !subscriptionPlanId) {
      const freePlanRes = await getSubscriptionPlanByName(adminDc, { name: 'express' });
      if (freePlanRes.data.subscriptionPlans && freePlanRes.data.subscriptionPlans.length > 0) {
        subscriptionPlanId = freePlanRes.data.subscriptionPlans[0].id;
      }
    }

    const adminId = caller.role === 'restaurant_admin' ? caller.uid : (req.body.adminId || null);

    const userRecord = await auth.createUser({ email, password, displayName: name, phoneNumber: phone || undefined });
    await auth.setCustomUserClaims(userRecord.uid, { role, restaurantId });

    const result = await createUser(adminDc, {
      id: userRecord.uid,
      name,
      email,
      role,
      phone,
      restaurantId: restaurantId || null,
      subscriptionPlanId: subscriptionPlanId || null,
      adminId: adminId
    });

    res.status(201).json({ success: true, uid: userRecord.uid, data: result.data });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const result = await getUserById(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/restaurant/:restaurantId', async (req, res) => {
  try {
    const result = await getUsersByRestaurant(adminDc, { restaurantId: req.params.restaurantId });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/', async (req, res) => {
  try {
    const result = await listAllUsers(adminDc);
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.patch('/:id', async (req, res) => {
  try {
    const { name, phone, role, restaurantId } = req.body;
    const updates: any = {};
    if (name) updates.displayName = name;
    if (phone) updates.phoneNumber = phone;
    if (Object.keys(updates).length > 0) await auth.updateUser(req.params.id, updates);
    if (role || restaurantId) await auth.setCustomUserClaims(req.params.id, { role, restaurantId });

    const result = await updateUser(adminDc, { id: req.params.id, name, phone, role, restaurantId: restaurantId || null });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.delete('/:id', async (req, res) => {
  try {
    await auth.deleteUser(req.params.id);
    await deleteUser(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, message: 'Usuario eliminado' });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});
export default router;
