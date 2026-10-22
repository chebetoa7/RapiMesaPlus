# CI de RapiMesa (GitHub Actions)

## Workflows

| Workflow | Qué hace | Qué necesita |
|---|---|---|
| **iOS Build** | Compila la app para iOS **sin firmar** y sube el `.app` como artefacto. Sirve para **comprobar que compila en CI** | Nada |
| **iOS TestFlight** | Genera un **IPA firmado** y opcionalmente lo sube a TestFlight | 6 secretos (ver abajo) |
| **Build web y Android** | Compila la web (`/app/`) y un APK de Android debug | Nada |

Se ejecutan solos en cada `push` a `main` que toque `RapiMesaFlutter/`, y
también se pueden lanzar a mano desde la pestaña **Actions**.

---

## 1) El primer workflow: iOS Build (sin certificados)

Es el que funciona **de una**. Ve a **Actions → "iOS Build" → Run workflow**.

Sirve para:
- Verificar que el proyecto compila en un Mac moderno (tu Xcode 14.2 es de 2022).
- Tener el `.app` como artefacto.

> No se puede instalar en un iPad: sin firmar. Para eso, el siguiente.

---

## 2) iOS TestFlight: qué hay que preparar (una sola vez)

### 2.1 Cambiar el bundle id ⚠️ (obligatorio)

El proyecto usa `com.example.rapimesaFlutter`. **Apple no acepta el prefijo
`com.example`** (está reservado), así que TestFlight lo rechazaría.

Hay que cambiarlo en **3 sitios**:

| Archivo | Qué cambiar |
|---|---|
| `ios/Runner.xcodeproj/project.pbxproj` | `PRODUCT_BUNDLE_IDENTIFIER = com.example.rapimesaFlutter` |
| `ios/Runner/GoogleService-Info.plist` | la clave `BUNDLE_ID` |
| `lib/firebase_options.dart` | en `ios`, el `bundleId` |

Y registrar ese identificador en:
- **Apple Developer** → Certificates, Identifiers & Profiles → App IDs → registrar.
- **Firebase Console** → Project settings → Your apps → Add app → iOS → con ese
  bundle id → descargar el `GoogleService-Info.plist` nuevo y reemplazar el del repo.

El workflow **falla con un mensaje claro** si detecta un bundle id de ejemplo,
para que no se pierda tiempo con errores raros de Apple.

### 2.2 Los secretos

En el repo: **Settings → Secrets and variables → Actions → New repository secret**

| Secreto | Cómo se obtiene |
|---|---|
| `APPLE_CERT_P12` | Apple Developer → Certificates → crear **Apple Distribution** → exportar `.p12` → `base64 -i Cert.p12 \| pbcopy` |
| `APPLE_CERT_PASSWORD` | la contraseña que elegiste al exportar el `.p12` |
| `APPLE_PROVISIONING_PROFILE` | el `.mobileprovision` → `base64 -i Perfil.mobileprovision \| pbcopy` |
| `APP_STORE_CONNECT_KEY_P8` | App Store Connect → Users and Access → Keys → crear key → `base64 -i AuthKey_XXX.p8 \| pbcopy` |
| `APP_STORE_CONNECT_KEY_ID` | el Key ID (10 caracteres) |
| `APP_STORE_CONNECT_ISSUER_ID` | el Issuer ID (UUID) |

### 2.3 El perfil de provisión

En `RapiMesaFlutter/ios/ExportOptions.plist` hay que poner:
- `teamID`: tu Team ID (10 caracteres).
- `provisioningProfiles`: el **nombre exacto** del perfil en tu cuenta de Apple.
- `method`: `ad-hoc` (instalar directo en un iPad) o `app-store` (TestFlight).

---

## 3) Detalles que importan (ya resueltos en los workflows)

| Detalle | Qué hace el workflow |
|---|---|
| **Entitlement de APNs** | En un build firmado con certificado de **Distribution**, APNs usa el endpoint de producción. El workflow cambia `aps-environment` de `development` a `production` automáticamente. Sin esto, la app se sube a TestFlight **pero el push no llega** (se queda en el sandbox). En local sigue en `development`. |
| **Background modes** | `Info.plist` ya declara `remote-notification` y `fetch`. Sin eso, iOS solo entrega el push con la app en primer plano. |
| **POST_NOTIFICATIONS (Android)** | Añadido al `AndroidManifest.xml`. Sin él, en Android 13+ las notificaciones no se muestran. |
| **Llave de firma** | Se importa en un keychain temporal del runner y se borra al terminar. El runner no guarda nada. |
| **Versión de Flutter** | Fijada a `3.19.6` (la misma que en local) para que el CI no se desincronice. |

---

## 4) Para instalar en tu iPad sin TestFlight

1. Perfil de provisión de tipo **Ad Hoc** (o Development) que incluya el UDID del iPad.
   - El UDID lo puedes ver en Xcode → Window → Devices and Simulators.
   - O gratis con la app **Configurator** de Apple (macOS App Store).
2. `method: "ad-hoc"` en el `ExportOptions.plist`.
3. Descargar el artefacto **RapiMesa-ipa** y abrirlo con **Apple Configurator**
   (arrastrar el `.ipa` al dispositivo). O con `ios-deploy` / `xcrun devicectl`.

---

## 5) Cosas que NO se suben al repo

| Archivo | Por qué |
|---|---|
| `RapiMesaFlutter/keylocal.txt` | Contraseña del conmutador QA y URL local |
| `DataConnect/api/.env` | Configuración local |
| `*firebase-adminsdk*.json` | Llave de la cuenta de servicio (control total del proyecto) |
| `android/key.properties` | Keystore de Android para release |

Los workflows **no** usan ninguno de esos: usan secretos de GitHub y
`Application Default Credentials` de Google en el runner.
