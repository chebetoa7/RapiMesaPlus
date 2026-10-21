import express from 'express';
import cors from 'cors';
import swaggerUi from 'swagger-ui-express';
import fs from 'fs';
import path from 'path';
import './firebase'; // Inicialización Firebase Admin con Service Account oficial y FCM Multicast

// Rutas
import restaurantRoutes from './routes/restaurant.routes';
import userRoutes from './routes/user.routes';
import orderRoutes from './routes/order.routes';
import authRoutes from './routes/auth.routes';
import menuRoutes from './routes/menu.routes';
import tableRoutes from './routes/table.routes';
import pushRoutes from './routes/push.routes';
import { hydrateDevicesFromDatabase } from './services/push.service';

export const app = express();

// CORS: se restricts a los origenes permitidos si se defines ALLOWED_ORIGINS.
// Si no se define (entorno local), se permite cualquier origen para no romper el desarrollo.
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
  .split(',')
  .map((o) => o.trim())
  .filter((o) => o.length > 0);

app.use(
  cors({
    origin: allowedOrigins.length > 0 ? allowedOrigins : true,
    credentials: true,
  }),
);

app.use(express.json({ limit: '20mb' }));
app.use(express.urlencoded({ extended: true, limit: '20mb' }));

// Telemetría de Peticiones en Tiempo Real (Métricas para prueba y cálculo de 100 restaurantes)
interface RequestMetrics {
  totalRequests: number;
  byMethod: Record<string, number>;
  byRoute: Record<string, number>;
  startedAt: string;
}

const metrics: RequestMetrics = {
  totalRequests: 0,
  byMethod: {},
  byRoute: {},
  startedAt: new Date().toISOString(),
};

app.use((req, res, next) => {
  // Ignorar peticiones estáticas o swagger para medir solo actividad operativa de la API
  if (!req.path.startsWith('/api-docs') && !req.path.endsWith('.png') && !req.path.endsWith('.html') && !req.path.endsWith('.css') && !req.path.endsWith('.js')) {
    metrics.totalRequests++;
    metrics.byMethod[req.method] = (metrics.byMethod[req.method] || 0) + 1;
    const cleanRoute = req.path.replace(/\/[a-zA-Z0-9_\-]+$/g, '/:id');
    metrics.byRoute[cleanRoute] = (metrics.byRoute[cleanRoute] || 0) + 1;
  }
  next();
});

// Endpoint para consultar las métricas acumuladas de la prueba
app.get('/api/telemetry/stats', (req, res) => {
  res.json({
    success: true,
    metrics,
    now: new Date().toISOString(),
    uptimeSeconds: Math.floor(process.uptime()),
  });
});

// Endpoint para reiniciar el contador a 0 antes de una prueba limpia
app.post('/api/telemetry/reset', (req, res) => {
  metrics.totalRequests = 0;
  metrics.byMethod = {};
  metrics.byRoute = {};
  metrics.startedAt = new Date().toISOString();
  res.json({ success: true, message: 'Contador de peticiones reiniciado a 0' });
});

// Configuracion de Rutas
app.use('/api/auth', authRoutes);
app.use('/api/restaurants', restaurantRoutes);
app.use('/api/users', userRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/tables', tableRoutes);
app.use('/api/push', pushRoutes);

// Cargar los dispositivos push registrados desde la base de datos.
//
// La base (tabla PushDevice) es la fuente de verdad; la caché en memoria es
// solo el camino caliente. Antes esto no existía y los tokens se perdían con
// cada reinicio del backend, dejando a los dispositivos sin push.
hydrateDevicesFromDatabase().catch((e) =>
  console.warn('[FCM Registry] No se pudo hidratar el registro de dispositivos:', e?.message),
);

// Configuracion de Swagger leyendo el archivo JSON (solo si existe en el bundle desplegado)
const swaggerPath = path.resolve(__dirname, '../swagger.json');
if (fs.existsSync(swaggerPath)) {
  try {
    const swaggerDocument = JSON.parse(fs.readFileSync(swaggerPath, 'utf8'));
    app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
  } catch (err) {
    console.warn('[Swagger] No se pudo cargar swagger.json:', (err as Error).message);
  }
} else {
  console.warn('[Swagger] swagger.json no encontrado en el bundle; /api-docs queda deshabilitado.');
}

// Servir Landing Page y Dashboard Web estático (solo si el directorio existe en el bundle)
const publicDir = path.resolve(__dirname, '../public');
if (fs.existsSync(publicDir)) {
  app.use(express.static(publicDir));
} else {
  console.warn('[Static] public/ no encontrado en el bundle; la landing se sirve desde Firebase Hosting.');
}

// Health check: útil para Cloud Functions, monitors y pruebas de despliegue
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    service: 'rapimesa-api',
    status: 'ok',
    instance: process.env.K_SERVICE || 'local',
    uptimeSeconds: Math.floor(process.uptime()),
    now: new Date().toISOString(),
  });
});
