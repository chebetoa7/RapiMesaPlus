#!/usr/bin/env bash
# ===========================================================================
# build_qa.sh — Compila la app con el conmutador QA habilitado.
# ===========================================================================
#
# Lee `keylocal.txt` (NO está en git) y pasa sus valores al build con
# --dart-define. Así la contraseña del modo QA nunca está en el código fuente
# ni en el repositorio, y solo hay un archivo que editar para cambiar la IP
# o la contraseña.
#
#   ./scripts/build_qa.sh                 → IPA de release (iOS)
#   ./scripts/build_qa.sh --web           → build web
#   ./scripts/build_qa.sh --debug         → IPA de debug (para probar rápido)
#
# Requisitos: keylocal.txt existente (cp keylocal.example.txt keylocal.txt)

set -euo pipefail

cd "$(dirname "$0")/.."

KEYFILE="keylocal.txt"
PLATAFORMA="ipa"
MODO="release"

for arg in "$@"; do
  # Un comentario pegado en la línea de comando ("./build_qa.sh --web # nota")
  # llega como argumento: se ignora en vez de romper el build.
  case "$arg" in
    \#*) continue ;;
    --web)   PLATAFORMA="web" ;;
    --debug) MODO="debug" ;;
    *) echo "⚠️  Opción desconocida, se ignora: $arg" ;;
  esac
done

if [ ! -f "$KEYFILE" ]; then
  echo "❌ Falta $KEYFILE"
  echo "   Copia la plantilla:  cp keylocal.example.txt keylocal.txt"
  exit 1
fi

# Lee CLAVE=VALOR del archivo (sin imprimir el valor de la contraseña).
leer() {
  grep -E "^$1=" "$KEYFILE" | head -1 | cut -d= -f2- | sed 's/[[:space:]]*$//'
}

QA_PASSWORD="$(leer QA_PASSWORD)"
QA_API_URL="$(leer QA_API_URL)"

if [ -z "$QA_PASSWORD" ]; then
  echo "❌ keylocal.txt no tiene QA_PASSWORD"
  exit 1
fi

if [ -z "$QA_API_URL" ]; then
  echo "❌ keylocal.txt no tiene QA_API_URL"
  exit 1
fi

echo "▶ Modo QA habilitado"
echo "   QA_API_URL  = $QA_API_URL"
echo "   QA_PASSWORD = (oculta, ${#QA_PASSWORD} caracteres)"
echo

if [ "$PLATAFORMA" = "web" ]; then
  # En web la API se sirve desde el mismo origen: API_BASE_URL=/ .
  #
  # ⚠️  ESTE BUILD CONTIENE LA CONTRASEÑA DENTRO (main.dart.js). NO SUBIRLO
  #     A PRODUCCIÓN: es un build de pruebas.
  flutter build web --"$MODO" \
    --base-href /app/ \
    --dart-define=APP_ENV=qa \
    --dart-define=API_BASE_URL=/ \
    --dart-define=QA_PASSWORD="$QA_PASSWORD" \
    --dart-define=QA_API_URL="$QA_API_URL"
else
  # En QA el dispositivo va contra la API de la LAN.
  flutter build ipa --"$MODO" \
    --dart-define=APP_ENV=qa \
    --dart-define=API_BASE_URL="$QA_API_URL" \
    --dart-define=QA_PASSWORD="$QA_PASSWORD" \
    --dart-define=QA_API_URL="$QA_API_URL"
fi

echo
echo "✅ Build QA listo. En la app: 5 toques en «v1.0.0 (Flutter)» → contraseña → QA."
if [ "$PLATAFORMA" = "web" ]; then
  echo
  echo "⚠️  Este build web lleva la contraseña dentro (main.dart.js)."
  echo "    Solo para pruebas en la red local. NO lo publiques en producción."
  echo "    Para servirlo desde tu Mac:"
  echo "      rm -rf ../DataConnect/api/public/app && cp -R build/web ../DataConnect/api/public/app"
fi
