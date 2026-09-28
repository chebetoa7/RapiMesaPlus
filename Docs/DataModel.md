# Modelo de Datos (Firebase Firestore)

Para soportar la estructura de la aplicación (Super Admin -> Admin Restaurante -> Mesero -> Órdenes), proponemos la siguiente estructura de colecciones en Firebase Firestore:

## Colección `Users` (Usuarios)
Almacena todos los usuarios del sistema. Utilizaremos Firebase Authentication, pero guardaremos datos adicionales y su rol aquí.

```json
{
  "uid": "abc123xyz", // El ID de Firebase Auth
  "name": "Pedro Castillo Lopez",
  "email": "pedro@email.com",
  "role": "restaurant_admin", // Roles: 'super_admin', 'restaurant_admin', 'waiter'
  "restaurantIds": ["rest_001"], // Un admin puede tener varios restaurantes, un mesero solo uno
  "phone": "+52...", // Datos extra del mesero/admin
  "createdAt": "2026-09-24T10:00:00Z"
}
```

## Colección `Restaurants` (Restaurantes)
Información de cada restaurante.

```json
{
  "id": "rest_001",
  "name": "Burger",
  "logoUrl": "https://firebase.storage.../logo.png",
  "adminId": "abc123xyz", // Referencia a Pedro
  "tableCount": 15,
  "createdAt": "2026-09-24T10:00:00Z"
}
```

## Colección `Tables` (Mesas)
Dependiendo de la necesidad, podemos tener una colección separada para mesas, o manejarlo como un array dentro del Restaurante si son simples. Colección separada es mejor para escalabilidad:

```json
{
  "id": "table_001",
  "restaurantId": "rest_001",
  "identifier": "Mesa 1 - Terraza",
  "status": "available", // 'available', 'occupied'
  "qrCodeUrl": "..." // Opcional
}
```

## Colección `Orders` (Pedidos/Tickets)
Aquí registramos lo que captura el mesero.

```json
{
  "id": "order_001",
  "restaurantId": "rest_001",
  "waiterId": "waiter_xyz", // Referencia al mesero1
  "tableId": "table_001", // Referencia a la mesa
  "status": "open", // 'open', 'completed', 'cancelled'
  "items": [
    {
      "productId": "prod_1",
      "name": "Hamburguesa Sencilla",
      "quantity": 2,
      "price": 100.00
    }
  ],
  "totalAmount": 200.00,
  "comments": "Sin cebolla una de ellas",
  "incidents": "", // Si el mesero reporta algo
  "createdAt": "2026-09-24T10:30:00Z",
  "closedAt": "2026-09-24T11:00:00Z"
}
```

## Seguridad y Permisos
- Usaremos **Custom Claims de Firebase Auth** para identificar rápidamente el `role` del usuario en el token y proteger las rutas de la API en Node.js.
- El **Super Admin** tiene acceso a todo.
- El **Admin de Restaurante (Pedro)** solo puede consultar/modificar datos donde `restaurantId` le pertenezca.
- El **Mesero** solo puede crear órdenes y ver las órdenes abiertas que él gestiona (o las de su restaurante, según reglas del negocio).
