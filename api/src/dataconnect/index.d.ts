import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, ExecuteQueryOptions, MutationRef, MutationPromise } from 'firebase/data-connect';

export const connectorConfig: ConnectorConfig;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;




export interface AddOrderItemData {
  orderItem_insert: OrderItem_Key;
}

export interface AddOrderItemVariables {
  orderId: UUIDString;
  productId: string;
  name: string;
  quantity: number;
  price: number;
}

export interface CreateMenuCategoryData {
  menuCategory_insert: MenuCategory_Key;
}

export interface CreateMenuCategoryVariables {
  restaurantId: UUIDString;
  name: string;
  iconUrl?: string | null;
  sortOrder: number;
}

export interface CreateMenuItemData {
  menuItem_insert: MenuItem_Key;
}

export interface CreateMenuItemVariables {
  categoryId: UUIDString;
  name: string;
  description?: string | null;
  price: number;
  imageUrl?: string | null;
}

export interface CreateOrderData {
  order_insert: Order_Key;
}

export interface CreateOrderVariables {
  restaurantId: UUIDString;
  waiterId: string;
  tableId: UUIDString;
  totalAmount: number;
  comments?: string | null;
}

export interface CreateRestaurantData {
  restaurant_insert: Restaurant_Key;
}

export interface CreateRestaurantVariables {
  name: string;
  tableCount: number;
  adminId: string;
}

export interface CreateSubscriptionPlanData {
  subscriptionPlan_insert: SubscriptionPlan_Key;
}

export interface CreateSubscriptionPlanVariables {
  name: string;
  pricePerMonth: number;
  maxRestaurants: number;
  maxWaiters: number;
  maxTables: number;
}

export interface CreateTableData {
  table_insert: Table_Key;
}

export interface CreateTableVariables {
  restaurantId: UUIDString;
  identifier: string;
}

export interface CreateUserData {
  user_insert: User_Key;
}

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

export interface DeleteMenuCategoryData {
  menuCategory_delete?: MenuCategory_Key | null;
}

export interface DeleteMenuCategoryVariables {
  id: UUIDString;
}

export interface DeleteMenuItemData {
  menuItem_delete?: MenuItem_Key | null;
}

export interface DeleteMenuItemVariables {
  id: UUIDString;
}

export interface DeleteTableData {
  table_delete?: Table_Key | null;
}

export interface DeleteTableVariables {
  id: UUIDString;
}

export interface DeleteUserData {
  user_delete?: User_Key | null;
}

export interface DeleteUserVariables {
  id: string;
}

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

export interface GetMenuByRestaurantVariables {
  restaurantId: UUIDString;
}

export interface GetMenuCategoryByIdData {
  menuCategory?: {
    id: UUIDString;
    name: string;
    iconUrl?: string | null;
    sortOrder: number;
  } & MenuCategory_Key;
}

export interface GetMenuCategoryByIdVariables {
  id: UUIDString;
}

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

export interface GetMenuItemByIdVariables {
  id: UUIDString;
}

export interface GetOrderByIdData {
  order?: {
    id: UUIDString;
    tableId: UUIDString;
    waiterId: string;
    status: string;
    totalAmount: number;
    comments?: string | null;
    createdAt: TimestampString;
    orderItems_on_order: ({
      id: UUIDString;
      productId: string;
      name: string;
      quantity: number;
      price: number;
    } & OrderItem_Key)[];
  } & Order_Key;
}

export interface GetOrderByIdVariables {
  id: UUIDString;
}

export interface GetOrdersByWaiterData {
  orders: ({
    id: UUIDString;
    status: string;
    totalAmount: number;
    createdAt: TimestampString;
    table: {
      identifier: string;
    };
  } & Order_Key)[];
}

export interface GetOrdersByWaiterVariables {
  waiterId: string;
}

export interface GetRestaurantsByAdminData {
  restaurants: ({
    id: UUIDString;
  } & Restaurant_Key)[];
}

export interface GetRestaurantsByAdminVariables {
  adminId: string;
}

export interface GetSubscriptionPlanByIdData {
  subscriptionPlan?: {
    id: UUIDString;
    name: string;
    pricePerMonth: number;
    maxRestaurants: number;
    maxWaiters: number;
    maxTables: number;
  } & SubscriptionPlan_Key;
}

export interface GetSubscriptionPlanByIdVariables {
  id: UUIDString;
}

export interface GetSubscriptionPlanByNameData {
  subscriptionPlans: ({
    id: UUIDString;
    name: string;
    pricePerMonth: number;
    maxRestaurants: number;
    maxWaiters: number;
    maxTables: number;
  } & SubscriptionPlan_Key)[];
}

export interface GetSubscriptionPlanByNameVariables {
  name: string;
}

export interface GetTableByIdData {
  table?: {
    id: UUIDString;
    restaurantId: UUIDString;
    identifier: string;
    status: string;
  } & Table_Key;
}

export interface GetTableByIdVariables {
  id: UUIDString;
}

export interface GetUserByIdData {
  user?: {
    id: string;
    name: string;
    email: string;
    role: string;
    restaurantId?: string | null;
  } & User_Key;
}

export interface GetUserByIdVariables {
  id: string;
}

export interface GetUsersByRestaurantData {
  users: ({
    id: string;
    name: string;
    role: string;
    email: string;
  } & User_Key)[];
}

export interface GetUsersByRestaurantVariables {
  restaurantId: string;
}

export interface GetWaitersByAdminData {
  users: ({
    id: string;
  } & User_Key)[];
}

export interface GetWaitersByAdminVariables {
  adminId: string;
}

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

export interface ListOrdersByRestaurantData {
  orders: ({
    id: UUIDString;
    tableId: UUIDString;
    waiterId: string;
    status: string;
    totalAmount: number;
    createdAt: TimestampString;
  } & Order_Key)[];
}

export interface ListOrdersByRestaurantVariables {
  restaurantId: UUIDString;
}

export interface ListRestaurantsData {
  restaurants: ({
    id: UUIDString;
    name: string;
    tableCount: number;
    admin: {
      id: string;
      name: string;
    } & User_Key;
  } & Restaurant_Key)[];
}

export interface ListSubscriptionPlansData {
  subscriptionPlans: ({
    id: UUIDString;
    name: string;
    pricePerMonth: number;
    maxRestaurants: number;
    maxWaiters: number;
    maxTables: number;
  } & SubscriptionPlan_Key)[];
}

export interface ListTablesByRestaurantData {
  tables: ({
    id: UUIDString;
    identifier: string;
    status: string;
  } & Table_Key)[];
}

export interface ListTablesByRestaurantVariables {
  restaurantId: UUIDString;
}

export interface MenuCategory_Key {
  id: UUIDString;
  __typename?: 'MenuCategory_Key';
}

export interface MenuItem_Key {
  id: UUIDString;
  __typename?: 'MenuItem_Key';
}

export interface OrderItem_Key {
  id: UUIDString;
  __typename?: 'OrderItem_Key';
}

export interface Order_Key {
  id: UUIDString;
  __typename?: 'Order_Key';
}

export interface Restaurant_Key {
  id: UUIDString;
  __typename?: 'Restaurant_Key';
}

export interface SubscriptionPlan_Key {
  id: UUIDString;
  __typename?: 'SubscriptionPlan_Key';
}

export interface Table_Key {
  id: UUIDString;
  __typename?: 'Table_Key';
}

export interface UpdateMenuCategoryData {
  menuCategory_update?: MenuCategory_Key | null;
}

export interface UpdateMenuCategoryVariables {
  id: UUIDString;
  name?: string | null;
  iconUrl?: string | null;
  sortOrder?: number | null;
}

export interface UpdateMenuItemData {
  menuItem_update?: MenuItem_Key | null;
}

export interface UpdateMenuItemVariables {
  id: UUIDString;
  name?: string | null;
  description?: string | null;
  price?: number | null;
  imageUrl?: string | null;
  isAvailable?: boolean | null;
}

export interface UpdateOrderStatusData {
  order_update?: Order_Key | null;
}

export interface UpdateOrderStatusVariables {
  id: UUIDString;
  status: string;
}

export interface UpdateTableData {
  table_update?: Table_Key | null;
}

export interface UpdateTableVariables {
  id: UUIDString;
  identifier?: string | null;
  status?: string | null;
}

export interface UpdateUserData {
  user_update?: User_Key | null;
}

export interface UpdateUserVariables {
  id: string;
  name?: string | null;
  phone?: string | null;
  role?: string | null;
  restaurantId?: string | null;
  subscriptionPlanId?: UUIDString | null;
  adminId?: string | null;
}

export interface User_Key {
  id: string;
  __typename?: 'User_Key';
}

interface CreateUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
  operationName: string;
}
export const createUserRef: CreateUserRef;

export function createUser(vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;
export function createUser(dc: DataConnect, vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface CreateRestaurantRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateRestaurantVariables): MutationRef<CreateRestaurantData, CreateRestaurantVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateRestaurantVariables): MutationRef<CreateRestaurantData, CreateRestaurantVariables>;
  operationName: string;
}
export const createRestaurantRef: CreateRestaurantRef;

export function createRestaurant(vars: CreateRestaurantVariables): MutationPromise<CreateRestaurantData, CreateRestaurantVariables>;
export function createRestaurant(dc: DataConnect, vars: CreateRestaurantVariables): MutationPromise<CreateRestaurantData, CreateRestaurantVariables>;

interface CreateOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
  operationName: string;
}
export const createOrderRef: CreateOrderRef;

export function createOrder(vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;
export function createOrder(dc: DataConnect, vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface UpdateOrderStatusRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateOrderStatusVariables): MutationRef<UpdateOrderStatusData, UpdateOrderStatusVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateOrderStatusVariables): MutationRef<UpdateOrderStatusData, UpdateOrderStatusVariables>;
  operationName: string;
}
export const updateOrderStatusRef: UpdateOrderStatusRef;

export function updateOrderStatus(vars: UpdateOrderStatusVariables): MutationPromise<UpdateOrderStatusData, UpdateOrderStatusVariables>;
export function updateOrderStatus(dc: DataConnect, vars: UpdateOrderStatusVariables): MutationPromise<UpdateOrderStatusData, UpdateOrderStatusVariables>;

interface UpdateUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
  operationName: string;
}
export const updateUserRef: UpdateUserRef;

export function updateUser(vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;
export function updateUser(dc: DataConnect, vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface DeleteUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteUserVariables): MutationRef<DeleteUserData, DeleteUserVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteUserVariables): MutationRef<DeleteUserData, DeleteUserVariables>;
  operationName: string;
}
export const deleteUserRef: DeleteUserRef;

export function deleteUser(vars: DeleteUserVariables): MutationPromise<DeleteUserData, DeleteUserVariables>;
export function deleteUser(dc: DataConnect, vars: DeleteUserVariables): MutationPromise<DeleteUserData, DeleteUserVariables>;

interface CreateMenuCategoryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateMenuCategoryVariables): MutationRef<CreateMenuCategoryData, CreateMenuCategoryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateMenuCategoryVariables): MutationRef<CreateMenuCategoryData, CreateMenuCategoryVariables>;
  operationName: string;
}
export const createMenuCategoryRef: CreateMenuCategoryRef;

export function createMenuCategory(vars: CreateMenuCategoryVariables): MutationPromise<CreateMenuCategoryData, CreateMenuCategoryVariables>;
export function createMenuCategory(dc: DataConnect, vars: CreateMenuCategoryVariables): MutationPromise<CreateMenuCategoryData, CreateMenuCategoryVariables>;

interface CreateMenuItemRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateMenuItemVariables): MutationRef<CreateMenuItemData, CreateMenuItemVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateMenuItemVariables): MutationRef<CreateMenuItemData, CreateMenuItemVariables>;
  operationName: string;
}
export const createMenuItemRef: CreateMenuItemRef;

export function createMenuItem(vars: CreateMenuItemVariables): MutationPromise<CreateMenuItemData, CreateMenuItemVariables>;
export function createMenuItem(dc: DataConnect, vars: CreateMenuItemVariables): MutationPromise<CreateMenuItemData, CreateMenuItemVariables>;

interface CreateTableRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateTableVariables): MutationRef<CreateTableData, CreateTableVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateTableVariables): MutationRef<CreateTableData, CreateTableVariables>;
  operationName: string;
}
export const createTableRef: CreateTableRef;

export function createTable(vars: CreateTableVariables): MutationPromise<CreateTableData, CreateTableVariables>;
export function createTable(dc: DataConnect, vars: CreateTableVariables): MutationPromise<CreateTableData, CreateTableVariables>;

interface AddOrderItemRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: AddOrderItemVariables): MutationRef<AddOrderItemData, AddOrderItemVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: AddOrderItemVariables): MutationRef<AddOrderItemData, AddOrderItemVariables>;
  operationName: string;
}
export const addOrderItemRef: AddOrderItemRef;

export function addOrderItem(vars: AddOrderItemVariables): MutationPromise<AddOrderItemData, AddOrderItemVariables>;
export function addOrderItem(dc: DataConnect, vars: AddOrderItemVariables): MutationPromise<AddOrderItemData, AddOrderItemVariables>;

interface UpdateTableRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateTableVariables): MutationRef<UpdateTableData, UpdateTableVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateTableVariables): MutationRef<UpdateTableData, UpdateTableVariables>;
  operationName: string;
}
export const updateTableRef: UpdateTableRef;

export function updateTable(vars: UpdateTableVariables): MutationPromise<UpdateTableData, UpdateTableVariables>;
export function updateTable(dc: DataConnect, vars: UpdateTableVariables): MutationPromise<UpdateTableData, UpdateTableVariables>;

interface UpdateMenuCategoryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateMenuCategoryVariables): MutationRef<UpdateMenuCategoryData, UpdateMenuCategoryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateMenuCategoryVariables): MutationRef<UpdateMenuCategoryData, UpdateMenuCategoryVariables>;
  operationName: string;
}
export const updateMenuCategoryRef: UpdateMenuCategoryRef;

export function updateMenuCategory(vars: UpdateMenuCategoryVariables): MutationPromise<UpdateMenuCategoryData, UpdateMenuCategoryVariables>;
export function updateMenuCategory(dc: DataConnect, vars: UpdateMenuCategoryVariables): MutationPromise<UpdateMenuCategoryData, UpdateMenuCategoryVariables>;

interface UpdateMenuItemRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateMenuItemVariables): MutationRef<UpdateMenuItemData, UpdateMenuItemVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateMenuItemVariables): MutationRef<UpdateMenuItemData, UpdateMenuItemVariables>;
  operationName: string;
}
export const updateMenuItemRef: UpdateMenuItemRef;

export function updateMenuItem(vars: UpdateMenuItemVariables): MutationPromise<UpdateMenuItemData, UpdateMenuItemVariables>;
export function updateMenuItem(dc: DataConnect, vars: UpdateMenuItemVariables): MutationPromise<UpdateMenuItemData, UpdateMenuItemVariables>;

interface DeleteTableRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteTableVariables): MutationRef<DeleteTableData, DeleteTableVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteTableVariables): MutationRef<DeleteTableData, DeleteTableVariables>;
  operationName: string;
}
export const deleteTableRef: DeleteTableRef;

export function deleteTable(vars: DeleteTableVariables): MutationPromise<DeleteTableData, DeleteTableVariables>;
export function deleteTable(dc: DataConnect, vars: DeleteTableVariables): MutationPromise<DeleteTableData, DeleteTableVariables>;

interface DeleteMenuCategoryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteMenuCategoryVariables): MutationRef<DeleteMenuCategoryData, DeleteMenuCategoryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteMenuCategoryVariables): MutationRef<DeleteMenuCategoryData, DeleteMenuCategoryVariables>;
  operationName: string;
}
export const deleteMenuCategoryRef: DeleteMenuCategoryRef;

export function deleteMenuCategory(vars: DeleteMenuCategoryVariables): MutationPromise<DeleteMenuCategoryData, DeleteMenuCategoryVariables>;
export function deleteMenuCategory(dc: DataConnect, vars: DeleteMenuCategoryVariables): MutationPromise<DeleteMenuCategoryData, DeleteMenuCategoryVariables>;

interface DeleteMenuItemRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteMenuItemVariables): MutationRef<DeleteMenuItemData, DeleteMenuItemVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteMenuItemVariables): MutationRef<DeleteMenuItemData, DeleteMenuItemVariables>;
  operationName: string;
}
export const deleteMenuItemRef: DeleteMenuItemRef;

export function deleteMenuItem(vars: DeleteMenuItemVariables): MutationPromise<DeleteMenuItemData, DeleteMenuItemVariables>;
export function deleteMenuItem(dc: DataConnect, vars: DeleteMenuItemVariables): MutationPromise<DeleteMenuItemData, DeleteMenuItemVariables>;

interface CreateSubscriptionPlanRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateSubscriptionPlanVariables): MutationRef<CreateSubscriptionPlanData, CreateSubscriptionPlanVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateSubscriptionPlanVariables): MutationRef<CreateSubscriptionPlanData, CreateSubscriptionPlanVariables>;
  operationName: string;
}
export const createSubscriptionPlanRef: CreateSubscriptionPlanRef;

export function createSubscriptionPlan(vars: CreateSubscriptionPlanVariables): MutationPromise<CreateSubscriptionPlanData, CreateSubscriptionPlanVariables>;
export function createSubscriptionPlan(dc: DataConnect, vars: CreateSubscriptionPlanVariables): MutationPromise<CreateSubscriptionPlanData, CreateSubscriptionPlanVariables>;

interface ListRestaurantsRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListRestaurantsData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListRestaurantsData, undefined>;
  operationName: string;
}
export const listRestaurantsRef: ListRestaurantsRef;

export function listRestaurants(options?: ExecuteQueryOptions): QueryPromise<ListRestaurantsData, undefined>;
export function listRestaurants(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListRestaurantsData, undefined>;

interface GetUserByIdRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUserByIdVariables): QueryRef<GetUserByIdData, GetUserByIdVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetUserByIdVariables): QueryRef<GetUserByIdData, GetUserByIdVariables>;
  operationName: string;
}
export const getUserByIdRef: GetUserByIdRef;

export function getUserById(vars: GetUserByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetUserByIdData, GetUserByIdVariables>;
export function getUserById(dc: DataConnect, vars: GetUserByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetUserByIdData, GetUserByIdVariables>;

interface GetOrdersByWaiterRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrdersByWaiterVariables): QueryRef<GetOrdersByWaiterData, GetOrdersByWaiterVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetOrdersByWaiterVariables): QueryRef<GetOrdersByWaiterData, GetOrdersByWaiterVariables>;
  operationName: string;
}
export const getOrdersByWaiterRef: GetOrdersByWaiterRef;

export function getOrdersByWaiter(vars: GetOrdersByWaiterVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrdersByWaiterData, GetOrdersByWaiterVariables>;
export function getOrdersByWaiter(dc: DataConnect, vars: GetOrdersByWaiterVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrdersByWaiterData, GetOrdersByWaiterVariables>;

interface GetUsersByRestaurantRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetUsersByRestaurantVariables): QueryRef<GetUsersByRestaurantData, GetUsersByRestaurantVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetUsersByRestaurantVariables): QueryRef<GetUsersByRestaurantData, GetUsersByRestaurantVariables>;
  operationName: string;
}
export const getUsersByRestaurantRef: GetUsersByRestaurantRef;

export function getUsersByRestaurant(vars: GetUsersByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<GetUsersByRestaurantData, GetUsersByRestaurantVariables>;
export function getUsersByRestaurant(dc: DataConnect, vars: GetUsersByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<GetUsersByRestaurantData, GetUsersByRestaurantVariables>;

interface ListAllUsersRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListAllUsersData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListAllUsersData, undefined>;
  operationName: string;
}
export const listAllUsersRef: ListAllUsersRef;

export function listAllUsers(options?: ExecuteQueryOptions): QueryPromise<ListAllUsersData, undefined>;
export function listAllUsers(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListAllUsersData, undefined>;

interface GetMenuByRestaurantRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetMenuByRestaurantVariables): QueryRef<GetMenuByRestaurantData, GetMenuByRestaurantVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetMenuByRestaurantVariables): QueryRef<GetMenuByRestaurantData, GetMenuByRestaurantVariables>;
  operationName: string;
}
export const getMenuByRestaurantRef: GetMenuByRestaurantRef;

export function getMenuByRestaurant(vars: GetMenuByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuByRestaurantData, GetMenuByRestaurantVariables>;
export function getMenuByRestaurant(dc: DataConnect, vars: GetMenuByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuByRestaurantData, GetMenuByRestaurantVariables>;

interface ListTablesByRestaurantRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListTablesByRestaurantVariables): QueryRef<ListTablesByRestaurantData, ListTablesByRestaurantVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: ListTablesByRestaurantVariables): QueryRef<ListTablesByRestaurantData, ListTablesByRestaurantVariables>;
  operationName: string;
}
export const listTablesByRestaurantRef: ListTablesByRestaurantRef;

export function listTablesByRestaurant(vars: ListTablesByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListTablesByRestaurantData, ListTablesByRestaurantVariables>;
export function listTablesByRestaurant(dc: DataConnect, vars: ListTablesByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListTablesByRestaurantData, ListTablesByRestaurantVariables>;

interface GetTableByIdRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetTableByIdVariables): QueryRef<GetTableByIdData, GetTableByIdVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetTableByIdVariables): QueryRef<GetTableByIdData, GetTableByIdVariables>;
  operationName: string;
}
export const getTableByIdRef: GetTableByIdRef;

export function getTableById(vars: GetTableByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetTableByIdData, GetTableByIdVariables>;
export function getTableById(dc: DataConnect, vars: GetTableByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetTableByIdData, GetTableByIdVariables>;

interface ListOrdersByRestaurantRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListOrdersByRestaurantVariables): QueryRef<ListOrdersByRestaurantData, ListOrdersByRestaurantVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: ListOrdersByRestaurantVariables): QueryRef<ListOrdersByRestaurantData, ListOrdersByRestaurantVariables>;
  operationName: string;
}
export const listOrdersByRestaurantRef: ListOrdersByRestaurantRef;

export function listOrdersByRestaurant(vars: ListOrdersByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListOrdersByRestaurantData, ListOrdersByRestaurantVariables>;
export function listOrdersByRestaurant(dc: DataConnect, vars: ListOrdersByRestaurantVariables, options?: ExecuteQueryOptions): QueryPromise<ListOrdersByRestaurantData, ListOrdersByRestaurantVariables>;

interface GetOrderByIdRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderByIdVariables): QueryRef<GetOrderByIdData, GetOrderByIdVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetOrderByIdVariables): QueryRef<GetOrderByIdData, GetOrderByIdVariables>;
  operationName: string;
}
export const getOrderByIdRef: GetOrderByIdRef;

export function getOrderById(vars: GetOrderByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderByIdData, GetOrderByIdVariables>;
export function getOrderById(dc: DataConnect, vars: GetOrderByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderByIdData, GetOrderByIdVariables>;

interface GetMenuCategoryByIdRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetMenuCategoryByIdVariables): QueryRef<GetMenuCategoryByIdData, GetMenuCategoryByIdVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetMenuCategoryByIdVariables): QueryRef<GetMenuCategoryByIdData, GetMenuCategoryByIdVariables>;
  operationName: string;
}
export const getMenuCategoryByIdRef: GetMenuCategoryByIdRef;

export function getMenuCategoryById(vars: GetMenuCategoryByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuCategoryByIdData, GetMenuCategoryByIdVariables>;
export function getMenuCategoryById(dc: DataConnect, vars: GetMenuCategoryByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuCategoryByIdData, GetMenuCategoryByIdVariables>;

interface GetMenuItemByIdRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetMenuItemByIdVariables): QueryRef<GetMenuItemByIdData, GetMenuItemByIdVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetMenuItemByIdVariables): QueryRef<GetMenuItemByIdData, GetMenuItemByIdVariables>;
  operationName: string;
}
export const getMenuItemByIdRef: GetMenuItemByIdRef;

export function getMenuItemById(vars: GetMenuItemByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuItemByIdData, GetMenuItemByIdVariables>;
export function getMenuItemById(dc: DataConnect, vars: GetMenuItemByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetMenuItemByIdData, GetMenuItemByIdVariables>;

interface ListSubscriptionPlansRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListSubscriptionPlansData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListSubscriptionPlansData, undefined>;
  operationName: string;
}
export const listSubscriptionPlansRef: ListSubscriptionPlansRef;

export function listSubscriptionPlans(options?: ExecuteQueryOptions): QueryPromise<ListSubscriptionPlansData, undefined>;
export function listSubscriptionPlans(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListSubscriptionPlansData, undefined>;

interface GetSubscriptionPlanByNameRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetSubscriptionPlanByNameVariables): QueryRef<GetSubscriptionPlanByNameData, GetSubscriptionPlanByNameVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetSubscriptionPlanByNameVariables): QueryRef<GetSubscriptionPlanByNameData, GetSubscriptionPlanByNameVariables>;
  operationName: string;
}
export const getSubscriptionPlanByNameRef: GetSubscriptionPlanByNameRef;

export function getSubscriptionPlanByName(vars: GetSubscriptionPlanByNameVariables, options?: ExecuteQueryOptions): QueryPromise<GetSubscriptionPlanByNameData, GetSubscriptionPlanByNameVariables>;
export function getSubscriptionPlanByName(dc: DataConnect, vars: GetSubscriptionPlanByNameVariables, options?: ExecuteQueryOptions): QueryPromise<GetSubscriptionPlanByNameData, GetSubscriptionPlanByNameVariables>;

interface GetSubscriptionPlanByIdRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetSubscriptionPlanByIdVariables): QueryRef<GetSubscriptionPlanByIdData, GetSubscriptionPlanByIdVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetSubscriptionPlanByIdVariables): QueryRef<GetSubscriptionPlanByIdData, GetSubscriptionPlanByIdVariables>;
  operationName: string;
}
export const getSubscriptionPlanByIdRef: GetSubscriptionPlanByIdRef;

export function getSubscriptionPlanById(vars: GetSubscriptionPlanByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetSubscriptionPlanByIdData, GetSubscriptionPlanByIdVariables>;
export function getSubscriptionPlanById(dc: DataConnect, vars: GetSubscriptionPlanByIdVariables, options?: ExecuteQueryOptions): QueryPromise<GetSubscriptionPlanByIdData, GetSubscriptionPlanByIdVariables>;

interface GetRestaurantsByAdminRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetRestaurantsByAdminVariables): QueryRef<GetRestaurantsByAdminData, GetRestaurantsByAdminVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetRestaurantsByAdminVariables): QueryRef<GetRestaurantsByAdminData, GetRestaurantsByAdminVariables>;
  operationName: string;
}
export const getRestaurantsByAdminRef: GetRestaurantsByAdminRef;

export function getRestaurantsByAdmin(vars: GetRestaurantsByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetRestaurantsByAdminData, GetRestaurantsByAdminVariables>;
export function getRestaurantsByAdmin(dc: DataConnect, vars: GetRestaurantsByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetRestaurantsByAdminData, GetRestaurantsByAdminVariables>;

interface GetWaitersByAdminRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetWaitersByAdminVariables): QueryRef<GetWaitersByAdminData, GetWaitersByAdminVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetWaitersByAdminVariables): QueryRef<GetWaitersByAdminData, GetWaitersByAdminVariables>;
  operationName: string;
}
export const getWaitersByAdminRef: GetWaitersByAdminRef;

export function getWaitersByAdmin(vars: GetWaitersByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetWaitersByAdminData, GetWaitersByAdminVariables>;
export function getWaitersByAdmin(dc: DataConnect, vars: GetWaitersByAdminVariables, options?: ExecuteQueryOptions): QueryPromise<GetWaitersByAdminData, GetWaitersByAdminVariables>;

