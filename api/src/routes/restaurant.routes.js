"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const dataconnect_admin_generated_1 = require("../dataconnect-admin-generated");
const firebase_1 = require("../firebase");
const router = (0, express_1.Router)();
// Crear un Restaurante
router.post('/', async (req, res) => {
    try {
        const { name, tableCount, adminId } = req.body;
        // Llamamos a la mutacion autogenerada omitiendo 'impersonate' para correr como Admin (con todos los permisos)
        const result = await (0, dataconnect_admin_generated_1.createRestaurant)(firebase_1.adminDc, { name, tableCount, adminId });
        res.status(201).json({ success: true, data: result.data });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Listar Restaurantes
router.get('/', async (req, res) => {
    try {
        const result = await (0, dataconnect_admin_generated_1.listRestaurants)(firebase_1.adminDc);
        res.status(200).json({ success: true, data: result.data });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=restaurant.routes.js.map