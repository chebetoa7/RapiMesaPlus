import { adminDc, app } from './src/firebase';
import { createUser, updateUser, listRestaurants } from './src/dataconnect-admin-generated/index.cjs.js';
import { getAuth } from 'firebase-admin/auth';

async function registerChef() {
  const uid = 'Q13GbO8Mn1Nl11bKyvSJ6N24GfL2';
  const restaurantId = '641d8c4bd87847bf803ef3f4218ac7ce';
  const adminId = 'T34GQQ7FkkPwhvDWnTiXA0bArc32';

  // 1. Set Custom Claims in Firebase Auth
  const auth = getAuth(app);
  await auth.setCustomUserClaims(uid, {
    role: 'kitchen',
    restaurantId: restaurantId,
  });
  console.log('Chef claims updated: role=kitchen, restaurantId=' + restaurantId);

  // 2. Insert into Cloud SQL User table
  try {
    const res = await createUser(adminDc, {
      id: uid,
      name: 'Chef Cocina 1',
      email: 'mesero1@vianeycoffe.com',
      role: 'kitchen',
      phone: null,
      restaurantId: restaurantId,
      subscriptionPlanId: null,
      adminId: adminId,
    });
    console.log('Chef created in Cloud SQL:', res.data);
  } catch (e: any) {
    console.error('Error creating chef in Cloud SQL:', e.message);
  }
}

registerChef();
