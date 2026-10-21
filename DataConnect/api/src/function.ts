import { onRequest } from 'firebase-functions/v2/https';
import { app } from './app';

/**
 * Función HTTP de RapiMesa.
 *
 * Notas de diseño importantes:
 * - `maxInstances: 1` es INTENCIONAL: el backend mantiene el estado operativo
 *   (comandas activas, datos bancarios, tokens de push) en memoria. Con una sola
 *   instancia garantizamos que todas las peticiones vean el mismo estado.
 *   Pendiente: migrar ese estado a Cloud SQL (PostgreSQL) para permitir escalado.
 * - `minInstances: 1` mantiene la instancia caliente para que el estado en
 *   memoria sobreviva entre peticiones y no se pierda en un arranque en frío.
 *
 * NOTA SOBRE EL TAMAÑO DEL CUERPO: la plataforma (Cloud Run) impone un límite
 * de 10 MB por petición y `firebase-functions` no permite cambiarlo desde el
 * SDK. Los comprobantes SPEI viajan como imagen base64 dentro del JSON, por lo
 * que el cliente DEBE reducir la imagen antes de enviarla (ancho máximo ~1080px,
 * JPEG calidad 70). Ver `lib/core/utils/receipt_image_picker_web.dart`.
 */
export const api = onRequest(
  {
    region: 'us-east1',
    minInstances: 1,
    maxInstances: 1,
    memory: '512MiB',
    timeoutSeconds: 120,
  },
  app,
);
