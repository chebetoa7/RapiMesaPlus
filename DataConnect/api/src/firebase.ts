import { initializeApp, cert, applicationDefault, Credential } from 'firebase-admin/app';
import { getDataConnect } from 'firebase-admin/data-connect';
import { connectorConfig } from '@dataconnect/admin-generated';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import os from 'os';

dotenv.config();

/**
 * Carga el helper de autenticación del CLI de firebase-tools.
 * Se prueban varias ubicaciones porque firebase-tools suele instalarse de
 * forma global y no como dependencia del proyecto.
 */
function loadFirebaseToolsAuth(): any | null {
  const candidates = [
    'firebase-tools/lib/auth.js',
    '/usr/local/lib/node_modules/firebase-tools/lib/auth.js',
    '/opt/homebrew/lib/node_modules/firebase-tools/lib/auth.js',
  ];
  for (const candidate of candidates) {
    try {
      return require(candidate);
    } catch (_) {}
  }
  return null;
}

/**
 * Resuelve la credencial de Firebase Admin según el entorno de ejecución.
 *
 * 1. Archivo de service account en la carpeta del backend (desarrollo local).
 * 2. Variable de entorno GOOGLE_APPLICATION_CREDENTIALS.
 * 3. Sesión del CLI de firebase-tools (desarrollo local).
 * 4. Application Default Credentials (Cloud Functions / Cloud Run / GCE).
 *    En el runtime de Google el propio entorno entrega las credenciales de la
 *    cuenta de servicio del proyecto, por lo que no se necesita ningún archivo.
 */
function getFirebaseCredential(): Credential | undefined {
  // 1. Archivo de service account oficial junto al backend
  const apiDir = path.resolve(__dirname, '..');
  const serviceAccountFiles = [
    'restaurantapp-3007c-firebase-adminsdk-fbsvc-0d35d65afc.json',
    'serviceAccountKey.json',
  ];

  for (const filename of serviceAccountFiles) {
    const fullPath = path.join(apiDir, filename);
    if (fs.existsSync(fullPath)) {
      try {
        console.log(`[Firebase Admin] Cargando credencial de servicio desde: ${filename}`);
        return cert(fullPath);
      } catch (err: any) {
        console.warn(`[Firebase Admin] Error leyendo ${filename}:`, err.message);
      }
    }
  }

  // 2. Variable GOOGLE_APPLICATION_CREDENTIALS
  if (
    process.env.GOOGLE_APPLICATION_CREDENTIALS &&
    fs.existsSync(process.env.GOOGLE_APPLICATION_CREDENTIALS)
  ) {
    return cert(process.env.GOOGLE_APPLICATION_CREDENTIALS);
  }

  // 3. Sesión del CLI de firebase-tools (solo desarrollo local)
  const configPath = path.resolve(os.homedir(), '.config/configstore/firebase-tools.json');
  if (fs.existsSync(configPath)) {
    try {
      const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      if (cfg.tokens?.refresh_token) {
        return {
          getAccessToken: async () => {
            try {
              const authTool = loadFirebaseToolsAuth();
              if (!authTool) throw new Error('firebase-tools no disponible');
              const res = await authTool.getAccessToken(cfg.tokens.refresh_token, cfg.tokens.scopes);
              return {
                access_token: res.access_token,
                expires_in: res.expires_in || 3600,
              };
            } catch (toolErr) {
              const freshCfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
              return {
                access_token: freshCfg.tokens?.access_token || cfg.tokens.access_token,
                expires_in: 3600,
              };
            }
          },
        };
      }
    } catch (_) {}
  }

  // 4. Application Default Credentials: es lo que ocurre en Cloud Functions,
  //    Cloud Run y cualquier Compute Engine. El runtime ya tiene la credencial
  //    de la cuenta de servicio del proyecto.
  console.log('[Firebase Admin] Usando Application Default Credentials del entorno.');
  return applicationDefault();
}

const credential = getFirebaseCredential();

// Inicializamos la app con el projectId y la credencial activa
export const app = initializeApp({
  projectId: process.env.GCLOUD_PROJECT || 'restaurantapp-3007c',
  ...(credential ? { credential } : {}),
});

// Inicializamos el conector autogenerado de Firebase Data Connect
export const adminDc = getDataConnect(connectorConfig);
