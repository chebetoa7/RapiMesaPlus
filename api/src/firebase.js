"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminDc = void 0;
const data_connect_1 = require("firebase-admin/data-connect");
const dataconnect_admin_generated_1 = require("../dataconnect-admin-generated");
// Inicializamos el conector autogenerado de Firebase Data Connect
exports.adminDc = (0, data_connect_1.getDataConnect)(dataconnect_admin_generated_1.connectorConfig);
//# sourceMappingURL=firebase.js.map