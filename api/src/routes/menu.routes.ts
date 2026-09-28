import { Router } from 'express';
import { adminDc } from '../firebase';
import { verifyFirebaseToken } from '../middlewares/auth.middleware';
import { createMenuCategory, createMenuItem, getMenuByRestaurant, getMenuCategoryById, getMenuItemById, updateMenuCategory, updateMenuItem, deleteMenuCategory, deleteMenuItem } from '@dataconnect/admin-generated';

const router = Router();
router.use(verifyFirebaseToken);

// CATEGORIES
router.post('/category', async (req, res) => {
  try {
    const { restaurantId, name, iconUrl, sortOrder } = req.body;
    const result = await createMenuCategory(adminDc, { restaurantId, name, iconUrl, sortOrder });
    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/category/:id', async (req, res) => {
  try {
    const result = await getMenuCategoryById(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.patch('/category/:id', async (req, res) => {
  try {
    const { name, iconUrl, sortOrder } = req.body;
    const result = await updateMenuCategory(adminDc, { id: req.params.id, name, iconUrl, sortOrder });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.delete('/category/:id', async (req, res) => {
  try {
    await deleteMenuCategory(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, message: 'Categoría eliminada' });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});


// ITEMS
router.post('/item', async (req, res) => {
  try {
    const { categoryId, name, description, price, imageUrl } = req.body;
    const result = await createMenuItem(adminDc, { categoryId, name, description, price, imageUrl });
    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/item/:id', async (req, res) => {
  try {
    const result = await getMenuItemById(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.patch('/item/:id', async (req, res) => {
  try {
    const { name, description, price, imageUrl, isAvailable } = req.body;
    const result = await updateMenuItem(adminDc, { id: req.params.id, name, description, price, imageUrl, isAvailable });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.delete('/item/:id', async (req, res) => {
  try {
    await deleteMenuItem(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, message: 'Producto eliminado' });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

// RESTAURANT MENU
router.get('/restaurant/:restaurantId', async (req, res) => {
  try {
    const result = await getMenuByRestaurant(adminDc, { restaurantId: req.params.restaurantId });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

export default router;
