# CI de RapiMesa (GitHub Actions)

## Workflows

| Workflow | Qué hace | Qué necesita |
|---|---|---|
| **iOS Build** | Compila la app para iOS **sin firmar** y sube el `.app` como artefacto. Sirve para **comprobar que compila en CI** | Nada |
| **iOS TestFlight** | Genera un **IPA firmado** y opcionalmente lo sube a TestFlight | 6 secretos (ver abajo) |
| **Build web y Android** | Compila la web (`/app/`) y un APK de Android debug | Nada |

Se ejecutan solos en cada `push` a `main` que toque `RapiMesaFlutter/`, y
también se pueden lanzar a mano desde la pestaña **Actions**.

> Se eliminó `.github/workflows/ios.yml` (el *"iOS starter workflow"* que genera
> GitHub al detectar un proyecto Flutter). Corría `xcodebuild -list` en la **raíz**
> del repo, donde no hay ningún `.xcodeproj` —el proyecto está en
> `RapiMesaFlutter/ios/`— y además usaba `macos-latest` con un Xcode distinto al
> del proyecto. Fallaba siempre y no aportaba nada: la compilación iOS ya la
> cubre **iOS Build**. Para recuperarlo:
> `git checkout <commit-anterior> -- .github/workflows/ios.yml`.

---

## 1) El primer workflow: iOS Build (sin certificados)

Es el que funciona **de una**. Ve a **Actions → "iOS Build" → Run workflow**.

Sirve para:
- Verificar que el proyecto compila en un Mac moderno (tu Xcode 14.2 es de 2022).
- Tener el `.app` como artefacto.

> No se puede instalar en un iPad: sin firmar. Para eso, el siguiente.

---

## 2) iOS TestFlight: qué hay que preparar (una sola vez)

### 2.1 Bundle id (ya hecho) ✅

El proyecto usa **`com.rapimesa.app`** en los tres sitios que importan:

| Archivo | Valor |
|---|---|
| `ios/Runner.xcodeproj/project.pbxproj` | `PRODUCT_BUNDLE_IDENTIFIER = com.rapimesa.app` |
| `ios/Runner/GoogleService-Info.plist` | `BUNDLE_ID = com.rapimesa.app` |
| `lib/firebase_options.dart` | `ios → iosBundleId: 'com.rapimesa.app'` |

> El antiguo `com.example.rapimesaFlutter` no sirve: el prefijo `com.example`
> está reservado y Apple lo rechaza para TestFlight.
>
> ⚠️ En la consola de Firebase hay que tener registrada una app iOS con ese
> bundle id y volver a descargar el `GoogleService-Info.plist` (el `GOOGLE_APP_ID`
> actual es el de la app antigua). Si no, FCM/Auth fallan en runtime.

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

El proyecto está en **firma manual**: `project.pbxproj` (configuraciones
Release y Profile del target Runner) lleva

```
CODE_SIGN_STYLE              = Manual
DEVELOPMENT_TEAM             = 3XW2235F4W
PROVISIONING_PROFILE_SPECIFIER = RapiMesa AppStore
CODE_SIGN_IDENTITY           = Apple Distribution
```

así que el perfil **tiene que llamarse exactamente `RapiMesa AppStore`** y ser
de tipo **App Store** para el App ID `com.rapimesa.app`.

Crearlo (una sola vez):

1. <https://developer.apple.com/account/resources/profiles/add>
2. **App Store** → App ID `com.rapimesa.app` → certificado *Apple Distribution*.
3. Nombre: **`RapiMesa AppStore`** → Generate → Download.
4. Instalarlo y validarlo:

```bash
cd RapiMesaFlutter
./scripts/preparar_firma.sh perfil ~/Downloads/RapiMesa_AppStore.mobileprovision
```

El script lo copia como `<UUID>.mobileprovision` (el nombre que espera Xcode) y
comprueba Team ID, bundle id y entitlement de APNs. Si el perfil se llama de
otra forma, avisa: o lo renombras en el portal o cambias
`PROVISIONING_PROFILE_SPECIFIER` / `ExportOptions.plist`.

Para el CI, además:

```bash
base64 -i ~/Downloads/RapiMesa_AppStore.mobileprovision | tr -d '\n' | pbcopy
# → secreto APPLE_PROVISIONING_PROFILE
```

En `RapiMesaFlutter/ios/ExportOptions.plist` están:
- `method`: `app-store` (TestFlight) o `ad-hoc` (instalar directo en un iPad).
- `teamID`: `3XW2235F4W`.
- `provisioningProfiles`: `com.rapimesa.app → RapiMesa AppStore`.

---

## 3) Detalles que importan (ya resueltos en los workflows)

| Detalle | Qué hace el workflow |
|---|---|
| **Entitlement de APNs** | `Runner.entitlements` lleva `aps-environment = production`, que es lo que autoriza un perfil de App Store (con `development` la firma falla con *entitlements are not permitted*). Para depurar push en local con un perfil de desarrollo hay que ponerlo en `development` temporalmente; el workflow **falla** si detecta `development` en el repo, para no subir un IPA con el entitlement del sandbox. |
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
