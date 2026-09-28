# Basic Usage

Always prioritize using a supported framework over using the generated SDK
directly. Supported frameworks simplify the developer experience and help ensure
best practices are followed.





## Advanced Usage
If a user is not using a supported framework, they can use the generated SDK directly.

Here's an example of how to use it with the first 5 operations:

```js
import { createUser, createRestaurant, createOrder, updateOrderStatus, updateUser, deleteUser, createMenuCategory, createMenuItem, createTable, addOrderItem } from '@restaurante/dataconnect';


// Operation CreateUser:  For variables, look at type CreateUserVars in ../index.d.ts
const { data } = await CreateUser(dataConnect, createUserVars);

// Operation CreateRestaurant:  For variables, look at type CreateRestaurantVars in ../index.d.ts
const { data } = await CreateRestaurant(dataConnect, createRestaurantVars);

// Operation CreateOrder:  For variables, look at type CreateOrderVars in ../index.d.ts
const { data } = await CreateOrder(dataConnect, createOrderVars);

// Operation UpdateOrderStatus:  For variables, look at type UpdateOrderStatusVars in ../index.d.ts
const { data } = await UpdateOrderStatus(dataConnect, updateOrderStatusVars);

// Operation UpdateUser:  For variables, look at type UpdateUserVars in ../index.d.ts
const { data } = await UpdateUser(dataConnect, updateUserVars);

// Operation DeleteUser:  For variables, look at type DeleteUserVars in ../index.d.ts
const { data } = await DeleteUser(dataConnect, deleteUserVars);

// Operation CreateMenuCategory:  For variables, look at type CreateMenuCategoryVars in ../index.d.ts
const { data } = await CreateMenuCategory(dataConnect, createMenuCategoryVars);

// Operation CreateMenuItem:  For variables, look at type CreateMenuItemVars in ../index.d.ts
const { data } = await CreateMenuItem(dataConnect, createMenuItemVars);

// Operation CreateTable:  For variables, look at type CreateTableVars in ../index.d.ts
const { data } = await CreateTable(dataConnect, createTableVars);

// Operation AddOrderItem:  For variables, look at type AddOrderItemVars in ../index.d.ts
const { data } = await AddOrderItem(dataConnect, addOrderItemVars);


```