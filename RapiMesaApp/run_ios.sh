#!/bin/bash
# Este script soluciona el error MT1207 (iPhone 4s) al compilar en MAUI
# con Xcode 16.2+, saltándose el lanzador mlaunch y usando simctl nativo.

UDID="83BFD53D-4373-4667-8AD4-123A53ED8126"
BUNDLE_ID="com.companyname.rapimesaapp"
APP_PATH="bin/Debug/net9.0-ios/iossimulator-x64/RapiMesaApp.app"

echo "========================================="
echo "🚀 Compilando proyecto en .NET 9.0 para iOS..."
echo "========================================="
dotnet build -f net9.0-ios
if [ $? -ne 0 ]; then
    echo "❌ Error en la compilación."
    exit 1
fi

echo "========================================="
echo "📱 Instalando aplicación en el iPad Mini 6..."
echo "========================================="
xcrun simctl install $UDID $APP_PATH
if [ $? -ne 0 ]; then
    echo "❌ Error instalando la app. Asegúrate de que el simulador esté abierto."
    exit 1
fi

echo "========================================="
echo "✨ Lanzando RapiMesaApp..."
echo "========================================="
xcrun simctl launch $UDID $BUNDLE_ID

echo "✅ ¡Listo! La app se está ejecutando en tu simulador."
