"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const swagger_ui_express_1 = __importDefault(require("swagger-ui-express"));
const app_1 = require("firebase-admin/app");
const data_connect_1 = require("firebase-admin/data-connect");
// Rutas
const restaurant_routes_1 = __importDefault(require("./routes/restaurant.routes"));
const user_routes_1 = __importDefault(require("./routes/user.routes"));
const order_routes_1 = __importDefault(require("./routes/order.routes"));
const auth_routes_1 = __importDefault(require("./routes/auth.routes"));
// Inicializar Firebase Admin (usa la variable de entorno GOOGLE_APPLICATION_CREDENTIALS)
(0, app_1.initializeApp)();
const app = (0, express_1.default)();
const port = process.env.PORT || 3000;
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// Configuracion de Rutas
app.use('/api/auth', auth_routes_1.default);
app.use('/api/restaurants', restaurant_routes_1.default);
app.use('/api/users', user_routes_1.default);
app.use('/api/orders', order_routes_1.default);
// Configuracion basica de Swagger
const swaggerDocument = {
    openapi: '3.0.0',
    info: { title: 'Restaurante App API', version: '1.0.0' },
    paths: {} // Aqui irían las definiciones detalladas
};
app.use('/api-docs', swagger_ui_express_1.default.serve, swagger_ui_express_1.default.setup(swaggerDocument));
app.listen(port, () => {
    console.log(`[server]: API corriendo en http://localhost:${port}`);
});
//# sourceMappingURL=index.js.map