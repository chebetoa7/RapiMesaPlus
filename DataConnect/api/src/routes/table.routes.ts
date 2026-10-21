import { Router } from 'express';
import { adminDc } from '../firebase';
import { verifyFirebaseToken } from '../middlewares/auth.middleware';
import { createTable, listTablesByRestaurant, getTableById, updateTable, deleteTable } from '@dataconnect/admin-generated';

const router = Router();
router.use(verifyFirebaseToken);

router.post('/', async (req, res) => {
  try {
    const { restaurantId, identifier } = req.body;
    const result = await createTable(adminDc, { restaurantId, identifier });
    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/restaurant/:restaurantId', async (req, res) => {
  try {
    const result = await listTablesByRestaurant(adminDc, { restaurantId: req.params.restaurantId });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const result = await getTableById(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.patch('/:id', async (req, res) => {
  try {
    const { identifier, status } = req.body;
    const result = await updateTable(adminDc, { id: req.params.id, identifier, status });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.delete('/:id', async (req, res) => {
  try {
    const result = await deleteTable(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, message: 'Mesa eliminada' });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

export default router;
