import { adminDc } from './src/firebase';
import { getUserById } from './src/dataconnect-admin-generated/index.cjs.js';

async function checkCloudSqlUsers() {
  const adminUid = 'T34GQQ7FkkPwhvDWnTiXA0bArc32';
  const chefUid = 'Q13GbO8Mn1Nl11bKyvSJ6N24GfL2';

  try {
    const adminRes = await getUserById(adminDc, { id: adminUid });
    console.log('Admin in Cloud SQL:', adminRes.data.user);
  } catch (e: any) {
    console.error('Error admin:', e.message);
  }

  try {
    const chefRes = await getUserById(adminDc, { id: chefUid });
    console.log('Chef in Cloud SQL:', chefRes.data.user);
  } catch (e: any) {
    console.error('Error chef:', e.message);
  }
}

checkCloudSqlUsers();
