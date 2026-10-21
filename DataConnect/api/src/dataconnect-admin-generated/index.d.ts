import { ConnectorConfig, DataConnect, OperationOptions, ExecuteOperationResponse } from 'firebase-admin/data-connect';

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
  extras?: string | null;
  kitchenNotes?: string | null;
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
  tableId?: UUIDString | null;
  orderType?: string | null;
  customerName?: string | null;
  customerPhone?: string | null;
  totalAmount: number;
  comments?: string | null;
}

export interface CreatePushMessageData {
  pushMessage_insert: PushMessage_Key;
}

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
  maxAdmins: number;
  maxWaiters: number;
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

export interface DeactivatePushDeviceData {
  pushDevice_update?: PushDevice_Key | null;
}

export interface DeactivatePushDeviceVariables {
  id: UUIDString;
  lastSeenAt: TimestampString;
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

export interface DeletePushDeviceData {
  pushDevice_delete?: PushDevice_Key | null;
}

export interface DeletePushDeviceVariables {
  id: UUIDString;
}

export interface DeleteSubscriptionPlanData {
  subscriptionPlan_delete?: SubscriptionPlan_Key | null;
}

export interface DeleteSubscriptionPlanVariables {
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

export interface GetAdminsByAdminData {
  users: ({
    id: string;
  } & User_Key)[];
}

export interface GetAdminsByAdminVariables {
  adminId: string;
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
    restaurantId: UUIDString;
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

export interface GetOrderByIdVariables {
  id: UUIDString;
}

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

export interface GetOrdersByWaiterVariables {
  waiterId: string;
}

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

export interface GetPushDeviceByTokenVariables {
  token: string;
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
    maxAdmins?: number | null;
    maxWaiters: number;
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
    maxAdmins?: number | null;
    maxWaiters: number;
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
    subscriptionPlanId?: UUIDString | null;
    adminId?: string | null;
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

export interface ListOrdersByRestaurantVariables {
  restaurantId: UUIDString;
}

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

export interface ListPushDevicesByRestaurantVariables {
  restaurantId: string;
}

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

export interface ListPushMessagesByRestaurantVariables {
  restaurantId: string;
  limit?: number | null;
}

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

export interface PushDevice_Key {
  id: UUIDString;
  __typename?: 'PushDevice_Key';
}

export interface PushMessage_Key {
  id: UUIDString;
  __typename?: 'PushMessage_Key';
}

export interface RegisterPushDeviceData {
  pushDevice_insert: PushDevice_Key;
}

export interface RegisterPushDeviceVariables {
  id: UUIDString;
  token: string;
  userId: string;
  restaurantId?: string | null;
  role: string;
  platform: string;
  deviceLabel?: string | null;
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
  confirmedAt?: TimestampString | null;
  cookingStartedAt?: TimestampString | null;
  readyAt?: TimestampString | null;
}

export interface UpdatePushDeviceData {
  pushDevice_update?: PushDevice_Key | null;
}

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

export interface UpdateSubscriptionPlanData {
  subscriptionPlan_update?: SubscriptionPlan_Key | null;
}

export interface UpdateSubscriptionPlanVariables {
  id: UUIDString;
  maxAdmins?: number | null;
  maxWaiters?: number | null;
  maxRestaurants?: number | null;
  pricePerMonth?: number | null;
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

/** Generated Node Admin SDK operation action function for the 'CreateUser' Mutation. Allow users to execute without passing in DataConnect. */
export function createUser(dc: DataConnect, vars: CreateUserVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateUserData>>;
/** Generated Node Admin SDK operation action function for the 'CreateUser' Mutation. Allow users to pass in custom DataConnect instances. */
export function createUser(vars: CreateUserVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateUserData>>;

/** Generated Node Admin SDK operation action function for the 'CreateRestaurant' Mutation. Allow users to execute without passing in DataConnect. */
export function createRestaurant(dc: DataConnect, vars: CreateRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateRestaurantData>>;
/** Generated Node Admin SDK operation action function for the 'CreateRestaurant' Mutation. Allow users to pass in custom DataConnect instances. */
export function createRestaurant(vars: CreateRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateRestaurantData>>;

/** Generated Node Admin SDK operation action function for the 'CreateOrder' Mutation. Allow users to execute without passing in DataConnect. */
export function createOrder(dc: DataConnect, vars: CreateOrderVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateOrderData>>;
/** Generated Node Admin SDK operation action function for the 'CreateOrder' Mutation. Allow users to pass in custom DataConnect instances. */
export function createOrder(vars: CreateOrderVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateOrderData>>;

/** Generated Node Admin SDK operation action function for the 'UpdateOrderStatus' Mutation. Allow users to execute without passing in DataConnect. */
export function updateOrderStatus(dc: DataConnect, vars: UpdateOrderStatusVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateOrderStatusData>>;
/** Generated Node Admin SDK operation action function for the 'UpdateOrderStatus' Mutation. Allow users to pass in custom DataConnect instances. */
export function updateOrderStatus(vars: UpdateOrderStatusVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateOrderStatusData>>;

/** Generated Node Admin SDK operation action function for the 'UpdateUser' Mutation. Allow users to execute without passing in DataConnect. */
export function updateUser(dc: DataConnect, vars: UpdateUserVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateUserData>>;
/** Generated Node Admin SDK operation action function for the 'UpdateUser' Mutation. Allow users to pass in custom DataConnect instances. */
export function updateUser(vars: UpdateUserVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateUserData>>;

/** Generated Node Admin SDK operation action function for the 'DeleteUser' Mutation. Allow users to execute without passing in DataConnect. */
export function deleteUser(dc: DataConnect, vars: DeleteUserVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteUserData>>;
/** Generated Node Admin SDK operation action function for the 'DeleteUser' Mutation. Allow users to pass in custom DataConnect instances. */
export function deleteUser(vars: DeleteUserVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteUserData>>;

/** Generated Node Admin SDK operation action function for the 'CreateMenuCategory' Mutation. Allow users to execute without passing in DataConnect. */
export function createMenuCategory(dc: DataConnect, vars: CreateMenuCategoryVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateMenuCategoryData>>;
/** Generated Node Admin SDK operation action function for the 'CreateMenuCategory' Mutation. Allow users to pass in custom DataConnect instances. */
export function createMenuCategory(vars: CreateMenuCategoryVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateMenuCategoryData>>;

/** Generated Node Admin SDK operation action function for the 'CreateMenuItem' Mutation. Allow users to execute without passing in DataConnect. */
export function createMenuItem(dc: DataConnect, vars: CreateMenuItemVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateMenuItemData>>;
/** Generated Node Admin SDK operation action function for the 'CreateMenuItem' Mutation. Allow users to pass in custom DataConnect instances. */
export function createMenuItem(vars: CreateMenuItemVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateMenuItemData>>;

/** Generated Node Admin SDK operation action function for the 'CreateTable' Mutation. Allow users to execute without passing in DataConnect. */
export function createTable(dc: DataConnect, vars: CreateTableVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateTableData>>;
/** Generated Node Admin SDK operation action function for the 'CreateTable' Mutation. Allow users to pass in custom DataConnect instances. */
export function createTable(vars: CreateTableVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateTableData>>;

/** Generated Node Admin SDK operation action function for the 'AddOrderItem' Mutation. Allow users to execute without passing in DataConnect. */
export function addOrderItem(dc: DataConnect, vars: AddOrderItemVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<AddOrderItemData>>;
/** Generated Node Admin SDK operation action function for the 'AddOrderItem' Mutation. Allow users to pass in custom DataConnect instances. */
export function addOrderItem(vars: AddOrderItemVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<AddOrderItemData>>;

/** Generated Node Admin SDK operation action function for the 'UpdateTable' Mutation. Allow users to execute without passing in DataConnect. */
export function updateTable(dc: DataConnect, vars: UpdateTableVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateTableData>>;
/** Generated Node Admin SDK operation action function for the 'UpdateTable' Mutation. Allow users to pass in custom DataConnect instances. */
export function updateTable(vars: UpdateTableVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateTableData>>;

/** Generated Node Admin SDK operation action function for the 'UpdateMenuCategory' Mutation. Allow users to execute without passing in DataConnect. */
export function updateMenuCategory(dc: DataConnect, vars: UpdateMenuCategoryVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateMenuCategoryData>>;
/** Generated Node Admin SDK operation action function for the 'UpdateMenuCategory' Mutation. Allow users to pass in custom DataConnect instances. */
export function updateMenuCategory(vars: UpdateMenuCategoryVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateMenuCategoryData>>;

/** Generated Node Admin SDK operation action function for the 'UpdateMenuItem' Mutation. Allow users to execute without passing in DataConnect. */
export function updateMenuItem(dc: DataConnect, vars: UpdateMenuItemVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateMenuItemData>>;
/** Generated Node Admin SDK operation action function for the 'UpdateMenuItem' Mutation. Allow users to pass in custom DataConnect instances. */
export function updateMenuItem(vars: UpdateMenuItemVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateMenuItemData>>;

/** Generated Node Admin SDK operation action function for the 'DeleteTable' Mutation. Allow users to execute without passing in DataConnect. */
export function deleteTable(dc: DataConnect, vars: DeleteTableVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteTableData>>;
/** Generated Node Admin SDK operation action function for the 'DeleteTable' Mutation. Allow users to pass in custom DataConnect instances. */
export function deleteTable(vars: DeleteTableVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteTableData>>;

/** Generated Node Admin SDK operation action function for the 'DeleteMenuCategory' Mutation. Allow users to execute without passing in DataConnect. */
export function deleteMenuCategory(dc: DataConnect, vars: DeleteMenuCategoryVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteMenuCategoryData>>;
/** Generated Node Admin SDK operation action function for the 'DeleteMenuCategory' Mutation. Allow users to pass in custom DataConnect instances. */
export function deleteMenuCategory(vars: DeleteMenuCategoryVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteMenuCategoryData>>;

/** Generated Node Admin SDK operation action function for the 'DeleteMenuItem' Mutation. Allow users to execute without passing in DataConnect. */
export function deleteMenuItem(dc: DataConnect, vars: DeleteMenuItemVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteMenuItemData>>;
/** Generated Node Admin SDK operation action function for the 'DeleteMenuItem' Mutation. Allow users to pass in custom DataConnect instances. */
export function deleteMenuItem(vars: DeleteMenuItemVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteMenuItemData>>;

/** Generated Node Admin SDK operation action function for the 'CreateSubscriptionPlan' Mutation. Allow users to execute without passing in DataConnect. */
export function createSubscriptionPlan(dc: DataConnect, vars: CreateSubscriptionPlanVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateSubscriptionPlanData>>;
/** Generated Node Admin SDK operation action function for the 'CreateSubscriptionPlan' Mutation. Allow users to pass in custom DataConnect instances. */
export function createSubscriptionPlan(vars: CreateSubscriptionPlanVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreateSubscriptionPlanData>>;

/** Generated Node Admin SDK operation action function for the 'UpdateSubscriptionPlan' Mutation. Allow users to execute without passing in DataConnect. */
export function updateSubscriptionPlan(dc: DataConnect, vars: UpdateSubscriptionPlanVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateSubscriptionPlanData>>;
/** Generated Node Admin SDK operation action function for the 'UpdateSubscriptionPlan' Mutation. Allow users to pass in custom DataConnect instances. */
export function updateSubscriptionPlan(vars: UpdateSubscriptionPlanVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdateSubscriptionPlanData>>;

/** Generated Node Admin SDK operation action function for the 'DeleteSubscriptionPlan' Mutation. Allow users to execute without passing in DataConnect. */
export function deleteSubscriptionPlan(dc: DataConnect, vars: DeleteSubscriptionPlanVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteSubscriptionPlanData>>;
/** Generated Node Admin SDK operation action function for the 'DeleteSubscriptionPlan' Mutation. Allow users to pass in custom DataConnect instances. */
export function deleteSubscriptionPlan(vars: DeleteSubscriptionPlanVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeleteSubscriptionPlanData>>;

/** Generated Node Admin SDK operation action function for the 'RegisterPushDevice' Mutation. Allow users to execute without passing in DataConnect. */
export function registerPushDevice(dc: DataConnect, vars: RegisterPushDeviceVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<RegisterPushDeviceData>>;
/** Generated Node Admin SDK operation action function for the 'RegisterPushDevice' Mutation. Allow users to pass in custom DataConnect instances. */
export function registerPushDevice(vars: RegisterPushDeviceVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<RegisterPushDeviceData>>;

/** Generated Node Admin SDK operation action function for the 'UpdatePushDevice' Mutation. Allow users to execute without passing in DataConnect. */
export function updatePushDevice(dc: DataConnect, vars: UpdatePushDeviceVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdatePushDeviceData>>;
/** Generated Node Admin SDK operation action function for the 'UpdatePushDevice' Mutation. Allow users to pass in custom DataConnect instances. */
export function updatePushDevice(vars: UpdatePushDeviceVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<UpdatePushDeviceData>>;

/** Generated Node Admin SDK operation action function for the 'DeactivatePushDevice' Mutation. Allow users to execute without passing in DataConnect. */
export function deactivatePushDevice(dc: DataConnect, vars: DeactivatePushDeviceVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeactivatePushDeviceData>>;
/** Generated Node Admin SDK operation action function for the 'DeactivatePushDevice' Mutation. Allow users to pass in custom DataConnect instances. */
export function deactivatePushDevice(vars: DeactivatePushDeviceVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeactivatePushDeviceData>>;

/** Generated Node Admin SDK operation action function for the 'DeletePushDevice' Mutation. Allow users to execute without passing in DataConnect. */
export function deletePushDevice(dc: DataConnect, vars: DeletePushDeviceVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeletePushDeviceData>>;
/** Generated Node Admin SDK operation action function for the 'DeletePushDevice' Mutation. Allow users to pass in custom DataConnect instances. */
export function deletePushDevice(vars: DeletePushDeviceVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<DeletePushDeviceData>>;

/** Generated Node Admin SDK operation action function for the 'CreatePushMessage' Mutation. Allow users to execute without passing in DataConnect. */
export function createPushMessage(dc: DataConnect, vars: CreatePushMessageVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreatePushMessageData>>;
/** Generated Node Admin SDK operation action function for the 'CreatePushMessage' Mutation. Allow users to pass in custom DataConnect instances. */
export function createPushMessage(vars: CreatePushMessageVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<CreatePushMessageData>>;

/** Generated Node Admin SDK operation action function for the 'ListRestaurants' Query. Allow users to execute without passing in DataConnect. */
export function listRestaurants(dc: DataConnect, options?: OperationOptions): Promise<ExecuteOperationResponse<ListRestaurantsData>>;
/** Generated Node Admin SDK operation action function for the 'ListRestaurants' Query. Allow users to pass in custom DataConnect instances. */
export function listRestaurants(options?: OperationOptions): Promise<ExecuteOperationResponse<ListRestaurantsData>>;

/** Generated Node Admin SDK operation action function for the 'GetUserById' Query. Allow users to execute without passing in DataConnect. */
export function getUserById(dc: DataConnect, vars: GetUserByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetUserByIdData>>;
/** Generated Node Admin SDK operation action function for the 'GetUserById' Query. Allow users to pass in custom DataConnect instances. */
export function getUserById(vars: GetUserByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetUserByIdData>>;

/** Generated Node Admin SDK operation action function for the 'GetOrdersByWaiter' Query. Allow users to execute without passing in DataConnect. */
export function getOrdersByWaiter(dc: DataConnect, vars: GetOrdersByWaiterVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetOrdersByWaiterData>>;
/** Generated Node Admin SDK operation action function for the 'GetOrdersByWaiter' Query. Allow users to pass in custom DataConnect instances. */
export function getOrdersByWaiter(vars: GetOrdersByWaiterVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetOrdersByWaiterData>>;

/** Generated Node Admin SDK operation action function for the 'GetUsersByRestaurant' Query. Allow users to execute without passing in DataConnect. */
export function getUsersByRestaurant(dc: DataConnect, vars: GetUsersByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetUsersByRestaurantData>>;
/** Generated Node Admin SDK operation action function for the 'GetUsersByRestaurant' Query. Allow users to pass in custom DataConnect instances. */
export function getUsersByRestaurant(vars: GetUsersByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetUsersByRestaurantData>>;

/** Generated Node Admin SDK operation action function for the 'ListAllUsers' Query. Allow users to execute without passing in DataConnect. */
export function listAllUsers(dc: DataConnect, options?: OperationOptions): Promise<ExecuteOperationResponse<ListAllUsersData>>;
/** Generated Node Admin SDK operation action function for the 'ListAllUsers' Query. Allow users to pass in custom DataConnect instances. */
export function listAllUsers(options?: OperationOptions): Promise<ExecuteOperationResponse<ListAllUsersData>>;

/** Generated Node Admin SDK operation action function for the 'GetMenuByRestaurant' Query. Allow users to execute without passing in DataConnect. */
export function getMenuByRestaurant(dc: DataConnect, vars: GetMenuByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetMenuByRestaurantData>>;
/** Generated Node Admin SDK operation action function for the 'GetMenuByRestaurant' Query. Allow users to pass in custom DataConnect instances. */
export function getMenuByRestaurant(vars: GetMenuByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetMenuByRestaurantData>>;

/** Generated Node Admin SDK operation action function for the 'ListTablesByRestaurant' Query. Allow users to execute without passing in DataConnect. */
export function listTablesByRestaurant(dc: DataConnect, vars: ListTablesByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<ListTablesByRestaurantData>>;
/** Generated Node Admin SDK operation action function for the 'ListTablesByRestaurant' Query. Allow users to pass in custom DataConnect instances. */
export function listTablesByRestaurant(vars: ListTablesByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<ListTablesByRestaurantData>>;

/** Generated Node Admin SDK operation action function for the 'GetTableById' Query. Allow users to execute without passing in DataConnect. */
export function getTableById(dc: DataConnect, vars: GetTableByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetTableByIdData>>;
/** Generated Node Admin SDK operation action function for the 'GetTableById' Query. Allow users to pass in custom DataConnect instances. */
export function getTableById(vars: GetTableByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetTableByIdData>>;

/** Generated Node Admin SDK operation action function for the 'ListOrdersByRestaurant' Query. Allow users to execute without passing in DataConnect. */
export function listOrdersByRestaurant(dc: DataConnect, vars: ListOrdersByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<ListOrdersByRestaurantData>>;
/** Generated Node Admin SDK operation action function for the 'ListOrdersByRestaurant' Query. Allow users to pass in custom DataConnect instances. */
export function listOrdersByRestaurant(vars: ListOrdersByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<ListOrdersByRestaurantData>>;

/** Generated Node Admin SDK operation action function for the 'GetOrderById' Query. Allow users to execute without passing in DataConnect. */
export function getOrderById(dc: DataConnect, vars: GetOrderByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetOrderByIdData>>;
/** Generated Node Admin SDK operation action function for the 'GetOrderById' Query. Allow users to pass in custom DataConnect instances. */
export function getOrderById(vars: GetOrderByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetOrderByIdData>>;

/** Generated Node Admin SDK operation action function for the 'GetMenuCategoryById' Query. Allow users to execute without passing in DataConnect. */
export function getMenuCategoryById(dc: DataConnect, vars: GetMenuCategoryByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetMenuCategoryByIdData>>;
/** Generated Node Admin SDK operation action function for the 'GetMenuCategoryById' Query. Allow users to pass in custom DataConnect instances. */
export function getMenuCategoryById(vars: GetMenuCategoryByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetMenuCategoryByIdData>>;

/** Generated Node Admin SDK operation action function for the 'GetMenuItemById' Query. Allow users to execute without passing in DataConnect. */
export function getMenuItemById(dc: DataConnect, vars: GetMenuItemByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetMenuItemByIdData>>;
/** Generated Node Admin SDK operation action function for the 'GetMenuItemById' Query. Allow users to pass in custom DataConnect instances. */
export function getMenuItemById(vars: GetMenuItemByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetMenuItemByIdData>>;

/** Generated Node Admin SDK operation action function for the 'ListSubscriptionPlans' Query. Allow users to execute without passing in DataConnect. */
export function listSubscriptionPlans(dc: DataConnect, options?: OperationOptions): Promise<ExecuteOperationResponse<ListSubscriptionPlansData>>;
/** Generated Node Admin SDK operation action function for the 'ListSubscriptionPlans' Query. Allow users to pass in custom DataConnect instances. */
export function listSubscriptionPlans(options?: OperationOptions): Promise<ExecuteOperationResponse<ListSubscriptionPlansData>>;

/** Generated Node Admin SDK operation action function for the 'GetSubscriptionPlanByName' Query. Allow users to execute without passing in DataConnect. */
export function getSubscriptionPlanByName(dc: DataConnect, vars: GetSubscriptionPlanByNameVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetSubscriptionPlanByNameData>>;
/** Generated Node Admin SDK operation action function for the 'GetSubscriptionPlanByName' Query. Allow users to pass in custom DataConnect instances. */
export function getSubscriptionPlanByName(vars: GetSubscriptionPlanByNameVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetSubscriptionPlanByNameData>>;

/** Generated Node Admin SDK operation action function for the 'GetSubscriptionPlanById' Query. Allow users to execute without passing in DataConnect. */
export function getSubscriptionPlanById(dc: DataConnect, vars: GetSubscriptionPlanByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetSubscriptionPlanByIdData>>;
/** Generated Node Admin SDK operation action function for the 'GetSubscriptionPlanById' Query. Allow users to pass in custom DataConnect instances. */
export function getSubscriptionPlanById(vars: GetSubscriptionPlanByIdVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetSubscriptionPlanByIdData>>;

/** Generated Node Admin SDK operation action function for the 'GetRestaurantsByAdmin' Query. Allow users to execute without passing in DataConnect. */
export function getRestaurantsByAdmin(dc: DataConnect, vars: GetRestaurantsByAdminVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetRestaurantsByAdminData>>;
/** Generated Node Admin SDK operation action function for the 'GetRestaurantsByAdmin' Query. Allow users to pass in custom DataConnect instances. */
export function getRestaurantsByAdmin(vars: GetRestaurantsByAdminVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetRestaurantsByAdminData>>;

/** Generated Node Admin SDK operation action function for the 'GetWaitersByAdmin' Query. Allow users to execute without passing in DataConnect. */
export function getWaitersByAdmin(dc: DataConnect, vars: GetWaitersByAdminVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetWaitersByAdminData>>;
/** Generated Node Admin SDK operation action function for the 'GetWaitersByAdmin' Query. Allow users to pass in custom DataConnect instances. */
export function getWaitersByAdmin(vars: GetWaitersByAdminVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetWaitersByAdminData>>;

/** Generated Node Admin SDK operation action function for the 'GetAdminsByAdmin' Query. Allow users to execute without passing in DataConnect. */
export function getAdminsByAdmin(dc: DataConnect, vars: GetAdminsByAdminVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetAdminsByAdminData>>;
/** Generated Node Admin SDK operation action function for the 'GetAdminsByAdmin' Query. Allow users to pass in custom DataConnect instances. */
export function getAdminsByAdmin(vars: GetAdminsByAdminVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetAdminsByAdminData>>;

/** Generated Node Admin SDK operation action function for the 'GetPushDeviceByToken' Query. Allow users to execute without passing in DataConnect. */
export function getPushDeviceByToken(dc: DataConnect, vars: GetPushDeviceByTokenVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetPushDeviceByTokenData>>;
/** Generated Node Admin SDK operation action function for the 'GetPushDeviceByToken' Query. Allow users to pass in custom DataConnect instances. */
export function getPushDeviceByToken(vars: GetPushDeviceByTokenVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<GetPushDeviceByTokenData>>;

/** Generated Node Admin SDK operation action function for the 'ListAllPushDevices' Query. Allow users to execute without passing in DataConnect. */
export function listAllPushDevices(dc: DataConnect, options?: OperationOptions): Promise<ExecuteOperationResponse<ListAllPushDevicesData>>;
/** Generated Node Admin SDK operation action function for the 'ListAllPushDevices' Query. Allow users to pass in custom DataConnect instances. */
export function listAllPushDevices(options?: OperationOptions): Promise<ExecuteOperationResponse<ListAllPushDevicesData>>;

/** Generated Node Admin SDK operation action function for the 'ListPushDevicesByRestaurant' Query. Allow users to execute without passing in DataConnect. */
export function listPushDevicesByRestaurant(dc: DataConnect, vars: ListPushDevicesByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<ListPushDevicesByRestaurantData>>;
/** Generated Node Admin SDK operation action function for the 'ListPushDevicesByRestaurant' Query. Allow users to pass in custom DataConnect instances. */
export function listPushDevicesByRestaurant(vars: ListPushDevicesByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<ListPushDevicesByRestaurantData>>;

/** Generated Node Admin SDK operation action function for the 'ListPushMessagesByRestaurant' Query. Allow users to execute without passing in DataConnect. */
export function listPushMessagesByRestaurant(dc: DataConnect, vars: ListPushMessagesByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<ListPushMessagesByRestaurantData>>;
/** Generated Node Admin SDK operation action function for the 'ListPushMessagesByRestaurant' Query. Allow users to pass in custom DataConnect instances. */
export function listPushMessagesByRestaurant(vars: ListPushMessagesByRestaurantVariables, options?: OperationOptions): Promise<ExecuteOperationResponse<ListPushMessagesByRestaurantData>>;

