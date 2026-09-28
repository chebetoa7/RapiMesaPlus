"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyFirebaseToken = void 0;
const express_1 = require("express");
const auth_1 = require("firebase-admin/auth");
// Middleware para verificar el JWT de Firebase
const verifyFirebaseToken = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'No autorizado, falta token' });
    }
    const token = authHeader.split('Bearer ')[1];
    try {
        const decodedToken = await (0, auth_1.getAuth)().verifyIdToken(token);
        // Agregamos los datos del usuario a la request para usarlos en los controladores
        req.user = decodedToken;
        next();
    }
    catch (error) {
        return res.status(401).json({ error: 'Token inválido o expirado' });
    }
};
exports.verifyFirebaseToken = verifyFirebaseToken;
//# sourceMappingURL=auth.middleware.js.map