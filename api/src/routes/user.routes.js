"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_1 = require("firebase-admin/auth");
const dataconnect_admin_generated_1 = require("../dataconnect-admin-generated");
const firebase_1 = require("../firebase");
const router = (0, express_1.Router)();
const auth = (0, auth_1.getAuth)();
// Crear Administrador o Mesero
router.post('/', async (req, res) => {
    try {
        const { name, email, password, role, phone, restaurantId } = req.body;
        // 1. Crear usuario en Firebase Auth
        const userRecord = await auth.createUser({
            email,
            password,
            displayName: name,
            phoneNumber: phone || undefined,
        });
        // Opcional: Configurar Custom Claims
        await auth.setCustomUserClaims(userRecord.uid, { role, restaurantId });
        // 2. Guardar el perfil en la base de datos relacional (Data Connect)
        const result = await (0, dataconnect_admin_generated_1.createUser)(firebase_1.adminDc, {
            id: userRecord.uid,
            name,
            email,
            role, // 'restaurant_admin' o 'waiter'
            phone,
            restaurantId: restaurantId || null
        });
        res.status(201).json({ success: true, uid: userRecord.uid, data: result.data });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Obtener detalles del usuario
router.get('/:id', async (req, res) => {
    try {
        const result = await (0, dataconnect_admin_generated_1.getUserById)(firebase_1.adminDc, { id: req.params.id });
        res.status(200).json({ success: true, data: result.data });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Listar empleados de un restaurante
router.get('/restaurant/:restaurantId', async (req, res) => {
    try {
        const result = await (0, dataconnect_admin_generated_1.getUsersByRestaurant)(firebase_1.adminDc, { restaurantId: req.params.restaurantId });
        res.status(200).json({ success: true, data: result.data });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
exports.default = router;
//# sourceMappingURL=user.routes.js.map