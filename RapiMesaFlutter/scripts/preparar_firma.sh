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
  echo "▶ Instalando el certificado en el llavero"
  security import "$CER" -k ~/Library/Keychains/login.keychain-db
  echo
  echo "✅ Certificado instalado."
  echo "  Ahora expórtalo como .p12:"
  echo "    Abre el Llavero (Keychain Access) → busca 'Apple Distribution'"
  echo "    → clic derecho en la CLAVE PRIVADA (no en el certificado)"
  echo "    → 'Exportar…' → guárdalo como $CSR_DIR/cert.p12 con una contraseña"
  echo
  echo "  Después: ./scripts/preparar_firma.sh base64"
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
