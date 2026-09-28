import { Router } from 'express';
import { adminDc } from '../firebase';
import { verifyFirebaseToken } from '../middlewares/auth.middleware';
import { createOrder, updateOrderStatus, addOrderItem, listOrdersByRestaurant, getOrderById } from '@dataconnect/admin-generated';

const router = Router();
router.use(verifyFirebaseToken);

router.post('/', async (req, res) => {
  try {
    const { restaurantId, waiterId, tableId, totalAmount, comments } = req.body;
    const result = await createOrder(adminDc, { restaurantId, waiterId, tableId, totalAmount, comments });
    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.post('/item', async (req, res) => {
  try {
    const { orderId, productId, name, quantity, price } = req.body;
    const result = await addOrderItem(adminDc, { orderId, productId, name, quantity, price });
    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.patch('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const result = await updateOrderStatus(adminDc, { id: req.params.id, status });
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
