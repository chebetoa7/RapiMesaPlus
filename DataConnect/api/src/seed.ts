import { adminDc } from './firebase';
import { createSubscriptionPlan } from '@dataconnect/admin-generated';

async function seed() {
  try {
    console.log('Seeding plans...');
    await createSubscriptionPlan(adminDc, { name: 'free', pricePerMonth: 0, maxRestaurants: 1, maxAdmins: 1, maxWaiters: 3 });
    await createSubscriptionPlan(adminDc, { name: 'express', pricePerMonth: 29, maxRestaurants: 1, maxAdmins: 2, maxWaiters: 15 });
    await createSubscriptionPlan(adminDc, { name: 'full', pricePerMonth: 89, maxRestaurants: 3, maxAdmins: 5, maxWaiters: 50 });
    await createSubscriptionPlan(adminDc, { name: 'premium', pricePerMonth: 199, maxRestaurants: 999, maxAdmins: 999, maxWaiters: 999 });
    console.log('Done!');
  } catch(e) {
    console.error(e);
  }
}
seed();
