import { app } from './app';

/**
 * Entry point de desarrollo local.
 *
 * En produccion la API se expone como Cloud Function (ver `src/function.ts`),
 * donde NO se debe llamar a `listen()` porque el runtime invoca la app por
 * sí mismo. Aquí sí lo hacemos para correr `npm run dev` en el puerto 3000.
 */
const port = process.env.PORT || 3000;

app.listen(Number(port), '0.0.0.0', () => {
  console.log(`[server]: API corriendo en http://localhost:${port} y http://0.0.0.0:${port}`);
});
