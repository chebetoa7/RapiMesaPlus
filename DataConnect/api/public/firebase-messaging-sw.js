importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.11.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCBCve5631-3xqPOrVlJ8_iQg3VHURwOJY',
  appId: '1:474513328438:web:6fdc5c83ae0a6874a8cb97',
  messagingSenderId: '474513328438',
  projectId: 'restaurantapp-3007c',
  authDomain: 'restaurantapp-3007c.firebaseapp.com',
  storageBucket: 'restaurantapp-3007c.firebasestorage.app',
});

const messaging = firebase.messaging();

/**
 * Tipos de push que son SILENCIOSAS: llegan a la app pero NO deben mostrar
 * ninguna notificación en el sistema.
 *
 * `menu_updated` es el caso principal: cuando el administrador borra un
 * platillo del menú, la app del mesero solo tiene que recargar el catálogo.
 */
const TIPOS_SILENCIOSOS = ['menu_updated'];

function esSilencioso(payload) {
  const tipo = payload && payload.data ? payload.data.type : null;
  return TIPOS_SILENCIOSOS.indexOf(tipo) !== -1;
}

/**
 * El SDK de FCM solo reenvía el mensaje a las pestañas VISIBLES. Si la app
 * está en segundo plano (pestaña oculta, pero abierta), el mensaje se
 * quedaba en el service worker y la app no se enteraba hasta el siguiente
 * refresco.
 *
 * Este listener hace el relevo completo: reenvía a cualquier pestaña de la
 * app, visible o no, para que Flutter actualice el menú en el acto.
 */
self.addEventListener('push', function (event) {
  event.waitUntil(
    (async () => {
      let payload = null;
      try {
        payload = event.data ? event.data.json() : null;
      } catch (e) {
        payload = null;
      }
      if (!payload) return;

      const clients = await self.clients.matchAll({
        type: 'window',
        includeUncontrolled: true,
      });
      clients.forEach(function (client) {
        client.postMessage({
          isFirebaseMessaging: true,
          messageType: 'PUSH_RECEIVED',
          from: payload.from || '',
          data: payload.data || {},
          notification: payload.notification,
        });
      });
    })(),
  );
});

/**
 * Mensaje en segundo plano SIN pestaña visible.
 *
 * - Las push silenciosas no muestran nada (solo actualizan la app).
 * - Las demás muestran la notificación del sistema.
 */
messaging.onBackgroundMessage(function (payload) {
  if (esSilencioso(payload)) {
    console.log('[firebase-messaging-sw.js] Push silenciosa recibida (sin notificación):', payload.data);
    return undefined;
  }

  const notificationTitle = payload.notification?.title || 'RapiMesa';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/favicon.png',
    data: payload.data,
  };

  console.log('[firebase-messaging-sw.js] Mensaje recibido en segundo plano:', payload);
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

/**
 * Al tocar la notificación, se abre (o enfoca) la app.
 *
 * Antes no había manejador de `notificationclick`: tocar la notificación no
 * llevaba a ninguna parte.
 */
self.addEventListener('notificationclick', function (event) {
  event.notification.close();
  const data = event.notification.data || {};
  event.waitUntil(
    (async () => {
      const clients = await self.clients.matchAll({
        type: 'window',
        includeUncontrolled: true,
      });
      const mismoOrigen = clients.filter(function (c) {
        return new URL(c.url).origin === self.location.origin;
      });
      const enfocada = mismoOrigen.find(function (c) {
        return c.focused;
      });
      if (enfocada) {
        enfocada.postMessage({
          isFirebaseMessaging: true,
          messageType: 'NOTIFICATION_CLICKED',
          data: data,
        });
        return enfocada.focus();
      }
      const abierta = mismoOrigen[0];
      if (abierta) {
        abierta.postMessage({
          isFirebaseMessaging: true,
          messageType: 'NOTIFICATION_CLICKED',
          data: data,
        });
        return abierta.focus();
      }
      return self.clients.openWindow('/app/');
    })(),
  );
});
