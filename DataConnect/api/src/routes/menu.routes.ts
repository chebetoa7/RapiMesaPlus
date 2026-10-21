import { Router } from 'express';
import { adminDc } from '../firebase';
import { createMenuCategory, createMenuItem, getMenuByRestaurant, getMenuCategoryById, getMenuItemById, updateMenuCategory, updateMenuItem, deleteMenuCategory, deleteMenuItem } from '@dataconnect/admin-generated';
import { notifyMenuUpdated, sendPushToTopic } from '../services/push.service';
import { requireAdmin } from '../middlewares/auth.middleware';

const router = Router();

// RESTAURANT MENU (Público para comensales y salón)
router.get('/restaurant/:restaurantId', async (req, res) => {
  try {
    const result = await getMenuByRestaurant(adminDc, { restaurantId: req.params.restaurantId });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

// Endpoint explícito para despertar y forzar refresco del menú en todas las mesas vía Push
router.post('/restaurant/:restaurantId/notify-update', requireAdmin, async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const { reason } = req.body || {};
    const result = await notifyMenuUpdated({
      restaurantId,
      action: 'edit',
      targetType: 'item',
      name: reason || 'Menú sincronizado',
      sender: { userId: (req as any).user?.uid, role: (req as any).user?.role },
    });
    res.json({ success: true, pushResult: result });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/category/:id', async (req, res) => {
  try {
    const result = await getMenuCategoryById(adminDc, { id: req.params.id });
    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.get('/item/:id', async (req, res) => {
  try {
    const { id } = req.params;
    if (id === 'default_agua_gratis') {
      return res.status(200).json({ success: true, exists: true, available: true, message: 'Producto permanente disponible' });
    }
    const result = await getMenuItemById(adminDc, { id });
    const item = result.data?.menuItem;
    if (!item) {
      return res.status(200).json({ success: true, exists: false, available: false, message: 'El producto ya no existe en el menú' });
    }
    const isAvailable = item.isAvailable !== false;
    res.status(200).json({ 
      success: true, 
      exists: true, 
      available: isAvailable, 
      data: item,
      message: isAvailable ? 'Disponible' : 'Producto temporalmente agotado'
    });
  } catch (error: any) { 
    res.status(200).json({ success: true, exists: false, available: false, error: error.message }); 
  }
});

// CATEGORIES (Gestión del Administrador)
router.post('/category', requireAdmin, async (req, res) => {
  try {
    const { restaurantId, name, iconUrl, sortOrder } = req.body;
    const result = await createMenuCategory(adminDc, { 
      restaurantId, 
      name, 
      iconUrl: iconUrl || '', 
      sortOrder: sortOrder ? Number(sortOrder) : 0 
    });

    if (restaurantId) {
      notifyMenuUpdated({
        restaurantId,
        action: 'add',
        targetType: 'category',
        name,
        sender: { userId: (req as any).user?.uid, role: (req as any).user?.role },
      });
    }

    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.patch('/category/:id', requireAdmin, async (req, res) => {
  try {
    const { name, iconUrl, sortOrder, restaurantId } = req.body;
    const result = await updateMenuCategory(adminDc, { 
      id: req.params.id, 
      name, 
      iconUrl, 
      sortOrder: sortOrder !== undefined ? Number(sortOrder) : undefined 
    });

    if (restaurantId) {
      notifyMenuUpdated({
        restaurantId,
        action: 'edit',
        targetType: 'category',
        id: req.params.id,
        name,
        sender: { userId: (req as any).user?.uid, role: (req as any).user?.role },
      });
    }

    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.delete('/category/:id', requireAdmin, async (req, res) => {
  try {
    const { restaurantId } = req.query;

    let categoryName = '';
    try {
      const before = await getMenuCategoryById(adminDc, { id: req.params.id });
      categoryName = before.data?.menuCategory?.name || '';
    } catch (_) {}

    await deleteMenuCategory(adminDc, { id: req.params.id });

    if (restaurantId) {
      notifyMenuUpdated({
        restaurantId: restaurantId as string,
        action: 'delete',
        targetType: 'category',
        id: req.params.id,
        name: categoryName,
        sender: { userId: (req as any).user?.uid, role: (req as any).user?.role },
      });
    }

    res.status(200).json({ success: true, message: 'Categoría eliminada' });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

// ITEMS / PLATILLOS & BEBIDAS (Gestión del Administrador)
router.post('/item', requireAdmin, async (req, res) => {
  try {
    const { categoryId, name, description, price, imageUrl, extras, restaurantId } = req.body;
    let finalDescription = description || '';
    if (extras && Array.isArray(extras) && extras.length > 0) {
      finalDescription = `${finalDescription.trim()} __EXTRAS__:${JSON.stringify(extras)}`;
    }
    const result = await createMenuItem(adminDc, { 
      categoryId, 
      name, 
      description: finalDescription, 
      price: Number(price), 
      imageUrl: imageUrl || '' 
    });

    // Enviar notificación Push de menú actualizado
    let targetRestaurantId = restaurantId;
    if (!targetRestaurantId && categoryId) {
      try {
        const catRes = await getMenuCategoryById(adminDc, { id: categoryId });
        targetRestaurantId = catRes.data?.menuCategory?.restaurantId;
      } catch (_) {}
    }

    if (targetRestaurantId) {
      notifyMenuUpdated({
        restaurantId: targetRestaurantId,
        action: 'add',
        targetType: 'item',
        name,
        sender: { userId: (req as any).user?.uid, role: (req as any).user?.role },
      });
    }

    res.status(201).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.patch('/item/:id', requireAdmin, async (req, res) => {
  try {
    const { name, description, price, imageUrl, isAvailable, extras, restaurantId } = req.body;
    let finalDescription = description;
    if (description !== undefined && extras && Array.isArray(extras)) {
      finalDescription = `${description.trim()} __EXTRAS__:${JSON.stringify(extras)}`;
    }
    const result = await updateMenuItem(adminDc, { 
      id: req.params.id, 
      name, 
      description: finalDescription, 
      price: price !== undefined ? Number(price) : undefined, 
      imageUrl, 
      isAvailable 
    });

    if (restaurantId) {
      notifyMenuUpdated({
        restaurantId,
        action: 'edit',
        targetType: 'item',
        id: req.params.id,
        name,
        sender: { userId: (req as any).user?.uid, role: (req as any).user?.role },
      });
    }

    res.status(200).json({ success: true, data: result.data });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

router.delete('/item/:id', requireAdmin, async (req, res) => {
  try {
    const { restaurantId } = req.query;

    // Se resuelve el nombre ANTES de borrar: la push silenciosa lo lleva para
    // que la app del mesero pueda avisar qué platillo desapareció del menú
    // (y no solo recargar la lista en silencio).
    let itemName = '';
    try {
      const before = await getMenuItemById(adminDc, { id: req.params.id });
      itemName = before.data?.menuItem?.name || '';
    } catch (_) {}

    await deleteMenuItem(adminDc, { id: req.params.id });

    if (restaurantId) {
      notifyMenuUpdated({
        restaurantId: restaurantId as string,
        action: 'delete',
        targetType: 'item',
        id: req.params.id,
        name: itemName,
        sender: { userId: (req as any).user?.uid, role: (req as any).user?.role },
      });
    }

    res.status(200).json({ success: true, message: 'Producto eliminado' });
  } catch (error: any) { res.status(500).json({ error: error.message }); }
});

export default router;
