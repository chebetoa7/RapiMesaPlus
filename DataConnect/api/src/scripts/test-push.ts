/**
 * Herramienta de pruebas de Push Notification.
 *
 *   npm run push:devices
 *       Lista los dispositivos que tienen token FCM registrado en el backend.
 *
 *   npm run push:test -- --tipo menu_updated --restaurante <restaurantId>
 *   npm run push:test -- --tipo staff_call    --restaurante <restaurantId>
 *   npm run push:test -- --tipo new_order     --restaurante <restaurantId>
 *   npm run push:test -- --token <FCM_TOKEN_COMPLETO>
 *
 * Se autentica como `sebastian0@gmail.com` (administrador de VianeyCoffee's)
 * usando el service account del backend, así que no hace falta pasar
 * credenciales. Es una herramienta de DESARROLLO: no la uses en producción.
 */
import 'dotenv/config';
// Import con efecto secundario: inicializa Firebase Admin y carga el .env.
import '../firebase';
import { getAuth } from 'firebase-admin/auth';

const API = process.env.API_URL || 'http://localhost:3000';
const ADMIN_EMAIL = 'sebastian0@gmail.com';
const RESTAURANTE_POR_DEFECTO = '641d8c4bd87847bf803ef3f4218ac7ce';

function arg(nombre: string, porDefecto?: string): string | undefined {
  const i = process.argv.indexOf(`--${nombre}`);
  if (i >= 0 && process.argv[i + 1] && !process.argv[i + 1].startsWith('--')) {
    return process.argv[i + 1];
  }
  return porDefecto;
}

/** Consigue un ID token válido de Firebase para el administrador. */
async function tokenDeAdmin(): Promise<string> {
  const key = process.env.FIREBASE_API_KEY;
  if (!key) throw new Error('Falta FIREBASE_API_KEY en el .env');

  const uid = (await getAuth().getUserByEmail(ADMIN_EMAIL)).uid;
  const customToken = await getAuth().createCustomToken(uid, {});
  const resp = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=${key}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: customToken, returnSecureToken: true }),
    }
  );
  const data: any = await resp.json();
  if (!data.idToken) throw new Error(`No se pudo autenticar: ${JSON.stringify(data)}`);
  return data.idToken;
}

async function main() {
  const modo = process.argv.includes('--listar')
    ? 'devices'
    : process.argv.includes('--test')
      ? 'test'
      : 'devices';

  const token = await tokenDeAdmin();
  const headers = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  };

  if (modo === 'devices') {
    const restaurante = arg('restaurante');
    const url = `${API}/api/orders/sync/devices${restaurante ? `?restaurantId=${restaurante}` : ''}`;
    const resp = await fetch(url, { headers });
    const data: any = await resp.json();
    console.log('\n📱 DISPOSITIVOS REGISTRADOS\n');
    if (!data.dispositivos?.length) {
      console.log('  (ninguno) — la app todavía no ha registrado su token FCM.');
      console.log('  Para registrar: abre la app en el dispositivo objetivo y revisa el log:');
      console.log('    "[FCM] Dispositivo registrado exitosamente en backend (rol / restaurante)"');
      console.log('  Si la app es WEB y no aparece, revisa que el navegador haya dado permiso');
      console.log('  de notificaciones y que la app esté INICIADA (register-device exige sesión).');
    }
    for (const d of data.dispositivos ?? []) {
      console.log(`  • ${d.token}`);
      console.log(`      rol=${d.role}  restaurante=${d.restaurantId ?? '∅'}  ${d.actualizado}`);
    }
    console.log(`\n  Total: ${data.total}`);
    if (data.aviso) console.log(`  ⚠️  ${data.aviso}\n`);
    return;
  }

  const tipo = arg('tipo', 'menu_updated')!;
  const restaurante = arg('restaurante', RESTAURANTE_POR_DEFECTO)!;
  const tokenDestino = arg('token');

  console.log(`\n🧪 Enviando push de tipo "${tipo}"...`);
  const resp = await fetch(`${API}/api/orders/sync/test-push`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      restaurantId: restaurante,
      tipo,
      token: tokenDestino,
      title: arg('titulo'),
      body: arg('mensaje'),
    }),
  });
  const data: any = await resp.json();
  console.log(`  HTTP ${resp.status}`);
  console.log(`  ${JSON.stringify(data, null, 2)}\n`);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('❌ Error:', e.message);
    process.exit(1);
  });
