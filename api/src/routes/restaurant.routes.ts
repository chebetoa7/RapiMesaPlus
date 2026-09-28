import { Router } from 'express';
import { adminDc } from '../firebase';
import { verifyFirebaseToken } from '../middlewares/auth.middleware';
import { createRestaurant, listRestaurants, getUserById, getSubscriptionPlanById, getRestaurantsByAdmin } from '@dataconnect/admin-generated';

const router = Router();
router.use(verifyFirebaseToken);

router.post('/', async (req, res) => {
  try {
    const caller = (req as any).user;
    
    if (caller.role !== 'admin' && caller.role !== 'restaurant_admin') {
      return res.status(403).json({ error: 'Solo los administradores pueden crear restaurantes.' });
    }

    let finalAdminId = req.body.adminId;

    if (caller.role === 'restaurant_admin') {
      finalAdminId = caller.uid; // Forzar a que solo puedan crearlo para ellos mismos
      
      const adminProfile = await getUserById(adminDc, { id: caller.uid });
      const planId = (adminProfile.data.user as any)?.subscriptionPlanId;
      
      if (!planId) return res.status(403).json({ error: 'Tu cuenta no tiene un plan activo.' });
      
      const planRes = await getSubscriptionPlanById(adminDc, { id: planId });
      const maxRestaurants = planRes.data.subscriptionPlan?.maxRestaurants || 0;
      
      const currentRes = await getRestaurantsByAdmin(adminDc, { adminId: caller.uid });
      const currentCount = currentRes.data.restaurants.length;
      
      if (currentCount >= maxRestaurants) {
        return res.status(403).json({ error: `Has superado el limite de restaurantes en tu paquete (${maxRestaurants}). Realiza un Upgrade.` });
      }
    }

    const { name, tableCount } = req.body;
    const result = await createRestaurant(adminDc, { name, tableCount, adminId: finalAdminId });
    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/', async (req, res) => {
  try {
    const result = await listRestaurants(adminDc);
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

export default router;
