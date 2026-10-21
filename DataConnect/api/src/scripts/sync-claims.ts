/**
 * Sincroniza los Custom Claims de Firebase Auth con el rol que tiene cada
 * usuario en la tabla `User` de Cloud SQL.
 *
 * POR QUÉ EXISTE
 * ---------------
 * El backend autoriza por rol. La fuente principal son los Custom Claims del
 * token de Firebase, pero hay cuentas creadas antes de que el alta asignara
 * esos claims (por ejemplo `sebastian0@gmail.com`, que tiene
 * `role = 'restaurant_admin'` en la base de datos y `customClaims = undefined`
 * en Firebase Auth). Esas cuentas recibían 403 en todas las rutas de
 * administración aunque su rol en la base de datos fuera correcto.
 *
 * Este script deja los claims alineados con la base de datos, de modo que el
 * enrutamiento por rol del cliente (que usa los claims) también funcione.
 *
 * USO
 * ---
 *   npm run sync:claims            # solo muestra qué está desalineado
 *   npm run sync:claims -- --fix   # aplica la corrección
 */
import { listAllUsers } from '@dataconnect/admin-generated';
import { getAuth } from 'firebase-admin/auth';
import { adminDc } from '../firebase';

const ROLES_VALIDOS = new Set([
  'super_admin',
  'admin',
  'restaurant_admin',
  'waiter',
  'kitchen',
  'chef',
]);

async function main() {
  const aplicar = process.argv.includes('--fix');
  const auth = getAuth();

  console.log(`\n[Sync Claims] Modo: ${aplicar ? 'CORREGIR' : 'solo informe'}\n`);

  const res = await listAllUsers(adminDc);
  const usuarios = res.data?.users ?? [];
  console.log(`[Sync Claims] Usuarios en Cloud SQL: ${usuarios.length}\n`);

  let corregidos = 0;
  let sinCuenta = 0;

  for (const u of usuarios) {
    const email = u.email;
    const rolDb = String(u.role ?? '');
    if (!email) continue;

    let record;
    try {
      record = await auth.getUserByEmail(email);
    } catch {
      console.log(`  ⚠️  ${email.padEnd(42)} sin cuenta en Firebase Auth (rol BD: ${rolDb})`);
      sinCuenta++;
      continue;
    }

    const claims = (record.customClaims ?? {}) as Record<string, unknown>;
    const rolClaim = claims['role'] ? String(claims['role']) : undefined;
    const restClaim = claims['restaurantId'] ? String(claims['restaurantId']) : undefined;
    const restDb = u.restaurantId ? String(u.restaurantId) : undefined;

    const alineado =
      rolClaim === rolDb &&
      (restDb === undefined || restClaim === restDb || restClaim === undefined);

    if (alineado) {
      console.log(`  ✅ ${email.padEnd(42)} role=${rolClaim} (alineado)`);
      continue;
    }

    console.log(
      `  ⚠️  ${email.padEnd(42)} claim=${rolClaim ?? '∅'} / bd=${rolDb}` +
        (restClaim !== restDb ? `  restaurantId claim=${restClaim ?? '∅'} / bd=${restDb ?? '∅'}` : '')
    );

    if (!aplicar) continue;
    if (!ROLES_VALIDOS.has(rolDb)) {
      console.log(`      → rol "${rolDb}" no reconocido; se omite`);
      continue;
    }

    try {
      await auth.setCustomUserClaims(record.uid, {
        ...claims,
        role: rolDb,
        restaurantId: restDb ?? null,
      });
      console.log(`      → claims actualizados: role=${rolDb}, restaurantId=${restDb ?? 'null'}`);
      corregidos++;
    } catch (e: any) {
      console.log(`      → ERROR al actualizar claims: ${e.message}`);
    }
  }

  console.log(
    `\n[Sync Claims] Resumen: ${corregidos} corregidos, ${sinCuenta} sin cuenta en Firebase Auth, ` +
      `${usuarios.length} revisados.\n`
  );
  if (!aplicar && corregidos === 0) {
    console.log('[Sync Claims] Revisa con "npm run sync:claims -- --fix" para aplicar.\n');
  }
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('[Sync Claims] Error general:', e);
    process.exit(1);
  });
