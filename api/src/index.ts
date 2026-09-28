import express from 'express';
import cors from 'cors';
import swaggerUi from 'swagger-ui-express';
import './firebase'; // Esto asegura que Firebase se inicializa antes que las rutas

// Rutas
import restaurantRoutes from './routes/restaurant.routes';
import userRoutes from './routes/user.routes';
import orderRoutes from './routes/order.routes';
import authRoutes from './routes/auth.routes';
import menuRoutes from './routes/menu.routes';
import tableRoutes from './routes/table.routes';

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Configuracion de Rutas
app.use('/api/auth', authRoutes);
app.use('/api/restaurants', restaurantRoutes);
app.use('/api/users', userRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/tables', tableRoutes);

import fs from 'fs';
import path from 'path';

// Configuracion de Swagger leyendo el archivo JSON
const swaggerFile = path.resolve(__dirname, '../swagger.json');
const swaggerDocument = JSON.parse(fs.readFileSync(swaggerFile, 'utf8'));

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.listen(port, () => {
  console.log(`[server]: API corriendo en http://localhost:${port}`);
});
