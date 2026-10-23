#!/usr/bin/env bash
# ===========================================================================
# preparar_firma.sh — Prepara localmente todo lo que el CI necesita para
#                     firmar el IPA.
#
#   1. Genera el CSR (Certificate Signing Request) para el certificado
#      "Apple Distribution".
#   2. Instala el certificado en el llavero y arma el .p12.
#   3. Codifica en base64 el .p12 y el .mobileprovision para pegarlos
#      como secretos de GitHub.
#
# Uso:
#   ./scripts/preparar_firma.sh csr        → genera el CSR
#   ./scripts/preparar_firma.sh exportar    → instala el .cer y arma el .p12
#   ./scripts/preparar_firma.sh base64     → codifica para GitHub
#   ./scripts/preparar_firma.sh equipo     → muestra el Team ID
# ===========================================================================

set -euo pipefail
cd "$(dirname "$0")/.."

BUNDLE_ID="${BUNDLE_ID:-com.rapimesa.app}"
CSR_DIR="$HOME/rapimesa-firma"
mkdir -p "$CSR_DIR"

# ─────────────────────────────────────────────────────────────────────────────
case "${1:-}" in

csr)
  echo "▶ Generando el CSR para el certificado Apple Distribution"
  echo "  (guárdalo en $CSR_DIR/certificateSigningRequest.crt)"
  echo
  openssl req -new -newkey rsa:2048 -nodes \
    -keyout "$CSR_DIR/private.key" \
    -out "$CSR_DIR/certificateSigningRequest.crt" \
    -sha256 -days 1000 \
    -subj "/email=chebetoa7@gmail.com/CN=Jose Alberto RapiMesa"
  echo
  echo "✅ CSR creado. Ahora:"
  echo "  1. Súbelo en https://developer.apple.com/account/resources/certificates/create"
  echo "     → tipo: Apple Distribution"
  echo "  2. Descarga el .cer y guárdalo en $CSR_DIR/apple_distribution.cer"
  echo "  3. Luego: P12_PASSWORD='...' $0 exportar"
  echo
  echo "  ⚠️  GUARDA private.key en un sitio seguro. Sin ella, el certificado"
  echo "      queda inservible (es lo que pasa si se pierde el llavero)."
  ;;

exportar)
  CER="$CSR_DIR/apple_distribution.cer"
  [ -f "$CER" ] || { echo "❌ No existe $CER"; exit 1; }
  [ -f "$CSR_DIR/private.key" ] || { echo "❌ No existe $CSR_DIR/private.key"; exit 1; }

  if [ -z "${P12_PASSWORD:-}" ]; then
    echo "❌ Define la contraseña del .p12, por ejemplo:"
    echo "     P12_PASSWORD='tu-contrasena' $0 exportar"
    exit 1
  fi

  # ─────────────────────────────────────────────────────────────────────────
  # 1) CADENA DE CONFIANZA
  #    Sin el "Apple Worldwide Developer Relations CA" (G3) instalado, el
  #    certificado se marca como NO CONFIABLE y `security find-identity`
  #    dice "0 valid identities found" aunque la clave esté presente.
  # ─────────────────────────────────────────────────────────────────────────
  WWDR="$CSR_DIR/AppleWWDRCAG3.cer"
  if [ ! -s "$WWDR" ]; then
    echo "▶ Descargando el CA de Apple (WWDR G3)"
    curl -sL -o "$WWDR" https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer || true
  fi
  if [ -s "$WWDR" ]; then
    security import "$WWDR" -k ~/Library/Keychains/login.keychain-db 2>&1 \
      | grep -v "already exists" || true
  fi

  # ─────────────────────────────────────────────────────────────────────────
  # 2) EL .p12
  #    El .cer de Apple viene en DER (binario): hay que convertirlo a PEM.
  #    Y el .p12 se genera con PBE-SHA1-3DES porque es lo único que el
  #    llavero de macOS sabe leer: con el cifrado moderno de OpenSSL 3,
  #    `security import` importa el certificado pero IGNORA la clave privada
  #    en silencio, y la firma falla con "0 valid identities found".
  # ─────────────────────────────────────────────────────────────────────────
  CERT_PEM="$CSR_DIR/apple_distribution.pem"
  if openssl x509 -inform DER -in "$CER" -out "$CERT_PEM" 2>/dev/null; then
    echo "  (el .cer estaba en DER, convertido a PEM)"
  else
    cp "$CER" "$CERT_PEM"
  fi

  echo "▶ Generando el .p12 (certificado + clave privada)"
  rm -f "$CSR_DIR/cert.p12"
  openssl pkcs12 -export \
    -inkey "$CSR_DIR/private.key" \
    -in "$CERT_PEM" \
    -out "$CSR_DIR/cert.p12" \
    -name "Apple Distribution" \
    -passout "pass:$P12_PASSWORD" \
    -keypbe PBE-SHA1-3DES \
    -certpbe PBE-SHA1-3DES \
    -macalg sha1

  [ -s "$CSR_DIR/cert.p12" ] || { echo "❌ El .p12 salió vacío"; exit 1; }

  # ─────────────────────────────────────────────────────────────────────────
  # 3) INSTALAR EN EL LLAVERO
  #    -A = que cualquier aplicación pueda usarlo (codesign).
  # ─────────────────────────────────────────────────────────────────────────
  echo "▶ Instalando en el llavero"
  security import "$CSR_DIR/cert.p12" \
    -k ~/Library/Keychains/login.keychain-db \
    -T /usr/bin/codesign -A -P "$P12_PASSWORD" 2>&1 \
    | grep -v "already exists" || true

  # La clave privada suelta, por si el .p12 no la trajo:
  openssl pkcs8 -topk8 -inform PEM -outform DER -nocrypt \
    -in "$CSR_DIR/private.key" -out "$CSR_DIR/private_pkcs8.der" 2>/dev/null || true
  if [ -s "$CSR_DIR/private_pkcs8.der" ]; then
    security import "$CSR_DIR/private_pkcs8.der" \
      -k ~/Library/Keychains/login.keychain-db -T /usr/bin/codesign -A 2>&1 \
      | grep -v "already exists" || true
  fi

  echo
  echo "✅ Identidades de firma:"
  security find-identity -v -p codesigning

  if [ "$(security find-identity -v -p codesigning 2>/dev/null | grep -c '"Apple Distribution')" -eq 0 ]; then
    echo
    echo "⚠️  Sigue sin identidad válida. Comprueba:"
    echo "   - que el .cer corresponda al CSR de $CSR_DIR/certificateSigningRequest.crt"
    echo "   - que el WWDR G3 esté en el llavero (ls $CSR_DIR/AppleWWDRCAG3.cer)"
    exit 1
  fi

  echo
  echo "  .p12 en $CSR_DIR/cert.p12 ($(du -h "$CSR_DIR/cert.p12" | cut -f1))"
  echo "  Siguiente: $0 base64"
  ;;

base64)
  echo "▶ Codificando en base64 para los secretos de GitHub"
  echo
  for f in "$CSR_DIR/cert.p12" "$CSR_DIR/Perfil.mobileprovision"; do
    if [ -f "$f" ]; then
      b=$(base64 -i "$f" | tr -d '\n')
      echo "────────────────────────────────────────────────────────"
      echo "SECRETO: $(basename "$f")   (${#b} caracteres)"
      echo "────────────────────────────────────────────────────────"
      echo "$b"
      echo
    else
      echo "⚠️  Falta $f"
    fi
  done
  echo "Pega cada bloque en Settings → Secrets and variables → Actions."
  ;;

equipo)
  echo "Tu Team ID: 3XW2235F4W"
  echo "(sale del propio certificado: CN=Apple Distribution: JOSE ALBERTO DE LA CRUZ SOLANO (3XW2235F4W))"
  ;;

perfil)
  # Instala un .mobileprovision como <UUID>.mobileprovision, que es el nombre
  # que espera Xcode, y comprueba que sirve para ESTA app (Team ID, bundle id,
  # APNs de producción y fecha de caducidad).
  PERFIL="${2:-}"
  if [ -z "$PERFIL" ]; then
    for f in "$CSR_DIR"/*.mobileprovision "$HOME/Downloads"/*.mobileprovision; do
      [ -f "$f" ] && PERFIL="$f" && break
    done
  fi
  [ -n "$PERFIL" ] && [ -f "$PERFIL" ] || {
    echo "❌ No encuentro ningún .mobileprovision."
    echo "   Uso: $0 perfil /ruta/al/RapiMesa_AppStore.mobileprovision"
    exit 1
  }

  TMP_PLIST=$(mktemp)
  if ! security cms -D -i "$PERFIL" > "$TMP_PLIST" 2>/dev/null; then
    echo "❌ $PERFIL no es un .mobileprovision válido."
    rm -f "$TMP_PLIST"; exit 1
  fi

  P_UUID=$(/usr/libexec/PlistBuddy -c 'Print :UUID' "$TMP_PLIST")
  P_NAME=$(/usr/libexec/PlistBuddy -c 'Print :Name' "$TMP_PLIST")
  P_TEAM=$(/usr/libexec/PlistBuddy -c 'Print :TeamIdentifier:0' "$TMP_PLIST")
  P_APPID=$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' "$TMP_PLIST")
  P_APS=$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:aps-environment' "$TMP_PLIST" 2>/dev/null || echo "(sin APNs)")
  P_EXP=$(/usr/libexec/PlistBuddy -c 'Print :ExpirationDate' "$TMP_PLIST")

  echo "Perfil : $P_NAME"
  echo "UUID   : $P_UUID"
  echo "Team   : $P_TEAM"
  echo "App ID : $P_APPID"
  echo "APNs   : $P_APS"
  echo "Caduca : $P_EXP"

  if [ "$P_TEAM" != "3XW2235F4W" ]; then
    echo "❌ El perfil es de otro equipo ($P_TEAM), no 3XW2235F4W."
    rm -f "$TMP_PLIST"; exit 1
  fi
  if [ "$P_APPID" != "3XW2235F4W.com.rapimesa.app" ]; then
    echo "❌ El perfil es para '$P_APPID' y no para 3XW2235F4W.com.rapimesa.app."
    echo "   Regístralo para el App ID com.rapimesa.app."
    rm -f "$TMP_PLIST"; exit 1
  fi
  if [ "$P_NAME" != "RapiMesa AppStore" ]; then
    echo "⚠️  El perfil se llama '$P_NAME'. El proyecto espera 'RapiMesa AppStore':"
    echo "   renómbralo en developer.apple.com (Edit → nombre) y vuelve a descargarlo,"
    echo "   o actualiza PROVISIONING_PROFILE_SPECIFIER en project.pbxproj."
  fi

  DEST="$HOME/Library/MobileDevice/Provisioning Profiles"
  mkdir -p "$DEST"
  cp "$PERFIL" "$DEST/$P_UUID.mobileprovision"
  rm -f "$TMP_PLIST"
  echo
  echo "✅ Instalado en $DEST/$P_UUID.mobileprovision"
  echo "   Siguiente:  cd $PWD && flutter build ipa --release --export-options-plist=ios/ExportOptions.plist"
  echo "   Y para GitHub:  $0 base64   (copia el bloque del .mobileprovision)"
  ;;

*)
  echo "Uso: $0 {csr|exportar|perfil|base64|equipo}"
  echo
  echo "  csr       Genera el CSR para subirlo en el portal de Apple"
  echo "  exportar  Instala el .cer, arma el .p12 y verifica la identidad"
  echo "  perfil    Instala y valida un .mobileprovision (opcional: ruta)"
  echo "  base64    Codifica cert.p12 y el .mobileprovision para GitHub"
  echo "  equipo    Muestra el Team ID"
  ;;
esac
