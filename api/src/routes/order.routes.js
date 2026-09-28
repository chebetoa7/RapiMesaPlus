"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const dataconnect_admin_generated_1 = require("../dataconnect-admin-generated");
const firebase_1 = require("../firebase");
const router = (0, express_1.Router)();
// Crear una Orden
router.post('/', async (req, res) => {
    try {
        const { restaurantId, waiterId, tableId, totalAmount, comments } = req.body;
        const result = await (0, dataconnect_admin_generated_1.createOrder)(firebase_1.adminDc, {
            restaurantId,
            waiterId,
            tableId,
            totalAmount,
            comments: comments || null
        });
        res.status(201).json({ success: true, data: result.data });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Obtener órdenes de un mesero
router.get('/waiter/:waiterId', async (req, res) => {
    try {
        const result = await (0, dataconnect_admin_generated_1.getOrdersByWaiter)(firebase_1.adminDc, { waiterId: req.params.waiterId });
        res.status(200).json({ success: true, data: result.data });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Cambiar estado de una orden
router.put('/:id/status', async (req, res) => {
    try {
        const { status } = req.body;
        const result = await (0, dataconnect_admin_generated_1.updateOrderStatus)(firebase_1.adminDc, { id: req.params.id, status });
        res.status(200).json({ success: true, data: result.data });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=order.routes.js.map