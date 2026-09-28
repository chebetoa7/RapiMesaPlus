"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const router = (0, express_1.Router)();
/**
 * IMPORTANTE:
 * En la arquitectura de Firebase, el "Login" real (ingresar email/contraseña para obtener un JWT)
 * debe hacerse desde las aplicaciones cliente (.NET MAUI) usando los SDKs de Firebase Client.
 *
 * Una vez que la App obtiene el Token JWT, lo envía a esta API en el header de 'Authorization'.
 * Esta ruta es solo un ejemplo para verificar que tu token funcione.
 */
router.post('/verify-login', auth_middleware_1.verifyFirebaseToken, (req, res) => {
    // Si pasa el middleware, el token es valido
    const user = req.user;
    res.status(200).json({
        success: true,
        message: 'Token válido, el usuario está logueado correctamente',
        uid: user.uid,
        role: user.role, // Obtenido de Custom Claims
        restaurantId: user.restaurantId
    });
});
exports.default = router;
//# sourceMappingURL=auth.routes.js.map