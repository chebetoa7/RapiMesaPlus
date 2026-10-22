#!/usr/bin/env bash
# ===========================================================================
# preparar_firma.sh — Prepara localmente todo lo que el CI necesita para
#                     firmar el IPA.
#
#   1. Genera el CSR (Certificate Signing Request) para el certificado
#      "Apple Distribution".
#   2. Codifica en base64 el .p12 y el .mobileprovision para pegarlos
#      como secretos de GitHub.
#   3. Rellena ios/ExportOptions.plist con tu Team ID y el bundle id.
#
# Uso:
#   ./scripts/preparar_firma.sh csr        → genera el CSR
#   ./scripts/preparar_firma.sh base64     → codifica cert.p12 y el perfil
#   ./scripts/preparar_firma.sh exportar   → instala el .cer y exporta el .p12
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
  echo "  3. Luego: ./scripts/preparar_firma.sh exportar"
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

  echo "▶ Instalando el certificado en el llavero"
  security import "$CER" -k ~/Library/Keychains/login.keychain-db -T /usr/bin/codesign

  echo "▶ Generando el .p12 (certificado + clave privada)"
  openssl pkcs12 -export \
    -inkey "$CSR_DIR/private.key" \
    -in "$CER" \
    -out "$CSR_DIR/cert.p12" \
    -name "Apple Distribution" \
    -passout "pass:$P12_PASSWORD"

  echo "▶ Instalando el .p12 en el llavero (para poder firmar en local)"
  security import "$CSR_DIR/cert.p12" \
    -k ~/Library/Keychains/login.keychain-db \
    -T /usr/bin/codesign \
    -P "$P12_PASSWORD"

  echo
  echo "✅ Listo. Identidades de firma ahora:"
  security find-identity -v -p codesigning
  echo
  echo "  .p12 en $CSR_DIR/cert.p12"
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

exportoptions)
  TEAM="${1:-$2}"
  echo "▶ Actualizando ios/ExportOptions.plist"
  echo "   Team ID: $TEAM"
  echo "   Bundle id: $BUNDLE_ID"
  echo
  echo "Edita a mano ios/ExportOptions.plist y pon:"
  echo "  <key>teamID</key>            <string>$TEAM</string>"
  echo "  <key>method</key>            <string>app-store</string>   # TestFlight"
  echo "                                (o 'ad-hoc' para instalar directo en el iPad)"
  echo "  <key>com.rapimesa.app</key>  <string>Nombre Exacto Del Perfil</string>"
  ;;

*)
  echo "Uso: $0 {csr|exportar|base64}"
  echo
  echo "  csr       Genera el CSR para subirlo en el portal de Apple"
  echo "  exportar  Instala el .cer descargado en el llavero"
  echo "  base64    Codifica cert.p12 y el .mobileprovision para GitHub"
  ;;
esac
