# Generated TypeScript README
This README will guide you through the process of using the generated JavaScript SDK package for the connector `restaurante-connector`. It will also provide examples on how to use your generated SDK to call your Data Connect queries and mutations.

***NOTE:** This README is generated alongside the generated SDK. If you make changes to this file, they will be overwritten when the SDK is regenerated.*

# Table of Contents
- [**Overview**](#generated-javascript-readme)
- [**Accessing the connector**](#accessing-the-connector)
  - [*Connecting to the local Emulator*](#connecting-to-the-local-emulator)
- [**Queries**](#queries)
  - [*ListRestaurants*](#listrestaurants)
  - [*GetUserById*](#getuserbyid)
  - [*GetOrdersByWaiter*](#getordersbywaiter)
  - [*GetUsersByRestaurant*](#getusersbyrestaurant)
  - [*ListAllUsers*](#listallusers)
  - [*GetMenuByRestaurant*](#getmenubyrestaurant)
  - [*ListTablesByRestaurant*](#listtablesbyrestaurant)
  - [*GetTableById*](#gettablebyid)
  - [*ListOrdersByRestaurant*](#listordersbyrestaurant)
  - [*GetOrderById*](#getorderbyid)
  - [*GetMenuCategoryById*](#getmenucategorybyid)
  - [*GetMenuItemById*](#getmenuitembyid)
  - [*ListSubscriptionPlans*](#listsubscriptionplans)
  - [*GetSubscriptionPlanByName*](#getsubscriptionplanbyname)
  - [*GetSubscriptionPlanById*](#getsubscriptionplanbyid)
  - [*GetRestaurantsByAdmin*](#getrestaurantsbyadmin)
  - [*GetWaitersByAdmin*](#getwaitersbyadmin)
  - [*GetAdminsByAdmin*](#getadminsbyadmin)
  - [*GetPushDeviceByToken*](#getpushdevicebytoken)
  - [*ListAllPushDevices*](#listallpushdevices)
  - [*ListPushDevicesByRestaurant*](#listpushdevicesbyrestaurant)
  - [*ListPushMessagesByRestaurant*](#listpushmessagesbyrestaurant)
- [**Mutations**](#mutations)
  - [*CreateUser*](#createuser)
  - [*CreateRestaurant*](#createrestaurant)
  - [*CreateOrder*](#createorder)
  - [*UpdateOrderStatus*](#updateorderstatus)
  - [*UpdateUser*](#updateuser)
  - [*DeleteUser*](#deleteuser)
  - [*CreateMenuCategory*](#createmenucategory)
  - [*CreateMenuItem*](#createmenuitem)
  - [*CreateTable*](#createtable)
  - [*AddOrderItem*](#addorderitem)
  - [*UpdateTable*](#updatetable)
  - [*UpdateMenuCategory*](#updatemenucategory)
  - [*UpdateMenuItem*](#updatemenuitem)
  - [*DeleteTable*](#deletetable)
  - [*DeleteMenuCategory*](#deletemenucategory)
  - [*DeleteMenuItem*](#deletemenuitem)
  - [*CreateSubscriptionPlan*](#createsubscriptionplan)
  - [*UpdateSubscriptionPlan*](#updatesubscriptionplan)
  - [*DeleteSubscriptionPlan*](#deletesubscriptionplan)
  - [*RegisterPushDevice*](#registerpushdevice)
  - [*UpdatePushDevice*](#updatepushdevice)
  - [*DeactivatePushDevice*](#deactivatepushdevice)
  - [*DeletePushDevice*](#deletepushdevice)
  - [*CreatePushMessage*](#createpushmessage)

# Accessing the connector
A connector is a collection of Queries and Mutations. One SDK is generated for each connector - this SDK is generated for the connector `restaurante-connector`. You can find more information about connectors in the [Data Connect documentation](https://firebase.google.com/docs/data-connect#how-does).

You can use this generated SDK by importing from the package `@restaurante/dataconnect` as shown below. Both CommonJS and ESM imports are supported.

You can also follow the instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#set-client).

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@restaurante/dataconnect';

const dataConnect = getDataConnect(connectorConfig);
```

## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code.
You can also follow the emulator instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#instrument-clients).

```typescript
import { connectDataConnectEmulator, getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@restaurante/dataconnect';

const dataConnect = getDataConnect(connectorConfig);
connectDataConnectEmulator(dataConnect, 'localhost', 9399);
```

After it's initialized, you can call your Data Connect [queries](#queries) and [mutations](#mutations) from your generated SDK.

# Queries

There are two ways to execute a Data Connect Query using the generated Web SDK:
- Using a Query Reference function, which returns a `QueryRef`
  - The `QueryRef` can be used as an argument to `executeQuery()`, which will execute the Query and return a `QueryPromise`
- Using an action shortcut function, which returns a `QueryPromise`
  - Calling the action shortcut function will execute the Query and return a `QueryPromise`

The following is true for both the action shortcut function and the `QueryRef` function:
- The `QueryPromise` returned will resolve to the result of the Query once it has finished executing
- If the Query accepts arguments, both the action shortcut function and the `QueryRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Query
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `restaurante-connector` connector's generated functions to execute each query. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-queries).

## ListRestaurants
You can execute the `ListRestaurants` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listRestaurants(options?: ExecuteQueryOptions): QueryPromise<ListRestaurantsData, undefined>;

interface ListRestaurantsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListRestaurantsData, undefined>;
}
export const listRestaurantsRef: ListRestaurantsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listRestaurants(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListRestaurantsData, undefined>;

interface ListRestaurantsRef {
  ...
  (dc: DataConnect): QueryRef<ListRestaurantsData, undefined>;
}
export const listRestaurantsRef: ListRestaurantsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listRestaurantsRef:
```typescript
const name = listRestaurantsRef.operationName;
console.log(name);
```

### Variables
The `ListRestaurants` query has no variables.
### Return Type
Recall that executing the `ListRestaurants` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListRestaurantsData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListRestaurantsData {
  restaurants: ({
    id: UUIDString;
    name: string;
    tableCount: number;
    adminId: string;
    admin: {
      id: string;
      name: string;
    } & User_Key;
  } & Restaurant_Key)[];
}
```
### Using `ListRestaurants`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listRestaurants } from '@restaurante/dataconnect';


// Call the `listRestaurants()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listRestaurants();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listRestaurants(dataConnect);

console.log(data.restaurants);

// Or, you can use the `Promise` API.
listRestaurants().then((response) => {
  const data = response.data;
  console.log(data.restaurants);
});
```

### Using `ListRestaurants`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listRestaurantsRef } from '@restaurante/dataconnect';


// Call the `listRestaurantsRef()` function to get a reference to the query.
const ref = listRestaurantsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listRestaurantsRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.restaurants);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.restaurants);
});
```

## GetUserById
You can execute the `GetUserById` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getUserById(vars: GetUserByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetUserByIdData, GetUserByIdVariables>;

interface GetUserByIdRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUserByIdVariables): QueryRef<GetUserByIdData, GetUserByIdVariables>;
}
export const getUserByIdRef: GetUserByIdRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getUserById(dc: DataConnect, vars: GetUserByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetUserByIdData, GetUserByIdVariables>;

interface GetUserByIdRef {
  ...
  (dc: DataConnect, vars: GetUserByIdVariables): QueryRef<GetUserByIdData, GetUserByIdVariables>;
}
export const getUserByIdRef: GetUserByIdRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getUserByIdRef:
```typescript
const name = getUserByIdRef.operationName;
console.log(name);
```

### Variables
The `GetUserById` query requires an argument of type `GetUserByIdVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetUserByIdVariables {
  id: string;
}
```
### Return Type
Recall that executing the `GetUserById` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetUserByIdData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetUserByIdData {
  user?: {
    id: string;
    name: string;
    email: string;
    role: string;
    restaurantId?: string | null;
    subscriptionPlanId?: UUIDString | null;
    adminId?: string | null;
  } & User_Key;
}
```
### Using `GetUserById`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getUserById, GetUserByIdVariables } from '@restaurante/dataconnect';

// The `GetUserById` query requires an argument of type `GetUserByIdVariables`:
const getUserByIdVars: GetUserByIdVariables = {
  id: ..., 
};

// Call the `getUserById()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getUserById(getUserByIdVars);
// Variables can be defined inline as well.
const { data } = await getUserById({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getUserById(dataConnect, getUserByIdVars);

console.log(data.user);

// Or, you can use the `Promise` API.
getUserById(getUserByIdVars).then((response) => {
  const data = response.data;
  console.log(data.user);
});
```

### Using `GetUserById`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getUserByIdRef, GetUserByIdVariables } from '@restaurante/dataconnect';

// The `GetUserById` query requires an argument of type `GetUserByIdVariables`:
const getUserByIdVars: GetUserByIdVariables = {
  id: ..., 
};

// Call the `getUserByIdRef()` function to get a reference to the query.
const ref = getUserByIdRef(getUserByIdVars);
// Variables can be defined inline as well.
const ref = getUserByIdRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getUserByIdRef(dataConnect, getUserByIdVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.user);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.user);
});
```

## GetOrdersByWaiter
You can execute the `GetOrdersByWaiter` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getOrdersByWaiter(vars: GetOrdersByWaiterVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrdersByWaiterData, GetOrdersByWaiterVariables>;

interface GetOrdersByWaiterRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrdersByWaiterVariables): QueryRef<GetOrdersByWaiterData, GetOrdersByWaiterVariables>;
}
export const getOrdersByWaiterRef: GetOrdersByWaiterRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getOrdersByWaiter(dc: DataConnect, vars: GetOrdersByWaiterVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrdersByWaiterData, GetOrdersByWaiterVariables>;

interface GetOrdersByWaiterRef {
  ...
  (dc: DataConnect, vars: GetOrdersByWaiterVariables): QueryRef<GetOrdersByWaiterData, GetOrdersByWaiterVariables>;
}
export const getOrdersByWaiterRef: GetOrdersByWaiterRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getOrdersByWaiterRef:
```typescript
const name = getOrdersByWaiterRef.operationName;
console.log(name);
```

### Variables
The `GetOrdersByWaiter` query requires an argument of type `GetOrdersByWaiterVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetOrdersByWaiterVariables {
  waiterId: string;
}
```
### Return Type
Recall that executing the `GetOrdersByWaiter` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetOrdersByWaiterData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetOrdersByWaiterData {
  orders: ({
    id: UUIDString;
    status: string;
    totalAmount: number;
    createdAt: TimestampString;
    table?: {
      identifier: string;
    };
  } & Order_Key)[];
}
```
### Using `GetOrdersByWaiter`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getOrdersByWaiter, GetOrdersByWaiterVariables } from '@restaurante/dataconnect';

// The `GetOrdersByWaiter` query requires an argument of type `GetOrdersByWaiterVariables`:
const getOrdersByWaiterVars: GetOrdersByWaiterVariables = {
  waiterId: ..., 
};

// Call the `getOrdersByWaiter()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getOrdersByWaiter(getOrdersByWaiterVars);
// Variables can be defined inline as well.
const { data } = await getOrdersByWaiter({ waiterId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getOrdersByWaiter(dataConnect, getOrdersByWaiterVars);

console.log(data.orders);

// Or, you can use the `Promise` API.
getOrdersByWaiter(getOrdersByWaiterVars).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

### Using `GetOrdersByWaiter`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getOrdersByWaiterRef, GetOrdersByWaiterVariables } from '@restaurante/dataconnect';

// The `GetOrdersByWaiter` query requires an argument of type `GetOrdersByWaiterVariables`:
const getOrdersByWaiterVars: GetOrdersByWaiterVariables = {
  waiterId: ..., 
};

// Call the `getOrdersByWaiterRef()` function to get a reference to the query.
const ref = getOrdersByWaiterRef(getOrdersByWaiterVars);
// Variables can be defined inline as well.
const ref = getOrdersByWaiterRef({ waiterId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getOrdersByWaiterRef(dataConnect, getOrdersByWaiterVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.orders);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

## GetUsersByRestaurant
You can execute the `GetUsersByRestaurant` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getUsersByRestaurant(vars: GetUsersByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<GetUsersByRestaurantData, GetUsersByRestaurantVariables>;

interface GetUsersByRestaurantRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUsersByRestaurantVariables): QueryRef<GetUsersByRestaurantData, GetUsersByRestaurantVariables>;
}
export const getUsersByRestaurantRef: GetUsersByRestaurantRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getUsersByRestaurant(dc: DataConnect, vars: GetUsersByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<GetUsersByRestaurantData, GetUsersByRestaurantVariables>;

interface GetUsersByRestaurantRef {
  ...
  (dc: DataConnect, vars: GetUsersByRestaurantVariables): QueryRef<GetUsersByRestaurantData, GetUsersByRestaurantVariables>;
}
export const getUsersByRestaurantRef: GetUsersByRestaurantRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getUsersByRestaurantRef:
```typescript
const name = getUsersByRestaurantRef.operationName;
console.log(name);
```

### Variables
The `GetUsersByRestaurant` query requires an argument of type `GetUsersByRestaurantVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetUsersByRestaurantVariables {
  restaurantId: string;
}
```
### Return Type
Recall that executing the `GetUsersByRestaurant` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetUsersByRestaurantData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetUsersByRestaurantData {
  users: ({
    id: string;
    name: string;
    role: string;
    email: string;
  } & User_Key)[];
}
```
### Using `GetUsersByRestaurant`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getUsersByRestaurant, GetUsersByRestaurantVariables } from '@restaurante/dataconnect';

// The `GetUsersByRestaurant` query requires an argument of type `GetUsersByRestaurantVariables`:
const getUsersByRestaurantVars: GetUsersByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `getUsersByRestaurant()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getUsersByRestaurant(getUsersByRestaurantVars);
// Variables can be defined inline as well.
const { data } = await getUsersByRestaurant({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getUsersByRestaurant(dataConnect, getUsersByRestaurantVars);

console.log(data.users);

// Or, you can use the `Promise` API.
getUsersByRestaurant(getUsersByRestaurantVars).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

### Using `GetUsersByRestaurant`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getUsersByRestaurantRef, GetUsersByRestaurantVariables } from '@restaurante/dataconnect';

// The `GetUsersByRestaurant` query requires an argument of type `GetUsersByRestaurantVariables`:
const getUsersByRestaurantVars: GetUsersByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `getUsersByRestaurantRef()` function to get a reference to the query.
const ref = getUsersByRestaurantRef(getUsersByRestaurantVars);
// Variables can be defined inline as well.
const ref = getUsersByRestaurantRef({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getUsersByRestaurantRef(dataConnect, getUsersByRestaurantVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.users);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

## ListAllUsers
You can execute the `ListAllUsers` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listAllUsers(options?: ExecuteQueryOptions): QueryPromise<ListAllUsersData, undefined>;

interface ListAllUsersRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListAllUsersData, undefined>;
}
export const listAllUsersRef: ListAllUsersRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listAllUsers(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListAllUsersData, undefined>;

interface ListAllUsersRef {
  ...
  (dc: DataConnect): QueryRef<ListAllUsersData, undefined>;
}
export const listAllUsersRef: ListAllUsersRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listAllUsersRef:
```typescript
const name = listAllUsersRef.operationName;
console.log(name);
```

### Variables
The `ListAllUsers` query has no variables.
### Return Type
Recall that executing the `ListAllUsers` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListAllUsersData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListAllUsersData {
  users: ({
    id: string;
    name: string;
    email: string;
    role: string;
    phone?: string | null;
    restaurantId?: string | null;
  } & User_Key)[];
}
```
### Using `ListAllUsers`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listAllUsers } from '@restaurante/dataconnect';


// Call the `listAllUsers()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listAllUsers();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listAllUsers(dataConnect);

console.log(data.users);

// Or, you can use the `Promise` API.
listAllUsers().then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

### Using `ListAllUsers`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listAllUsersRef } from '@restaurante/dataconnect';


// Call the `listAllUsersRef()` function to get a reference to the query.
const ref = listAllUsersRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listAllUsersRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.users);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

## GetMenuByRestaurant
You can execute the `GetMenuByRestaurant` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getMenuByRestaurant(vars: GetMenuByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuByRestaurantData, GetMenuByRestaurantVariables>;

interface GetMenuByRestaurantRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetMenuByRestaurantVariables): QueryRef<GetMenuByRestaurantData, GetMenuByRestaurantVariables>;
}
export const getMenuByRestaurantRef: GetMenuByRestaurantRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getMenuByRestaurant(dc: DataConnect, vars: GetMenuByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuByRestaurantData, GetMenuByRestaurantVariables>;

interface GetMenuByRestaurantRef {
  ...
  (dc: DataConnect, vars: GetMenuByRestaurantVariables): QueryRef<GetMenuByRestaurantData, GetMenuByRestaurantVariables>;
}
export const getMenuByRestaurantRef: GetMenuByRestaurantRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getMenuByRestaurantRef:
```typescript
const name = getMenuByRestaurantRef.operationName;
console.log(name);
```

### Variables
The `GetMenuByRestaurant` query requires an argument of type `GetMenuByRestaurantVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetMenuByRestaurantVariables {
  restaurantId: UUIDString;
}
```
### Return Type
Recall that executing the `GetMenuByRestaurant` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetMenuByRestaurantData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetMenuByRestaurantData {
  menuCategories: ({
    id: UUIDString;
    name: string;
    iconUrl?: string | null;
    menuItems_on_category: ({
      id: UUIDString;
      name: string;
      description?: string | null;
      price: number;
      imageUrl?: string | null;
      isAvailable: boolean;
    } & MenuItem_Key)[];
  } & MenuCategory_Key)[];
}
```
### Using `GetMenuByRestaurant`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getMenuByRestaurant, GetMenuByRestaurantVariables } from '@restaurante/dataconnect';

// The `GetMenuByRestaurant` query requires an argument of type `GetMenuByRestaurantVariables`:
const getMenuByRestaurantVars: GetMenuByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `getMenuByRestaurant()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getMenuByRestaurant(getMenuByRestaurantVars);
// Variables can be defined inline as well.
const { data } = await getMenuByRestaurant({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getMenuByRestaurant(dataConnect, getMenuByRestaurantVars);

console.log(data.menuCategories);

// Or, you can use the `Promise` API.
getMenuByRestaurant(getMenuByRestaurantVars).then((response) => {
  const data = response.data;
  console.log(data.menuCategories);
});
```

### Using `GetMenuByRestaurant`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getMenuByRestaurantRef, GetMenuByRestaurantVariables } from '@restaurante/dataconnect';

// The `GetMenuByRestaurant` query requires an argument of type `GetMenuByRestaurantVariables`:
const getMenuByRestaurantVars: GetMenuByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `getMenuByRestaurantRef()` function to get a reference to the query.
const ref = getMenuByRestaurantRef(getMenuByRestaurantVars);
// Variables can be defined inline as well.
const ref = getMenuByRestaurantRef({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getMenuByRestaurantRef(dataConnect, getMenuByRestaurantVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.menuCategories);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.menuCategories);
});
```

## ListTablesByRestaurant
You can execute the `ListTablesByRestaurant` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listTablesByRestaurant(vars: ListTablesByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListTablesByRestaurantData, ListTablesByRestaurantVariables>;

interface ListTablesByRestaurantRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListTablesByRestaurantVariables): QueryRef<ListTablesByRestaurantData, ListTablesByRestaurantVariables>;
}
export const listTablesByRestaurantRef: ListTablesByRestaurantRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listTablesByRestaurant(dc: DataConnect, vars: ListTablesByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListTablesByRestaurantData, ListTablesByRestaurantVariables>;

interface ListTablesByRestaurantRef {
  ...
  (dc: DataConnect, vars: ListTablesByRestaurantVariables): QueryRef<ListTablesByRestaurantData, ListTablesByRestaurantVariables>;
}
export const listTablesByRestaurantRef: ListTablesByRestaurantRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listTablesByRestaurantRef:
```typescript
const name = listTablesByRestaurantRef.operationName;
console.log(name);
```

### Variables
The `ListTablesByRestaurant` query requires an argument of type `ListTablesByRestaurantVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListTablesByRestaurantVariables {
  restaurantId: UUIDString;
}
```
### Return Type
Recall that executing the `ListTablesByRestaurant` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListTablesByRestaurantData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListTablesByRestaurantData {
  tables: ({
    id: UUIDString;
    identifier: string;
    status: string;
  } & Table_Key)[];
}
```
### Using `ListTablesByRestaurant`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listTablesByRestaurant, ListTablesByRestaurantVariables } from '@restaurante/dataconnect';

// The `ListTablesByRestaurant` query requires an argument of type `ListTablesByRestaurantVariables`:
const listTablesByRestaurantVars: ListTablesByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `listTablesByRestaurant()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listTablesByRestaurant(listTablesByRestaurantVars);
// Variables can be defined inline as well.
const { data } = await listTablesByRestaurant({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listTablesByRestaurant(dataConnect, listTablesByRestaurantVars);

console.log(data.tables);

// Or, you can use the `Promise` API.
listTablesByRestaurant(listTablesByRestaurantVars).then((response) => {
  const data = response.data;
  console.log(data.tables);
});
```

### Using `ListTablesByRestaurant`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listTablesByRestaurantRef, ListTablesByRestaurantVariables } from '@restaurante/dataconnect';

// The `ListTablesByRestaurant` query requires an argument of type `ListTablesByRestaurantVariables`:
const listTablesByRestaurantVars: ListTablesByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `listTablesByRestaurantRef()` function to get a reference to the query.
const ref = listTablesByRestaurantRef(listTablesByRestaurantVars);
// Variables can be defined inline as well.
const ref = listTablesByRestaurantRef({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listTablesByRestaurantRef(dataConnect, listTablesByRestaurantVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.tables);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.tables);
});
```

## GetTableById
You can execute the `GetTableById` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getTableById(vars: GetTableByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetTableByIdData, GetTableByIdVariables>;

interface GetTableByIdRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetTableByIdVariables): QueryRef<GetTableByIdData, GetTableByIdVariables>;
}
export const getTableByIdRef: GetTableByIdRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getTableById(dc: DataConnect, vars: GetTableByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetTableByIdData, GetTableByIdVariables>;

interface GetTableByIdRef {
  ...
  (dc: DataConnect, vars: GetTableByIdVariables): QueryRef<GetTableByIdData, GetTableByIdVariables>;
}
export const getTableByIdRef: GetTableByIdRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getTableByIdRef:
```typescript
const name = getTableByIdRef.operationName;
console.log(name);
```

### Variables
The `GetTableById` query requires an argument of type `GetTableByIdVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetTableByIdVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetTableById` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetTableByIdData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetTableByIdData {
  table?: {
    id: UUIDString;
    restaurantId: UUIDString;
    identifier: string;
    status: string;
  } & Table_Key;
}
```
### Using `GetTableById`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getTableById, GetTableByIdVariables } from '@restaurante/dataconnect';

// The `GetTableById` query requires an argument of type `GetTableByIdVariables`:
const getTableByIdVars: GetTableByIdVariables = {
  id: ..., 
};

// Call the `getTableById()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getTableById(getTableByIdVars);
// Variables can be defined inline as well.
const { data } = await getTableById({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getTableById(dataConnect, getTableByIdVars);

console.log(data.table);

// Or, you can use the `Promise` API.
getTableById(getTableByIdVars).then((response) => {
  const data = response.data;
  console.log(data.table);
});
```

### Using `GetTableById`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getTableByIdRef, GetTableByIdVariables } from '@restaurante/dataconnect';

// The `GetTableById` query requires an argument of type `GetTableByIdVariables`:
const getTableByIdVars: GetTableByIdVariables = {
  id: ..., 
};

// Call the `getTableByIdRef()` function to get a reference to the query.
const ref = getTableByIdRef(getTableByIdVars);
// Variables can be defined inline as well.
const ref = getTableByIdRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getTableByIdRef(dataConnect, getTableByIdVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.table);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.table);
});
```

## ListOrdersByRestaurant
You can execute the `ListOrdersByRestaurant` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listOrdersByRestaurant(vars: ListOrdersByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListOrdersByRestaurantData, ListOrdersByRestaurantVariables>;

interface ListOrdersByRestaurantRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListOrdersByRestaurantVariables): QueryRef<ListOrdersByRestaurantData, ListOrdersByRestaurantVariables>;
}
export const listOrdersByRestaurantRef: ListOrdersByRestaurantRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listOrdersByRestaurant(dc: DataConnect, vars: ListOrdersByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListOrdersByRestaurantData, ListOrdersByRestaurantVariables>;

interface ListOrdersByRestaurantRef {
  ...
  (dc: DataConnect, vars: ListOrdersByRestaurantVariables): QueryRef<ListOrdersByRestaurantData, ListOrdersByRestaurantVariables>;
}
export const listOrdersByRestaurantRef: ListOrdersByRestaurantRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listOrdersByRestaurantRef:
```typescript
const name = listOrdersByRestaurantRef.operationName;
console.log(name);
```

### Variables
The `ListOrdersByRestaurant` query requires an argument of type `ListOrdersByRestaurantVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListOrdersByRestaurantVariables {
  restaurantId: UUIDString;
}
```
### Return Type
Recall that executing the `ListOrdersByRestaurant` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListOrdersByRestaurantData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListOrdersByRestaurantData {
  orders: ({
    id: UUIDString;
    tableId?: UUIDString | null;
    waiterId: string;
    orderType: string;
    customerName?: string | null;
    customerPhone?: string | null;
    status: string;
    totalAmount: number;
    createdAt: TimestampString;
    confirmedAt?: TimestampString | null;
    cookingStartedAt?: TimestampString | null;
    readyAt?: TimestampString | null;
    orderItems_on_order: ({
      id: UUIDString;
      productId: string;
      name: string;
      quantity: number;
      price: number;
      extras?: string | null;
      kitchenNotes?: string | null;
    } & OrderItem_Key)[];
  } & Order_Key)[];
}
```
### Using `ListOrdersByRestaurant`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listOrdersByRestaurant, ListOrdersByRestaurantVariables } from '@restaurante/dataconnect';

// The `ListOrdersByRestaurant` query requires an argument of type `ListOrdersByRestaurantVariables`:
const listOrdersByRestaurantVars: ListOrdersByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `listOrdersByRestaurant()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listOrdersByRestaurant(listOrdersByRestaurantVars);
// Variables can be defined inline as well.
const { data } = await listOrdersByRestaurant({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listOrdersByRestaurant(dataConnect, listOrdersByRestaurantVars);

console.log(data.orders);

// Or, you can use the `Promise` API.
listOrdersByRestaurant(listOrdersByRestaurantVars).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

### Using `ListOrdersByRestaurant`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listOrdersByRestaurantRef, ListOrdersByRestaurantVariables } from '@restaurante/dataconnect';

// The `ListOrdersByRestaurant` query requires an argument of type `ListOrdersByRestaurantVariables`:
const listOrdersByRestaurantVars: ListOrdersByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `listOrdersByRestaurantRef()` function to get a reference to the query.
const ref = listOrdersByRestaurantRef(listOrdersByRestaurantVars);
// Variables can be defined inline as well.
const ref = listOrdersByRestaurantRef({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listOrdersByRestaurantRef(dataConnect, listOrdersByRestaurantVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.orders);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

## GetOrderById
You can execute the `GetOrderById` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getOrderById(vars: GetOrderByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderByIdData, GetOrderByIdVariables>;

interface GetOrderByIdRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderByIdVariables): QueryRef<GetOrderByIdData, GetOrderByIdVariables>;
}
export const getOrderByIdRef: GetOrderByIdRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getOrderById(dc: DataConnect, vars: GetOrderByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderByIdData, GetOrderByIdVariables>;

interface GetOrderByIdRef {
  ...
  (dc: DataConnect, vars: GetOrderByIdVariables): QueryRef<GetOrderByIdData, GetOrderByIdVariables>;
}
export const getOrderByIdRef: GetOrderByIdRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getOrderByIdRef:
```typescript
const name = getOrderByIdRef.operationName;
console.log(name);
```

### Variables
The `GetOrderById` query requires an argument of type `GetOrderByIdVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetOrderByIdVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetOrderById` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetOrderByIdData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetOrderByIdData {
  order?: {
    id: UUIDString;
    tableId?: UUIDString | null;
    waiterId: string;
    orderType: string;
    customerName?: string | null;
    customerPhone?: string | null;
    status: string;
    totalAmount: number;
    comments?: string | null;
    createdAt: TimestampString;
    confirmedAt?: TimestampString | null;
    cookingStartedAt?: TimestampString | null;
    readyAt?: TimestampString | null;
    orderItems_on_order: ({
      id: UUIDString;
      productId: string;
      name: string;
      quantity: number;
      price: number;
      extras?: string | null;
      kitchenNotes?: string | null;
    } & OrderItem_Key)[];
  } & Order_Key;
}
```
### Using `GetOrderById`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getOrderById, GetOrderByIdVariables } from '@restaurante/dataconnect';

// The `GetOrderById` query requires an argument of type `GetOrderByIdVariables`:
const getOrderByIdVars: GetOrderByIdVariables = {
  id: ..., 
};

// Call the `getOrderById()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getOrderById(getOrderByIdVars);
// Variables can be defined inline as well.
const { data } = await getOrderById({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getOrderById(dataConnect, getOrderByIdVars);

console.log(data.order);

// Or, you can use the `Promise` API.
getOrderById(getOrderByIdVars).then((response) => {
  const data = response.data;
  console.log(data.order);
});
```

### Using `GetOrderById`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getOrderByIdRef, GetOrderByIdVariables } from '@restaurante/dataconnect';

// The `GetOrderById` query requires an argument of type `GetOrderByIdVariables`:
const getOrderByIdVars: GetOrderByIdVariables = {
  id: ..., 
};

// Call the `getOrderByIdRef()` function to get a reference to the query.
const ref = getOrderByIdRef(getOrderByIdVars);
// Variables can be defined inline as well.
const ref = getOrderByIdRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getOrderByIdRef(dataConnect, getOrderByIdVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.order);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.order);
});
```

## GetMenuCategoryById
You can execute the `GetMenuCategoryById` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getMenuCategoryById(vars: GetMenuCategoryByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuCategoryByIdData, GetMenuCategoryByIdVariables>;

interface GetMenuCategoryByIdRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetMenuCategoryByIdVariables): QueryRef<GetMenuCategoryByIdData, GetMenuCategoryByIdVariables>;
}
export const getMenuCategoryByIdRef: GetMenuCategoryByIdRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getMenuCategoryById(dc: DataConnect, vars: GetMenuCategoryByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuCategoryByIdData, GetMenuCategoryByIdVariables>;

interface GetMenuCategoryByIdRef {
  ...
  (dc: DataConnect, vars: GetMenuCategoryByIdVariables): QueryRef<GetMenuCategoryByIdData, GetMenuCategoryByIdVariables>;
}
export const getMenuCategoryByIdRef: GetMenuCategoryByIdRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getMenuCategoryByIdRef:
```typescript
const name = getMenuCategoryByIdRef.operationName;
console.log(name);
```

### Variables
The `GetMenuCategoryById` query requires an argument of type `GetMenuCategoryByIdVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetMenuCategoryByIdVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetMenuCategoryById` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetMenuCategoryByIdData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetMenuCategoryByIdData {
  menuCategory?: {
    id: UUIDString;
    name: string;
    iconUrl?: string | null;
    sortOrder: number;
    restaurantId: UUIDString;
  } & MenuCategory_Key;
}
```
### Using `GetMenuCategoryById`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getMenuCategoryById, GetMenuCategoryByIdVariables } from '@restaurante/dataconnect';

// The `GetMenuCategoryById` query requires an argument of type `GetMenuCategoryByIdVariables`:
const getMenuCategoryByIdVars: GetMenuCategoryByIdVariables = {
  id: ..., 
};

// Call the `getMenuCategoryById()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getMenuCategoryById(getMenuCategoryByIdVars);
// Variables can be defined inline as well.
const { data } = await getMenuCategoryById({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getMenuCategoryById(dataConnect, getMenuCategoryByIdVars);

console.log(data.menuCategory);

// Or, you can use the `Promise` API.
getMenuCategoryById(getMenuCategoryByIdVars).then((response) => {
  const data = response.data;
  console.log(data.menuCategory);
});
```

### Using `GetMenuCategoryById`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getMenuCategoryByIdRef, GetMenuCategoryByIdVariables } from '@restaurante/dataconnect';

// The `GetMenuCategoryById` query requires an argument of type `GetMenuCategoryByIdVariables`:
const getMenuCategoryByIdVars: GetMenuCategoryByIdVariables = {
  id: ..., 
};

// Call the `getMenuCategoryByIdRef()` function to get a reference to the query.
const ref = getMenuCategoryByIdRef(getMenuCategoryByIdVars);
// Variables can be defined inline as well.
const ref = getMenuCategoryByIdRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getMenuCategoryByIdRef(dataConnect, getMenuCategoryByIdVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.menuCategory);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.menuCategory);
});
```

## GetMenuItemById
You can execute the `GetMenuItemById` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getMenuItemById(vars: GetMenuItemByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuItemByIdData, GetMenuItemByIdVariables>;

interface GetMenuItemByIdRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetMenuItemByIdVariables): QueryRef<GetMenuItemByIdData, GetMenuItemByIdVariables>;
}
export const getMenuItemByIdRef: GetMenuItemByIdRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getMenuItemById(dc: DataConnect, vars: GetMenuItemByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuItemByIdData, GetMenuItemByIdVariables>;

interface GetMenuItemByIdRef {
  ...
  (dc: DataConnect, vars: GetMenuItemByIdVariables): QueryRef<GetMenuItemByIdData, GetMenuItemByIdVariables>;
}
export const getMenuItemByIdRef: GetMenuItemByIdRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getMenuItemByIdRef:
```typescript
const name = getMenuItemByIdRef.operationName;
console.log(name);
```

### Variables
The `GetMenuItemById` query requires an argument of type `GetMenuItemByIdVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetMenuItemByIdVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetMenuItemById` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetMenuItemByIdData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetMenuItemByIdData {
  menuItem?: {
    id: UUIDString;
    name: string;
    description?: string | null;
    price: number;
    imageUrl?: string | null;
    isAvailable: boolean;
    categoryId: UUIDString;
  } & MenuItem_Key;
}
```
### Using `GetMenuItemById`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getMenuItemById, GetMenuItemByIdVariables } from '@restaurante/dataconnect';

// The `GetMenuItemById` query requires an argument of type `GetMenuItemByIdVariables`:
const getMenuItemByIdVars: GetMenuItemByIdVariables = {
  id: ..., 
};

// Call the `getMenuItemById()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getMenuItemById(getMenuItemByIdVars);
// Variables can be defined inline as well.
const { data } = await getMenuItemById({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getMenuItemById(dataConnect, getMenuItemByIdVars);

console.log(data.menuItem);

// Or, you can use the `Promise` API.
getMenuItemById(getMenuItemByIdVars).then((response) => {
  const data = response.data;
  console.log(data.menuItem);
});
```

### Using `GetMenuItemById`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getMenuItemByIdRef, GetMenuItemByIdVariables } from '@restaurante/dataconnect';

// The `GetMenuItemById` query requires an argument of type `GetMenuItemByIdVariables`:
const getMenuItemByIdVars: GetMenuItemByIdVariables = {
  id: ..., 
};

// Call the `getMenuItemByIdRef()` function to get a reference to the query.
const ref = getMenuItemByIdRef(getMenuItemByIdVars);
// Variables can be defined inline as well.
const ref = getMenuItemByIdRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getMenuItemByIdRef(dataConnect, getMenuItemByIdVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.menuItem);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.menuItem);
});
```

## ListSubscriptionPlans
You can execute the `ListSubscriptionPlans` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listSubscriptionPlans(options?: ExecuteQueryOptions): QueryPromise<ListSubscriptionPlansData, undefined>;

interface ListSubscriptionPlansRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListSubscriptionPlansData, undefined>;
}
export const listSubscriptionPlansRef: ListSubscriptionPlansRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listSubscriptionPlans(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListSubscriptionPlansData, undefined>;

interface ListSubscriptionPlansRef {
  ...
  (dc: DataConnect): QueryRef<ListSubscriptionPlansData, undefined>;
}
export const listSubscriptionPlansRef: ListSubscriptionPlansRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listSubscriptionPlansRef:
```typescript
const name = listSubscriptionPlansRef.operationName;
console.log(name);
```

### Variables
The `ListSubscriptionPlans` query has no variables.
### Return Type
Recall that executing the `ListSubscriptionPlans` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListSubscriptionPlansData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListSubscriptionPlansData {
  subscriptionPlans: ({
    id: UUIDString;
    name: string;
    pricePerMonth: number;
    maxRestaurants: number;
    maxAdmins?: number | null;
    maxWaiters: number;
  } & SubscriptionPlan_Key)[];
}
```
### Using `ListSubscriptionPlans`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listSubscriptionPlans } from '@restaurante/dataconnect';


// Call the `listSubscriptionPlans()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listSubscriptionPlans();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listSubscriptionPlans(dataConnect);

console.log(data.subscriptionPlans);

// Or, you can use the `Promise` API.
listSubscriptionPlans().then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlans);
});
```

### Using `ListSubscriptionPlans`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listSubscriptionPlansRef } from '@restaurante/dataconnect';


// Call the `listSubscriptionPlansRef()` function to get a reference to the query.
const ref = listSubscriptionPlansRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listSubscriptionPlansRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.subscriptionPlans);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlans);
});
```

## GetSubscriptionPlanByName
You can execute the `GetSubscriptionPlanByName` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getSubscriptionPlanByName(vars: GetSubscriptionPlanByNameVariables, options?: ExecuteQueryOptions): QueryPromise<GetSubscriptionPlanByNameData, GetSubscriptionPlanByNameVariables>;

interface GetSubscriptionPlanByNameRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetSubscriptionPlanByNameVariables): QueryRef<GetSubscriptionPlanByNameData, GetSubscriptionPlanByNameVariables>;
}
export const getSubscriptionPlanByNameRef: GetSubscriptionPlanByNameRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getSubscriptionPlanByName(dc: DataConnect, vars: GetSubscriptionPlanByNameVariables, options?: ExecuteQueryOptions): QueryPromise<GetSubscriptionPlanByNameData, GetSubscriptionPlanByNameVariables>;

interface GetSubscriptionPlanByNameRef {
  ...
  (dc: DataConnect, vars: GetSubscriptionPlanByNameVariables): QueryRef<GetSubscriptionPlanByNameData, GetSubscriptionPlanByNameVariables>;
}
export const getSubscriptionPlanByNameRef: GetSubscriptionPlanByNameRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getSubscriptionPlanByNameRef:
```typescript
const name = getSubscriptionPlanByNameRef.operationName;
console.log(name);
```

### Variables
The `GetSubscriptionPlanByName` query requires an argument of type `GetSubscriptionPlanByNameVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetSubscriptionPlanByNameVariables {
  name: string;
}
```
### Return Type
Recall that executing the `GetSubscriptionPlanByName` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetSubscriptionPlanByNameData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetSubscriptionPlanByNameData {
  subscriptionPlans: ({
    id: UUIDString;
    name: string;
    pricePerMonth: number;
    maxRestaurants: number;
    maxAdmins?: number | null;
    maxWaiters: number;
  } & SubscriptionPlan_Key)[];
}
```
### Using `GetSubscriptionPlanByName`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getSubscriptionPlanByName, GetSubscriptionPlanByNameVariables } from '@restaurante/dataconnect';

// The `GetSubscriptionPlanByName` query requires an argument of type `GetSubscriptionPlanByNameVariables`:
const getSubscriptionPlanByNameVars: GetSubscriptionPlanByNameVariables = {
  name: ..., 
};

// Call the `getSubscriptionPlanByName()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getSubscriptionPlanByName(getSubscriptionPlanByNameVars);
// Variables can be defined inline as well.
const { data } = await getSubscriptionPlanByName({ name: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getSubscriptionPlanByName(dataConnect, getSubscriptionPlanByNameVars);

console.log(data.subscriptionPlans);

// Or, you can use the `Promise` API.
getSubscriptionPlanByName(getSubscriptionPlanByNameVars).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlans);
});
```

### Using `GetSubscriptionPlanByName`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getSubscriptionPlanByNameRef, GetSubscriptionPlanByNameVariables } from '@restaurante/dataconnect';

// The `GetSubscriptionPlanByName` query requires an argument of type `GetSubscriptionPlanByNameVariables`:
const getSubscriptionPlanByNameVars: GetSubscriptionPlanByNameVariables = {
  name: ..., 
};

// Call the `getSubscriptionPlanByNameRef()` function to get a reference to the query.
const ref = getSubscriptionPlanByNameRef(getSubscriptionPlanByNameVars);
// Variables can be defined inline as well.
const ref = getSubscriptionPlanByNameRef({ name: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getSubscriptionPlanByNameRef(dataConnect, getSubscriptionPlanByNameVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.subscriptionPlans);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlans);
});
```

## GetSubscriptionPlanById
You can execute the `GetSubscriptionPlanById` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getSubscriptionPlanById(vars: GetSubscriptionPlanByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetSubscriptionPlanByIdData, GetSubscriptionPlanByIdVariables>;

interface GetSubscriptionPlanByIdRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetSubscriptionPlanByIdVariables): QueryRef<GetSubscriptionPlanByIdData, GetSubscriptionPlanByIdVariables>;
}
export const getSubscriptionPlanByIdRef: GetSubscriptionPlanByIdRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getSubscriptionPlanById(dc: DataConnect, vars: GetSubscriptionPlanByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetSubscriptionPlanByIdData, GetSubscriptionPlanByIdVariables>;

interface GetSubscriptionPlanByIdRef {
  ...
  (dc: DataConnect, vars: GetSubscriptionPlanByIdVariables): QueryRef<GetSubscriptionPlanByIdData, GetSubscriptionPlanByIdVariables>;
}
export const getSubscriptionPlanByIdRef: GetSubscriptionPlanByIdRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getSubscriptionPlanByIdRef:
```typescript
const name = getSubscriptionPlanByIdRef.operationName;
console.log(name);
```

### Variables
The `GetSubscriptionPlanById` query requires an argument of type `GetSubscriptionPlanByIdVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetSubscriptionPlanByIdVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetSubscriptionPlanById` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetSubscriptionPlanByIdData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetSubscriptionPlanByIdData {
  subscriptionPlan?: {
    id: UUIDString;
    name: string;
    pricePerMonth: number;
    maxRestaurants: number;
    maxAdmins?: number | null;
    maxWaiters: number;
  } & SubscriptionPlan_Key;
}
```
### Using `GetSubscriptionPlanById`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getSubscriptionPlanById, GetSubscriptionPlanByIdVariables } from '@restaurante/dataconnect';

// The `GetSubscriptionPlanById` query requires an argument of type `GetSubscriptionPlanByIdVariables`:
const getSubscriptionPlanByIdVars: GetSubscriptionPlanByIdVariables = {
  id: ..., 
};

// Call the `getSubscriptionPlanById()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getSubscriptionPlanById(getSubscriptionPlanByIdVars);
// Variables can be defined inline as well.
const { data } = await getSubscriptionPlanById({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getSubscriptionPlanById(dataConnect, getSubscriptionPlanByIdVars);

console.log(data.subscriptionPlan);

// Or, you can use the `Promise` API.
getSubscriptionPlanById(getSubscriptionPlanByIdVars).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlan);
});
```

### Using `GetSubscriptionPlanById`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getSubscriptionPlanByIdRef, GetSubscriptionPlanByIdVariables } from '@restaurante/dataconnect';

// The `GetSubscriptionPlanById` query requires an argument of type `GetSubscriptionPlanByIdVariables`:
const getSubscriptionPlanByIdVars: GetSubscriptionPlanByIdVariables = {
  id: ..., 
};

// Call the `getSubscriptionPlanByIdRef()` function to get a reference to the query.
const ref = getSubscriptionPlanByIdRef(getSubscriptionPlanByIdVars);
// Variables can be defined inline as well.
const ref = getSubscriptionPlanByIdRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getSubscriptionPlanByIdRef(dataConnect, getSubscriptionPlanByIdVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.subscriptionPlan);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlan);
});
```

## GetRestaurantsByAdmin
You can execute the `GetRestaurantsByAdmin` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getRestaurantsByAdmin(vars: GetRestaurantsByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetRestaurantsByAdminData, GetRestaurantsByAdminVariables>;

interface GetRestaurantsByAdminRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetRestaurantsByAdminVariables): QueryRef<GetRestaurantsByAdminData, GetRestaurantsByAdminVariables>;
}
export const getRestaurantsByAdminRef: GetRestaurantsByAdminRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getRestaurantsByAdmin(dc: DataConnect, vars: GetRestaurantsByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetRestaurantsByAdminData, GetRestaurantsByAdminVariables>;

interface GetRestaurantsByAdminRef {
  ...
  (dc: DataConnect, vars: GetRestaurantsByAdminVariables): QueryRef<GetRestaurantsByAdminData, GetRestaurantsByAdminVariables>;
}
export const getRestaurantsByAdminRef: GetRestaurantsByAdminRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getRestaurantsByAdminRef:
```typescript
const name = getRestaurantsByAdminRef.operationName;
console.log(name);
```

### Variables
The `GetRestaurantsByAdmin` query requires an argument of type `GetRestaurantsByAdminVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetRestaurantsByAdminVariables {
  adminId: string;
}
```
### Return Type
Recall that executing the `GetRestaurantsByAdmin` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetRestaurantsByAdminData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetRestaurantsByAdminData {
  restaurants: ({
    id: UUIDString;
  } & Restaurant_Key)[];
}
```
### Using `GetRestaurantsByAdmin`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getRestaurantsByAdmin, GetRestaurantsByAdminVariables } from '@restaurante/dataconnect';

// The `GetRestaurantsByAdmin` query requires an argument of type `GetRestaurantsByAdminVariables`:
const getRestaurantsByAdminVars: GetRestaurantsByAdminVariables = {
  adminId: ..., 
};

// Call the `getRestaurantsByAdmin()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getRestaurantsByAdmin(getRestaurantsByAdminVars);
// Variables can be defined inline as well.
const { data } = await getRestaurantsByAdmin({ adminId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getRestaurantsByAdmin(dataConnect, getRestaurantsByAdminVars);

console.log(data.restaurants);

// Or, you can use the `Promise` API.
getRestaurantsByAdmin(getRestaurantsByAdminVars).then((response) => {
  const data = response.data;
  console.log(data.restaurants);
});
```

### Using `GetRestaurantsByAdmin`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getRestaurantsByAdminRef, GetRestaurantsByAdminVariables } from '@restaurante/dataconnect';

// The `GetRestaurantsByAdmin` query requires an argument of type `GetRestaurantsByAdminVariables`:
const getRestaurantsByAdminVars: GetRestaurantsByAdminVariables = {
  adminId: ..., 
};

// Call the `getRestaurantsByAdminRef()` function to get a reference to the query.
const ref = getRestaurantsByAdminRef(getRestaurantsByAdminVars);
// Variables can be defined inline as well.
const ref = getRestaurantsByAdminRef({ adminId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getRestaurantsByAdminRef(dataConnect, getRestaurantsByAdminVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.restaurants);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.restaurants);
});
```

## GetWaitersByAdmin
You can execute the `GetWaitersByAdmin` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getWaitersByAdmin(vars: GetWaitersByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetWaitersByAdminData, GetWaitersByAdminVariables>;

interface GetWaitersByAdminRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetWaitersByAdminVariables): QueryRef<GetWaitersByAdminData, GetWaitersByAdminVariables>;
}
export const getWaitersByAdminRef: GetWaitersByAdminRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getWaitersByAdmin(dc: DataConnect, vars: GetWaitersByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetWaitersByAdminData, GetWaitersByAdminVariables>;

interface GetWaitersByAdminRef {
  ...
  (dc: DataConnect, vars: GetWaitersByAdminVariables): QueryRef<GetWaitersByAdminData, GetWaitersByAdminVariables>;
}
export const getWaitersByAdminRef: GetWaitersByAdminRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getWaitersByAdminRef:
```typescript
const name = getWaitersByAdminRef.operationName;
console.log(name);
```

### Variables
The `GetWaitersByAdmin` query requires an argument of type `GetWaitersByAdminVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetWaitersByAdminVariables {
  adminId: string;
}
```
### Return Type
Recall that executing the `GetWaitersByAdmin` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetWaitersByAdminData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetWaitersByAdminData {
  users: ({
    id: string;
  } & User_Key)[];
}
```
### Using `GetWaitersByAdmin`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getWaitersByAdmin, GetWaitersByAdminVariables } from '@restaurante/dataconnect';

// The `GetWaitersByAdmin` query requires an argument of type `GetWaitersByAdminVariables`:
const getWaitersByAdminVars: GetWaitersByAdminVariables = {
  adminId: ..., 
};

// Call the `getWaitersByAdmin()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getWaitersByAdmin(getWaitersByAdminVars);
// Variables can be defined inline as well.
const { data } = await getWaitersByAdmin({ adminId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getWaitersByAdmin(dataConnect, getWaitersByAdminVars);

console.log(data.users);

// Or, you can use the `Promise` API.
getWaitersByAdmin(getWaitersByAdminVars).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

### Using `GetWaitersByAdmin`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getWaitersByAdminRef, GetWaitersByAdminVariables } from '@restaurante/dataconnect';

// The `GetWaitersByAdmin` query requires an argument of type `GetWaitersByAdminVariables`:
const getWaitersByAdminVars: GetWaitersByAdminVariables = {
  adminId: ..., 
};

// Call the `getWaitersByAdminRef()` function to get a reference to the query.
const ref = getWaitersByAdminRef(getWaitersByAdminVars);
// Variables can be defined inline as well.
const ref = getWaitersByAdminRef({ adminId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getWaitersByAdminRef(dataConnect, getWaitersByAdminVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.users);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

## GetAdminsByAdmin
You can execute the `GetAdminsByAdmin` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getAdminsByAdmin(vars: GetAdminsByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetAdminsByAdminData, GetAdminsByAdminVariables>;

interface GetAdminsByAdminRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetAdminsByAdminVariables): QueryRef<GetAdminsByAdminData, GetAdminsByAdminVariables>;
}
export const getAdminsByAdminRef: GetAdminsByAdminRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getAdminsByAdmin(dc: DataConnect, vars: GetAdminsByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetAdminsByAdminData, GetAdminsByAdminVariables>;

interface GetAdminsByAdminRef {
  ...
  (dc: DataConnect, vars: GetAdminsByAdminVariables): QueryRef<GetAdminsByAdminData, GetAdminsByAdminVariables>;
}
export const getAdminsByAdminRef: GetAdminsByAdminRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getAdminsByAdminRef:
```typescript
const name = getAdminsByAdminRef.operationName;
console.log(name);
```

### Variables
The `GetAdminsByAdmin` query requires an argument of type `GetAdminsByAdminVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetAdminsByAdminVariables {
  adminId: string;
}
```
### Return Type
Recall that executing the `GetAdminsByAdmin` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetAdminsByAdminData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetAdminsByAdminData {
  users: ({
    id: string;
  } & User_Key)[];
}
```
### Using `GetAdminsByAdmin`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getAdminsByAdmin, GetAdminsByAdminVariables } from '@restaurante/dataconnect';

// The `GetAdminsByAdmin` query requires an argument of type `GetAdminsByAdminVariables`:
const getAdminsByAdminVars: GetAdminsByAdminVariables = {
  adminId: ..., 
};

// Call the `getAdminsByAdmin()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getAdminsByAdmin(getAdminsByAdminVars);
// Variables can be defined inline as well.
const { data } = await getAdminsByAdmin({ adminId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getAdminsByAdmin(dataConnect, getAdminsByAdminVars);

console.log(data.users);

// Or, you can use the `Promise` API.
getAdminsByAdmin(getAdminsByAdminVars).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

### Using `GetAdminsByAdmin`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getAdminsByAdminRef, GetAdminsByAdminVariables } from '@restaurante/dataconnect';

// The `GetAdminsByAdmin` query requires an argument of type `GetAdminsByAdminVariables`:
const getAdminsByAdminVars: GetAdminsByAdminVariables = {
  adminId: ..., 
};

// Call the `getAdminsByAdminRef()` function to get a reference to the query.
const ref = getAdminsByAdminRef(getAdminsByAdminVars);
// Variables can be defined inline as well.
const ref = getAdminsByAdminRef({ adminId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getAdminsByAdminRef(dataConnect, getAdminsByAdminVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.users);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

## GetPushDeviceByToken
You can execute the `GetPushDeviceByToken` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
getPushDeviceByToken(vars: GetPushDeviceByTokenVariables, options?: ExecuteQueryOptions): QueryPromise<GetPushDeviceByTokenData, GetPushDeviceByTokenVariables>;

interface GetPushDeviceByTokenRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetPushDeviceByTokenVariables): QueryRef<GetPushDeviceByTokenData, GetPushDeviceByTokenVariables>;
}
export const getPushDeviceByTokenRef: GetPushDeviceByTokenRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getPushDeviceByToken(dc: DataConnect, vars: GetPushDeviceByTokenVariables, options?: ExecuteQueryOptions): QueryPromise<GetPushDeviceByTokenData, GetPushDeviceByTokenVariables>;

interface GetPushDeviceByTokenRef {
  ...
  (dc: DataConnect, vars: GetPushDeviceByTokenVariables): QueryRef<GetPushDeviceByTokenData, GetPushDeviceByTokenVariables>;
}
export const getPushDeviceByTokenRef: GetPushDeviceByTokenRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getPushDeviceByTokenRef:
```typescript
const name = getPushDeviceByTokenRef.operationName;
console.log(name);
```

### Variables
The `GetPushDeviceByToken` query requires an argument of type `GetPushDeviceByTokenVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetPushDeviceByTokenVariables {
  token: string;
}
```
### Return Type
Recall that executing the `GetPushDeviceByToken` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetPushDeviceByTokenData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetPushDeviceByTokenData {
  pushDevices: ({
    id: UUIDString;
    token: string;
    userId: string;
    restaurantId?: string | null;
    role: string;
    platform: string;
    deviceLabel?: string | null;
    isActive: boolean;
    lastSeenAt: TimestampString;
    createdAt: TimestampString;
  } & PushDevice_Key)[];
}
```
### Using `GetPushDeviceByToken`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getPushDeviceByToken, GetPushDeviceByTokenVariables } from '@restaurante/dataconnect';

// The `GetPushDeviceByToken` query requires an argument of type `GetPushDeviceByTokenVariables`:
const getPushDeviceByTokenVars: GetPushDeviceByTokenVariables = {
  token: ..., 
};

// Call the `getPushDeviceByToken()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getPushDeviceByToken(getPushDeviceByTokenVars);
// Variables can be defined inline as well.
const { data } = await getPushDeviceByToken({ token: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getPushDeviceByToken(dataConnect, getPushDeviceByTokenVars);

console.log(data.pushDevices);

// Or, you can use the `Promise` API.
getPushDeviceByToken(getPushDeviceByTokenVars).then((response) => {
  const data = response.data;
  console.log(data.pushDevices);
});
```

### Using `GetPushDeviceByToken`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getPushDeviceByTokenRef, GetPushDeviceByTokenVariables } from '@restaurante/dataconnect';

// The `GetPushDeviceByToken` query requires an argument of type `GetPushDeviceByTokenVariables`:
const getPushDeviceByTokenVars: GetPushDeviceByTokenVariables = {
  token: ..., 
};

// Call the `getPushDeviceByTokenRef()` function to get a reference to the query.
const ref = getPushDeviceByTokenRef(getPushDeviceByTokenVars);
// Variables can be defined inline as well.
const ref = getPushDeviceByTokenRef({ token: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getPushDeviceByTokenRef(dataConnect, getPushDeviceByTokenVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.pushDevices);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.pushDevices);
});
```

## ListAllPushDevices
You can execute the `ListAllPushDevices` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listAllPushDevices(options?: ExecuteQueryOptions): QueryPromise<ListAllPushDevicesData, undefined>;

interface ListAllPushDevicesRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListAllPushDevicesData, undefined>;
}
export const listAllPushDevicesRef: ListAllPushDevicesRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listAllPushDevices(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListAllPushDevicesData, undefined>;

interface ListAllPushDevicesRef {
  ...
  (dc: DataConnect): QueryRef<ListAllPushDevicesData, undefined>;
}
export const listAllPushDevicesRef: ListAllPushDevicesRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listAllPushDevicesRef:
```typescript
const name = listAllPushDevicesRef.operationName;
console.log(name);
```

### Variables
The `ListAllPushDevices` query has no variables.
### Return Type
Recall that executing the `ListAllPushDevices` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListAllPushDevicesData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListAllPushDevicesData {
  pushDevices: ({
    id: UUIDString;
    token: string;
    userId: string;
    restaurantId?: string | null;
    role: string;
    platform: string;
    deviceLabel?: string | null;
    isActive: boolean;
    lastSeenAt: TimestampString;
    createdAt: TimestampString;
  } & PushDevice_Key)[];
}
```
### Using `ListAllPushDevices`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listAllPushDevices } from '@restaurante/dataconnect';


// Call the `listAllPushDevices()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listAllPushDevices();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listAllPushDevices(dataConnect);

console.log(data.pushDevices);

// Or, you can use the `Promise` API.
listAllPushDevices().then((response) => {
  const data = response.data;
  console.log(data.pushDevices);
});
```

### Using `ListAllPushDevices`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listAllPushDevicesRef } from '@restaurante/dataconnect';


// Call the `listAllPushDevicesRef()` function to get a reference to the query.
const ref = listAllPushDevicesRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listAllPushDevicesRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.pushDevices);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.pushDevices);
});
```

## ListPushDevicesByRestaurant
You can execute the `ListPushDevicesByRestaurant` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listPushDevicesByRestaurant(vars: ListPushDevicesByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListPushDevicesByRestaurantData, ListPushDevicesByRestaurantVariables>;

interface ListPushDevicesByRestaurantRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListPushDevicesByRestaurantVariables): QueryRef<ListPushDevicesByRestaurantData, ListPushDevicesByRestaurantVariables>;
}
export const listPushDevicesByRestaurantRef: ListPushDevicesByRestaurantRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listPushDevicesByRestaurant(dc: DataConnect, vars: ListPushDevicesByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListPushDevicesByRestaurantData, ListPushDevicesByRestaurantVariables>;

interface ListPushDevicesByRestaurantRef {
  ...
  (dc: DataConnect, vars: ListPushDevicesByRestaurantVariables): QueryRef<ListPushDevicesByRestaurantData, ListPushDevicesByRestaurantVariables>;
}
export const listPushDevicesByRestaurantRef: ListPushDevicesByRestaurantRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listPushDevicesByRestaurantRef:
```typescript
const name = listPushDevicesByRestaurantRef.operationName;
console.log(name);
```

### Variables
The `ListPushDevicesByRestaurant` query requires an argument of type `ListPushDevicesByRestaurantVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListPushDevicesByRestaurantVariables {
  restaurantId: string;
}
```
### Return Type
Recall that executing the `ListPushDevicesByRestaurant` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListPushDevicesByRestaurantData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListPushDevicesByRestaurantData {
  pushDevices: ({
    id: UUIDString;
    token: string;
    userId: string;
    restaurantId?: string | null;
    role: string;
    platform: string;
    deviceLabel?: string | null;
    isActive: boolean;
    lastSeenAt: TimestampString;
    createdAt: TimestampString;
  } & PushDevice_Key)[];
}
```
### Using `ListPushDevicesByRestaurant`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listPushDevicesByRestaurant, ListPushDevicesByRestaurantVariables } from '@restaurante/dataconnect';

// The `ListPushDevicesByRestaurant` query requires an argument of type `ListPushDevicesByRestaurantVariables`:
const listPushDevicesByRestaurantVars: ListPushDevicesByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `listPushDevicesByRestaurant()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listPushDevicesByRestaurant(listPushDevicesByRestaurantVars);
// Variables can be defined inline as well.
const { data } = await listPushDevicesByRestaurant({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listPushDevicesByRestaurant(dataConnect, listPushDevicesByRestaurantVars);

console.log(data.pushDevices);

// Or, you can use the `Promise` API.
listPushDevicesByRestaurant(listPushDevicesByRestaurantVars).then((response) => {
  const data = response.data;
  console.log(data.pushDevices);
});
```

### Using `ListPushDevicesByRestaurant`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listPushDevicesByRestaurantRef, ListPushDevicesByRestaurantVariables } from '@restaurante/dataconnect';

// The `ListPushDevicesByRestaurant` query requires an argument of type `ListPushDevicesByRestaurantVariables`:
const listPushDevicesByRestaurantVars: ListPushDevicesByRestaurantVariables = {
  restaurantId: ..., 
};

// Call the `listPushDevicesByRestaurantRef()` function to get a reference to the query.
const ref = listPushDevicesByRestaurantRef(listPushDevicesByRestaurantVars);
// Variables can be defined inline as well.
const ref = listPushDevicesByRestaurantRef({ restaurantId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listPushDevicesByRestaurantRef(dataConnect, listPushDevicesByRestaurantVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.pushDevices);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.pushDevices);
});
```

## ListPushMessagesByRestaurant
You can execute the `ListPushMessagesByRestaurant` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
listPushMessagesByRestaurant(vars: ListPushMessagesByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListPushMessagesByRestaurantData, ListPushMessagesByRestaurantVariables>;

interface ListPushMessagesByRestaurantRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListPushMessagesByRestaurantVariables): QueryRef<ListPushMessagesByRestaurantData, ListPushMessagesByRestaurantVariables>;
}
export const listPushMessagesByRestaurantRef: ListPushMessagesByRestaurantRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listPushMessagesByRestaurant(dc: DataConnect, vars: ListPushMessagesByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListPushMessagesByRestaurantData, ListPushMessagesByRestaurantVariables>;

interface ListPushMessagesByRestaurantRef {
  ...
  (dc: DataConnect, vars: ListPushMessagesByRestaurantVariables): QueryRef<ListPushMessagesByRestaurantData, ListPushMessagesByRestaurantVariables>;
}
export const listPushMessagesByRestaurantRef: ListPushMessagesByRestaurantRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listPushMessagesByRestaurantRef:
```typescript
const name = listPushMessagesByRestaurantRef.operationName;
console.log(name);
```

### Variables
The `ListPushMessagesByRestaurant` query requires an argument of type `ListPushMessagesByRestaurantVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListPushMessagesByRestaurantVariables {
  restaurantId: string;
  limit?: number | null;
}
```
### Return Type
Recall that executing the `ListPushMessagesByRestaurant` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListPushMessagesByRestaurantData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListPushMessagesByRestaurantData {
  pushMessages: ({
    id: UUIDString;
    eventType: string;
    deliveryMode: string;
    restaurantId?: string | null;
    senderUserId?: string | null;
    senderRole?: string | null;
    audience: string;
    targetUserId?: string | null;
    topic?: string | null;
    title?: string | null;
    body?: string | null;
    payload?: string | null;
    status: string;
    targetCount: number;
    successCount: number;
    failureCount: number;
    providerMessageId?: string | null;
    createdAt: TimestampString;
  } & PushMessage_Key)[];
}
```
### Using `ListPushMessagesByRestaurant`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listPushMessagesByRestaurant, ListPushMessagesByRestaurantVariables } from '@restaurante/dataconnect';

// The `ListPushMessagesByRestaurant` query requires an argument of type `ListPushMessagesByRestaurantVariables`:
const listPushMessagesByRestaurantVars: ListPushMessagesByRestaurantVariables = {
  restaurantId: ..., 
  limit: ..., // optional
};

// Call the `listPushMessagesByRestaurant()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listPushMessagesByRestaurant(listPushMessagesByRestaurantVars);
// Variables can be defined inline as well.
const { data } = await listPushMessagesByRestaurant({ restaurantId: ..., limit: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listPushMessagesByRestaurant(dataConnect, listPushMessagesByRestaurantVars);

console.log(data.pushMessages);

// Or, you can use the `Promise` API.
listPushMessagesByRestaurant(listPushMessagesByRestaurantVars).then((response) => {
  const data = response.data;
  console.log(data.pushMessages);
});
```

### Using `ListPushMessagesByRestaurant`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listPushMessagesByRestaurantRef, ListPushMessagesByRestaurantVariables } from '@restaurante/dataconnect';

// The `ListPushMessagesByRestaurant` query requires an argument of type `ListPushMessagesByRestaurantVariables`:
const listPushMessagesByRestaurantVars: ListPushMessagesByRestaurantVariables = {
  restaurantId: ..., 
  limit: ..., // optional
};

// Call the `listPushMessagesByRestaurantRef()` function to get a reference to the query.
const ref = listPushMessagesByRestaurantRef(listPushMessagesByRestaurantVars);
// Variables can be defined inline as well.
const ref = listPushMessagesByRestaurantRef({ restaurantId: ..., limit: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listPushMessagesByRestaurantRef(dataConnect, listPushMessagesByRestaurantVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.pushMessages);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.pushMessages);
});
```

# Mutations

There are two ways to execute a Data Connect Mutation using the generated Web SDK:
- Using a Mutation Reference function, which returns a `MutationRef`
  - The `MutationRef` can be used as an argument to `executeMutation()`, which will execute the Mutation and return a `MutationPromise`
- Using an action shortcut function, which returns a `MutationPromise`
  - Calling the action shortcut function will execute the Mutation and return a `MutationPromise`

The following is true for both the action shortcut function and the `MutationRef` function:
- The `MutationPromise` returned will resolve to the result of the Mutation once it has finished executing
- If the Mutation accepts arguments, both the action shortcut function and the `MutationRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Mutation
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `restaurante-connector` connector's generated functions to execute each mutation. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-mutations).

## CreateUser
You can execute the `CreateUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
createUser(vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface CreateUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
}
export const createUserRef: CreateUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createUser(dc: DataConnect, vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface CreateUserRef {
  ...
  (dc: DataConnect, vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
}
export const createUserRef: CreateUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createUserRef:
```typescript
const name = createUserRef.operationName;
console.log(name);
```

### Variables
The `CreateUser` mutation requires an argument of type `CreateUserVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateUserVariables {
  id: string;
  name: string;
  email: string;
  role: string;
  phone?: string | null;
  restaurantId?: string | null;
  subscriptionPlanId?: UUIDString | null;
  adminId?: string | null;
}
```
### Return Type
Recall that executing the `CreateUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateUserData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateUserData {
  user_insert: User_Key;
}
```
### Using `CreateUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createUser, CreateUserVariables } from '@restaurante/dataconnect';

// The `CreateUser` mutation requires an argument of type `CreateUserVariables`:
const createUserVars: CreateUserVariables = {
  id: ..., 
  name: ..., 
  email: ..., 
  role: ..., 
  phone: ..., // optional
  restaurantId: ..., // optional
  subscriptionPlanId: ..., // optional
  adminId: ..., // optional
};

// Call the `createUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createUser(createUserVars);
// Variables can be defined inline as well.
const { data } = await createUser({ id: ..., name: ..., email: ..., role: ..., phone: ..., restaurantId: ..., subscriptionPlanId: ..., adminId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createUser(dataConnect, createUserVars);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
createUser(createUserVars).then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

### Using `CreateUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createUserRef, CreateUserVariables } from '@restaurante/dataconnect';

// The `CreateUser` mutation requires an argument of type `CreateUserVariables`:
const createUserVars: CreateUserVariables = {
  id: ..., 
  name: ..., 
  email: ..., 
  role: ..., 
  phone: ..., // optional
  restaurantId: ..., // optional
  subscriptionPlanId: ..., // optional
  adminId: ..., // optional
};

// Call the `createUserRef()` function to get a reference to the mutation.
const ref = createUserRef(createUserVars);
// Variables can be defined inline as well.
const ref = createUserRef({ id: ..., name: ..., email: ..., role: ..., phone: ..., restaurantId: ..., subscriptionPlanId: ..., adminId: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createUserRef(dataConnect, createUserVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

## CreateRestaurant
You can execute the `CreateRestaurant` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
createRestaurant(vars: CreateRestaurantVariables): MutationPromise<CreateRestaurantData, CreateRestaurantVariables>;

interface CreateRestaurantRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateRestaurantVariables): MutationRef<CreateRestaurantData, CreateRestaurantVariables>;
}
export const createRestaurantRef: CreateRestaurantRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createRestaurant(dc: DataConnect, vars: CreateRestaurantVariables): MutationPromise<CreateRestaurantData, CreateRestaurantVariables>;

interface CreateRestaurantRef {
  ...
  (dc: DataConnect, vars: CreateRestaurantVariables): MutationRef<CreateRestaurantData, CreateRestaurantVariables>;
}
export const createRestaurantRef: CreateRestaurantRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createRestaurantRef:
```typescript
const name = createRestaurantRef.operationName;
console.log(name);
```

### Variables
The `CreateRestaurant` mutation requires an argument of type `CreateRestaurantVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateRestaurantVariables {
  name: string;
  tableCount: number;
  adminId: string;
}
```
### Return Type
Recall that executing the `CreateRestaurant` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateRestaurantData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateRestaurantData {
  restaurant_insert: Restaurant_Key;
}
```
### Using `CreateRestaurant`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createRestaurant, CreateRestaurantVariables } from '@restaurante/dataconnect';

// The `CreateRestaurant` mutation requires an argument of type `CreateRestaurantVariables`:
const createRestaurantVars: CreateRestaurantVariables = {
  name: ..., 
  tableCount: ..., 
  adminId: ..., 
};

// Call the `createRestaurant()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createRestaurant(createRestaurantVars);
// Variables can be defined inline as well.
const { data } = await createRestaurant({ name: ..., tableCount: ..., adminId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createRestaurant(dataConnect, createRestaurantVars);

console.log(data.restaurant_insert);

// Or, you can use the `Promise` API.
createRestaurant(createRestaurantVars).then((response) => {
  const data = response.data;
  console.log(data.restaurant_insert);
});
```

### Using `CreateRestaurant`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createRestaurantRef, CreateRestaurantVariables } from '@restaurante/dataconnect';

// The `CreateRestaurant` mutation requires an argument of type `CreateRestaurantVariables`:
const createRestaurantVars: CreateRestaurantVariables = {
  name: ..., 
  tableCount: ..., 
  adminId: ..., 
};

// Call the `createRestaurantRef()` function to get a reference to the mutation.
const ref = createRestaurantRef(createRestaurantVars);
// Variables can be defined inline as well.
const ref = createRestaurantRef({ name: ..., tableCount: ..., adminId: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createRestaurantRef(dataConnect, createRestaurantVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.restaurant_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.restaurant_insert);
});
```

## CreateOrder
You can execute the `CreateOrder` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
createOrder(vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface CreateOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
}
export const createOrderRef: CreateOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createOrder(dc: DataConnect, vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface CreateOrderRef {
  ...
  (dc: DataConnect, vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
}
export const createOrderRef: CreateOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createOrderRef:
```typescript
const name = createOrderRef.operationName;
console.log(name);
```

### Variables
The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateOrderVariables {
  restaurantId: UUIDString;
  waiterId: string;
  tableId?: UUIDString | null;
  orderType?: string | null;
  customerName?: string | null;
  customerPhone?: string | null;
  totalAmount: number;
  comments?: string | null;
}
```
### Return Type
Recall that executing the `CreateOrder` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateOrderData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateOrderData {
  order_insert: Order_Key;
}
```
### Using `CreateOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createOrder, CreateOrderVariables } from '@restaurante/dataconnect';

// The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`:
const createOrderVars: CreateOrderVariables = {
  restaurantId: ..., 
  waiterId: ..., 
  tableId: ..., // optional
  orderType: ..., // optional
  customerName: ..., // optional
  customerPhone: ..., // optional
  totalAmount: ..., 
  comments: ..., // optional
};

// Call the `createOrder()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createOrder(createOrderVars);
// Variables can be defined inline as well.
const { data } = await createOrder({ restaurantId: ..., waiterId: ..., tableId: ..., orderType: ..., customerName: ..., customerPhone: ..., totalAmount: ..., comments: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createOrder(dataConnect, createOrderVars);

console.log(data.order_insert);

// Or, you can use the `Promise` API.
createOrder(createOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order_insert);
});
```

### Using `CreateOrder`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createOrderRef, CreateOrderVariables } from '@restaurante/dataconnect';

// The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`:
const createOrderVars: CreateOrderVariables = {
  restaurantId: ..., 
  waiterId: ..., 
  tableId: ..., // optional
  orderType: ..., // optional
  customerName: ..., // optional
  customerPhone: ..., // optional
  totalAmount: ..., 
  comments: ..., // optional
};

// Call the `createOrderRef()` function to get a reference to the mutation.
const ref = createOrderRef(createOrderVars);
// Variables can be defined inline as well.
const ref = createOrderRef({ restaurantId: ..., waiterId: ..., tableId: ..., orderType: ..., customerName: ..., customerPhone: ..., totalAmount: ..., comments: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createOrderRef(dataConnect, createOrderVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_insert);
});
```

## UpdateOrderStatus
You can execute the `UpdateOrderStatus` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
updateOrderStatus(vars: UpdateOrderStatusVariables): MutationPromise<UpdateOrderStatusData, UpdateOrderStatusVariables>;

interface UpdateOrderStatusRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateOrderStatusVariables): MutationRef<UpdateOrderStatusData, UpdateOrderStatusVariables>;
}
export const updateOrderStatusRef: UpdateOrderStatusRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateOrderStatus(dc: DataConnect, vars: UpdateOrderStatusVariables): MutationPromise<UpdateOrderStatusData, UpdateOrderStatusVariables>;

interface UpdateOrderStatusRef {
  ...
  (dc: DataConnect, vars: UpdateOrderStatusVariables): MutationRef<UpdateOrderStatusData, UpdateOrderStatusVariables>;
}
export const updateOrderStatusRef: UpdateOrderStatusRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateOrderStatusRef:
```typescript
const name = updateOrderStatusRef.operationName;
console.log(name);
```

### Variables
The `UpdateOrderStatus` mutation requires an argument of type `UpdateOrderStatusVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateOrderStatusVariables {
  id: UUIDString;
  status: string;
  confirmedAt?: TimestampString | null;
  cookingStartedAt?: TimestampString | null;
  readyAt?: TimestampString | null;
}
```
### Return Type
Recall that executing the `UpdateOrderStatus` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateOrderStatusData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateOrderStatusData {
  order_update?: Order_Key | null;
}
```
### Using `UpdateOrderStatus`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateOrderStatus, UpdateOrderStatusVariables } from '@restaurante/dataconnect';

// The `UpdateOrderStatus` mutation requires an argument of type `UpdateOrderStatusVariables`:
const updateOrderStatusVars: UpdateOrderStatusVariables = {
  id: ..., 
  status: ..., 
  confirmedAt: ..., // optional
  cookingStartedAt: ..., // optional
  readyAt: ..., // optional
};

// Call the `updateOrderStatus()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateOrderStatus(updateOrderStatusVars);
// Variables can be defined inline as well.
const { data } = await updateOrderStatus({ id: ..., status: ..., confirmedAt: ..., cookingStartedAt: ..., readyAt: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateOrderStatus(dataConnect, updateOrderStatusVars);

console.log(data.order_update);

// Or, you can use the `Promise` API.
updateOrderStatus(updateOrderStatusVars).then((response) => {
  const data = response.data;
  console.log(data.order_update);
});
```

### Using `UpdateOrderStatus`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateOrderStatusRef, UpdateOrderStatusVariables } from '@restaurante/dataconnect';

// The `UpdateOrderStatus` mutation requires an argument of type `UpdateOrderStatusVariables`:
const updateOrderStatusVars: UpdateOrderStatusVariables = {
  id: ..., 
  status: ..., 
  confirmedAt: ..., // optional
  cookingStartedAt: ..., // optional
  readyAt: ..., // optional
};

// Call the `updateOrderStatusRef()` function to get a reference to the mutation.
const ref = updateOrderStatusRef(updateOrderStatusVars);
// Variables can be defined inline as well.
const ref = updateOrderStatusRef({ id: ..., status: ..., confirmedAt: ..., cookingStartedAt: ..., readyAt: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateOrderStatusRef(dataConnect, updateOrderStatusVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_update);
});
```

## UpdateUser
You can execute the `UpdateUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
updateUser(vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface UpdateUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
}
export const updateUserRef: UpdateUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateUser(dc: DataConnect, vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface UpdateUserRef {
  ...
  (dc: DataConnect, vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
}
export const updateUserRef: UpdateUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateUserRef:
```typescript
const name = updateUserRef.operationName;
console.log(name);
```

### Variables
The `UpdateUser` mutation requires an argument of type `UpdateUserVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateUserVariables {
  id: string;
  name?: string | null;
  phone?: string | null;
  role?: string | null;
  restaurantId?: string | null;
  subscriptionPlanId?: UUIDString | null;
  adminId?: string | null;
}
```
### Return Type
Recall that executing the `UpdateUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateUserData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateUserData {
  user_update?: User_Key | null;
}
```
### Using `UpdateUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateUser, UpdateUserVariables } from '@restaurante/dataconnect';

// The `UpdateUser` mutation requires an argument of type `UpdateUserVariables`:
const updateUserVars: UpdateUserVariables = {
  id: ..., 
  name: ..., // optional
  phone: ..., // optional
  role: ..., // optional
  restaurantId: ..., // optional
  subscriptionPlanId: ..., // optional
  adminId: ..., // optional
};

// Call the `updateUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateUser(updateUserVars);
// Variables can be defined inline as well.
const { data } = await updateUser({ id: ..., name: ..., phone: ..., role: ..., restaurantId: ..., subscriptionPlanId: ..., adminId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateUser(dataConnect, updateUserVars);

console.log(data.user_update);

// Or, you can use the `Promise` API.
updateUser(updateUserVars).then((response) => {
  const data = response.data;
  console.log(data.user_update);
});
```

### Using `UpdateUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateUserRef, UpdateUserVariables } from '@restaurante/dataconnect';

// The `UpdateUser` mutation requires an argument of type `UpdateUserVariables`:
const updateUserVars: UpdateUserVariables = {
  id: ..., 
  name: ..., // optional
  phone: ..., // optional
  role: ..., // optional
  restaurantId: ..., // optional
  subscriptionPlanId: ..., // optional
  adminId: ..., // optional
};

// Call the `updateUserRef()` function to get a reference to the mutation.
const ref = updateUserRef(updateUserVars);
// Variables can be defined inline as well.
const ref = updateUserRef({ id: ..., name: ..., phone: ..., role: ..., restaurantId: ..., subscriptionPlanId: ..., adminId: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateUserRef(dataConnect, updateUserVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_update);
});
```

## DeleteUser
You can execute the `DeleteUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
deleteUser(vars: DeleteUserVariables): MutationPromise<DeleteUserData, DeleteUserVariables>;

interface DeleteUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteUserVariables): MutationRef<DeleteUserData, DeleteUserVariables>;
}
export const deleteUserRef: DeleteUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteUser(dc: DataConnect, vars: DeleteUserVariables): MutationPromise<DeleteUserData, DeleteUserVariables>;

interface DeleteUserRef {
  ...
  (dc: DataConnect, vars: DeleteUserVariables): MutationRef<DeleteUserData, DeleteUserVariables>;
}
export const deleteUserRef: DeleteUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteUserRef:
```typescript
const name = deleteUserRef.operationName;
console.log(name);
```

### Variables
The `DeleteUser` mutation requires an argument of type `DeleteUserVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteUserVariables {
  id: string;
}
```
### Return Type
Recall that executing the `DeleteUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteUserData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteUserData {
  user_delete?: User_Key | null;
}
```
### Using `DeleteUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteUser, DeleteUserVariables } from '@restaurante/dataconnect';

// The `DeleteUser` mutation requires an argument of type `DeleteUserVariables`:
const deleteUserVars: DeleteUserVariables = {
  id: ..., 
};

// Call the `deleteUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteUser(deleteUserVars);
// Variables can be defined inline as well.
const { data } = await deleteUser({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteUser(dataConnect, deleteUserVars);

console.log(data.user_delete);

// Or, you can use the `Promise` API.
deleteUser(deleteUserVars).then((response) => {
  const data = response.data;
  console.log(data.user_delete);
});
```

### Using `DeleteUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteUserRef, DeleteUserVariables } from '@restaurante/dataconnect';

// The `DeleteUser` mutation requires an argument of type `DeleteUserVariables`:
const deleteUserVars: DeleteUserVariables = {
  id: ..., 
};

// Call the `deleteUserRef()` function to get a reference to the mutation.
const ref = deleteUserRef(deleteUserVars);
// Variables can be defined inline as well.
const ref = deleteUserRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteUserRef(dataConnect, deleteUserVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_delete);
});
```

## CreateMenuCategory
You can execute the `CreateMenuCategory` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
createMenuCategory(vars: CreateMenuCategoryVariables): MutationPromise<CreateMenuCategoryData, CreateMenuCategoryVariables>;

interface CreateMenuCategoryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateMenuCategoryVariables): MutationRef<CreateMenuCategoryData, CreateMenuCategoryVariables>;
}
export const createMenuCategoryRef: CreateMenuCategoryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createMenuCategory(dc: DataConnect, vars: CreateMenuCategoryVariables): MutationPromise<CreateMenuCategoryData, CreateMenuCategoryVariables>;

interface CreateMenuCategoryRef {
  ...
  (dc: DataConnect, vars: CreateMenuCategoryVariables): MutationRef<CreateMenuCategoryData, CreateMenuCategoryVariables>;
}
export const createMenuCategoryRef: CreateMenuCategoryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createMenuCategoryRef:
```typescript
const name = createMenuCategoryRef.operationName;
console.log(name);
```

### Variables
The `CreateMenuCategory` mutation requires an argument of type `CreateMenuCategoryVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateMenuCategoryVariables {
  restaurantId: UUIDString;
  name: string;
  iconUrl?: string | null;
  sortOrder: number;
}
```
### Return Type
Recall that executing the `CreateMenuCategory` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateMenuCategoryData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateMenuCategoryData {
  menuCategory_insert: MenuCategory_Key;
}
```
### Using `CreateMenuCategory`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createMenuCategory, CreateMenuCategoryVariables } from '@restaurante/dataconnect';

// The `CreateMenuCategory` mutation requires an argument of type `CreateMenuCategoryVariables`:
const createMenuCategoryVars: CreateMenuCategoryVariables = {
  restaurantId: ..., 
  name: ..., 
  iconUrl: ..., // optional
  sortOrder: ..., 
};

// Call the `createMenuCategory()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createMenuCategory(createMenuCategoryVars);
// Variables can be defined inline as well.
const { data } = await createMenuCategory({ restaurantId: ..., name: ..., iconUrl: ..., sortOrder: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createMenuCategory(dataConnect, createMenuCategoryVars);

console.log(data.menuCategory_insert);

// Or, you can use the `Promise` API.
createMenuCategory(createMenuCategoryVars).then((response) => {
  const data = response.data;
  console.log(data.menuCategory_insert);
});
```

### Using `CreateMenuCategory`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createMenuCategoryRef, CreateMenuCategoryVariables } from '@restaurante/dataconnect';

// The `CreateMenuCategory` mutation requires an argument of type `CreateMenuCategoryVariables`:
const createMenuCategoryVars: CreateMenuCategoryVariables = {
  restaurantId: ..., 
  name: ..., 
  iconUrl: ..., // optional
  sortOrder: ..., 
};

// Call the `createMenuCategoryRef()` function to get a reference to the mutation.
const ref = createMenuCategoryRef(createMenuCategoryVars);
// Variables can be defined inline as well.
const ref = createMenuCategoryRef({ restaurantId: ..., name: ..., iconUrl: ..., sortOrder: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createMenuCategoryRef(dataConnect, createMenuCategoryVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.menuCategory_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.menuCategory_insert);
});
```

## CreateMenuItem
You can execute the `CreateMenuItem` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
createMenuItem(vars: CreateMenuItemVariables): MutationPromise<CreateMenuItemData, CreateMenuItemVariables>;

interface CreateMenuItemRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateMenuItemVariables): MutationRef<CreateMenuItemData, CreateMenuItemVariables>;
}
export const createMenuItemRef: CreateMenuItemRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createMenuItem(dc: DataConnect, vars: CreateMenuItemVariables): MutationPromise<CreateMenuItemData, CreateMenuItemVariables>;

interface CreateMenuItemRef {
  ...
  (dc: DataConnect, vars: CreateMenuItemVariables): MutationRef<CreateMenuItemData, CreateMenuItemVariables>;
}
export const createMenuItemRef: CreateMenuItemRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createMenuItemRef:
```typescript
const name = createMenuItemRef.operationName;
console.log(name);
```

### Variables
The `CreateMenuItem` mutation requires an argument of type `CreateMenuItemVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateMenuItemVariables {
  categoryId: UUIDString;
  name: string;
  description?: string | null;
  price: number;
  imageUrl?: string | null;
}
```
### Return Type
Recall that executing the `CreateMenuItem` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateMenuItemData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateMenuItemData {
  menuItem_insert: MenuItem_Key;
}
```
### Using `CreateMenuItem`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createMenuItem, CreateMenuItemVariables } from '@restaurante/dataconnect';

// The `CreateMenuItem` mutation requires an argument of type `CreateMenuItemVariables`:
const createMenuItemVars: CreateMenuItemVariables = {
  categoryId: ..., 
  name: ..., 
  description: ..., // optional
  price: ..., 
  imageUrl: ..., // optional
};

// Call the `createMenuItem()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createMenuItem(createMenuItemVars);
// Variables can be defined inline as well.
const { data } = await createMenuItem({ categoryId: ..., name: ..., description: ..., price: ..., imageUrl: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createMenuItem(dataConnect, createMenuItemVars);

console.log(data.menuItem_insert);

// Or, you can use the `Promise` API.
createMenuItem(createMenuItemVars).then((response) => {
  const data = response.data;
  console.log(data.menuItem_insert);
});
```

### Using `CreateMenuItem`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createMenuItemRef, CreateMenuItemVariables } from '@restaurante/dataconnect';

// The `CreateMenuItem` mutation requires an argument of type `CreateMenuItemVariables`:
const createMenuItemVars: CreateMenuItemVariables = {
  categoryId: ..., 
  name: ..., 
  description: ..., // optional
  price: ..., 
  imageUrl: ..., // optional
};

// Call the `createMenuItemRef()` function to get a reference to the mutation.
const ref = createMenuItemRef(createMenuItemVars);
// Variables can be defined inline as well.
const ref = createMenuItemRef({ categoryId: ..., name: ..., description: ..., price: ..., imageUrl: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createMenuItemRef(dataConnect, createMenuItemVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.menuItem_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.menuItem_insert);
});
```

## CreateTable
You can execute the `CreateTable` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
createTable(vars: CreateTableVariables): MutationPromise<CreateTableData, CreateTableVariables>;

interface CreateTableRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateTableVariables): MutationRef<CreateTableData, CreateTableVariables>;
}
export const createTableRef: CreateTableRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createTable(dc: DataConnect, vars: CreateTableVariables): MutationPromise<CreateTableData, CreateTableVariables>;

interface CreateTableRef {
  ...
  (dc: DataConnect, vars: CreateTableVariables): MutationRef<CreateTableData, CreateTableVariables>;
}
export const createTableRef: CreateTableRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createTableRef:
```typescript
const name = createTableRef.operationName;
console.log(name);
```

### Variables
The `CreateTable` mutation requires an argument of type `CreateTableVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateTableVariables {
  restaurantId: UUIDString;
  identifier: string;
}
```
### Return Type
Recall that executing the `CreateTable` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateTableData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateTableData {
  table_insert: Table_Key;
}
```
### Using `CreateTable`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createTable, CreateTableVariables } from '@restaurante/dataconnect';

// The `CreateTable` mutation requires an argument of type `CreateTableVariables`:
const createTableVars: CreateTableVariables = {
  restaurantId: ..., 
  identifier: ..., 
};

// Call the `createTable()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createTable(createTableVars);
// Variables can be defined inline as well.
const { data } = await createTable({ restaurantId: ..., identifier: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createTable(dataConnect, createTableVars);

console.log(data.table_insert);

// Or, you can use the `Promise` API.
createTable(createTableVars).then((response) => {
  const data = response.data;
  console.log(data.table_insert);
});
```

### Using `CreateTable`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createTableRef, CreateTableVariables } from '@restaurante/dataconnect';

// The `CreateTable` mutation requires an argument of type `CreateTableVariables`:
const createTableVars: CreateTableVariables = {
  restaurantId: ..., 
  identifier: ..., 
};

// Call the `createTableRef()` function to get a reference to the mutation.
const ref = createTableRef(createTableVars);
// Variables can be defined inline as well.
const ref = createTableRef({ restaurantId: ..., identifier: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createTableRef(dataConnect, createTableVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.table_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.table_insert);
});
```

## AddOrderItem
You can execute the `AddOrderItem` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
addOrderItem(vars: AddOrderItemVariables): MutationPromise<AddOrderItemData, AddOrderItemVariables>;

interface AddOrderItemRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: AddOrderItemVariables): MutationRef<AddOrderItemData, AddOrderItemVariables>;
}
export const addOrderItemRef: AddOrderItemRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
addOrderItem(dc: DataConnect, vars: AddOrderItemVariables): MutationPromise<AddOrderItemData, AddOrderItemVariables>;

interface AddOrderItemRef {
  ...
  (dc: DataConnect, vars: AddOrderItemVariables): MutationRef<AddOrderItemData, AddOrderItemVariables>;
}
export const addOrderItemRef: AddOrderItemRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the addOrderItemRef:
```typescript
const name = addOrderItemRef.operationName;
console.log(name);
```

### Variables
The `AddOrderItem` mutation requires an argument of type `AddOrderItemVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface AddOrderItemVariables {
  orderId: UUIDString;
  productId: string;
  name: string;
  quantity: number;
  price: number;
  extras?: string | null;
  kitchenNotes?: string | null;
}
```
### Return Type
Recall that executing the `AddOrderItem` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `AddOrderItemData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface AddOrderItemData {
  orderItem_insert: OrderItem_Key;
}
```
### Using `AddOrderItem`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, addOrderItem, AddOrderItemVariables } from '@restaurante/dataconnect';

// The `AddOrderItem` mutation requires an argument of type `AddOrderItemVariables`:
const addOrderItemVars: AddOrderItemVariables = {
  orderId: ..., 
  productId: ..., 
  name: ..., 
  quantity: ..., 
  price: ..., 
  extras: ..., // optional
  kitchenNotes: ..., // optional
};

// Call the `addOrderItem()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await addOrderItem(addOrderItemVars);
// Variables can be defined inline as well.
const { data } = await addOrderItem({ orderId: ..., productId: ..., name: ..., quantity: ..., price: ..., extras: ..., kitchenNotes: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await addOrderItem(dataConnect, addOrderItemVars);

console.log(data.orderItem_insert);

// Or, you can use the `Promise` API.
addOrderItem(addOrderItemVars).then((response) => {
  const data = response.data;
  console.log(data.orderItem_insert);
});
```

### Using `AddOrderItem`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, addOrderItemRef, AddOrderItemVariables } from '@restaurante/dataconnect';

// The `AddOrderItem` mutation requires an argument of type `AddOrderItemVariables`:
const addOrderItemVars: AddOrderItemVariables = {
  orderId: ..., 
  productId: ..., 
  name: ..., 
  quantity: ..., 
  price: ..., 
  extras: ..., // optional
  kitchenNotes: ..., // optional
};

// Call the `addOrderItemRef()` function to get a reference to the mutation.
const ref = addOrderItemRef(addOrderItemVars);
// Variables can be defined inline as well.
const ref = addOrderItemRef({ orderId: ..., productId: ..., name: ..., quantity: ..., price: ..., extras: ..., kitchenNotes: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = addOrderItemRef(dataConnect, addOrderItemVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.orderItem_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.orderItem_insert);
});
```

## UpdateTable
You can execute the `UpdateTable` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
updateTable(vars: UpdateTableVariables): MutationPromise<UpdateTableData, UpdateTableVariables>;

interface UpdateTableRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateTableVariables): MutationRef<UpdateTableData, UpdateTableVariables>;
}
export const updateTableRef: UpdateTableRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateTable(dc: DataConnect, vars: UpdateTableVariables): MutationPromise<UpdateTableData, UpdateTableVariables>;

interface UpdateTableRef {
  ...
  (dc: DataConnect, vars: UpdateTableVariables): MutationRef<UpdateTableData, UpdateTableVariables>;
}
export const updateTableRef: UpdateTableRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateTableRef:
```typescript
const name = updateTableRef.operationName;
console.log(name);
```

### Variables
The `UpdateTable` mutation requires an argument of type `UpdateTableVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateTableVariables {
  id: UUIDString;
  identifier?: string | null;
  status?: string | null;
}
```
### Return Type
Recall that executing the `UpdateTable` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateTableData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateTableData {
  table_update?: Table_Key | null;
}
```
### Using `UpdateTable`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateTable, UpdateTableVariables } from '@restaurante/dataconnect';

// The `UpdateTable` mutation requires an argument of type `UpdateTableVariables`:
const updateTableVars: UpdateTableVariables = {
  id: ..., 
  identifier: ..., // optional
  status: ..., // optional
};

// Call the `updateTable()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateTable(updateTableVars);
// Variables can be defined inline as well.
const { data } = await updateTable({ id: ..., identifier: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateTable(dataConnect, updateTableVars);

console.log(data.table_update);

// Or, you can use the `Promise` API.
updateTable(updateTableVars).then((response) => {
  const data = response.data;
  console.log(data.table_update);
});
```

### Using `UpdateTable`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateTableRef, UpdateTableVariables } from '@restaurante/dataconnect';

// The `UpdateTable` mutation requires an argument of type `UpdateTableVariables`:
const updateTableVars: UpdateTableVariables = {
  id: ..., 
  identifier: ..., // optional
  status: ..., // optional
};

// Call the `updateTableRef()` function to get a reference to the mutation.
const ref = updateTableRef(updateTableVars);
// Variables can be defined inline as well.
const ref = updateTableRef({ id: ..., identifier: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateTableRef(dataConnect, updateTableVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.table_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.table_update);
});
```

## UpdateMenuCategory
You can execute the `UpdateMenuCategory` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
updateMenuCategory(vars: UpdateMenuCategoryVariables): MutationPromise<UpdateMenuCategoryData, UpdateMenuCategoryVariables>;

interface UpdateMenuCategoryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateMenuCategoryVariables): MutationRef<UpdateMenuCategoryData, UpdateMenuCategoryVariables>;
}
export const updateMenuCategoryRef: UpdateMenuCategoryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateMenuCategory(dc: DataConnect, vars: UpdateMenuCategoryVariables): MutationPromise<UpdateMenuCategoryData, UpdateMenuCategoryVariables>;

interface UpdateMenuCategoryRef {
  ...
  (dc: DataConnect, vars: UpdateMenuCategoryVariables): MutationRef<UpdateMenuCategoryData, UpdateMenuCategoryVariables>;
}
export const updateMenuCategoryRef: UpdateMenuCategoryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateMenuCategoryRef:
```typescript
const name = updateMenuCategoryRef.operationName;
console.log(name);
```

### Variables
The `UpdateMenuCategory` mutation requires an argument of type `UpdateMenuCategoryVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateMenuCategoryVariables {
  id: UUIDString;
  name?: string | null;
  iconUrl?: string | null;
  sortOrder?: number | null;
}
```
### Return Type
Recall that executing the `UpdateMenuCategory` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateMenuCategoryData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateMenuCategoryData {
  menuCategory_update?: MenuCategory_Key | null;
}
```
### Using `UpdateMenuCategory`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateMenuCategory, UpdateMenuCategoryVariables } from '@restaurante/dataconnect';

// The `UpdateMenuCategory` mutation requires an argument of type `UpdateMenuCategoryVariables`:
const updateMenuCategoryVars: UpdateMenuCategoryVariables = {
  id: ..., 
  name: ..., // optional
  iconUrl: ..., // optional
  sortOrder: ..., // optional
};

// Call the `updateMenuCategory()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateMenuCategory(updateMenuCategoryVars);
// Variables can be defined inline as well.
const { data } = await updateMenuCategory({ id: ..., name: ..., iconUrl: ..., sortOrder: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateMenuCategory(dataConnect, updateMenuCategoryVars);

console.log(data.menuCategory_update);

// Or, you can use the `Promise` API.
updateMenuCategory(updateMenuCategoryVars).then((response) => {
  const data = response.data;
  console.log(data.menuCategory_update);
});
```

### Using `UpdateMenuCategory`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateMenuCategoryRef, UpdateMenuCategoryVariables } from '@restaurante/dataconnect';

// The `UpdateMenuCategory` mutation requires an argument of type `UpdateMenuCategoryVariables`:
const updateMenuCategoryVars: UpdateMenuCategoryVariables = {
  id: ..., 
  name: ..., // optional
  iconUrl: ..., // optional
  sortOrder: ..., // optional
};

// Call the `updateMenuCategoryRef()` function to get a reference to the mutation.
const ref = updateMenuCategoryRef(updateMenuCategoryVars);
// Variables can be defined inline as well.
const ref = updateMenuCategoryRef({ id: ..., name: ..., iconUrl: ..., sortOrder: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateMenuCategoryRef(dataConnect, updateMenuCategoryVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.menuCategory_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.menuCategory_update);
});
```

## UpdateMenuItem
You can execute the `UpdateMenuItem` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
updateMenuItem(vars: UpdateMenuItemVariables): MutationPromise<UpdateMenuItemData, UpdateMenuItemVariables>;

interface UpdateMenuItemRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateMenuItemVariables): MutationRef<UpdateMenuItemData, UpdateMenuItemVariables>;
}
export const updateMenuItemRef: UpdateMenuItemRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateMenuItem(dc: DataConnect, vars: UpdateMenuItemVariables): MutationPromise<UpdateMenuItemData, UpdateMenuItemVariables>;

interface UpdateMenuItemRef {
  ...
  (dc: DataConnect, vars: UpdateMenuItemVariables): MutationRef<UpdateMenuItemData, UpdateMenuItemVariables>;
}
export const updateMenuItemRef: UpdateMenuItemRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateMenuItemRef:
```typescript
const name = updateMenuItemRef.operationName;
console.log(name);
```

### Variables
The `UpdateMenuItem` mutation requires an argument of type `UpdateMenuItemVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateMenuItemVariables {
  id: UUIDString;
  name?: string | null;
  description?: string | null;
  price?: number | null;
  imageUrl?: string | null;
  isAvailable?: boolean | null;
}
```
### Return Type
Recall that executing the `UpdateMenuItem` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateMenuItemData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateMenuItemData {
  menuItem_update?: MenuItem_Key | null;
}
```
### Using `UpdateMenuItem`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateMenuItem, UpdateMenuItemVariables } from '@restaurante/dataconnect';

// The `UpdateMenuItem` mutation requires an argument of type `UpdateMenuItemVariables`:
const updateMenuItemVars: UpdateMenuItemVariables = {
  id: ..., 
  name: ..., // optional
  description: ..., // optional
  price: ..., // optional
  imageUrl: ..., // optional
  isAvailable: ..., // optional
};

// Call the `updateMenuItem()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateMenuItem(updateMenuItemVars);
// Variables can be defined inline as well.
const { data } = await updateMenuItem({ id: ..., name: ..., description: ..., price: ..., imageUrl: ..., isAvailable: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateMenuItem(dataConnect, updateMenuItemVars);

console.log(data.menuItem_update);

// Or, you can use the `Promise` API.
updateMenuItem(updateMenuItemVars).then((response) => {
  const data = response.data;
  console.log(data.menuItem_update);
});
```

### Using `UpdateMenuItem`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateMenuItemRef, UpdateMenuItemVariables } from '@restaurante/dataconnect';

// The `UpdateMenuItem` mutation requires an argument of type `UpdateMenuItemVariables`:
const updateMenuItemVars: UpdateMenuItemVariables = {
  id: ..., 
  name: ..., // optional
  description: ..., // optional
  price: ..., // optional
  imageUrl: ..., // optional
  isAvailable: ..., // optional
};

// Call the `updateMenuItemRef()` function to get a reference to the mutation.
const ref = updateMenuItemRef(updateMenuItemVars);
// Variables can be defined inline as well.
const ref = updateMenuItemRef({ id: ..., name: ..., description: ..., price: ..., imageUrl: ..., isAvailable: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateMenuItemRef(dataConnect, updateMenuItemVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.menuItem_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.menuItem_update);
});
```

## DeleteTable
You can execute the `DeleteTable` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
deleteTable(vars: DeleteTableVariables): MutationPromise<DeleteTableData, DeleteTableVariables>;

interface DeleteTableRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteTableVariables): MutationRef<DeleteTableData, DeleteTableVariables>;
}
export const deleteTableRef: DeleteTableRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteTable(dc: DataConnect, vars: DeleteTableVariables): MutationPromise<DeleteTableData, DeleteTableVariables>;

interface DeleteTableRef {
  ...
  (dc: DataConnect, vars: DeleteTableVariables): MutationRef<DeleteTableData, DeleteTableVariables>;
}
export const deleteTableRef: DeleteTableRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteTableRef:
```typescript
const name = deleteTableRef.operationName;
console.log(name);
```

### Variables
The `DeleteTable` mutation requires an argument of type `DeleteTableVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteTableVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteTable` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteTableData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteTableData {
  table_delete?: Table_Key | null;
}
```
### Using `DeleteTable`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteTable, DeleteTableVariables } from '@restaurante/dataconnect';

// The `DeleteTable` mutation requires an argument of type `DeleteTableVariables`:
const deleteTableVars: DeleteTableVariables = {
  id: ..., 
};

// Call the `deleteTable()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteTable(deleteTableVars);
// Variables can be defined inline as well.
const { data } = await deleteTable({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteTable(dataConnect, deleteTableVars);

console.log(data.table_delete);

// Or, you can use the `Promise` API.
deleteTable(deleteTableVars).then((response) => {
  const data = response.data;
  console.log(data.table_delete);
});
```

### Using `DeleteTable`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteTableRef, DeleteTableVariables } from '@restaurante/dataconnect';

// The `DeleteTable` mutation requires an argument of type `DeleteTableVariables`:
const deleteTableVars: DeleteTableVariables = {
  id: ..., 
};

// Call the `deleteTableRef()` function to get a reference to the mutation.
const ref = deleteTableRef(deleteTableVars);
// Variables can be defined inline as well.
const ref = deleteTableRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteTableRef(dataConnect, deleteTableVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.table_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.table_delete);
});
```

## DeleteMenuCategory
You can execute the `DeleteMenuCategory` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
deleteMenuCategory(vars: DeleteMenuCategoryVariables): MutationPromise<DeleteMenuCategoryData, DeleteMenuCategoryVariables>;

interface DeleteMenuCategoryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteMenuCategoryVariables): MutationRef<DeleteMenuCategoryData, DeleteMenuCategoryVariables>;
}
export const deleteMenuCategoryRef: DeleteMenuCategoryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteMenuCategory(dc: DataConnect, vars: DeleteMenuCategoryVariables): MutationPromise<DeleteMenuCategoryData, DeleteMenuCategoryVariables>;

interface DeleteMenuCategoryRef {
  ...
  (dc: DataConnect, vars: DeleteMenuCategoryVariables): MutationRef<DeleteMenuCategoryData, DeleteMenuCategoryVariables>;
}
export const deleteMenuCategoryRef: DeleteMenuCategoryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteMenuCategoryRef:
```typescript
const name = deleteMenuCategoryRef.operationName;
console.log(name);
```

### Variables
The `DeleteMenuCategory` mutation requires an argument of type `DeleteMenuCategoryVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteMenuCategoryVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteMenuCategory` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteMenuCategoryData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteMenuCategoryData {
  menuCategory_delete?: MenuCategory_Key | null;
}
```
### Using `DeleteMenuCategory`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteMenuCategory, DeleteMenuCategoryVariables } from '@restaurante/dataconnect';

// The `DeleteMenuCategory` mutation requires an argument of type `DeleteMenuCategoryVariables`:
const deleteMenuCategoryVars: DeleteMenuCategoryVariables = {
  id: ..., 
};

// Call the `deleteMenuCategory()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteMenuCategory(deleteMenuCategoryVars);
// Variables can be defined inline as well.
const { data } = await deleteMenuCategory({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteMenuCategory(dataConnect, deleteMenuCategoryVars);

console.log(data.menuCategory_delete);

// Or, you can use the `Promise` API.
deleteMenuCategory(deleteMenuCategoryVars).then((response) => {
  const data = response.data;
  console.log(data.menuCategory_delete);
});
```

### Using `DeleteMenuCategory`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteMenuCategoryRef, DeleteMenuCategoryVariables } from '@restaurante/dataconnect';

// The `DeleteMenuCategory` mutation requires an argument of type `DeleteMenuCategoryVariables`:
const deleteMenuCategoryVars: DeleteMenuCategoryVariables = {
  id: ..., 
};

// Call the `deleteMenuCategoryRef()` function to get a reference to the mutation.
const ref = deleteMenuCategoryRef(deleteMenuCategoryVars);
// Variables can be defined inline as well.
const ref = deleteMenuCategoryRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteMenuCategoryRef(dataConnect, deleteMenuCategoryVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.menuCategory_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.menuCategory_delete);
});
```

## DeleteMenuItem
You can execute the `DeleteMenuItem` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
deleteMenuItem(vars: DeleteMenuItemVariables): MutationPromise<DeleteMenuItemData, DeleteMenuItemVariables>;

interface DeleteMenuItemRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteMenuItemVariables): MutationRef<DeleteMenuItemData, DeleteMenuItemVariables>;
}
export const deleteMenuItemRef: DeleteMenuItemRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteMenuItem(dc: DataConnect, vars: DeleteMenuItemVariables): MutationPromise<DeleteMenuItemData, DeleteMenuItemVariables>;

interface DeleteMenuItemRef {
  ...
  (dc: DataConnect, vars: DeleteMenuItemVariables): MutationRef<DeleteMenuItemData, DeleteMenuItemVariables>;
}
export const deleteMenuItemRef: DeleteMenuItemRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteMenuItemRef:
```typescript
const name = deleteMenuItemRef.operationName;
console.log(name);
```

### Variables
The `DeleteMenuItem` mutation requires an argument of type `DeleteMenuItemVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteMenuItemVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteMenuItem` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteMenuItemData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteMenuItemData {
  menuItem_delete?: MenuItem_Key | null;
}
```
### Using `DeleteMenuItem`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteMenuItem, DeleteMenuItemVariables } from '@restaurante/dataconnect';

// The `DeleteMenuItem` mutation requires an argument of type `DeleteMenuItemVariables`:
const deleteMenuItemVars: DeleteMenuItemVariables = {
  id: ..., 
};

// Call the `deleteMenuItem()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteMenuItem(deleteMenuItemVars);
// Variables can be defined inline as well.
const { data } = await deleteMenuItem({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteMenuItem(dataConnect, deleteMenuItemVars);

console.log(data.menuItem_delete);

// Or, you can use the `Promise` API.
deleteMenuItem(deleteMenuItemVars).then((response) => {
  const data = response.data;
  console.log(data.menuItem_delete);
});
```

### Using `DeleteMenuItem`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteMenuItemRef, DeleteMenuItemVariables } from '@restaurante/dataconnect';

// The `DeleteMenuItem` mutation requires an argument of type `DeleteMenuItemVariables`:
const deleteMenuItemVars: DeleteMenuItemVariables = {
  id: ..., 
};

// Call the `deleteMenuItemRef()` function to get a reference to the mutation.
const ref = deleteMenuItemRef(deleteMenuItemVars);
// Variables can be defined inline as well.
const ref = deleteMenuItemRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteMenuItemRef(dataConnect, deleteMenuItemVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.menuItem_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.menuItem_delete);
});
```

## CreateSubscriptionPlan
You can execute the `CreateSubscriptionPlan` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
createSubscriptionPlan(vars: CreateSubscriptionPlanVariables): MutationPromise<CreateSubscriptionPlanData, CreateSubscriptionPlanVariables>;

interface CreateSubscriptionPlanRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateSubscriptionPlanVariables): MutationRef<CreateSubscriptionPlanData, CreateSubscriptionPlanVariables>;
}
export const createSubscriptionPlanRef: CreateSubscriptionPlanRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createSubscriptionPlan(dc: DataConnect, vars: CreateSubscriptionPlanVariables): MutationPromise<CreateSubscriptionPlanData, CreateSubscriptionPlanVariables>;

interface CreateSubscriptionPlanRef {
  ...
  (dc: DataConnect, vars: CreateSubscriptionPlanVariables): MutationRef<CreateSubscriptionPlanData, CreateSubscriptionPlanVariables>;
}
export const createSubscriptionPlanRef: CreateSubscriptionPlanRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createSubscriptionPlanRef:
```typescript
const name = createSubscriptionPlanRef.operationName;
console.log(name);
```

### Variables
The `CreateSubscriptionPlan` mutation requires an argument of type `CreateSubscriptionPlanVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateSubscriptionPlanVariables {
  name: string;
  pricePerMonth: number;
  maxRestaurants: number;
  maxAdmins: number;
  maxWaiters: number;
}
```
### Return Type
Recall that executing the `CreateSubscriptionPlan` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateSubscriptionPlanData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateSubscriptionPlanData {
  subscriptionPlan_insert: SubscriptionPlan_Key;
}
```
### Using `CreateSubscriptionPlan`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createSubscriptionPlan, CreateSubscriptionPlanVariables } from '@restaurante/dataconnect';

// The `CreateSubscriptionPlan` mutation requires an argument of type `CreateSubscriptionPlanVariables`:
const createSubscriptionPlanVars: CreateSubscriptionPlanVariables = {
  name: ..., 
  pricePerMonth: ..., 
  maxRestaurants: ..., 
  maxAdmins: ..., 
  maxWaiters: ..., 
};

// Call the `createSubscriptionPlan()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createSubscriptionPlan(createSubscriptionPlanVars);
// Variables can be defined inline as well.
const { data } = await createSubscriptionPlan({ name: ..., pricePerMonth: ..., maxRestaurants: ..., maxAdmins: ..., maxWaiters: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createSubscriptionPlan(dataConnect, createSubscriptionPlanVars);

console.log(data.subscriptionPlan_insert);

// Or, you can use the `Promise` API.
createSubscriptionPlan(createSubscriptionPlanVars).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlan_insert);
});
```

### Using `CreateSubscriptionPlan`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createSubscriptionPlanRef, CreateSubscriptionPlanVariables } from '@restaurante/dataconnect';

// The `CreateSubscriptionPlan` mutation requires an argument of type `CreateSubscriptionPlanVariables`:
const createSubscriptionPlanVars: CreateSubscriptionPlanVariables = {
  name: ..., 
  pricePerMonth: ..., 
  maxRestaurants: ..., 
  maxAdmins: ..., 
  maxWaiters: ..., 
};

// Call the `createSubscriptionPlanRef()` function to get a reference to the mutation.
const ref = createSubscriptionPlanRef(createSubscriptionPlanVars);
// Variables can be defined inline as well.
const ref = createSubscriptionPlanRef({ name: ..., pricePerMonth: ..., maxRestaurants: ..., maxAdmins: ..., maxWaiters: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createSubscriptionPlanRef(dataConnect, createSubscriptionPlanVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.subscriptionPlan_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlan_insert);
});
```

## UpdateSubscriptionPlan
You can execute the `UpdateSubscriptionPlan` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
updateSubscriptionPlan(vars: UpdateSubscriptionPlanVariables): MutationPromise<UpdateSubscriptionPlanData, UpdateSubscriptionPlanVariables>;

interface UpdateSubscriptionPlanRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateSubscriptionPlanVariables): MutationRef<UpdateSubscriptionPlanData, UpdateSubscriptionPlanVariables>;
}
export const updateSubscriptionPlanRef: UpdateSubscriptionPlanRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateSubscriptionPlan(dc: DataConnect, vars: UpdateSubscriptionPlanVariables): MutationPromise<UpdateSubscriptionPlanData, UpdateSubscriptionPlanVariables>;

interface UpdateSubscriptionPlanRef {
  ...
  (dc: DataConnect, vars: UpdateSubscriptionPlanVariables): MutationRef<UpdateSubscriptionPlanData, UpdateSubscriptionPlanVariables>;
}
export const updateSubscriptionPlanRef: UpdateSubscriptionPlanRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateSubscriptionPlanRef:
```typescript
const name = updateSubscriptionPlanRef.operationName;
console.log(name);
```

### Variables
The `UpdateSubscriptionPlan` mutation requires an argument of type `UpdateSubscriptionPlanVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateSubscriptionPlanVariables {
  id: UUIDString;
  maxAdmins?: number | null;
  maxWaiters?: number | null;
  maxRestaurants?: number | null;
  pricePerMonth?: number | null;
}
```
### Return Type
Recall that executing the `UpdateSubscriptionPlan` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateSubscriptionPlanData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateSubscriptionPlanData {
  subscriptionPlan_update?: SubscriptionPlan_Key | null;
}
```
### Using `UpdateSubscriptionPlan`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateSubscriptionPlan, UpdateSubscriptionPlanVariables } from '@restaurante/dataconnect';

// The `UpdateSubscriptionPlan` mutation requires an argument of type `UpdateSubscriptionPlanVariables`:
const updateSubscriptionPlanVars: UpdateSubscriptionPlanVariables = {
  id: ..., 
  maxAdmins: ..., // optional
  maxWaiters: ..., // optional
  maxRestaurants: ..., // optional
  pricePerMonth: ..., // optional
};

// Call the `updateSubscriptionPlan()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateSubscriptionPlan(updateSubscriptionPlanVars);
// Variables can be defined inline as well.
const { data } = await updateSubscriptionPlan({ id: ..., maxAdmins: ..., maxWaiters: ..., maxRestaurants: ..., pricePerMonth: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateSubscriptionPlan(dataConnect, updateSubscriptionPlanVars);

console.log(data.subscriptionPlan_update);

// Or, you can use the `Promise` API.
updateSubscriptionPlan(updateSubscriptionPlanVars).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlan_update);
});
```

### Using `UpdateSubscriptionPlan`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateSubscriptionPlanRef, UpdateSubscriptionPlanVariables } from '@restaurante/dataconnect';

// The `UpdateSubscriptionPlan` mutation requires an argument of type `UpdateSubscriptionPlanVariables`:
const updateSubscriptionPlanVars: UpdateSubscriptionPlanVariables = {
  id: ..., 
  maxAdmins: ..., // optional
  maxWaiters: ..., // optional
  maxRestaurants: ..., // optional
  pricePerMonth: ..., // optional
};

// Call the `updateSubscriptionPlanRef()` function to get a reference to the mutation.
const ref = updateSubscriptionPlanRef(updateSubscriptionPlanVars);
// Variables can be defined inline as well.
const ref = updateSubscriptionPlanRef({ id: ..., maxAdmins: ..., maxWaiters: ..., maxRestaurants: ..., pricePerMonth: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateSubscriptionPlanRef(dataConnect, updateSubscriptionPlanVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.subscriptionPlan_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlan_update);
});
```

## DeleteSubscriptionPlan
You can execute the `DeleteSubscriptionPlan` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
deleteSubscriptionPlan(vars: DeleteSubscriptionPlanVariables): MutationPromise<DeleteSubscriptionPlanData, DeleteSubscriptionPlanVariables>;

interface DeleteSubscriptionPlanRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteSubscriptionPlanVariables): MutationRef<DeleteSubscriptionPlanData, DeleteSubscriptionPlanVariables>;
}
export const deleteSubscriptionPlanRef: DeleteSubscriptionPlanRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteSubscriptionPlan(dc: DataConnect, vars: DeleteSubscriptionPlanVariables): MutationPromise<DeleteSubscriptionPlanData, DeleteSubscriptionPlanVariables>;

interface DeleteSubscriptionPlanRef {
  ...
  (dc: DataConnect, vars: DeleteSubscriptionPlanVariables): MutationRef<DeleteSubscriptionPlanData, DeleteSubscriptionPlanVariables>;
}
export const deleteSubscriptionPlanRef: DeleteSubscriptionPlanRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteSubscriptionPlanRef:
```typescript
const name = deleteSubscriptionPlanRef.operationName;
console.log(name);
```

### Variables
The `DeleteSubscriptionPlan` mutation requires an argument of type `DeleteSubscriptionPlanVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteSubscriptionPlanVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteSubscriptionPlan` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteSubscriptionPlanData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteSubscriptionPlanData {
  subscriptionPlan_delete?: SubscriptionPlan_Key | null;
}
```
### Using `DeleteSubscriptionPlan`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteSubscriptionPlan, DeleteSubscriptionPlanVariables } from '@restaurante/dataconnect';

// The `DeleteSubscriptionPlan` mutation requires an argument of type `DeleteSubscriptionPlanVariables`:
const deleteSubscriptionPlanVars: DeleteSubscriptionPlanVariables = {
  id: ..., 
};

// Call the `deleteSubscriptionPlan()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteSubscriptionPlan(deleteSubscriptionPlanVars);
// Variables can be defined inline as well.
const { data } = await deleteSubscriptionPlan({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteSubscriptionPlan(dataConnect, deleteSubscriptionPlanVars);

console.log(data.subscriptionPlan_delete);

// Or, you can use the `Promise` API.
deleteSubscriptionPlan(deleteSubscriptionPlanVars).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlan_delete);
});
```

### Using `DeleteSubscriptionPlan`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteSubscriptionPlanRef, DeleteSubscriptionPlanVariables } from '@restaurante/dataconnect';

// The `DeleteSubscriptionPlan` mutation requires an argument of type `DeleteSubscriptionPlanVariables`:
const deleteSubscriptionPlanVars: DeleteSubscriptionPlanVariables = {
  id: ..., 
};

// Call the `deleteSubscriptionPlanRef()` function to get a reference to the mutation.
const ref = deleteSubscriptionPlanRef(deleteSubscriptionPlanVars);
// Variables can be defined inline as well.
const ref = deleteSubscriptionPlanRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteSubscriptionPlanRef(dataConnect, deleteSubscriptionPlanVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.subscriptionPlan_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.subscriptionPlan_delete);
});
```

## RegisterPushDevice
You can execute the `RegisterPushDevice` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
registerPushDevice(vars: RegisterPushDeviceVariables): MutationPromise<RegisterPushDeviceData, RegisterPushDeviceVariables>;

interface RegisterPushDeviceRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: RegisterPushDeviceVariables): MutationRef<RegisterPushDeviceData, RegisterPushDeviceVariables>;
}
export const registerPushDeviceRef: RegisterPushDeviceRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
registerPushDevice(dc: DataConnect, vars: RegisterPushDeviceVariables): MutationPromise<RegisterPushDeviceData, RegisterPushDeviceVariables>;

interface RegisterPushDeviceRef {
  ...
  (dc: DataConnect, vars: RegisterPushDeviceVariables): MutationRef<RegisterPushDeviceData, RegisterPushDeviceVariables>;
}
export const registerPushDeviceRef: RegisterPushDeviceRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the registerPushDeviceRef:
```typescript
const name = registerPushDeviceRef.operationName;
console.log(name);
```

### Variables
The `RegisterPushDevice` mutation requires an argument of type `RegisterPushDeviceVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface RegisterPushDeviceVariables {
  id: UUIDString;
  token: string;
  userId: string;
  restaurantId?: string | null;
  role: string;
  platform: string;
  deviceLabel?: string | null;
}
```
### Return Type
Recall that executing the `RegisterPushDevice` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `RegisterPushDeviceData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface RegisterPushDeviceData {
  pushDevice_insert: PushDevice_Key;
}
```
### Using `RegisterPushDevice`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, registerPushDevice, RegisterPushDeviceVariables } from '@restaurante/dataconnect';

// The `RegisterPushDevice` mutation requires an argument of type `RegisterPushDeviceVariables`:
const registerPushDeviceVars: RegisterPushDeviceVariables = {
  id: ..., 
  token: ..., 
  userId: ..., 
  restaurantId: ..., // optional
  role: ..., 
  platform: ..., 
  deviceLabel: ..., // optional
};

// Call the `registerPushDevice()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await registerPushDevice(registerPushDeviceVars);
// Variables can be defined inline as well.
const { data } = await registerPushDevice({ id: ..., token: ..., userId: ..., restaurantId: ..., role: ..., platform: ..., deviceLabel: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await registerPushDevice(dataConnect, registerPushDeviceVars);

console.log(data.pushDevice_insert);

// Or, you can use the `Promise` API.
registerPushDevice(registerPushDeviceVars).then((response) => {
  const data = response.data;
  console.log(data.pushDevice_insert);
});
```

### Using `RegisterPushDevice`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, registerPushDeviceRef, RegisterPushDeviceVariables } from '@restaurante/dataconnect';

// The `RegisterPushDevice` mutation requires an argument of type `RegisterPushDeviceVariables`:
const registerPushDeviceVars: RegisterPushDeviceVariables = {
  id: ..., 
  token: ..., 
  userId: ..., 
  restaurantId: ..., // optional
  role: ..., 
  platform: ..., 
  deviceLabel: ..., // optional
};

// Call the `registerPushDeviceRef()` function to get a reference to the mutation.
const ref = registerPushDeviceRef(registerPushDeviceVars);
// Variables can be defined inline as well.
const ref = registerPushDeviceRef({ id: ..., token: ..., userId: ..., restaurantId: ..., role: ..., platform: ..., deviceLabel: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = registerPushDeviceRef(dataConnect, registerPushDeviceVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.pushDevice_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.pushDevice_insert);
});
```

## UpdatePushDevice
You can execute the `UpdatePushDevice` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
updatePushDevice(vars: UpdatePushDeviceVariables): MutationPromise<UpdatePushDeviceData, UpdatePushDeviceVariables>;

interface UpdatePushDeviceRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdatePushDeviceVariables): MutationRef<UpdatePushDeviceData, UpdatePushDeviceVariables>;
}
export const updatePushDeviceRef: UpdatePushDeviceRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updatePushDevice(dc: DataConnect, vars: UpdatePushDeviceVariables): MutationPromise<UpdatePushDeviceData, UpdatePushDeviceVariables>;

interface UpdatePushDeviceRef {
  ...
  (dc: DataConnect, vars: UpdatePushDeviceVariables): MutationRef<UpdatePushDeviceData, UpdatePushDeviceVariables>;
}
export const updatePushDeviceRef: UpdatePushDeviceRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updatePushDeviceRef:
```typescript
const name = updatePushDeviceRef.operationName;
console.log(name);
```

### Variables
The `UpdatePushDevice` mutation requires an argument of type `UpdatePushDeviceVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdatePushDeviceVariables {
  id: UUIDString;
  token: string;
  userId: string;
  restaurantId?: string | null;
  role: string;
  platform: string;
  deviceLabel?: string | null;
  isActive: boolean;
  lastSeenAt: TimestampString;
}
```
### Return Type
Recall that executing the `UpdatePushDevice` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdatePushDeviceData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdatePushDeviceData {
  pushDevice_update?: PushDevice_Key | null;
}
```
### Using `UpdatePushDevice`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updatePushDevice, UpdatePushDeviceVariables } from '@restaurante/dataconnect';

// The `UpdatePushDevice` mutation requires an argument of type `UpdatePushDeviceVariables`:
const updatePushDeviceVars: UpdatePushDeviceVariables = {
  id: ..., 
  token: ..., 
  userId: ..., 
  restaurantId: ..., // optional
  role: ..., 
  platform: ..., 
  deviceLabel: ..., // optional
  isActive: ..., 
  lastSeenAt: ..., 
};

// Call the `updatePushDevice()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updatePushDevice(updatePushDeviceVars);
// Variables can be defined inline as well.
const { data } = await updatePushDevice({ id: ..., token: ..., userId: ..., restaurantId: ..., role: ..., platform: ..., deviceLabel: ..., isActive: ..., lastSeenAt: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updatePushDevice(dataConnect, updatePushDeviceVars);

console.log(data.pushDevice_update);

// Or, you can use the `Promise` API.
updatePushDevice(updatePushDeviceVars).then((response) => {
  const data = response.data;
  console.log(data.pushDevice_update);
});
```

### Using `UpdatePushDevice`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updatePushDeviceRef, UpdatePushDeviceVariables } from '@restaurante/dataconnect';

// The `UpdatePushDevice` mutation requires an argument of type `UpdatePushDeviceVariables`:
const updatePushDeviceVars: UpdatePushDeviceVariables = {
  id: ..., 
  token: ..., 
  userId: ..., 
  restaurantId: ..., // optional
  role: ..., 
  platform: ..., 
  deviceLabel: ..., // optional
  isActive: ..., 
  lastSeenAt: ..., 
};

// Call the `updatePushDeviceRef()` function to get a reference to the mutation.
const ref = updatePushDeviceRef(updatePushDeviceVars);
// Variables can be defined inline as well.
const ref = updatePushDeviceRef({ id: ..., token: ..., userId: ..., restaurantId: ..., role: ..., platform: ..., deviceLabel: ..., isActive: ..., lastSeenAt: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updatePushDeviceRef(dataConnect, updatePushDeviceVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.pushDevice_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.pushDevice_update);
});
```

## DeactivatePushDevice
You can execute the `DeactivatePushDevice` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
deactivatePushDevice(vars: DeactivatePushDeviceVariables): MutationPromise<DeactivatePushDeviceData, DeactivatePushDeviceVariables>;

interface DeactivatePushDeviceRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeactivatePushDeviceVariables): MutationRef<DeactivatePushDeviceData, DeactivatePushDeviceVariables>;
}
export const deactivatePushDeviceRef: DeactivatePushDeviceRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deactivatePushDevice(dc: DataConnect, vars: DeactivatePushDeviceVariables): MutationPromise<DeactivatePushDeviceData, DeactivatePushDeviceVariables>;

interface DeactivatePushDeviceRef {
  ...
  (dc: DataConnect, vars: DeactivatePushDeviceVariables): MutationRef<DeactivatePushDeviceData, DeactivatePushDeviceVariables>;
}
export const deactivatePushDeviceRef: DeactivatePushDeviceRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deactivatePushDeviceRef:
```typescript
const name = deactivatePushDeviceRef.operationName;
console.log(name);
```

### Variables
The `DeactivatePushDevice` mutation requires an argument of type `DeactivatePushDeviceVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeactivatePushDeviceVariables {
  id: UUIDString;
  lastSeenAt: TimestampString;
}
```
### Return Type
Recall that executing the `DeactivatePushDevice` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeactivatePushDeviceData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeactivatePushDeviceData {
  pushDevice_update?: PushDevice_Key | null;
}
```
### Using `DeactivatePushDevice`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deactivatePushDevice, DeactivatePushDeviceVariables } from '@restaurante/dataconnect';

// The `DeactivatePushDevice` mutation requires an argument of type `DeactivatePushDeviceVariables`:
const deactivatePushDeviceVars: DeactivatePushDeviceVariables = {
  id: ..., 
  lastSeenAt: ..., 
};

// Call the `deactivatePushDevice()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deactivatePushDevice(deactivatePushDeviceVars);
// Variables can be defined inline as well.
const { data } = await deactivatePushDevice({ id: ..., lastSeenAt: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deactivatePushDevice(dataConnect, deactivatePushDeviceVars);

console.log(data.pushDevice_update);

// Or, you can use the `Promise` API.
deactivatePushDevice(deactivatePushDeviceVars).then((response) => {
  const data = response.data;
  console.log(data.pushDevice_update);
});
```

### Using `DeactivatePushDevice`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deactivatePushDeviceRef, DeactivatePushDeviceVariables } from '@restaurante/dataconnect';

// The `DeactivatePushDevice` mutation requires an argument of type `DeactivatePushDeviceVariables`:
const deactivatePushDeviceVars: DeactivatePushDeviceVariables = {
  id: ..., 
  lastSeenAt: ..., 
};

// Call the `deactivatePushDeviceRef()` function to get a reference to the mutation.
const ref = deactivatePushDeviceRef(deactivatePushDeviceVars);
// Variables can be defined inline as well.
const ref = deactivatePushDeviceRef({ id: ..., lastSeenAt: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deactivatePushDeviceRef(dataConnect, deactivatePushDeviceVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.pushDevice_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.pushDevice_update);
});
```

## DeletePushDevice
You can execute the `DeletePushDevice` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
deletePushDevice(vars: DeletePushDeviceVariables): MutationPromise<DeletePushDeviceData, DeletePushDeviceVariables>;

interface DeletePushDeviceRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeletePushDeviceVariables): MutationRef<DeletePushDeviceData, DeletePushDeviceVariables>;
}
export const deletePushDeviceRef: DeletePushDeviceRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deletePushDevice(dc: DataConnect, vars: DeletePushDeviceVariables): MutationPromise<DeletePushDeviceData, DeletePushDeviceVariables>;

interface DeletePushDeviceRef {
  ...
  (dc: DataConnect, vars: DeletePushDeviceVariables): MutationRef<DeletePushDeviceData, DeletePushDeviceVariables>;
}
export const deletePushDeviceRef: DeletePushDeviceRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deletePushDeviceRef:
```typescript
const name = deletePushDeviceRef.operationName;
console.log(name);
```

### Variables
The `DeletePushDevice` mutation requires an argument of type `DeletePushDeviceVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeletePushDeviceVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeletePushDevice` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeletePushDeviceData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeletePushDeviceData {
  pushDevice_delete?: PushDevice_Key | null;
}
```
### Using `DeletePushDevice`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deletePushDevice, DeletePushDeviceVariables } from '@restaurante/dataconnect';

// The `DeletePushDevice` mutation requires an argument of type `DeletePushDeviceVariables`:
const deletePushDeviceVars: DeletePushDeviceVariables = {
  id: ..., 
};

// Call the `deletePushDevice()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deletePushDevice(deletePushDeviceVars);
// Variables can be defined inline as well.
const { data } = await deletePushDevice({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deletePushDevice(dataConnect, deletePushDeviceVars);

console.log(data.pushDevice_delete);

// Or, you can use the `Promise` API.
deletePushDevice(deletePushDeviceVars).then((response) => {
  const data = response.data;
  console.log(data.pushDevice_delete);
});
```

### Using `DeletePushDevice`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deletePushDeviceRef, DeletePushDeviceVariables } from '@restaurante/dataconnect';

// The `DeletePushDevice` mutation requires an argument of type `DeletePushDeviceVariables`:
const deletePushDeviceVars: DeletePushDeviceVariables = {
  id: ..., 
};

// Call the `deletePushDeviceRef()` function to get a reference to the mutation.
const ref = deletePushDeviceRef(deletePushDeviceVars);
// Variables can be defined inline as well.
const ref = deletePushDeviceRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deletePushDeviceRef(dataConnect, deletePushDeviceVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.pushDevice_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.pushDevice_delete);
});
```

## CreatePushMessage
You can execute the `CreatePushMessage` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect/index.d.ts](./index.d.ts):
```typescript
createPushMessage(vars: CreatePushMessageVariables): MutationPromise<CreatePushMessageData, CreatePushMessageVariables>;

interface CreatePushMessageRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreatePushMessageVariables): MutationRef<CreatePushMessageData, CreatePushMessageVariables>;
}
export const createPushMessageRef: CreatePushMessageRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createPushMessage(dc: DataConnect, vars: CreatePushMessageVariables): MutationPromise<CreatePushMessageData, CreatePushMessageVariables>;

interface CreatePushMessageRef {
  ...
  (dc: DataConnect, vars: CreatePushMessageVariables): MutationRef<CreatePushMessageData, CreatePushMessageVariables>;
}
export const createPushMessageRef: CreatePushMessageRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createPushMessageRef:
```typescript
const name = createPushMessageRef.operationName;
console.log(name);
```

### Variables
The `CreatePushMessage` mutation requires an argument of type `CreatePushMessageVariables`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreatePushMessageVariables {
  id: UUIDString;
  eventType: string;
  deliveryMode: string;
  restaurantId?: string | null;
  senderUserId?: string | null;
  senderRole?: string | null;
  audience: string;
  targetUserId?: string | null;
  topic?: string | null;
  title?: string | null;
  body?: string | null;
  payload?: string | null;
  status: string;
  targetCount: number;
  successCount: number;
  failureCount: number;
  providerMessageId?: string | null;
}
```
### Return Type
Recall that executing the `CreatePushMessage` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreatePushMessageData`, which is defined in [dataconnect/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreatePushMessageData {
  pushMessage_insert: PushMessage_Key;
}
```
### Using `CreatePushMessage`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createPushMessage, CreatePushMessageVariables } from '@restaurante/dataconnect';

// The `CreatePushMessage` mutation requires an argument of type `CreatePushMessageVariables`:
const createPushMessageVars: CreatePushMessageVariables = {
  id: ..., 
  eventType: ..., 
  deliveryMode: ..., 
  restaurantId: ..., // optional
  senderUserId: ..., // optional
  senderRole: ..., // optional
  audience: ..., 
  targetUserId: ..., // optional
  topic: ..., // optional
  title: ..., // optional
  body: ..., // optional
  payload: ..., // optional
  status: ..., 
  targetCount: ..., 
  successCount: ..., 
  failureCount: ..., 
  providerMessageId: ..., // optional
};

// Call the `createPushMessage()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createPushMessage(createPushMessageVars);
// Variables can be defined inline as well.
const { data } = await createPushMessage({ id: ..., eventType: ..., deliveryMode: ..., restaurantId: ..., senderUserId: ..., senderRole: ..., audience: ..., targetUserId: ..., topic: ..., title: ..., body: ..., payload: ..., status: ..., targetCount: ..., successCount: ..., failureCount: ..., providerMessageId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createPushMessage(dataConnect, createPushMessageVars);

console.log(data.pushMessage_insert);

// Or, you can use the `Promise` API.
createPushMessage(createPushMessageVars).then((response) => {
  const data = response.data;
  console.log(data.pushMessage_insert);
});
```

### Using `CreatePushMessage`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createPushMessageRef, CreatePushMessageVariables } from '@restaurante/dataconnect';

// The `CreatePushMessage` mutation requires an argument of type `CreatePushMessageVariables`:
const createPushMessageVars: CreatePushMessageVariables = {
  id: ..., 
  eventType: ..., 
  deliveryMode: ..., 
  restaurantId: ..., // optional
  senderUserId: ..., // optional
  senderRole: ..., // optional
  audience: ..., 
  targetUserId: ..., // optional
  topic: ..., // optional
  title: ..., // optional
  body: ..., // optional
  payload: ..., // optional
  status: ..., 
  targetCount: ..., 
  successCount: ..., 
  failureCount: ..., 
  providerMessageId: ..., // optional
};

// Call the `createPushMessageRef()` function to get a reference to the mutation.
const ref = createPushMessageRef(createPushMessageVars);
// Variables can be defined inline as well.
const ref = createPushMessageRef({ id: ..., eventType: ..., deliveryMode: ..., restaurantId: ..., senderUserId: ..., senderRole: ..., audience: ..., targetUserId: ..., topic: ..., title: ..., body: ..., payload: ..., status: ..., targetCount: ..., successCount: ..., failureCount: ..., providerMessageId: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createPushMessageRef(dataConnect, createPushMessageVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.pushMessage_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.pushMessage_insert);
});
```

