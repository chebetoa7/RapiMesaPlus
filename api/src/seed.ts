import { adminDc } from './firebase';
import { createSubscriptionPlan } from '@dataconnect/admin-generated';

async function seed() {
  try {
    console.log('Seeding plans...');
    await createSubscriptionPlan(adminDc, { name: 'free', pricePerMonth: 0, maxRestaurants: 1, maxWaiters: 1, maxTables: 3 });
    await createSubscriptionPlan(adminDc, { name: 'express', pricePerMonth: 29, maxRestaurants: 1, maxWaiters: 5, maxTables: 15 });
    await createSubscriptionPlan(adminDc, { name: 'full', pricePerMonth: 89, maxRestaurants: 3, maxWaiters: 15, maxTables: 50 });
    await createSubscriptionPlan(adminDc, { name: 'premium', pricePerMonth: 199, maxRestaurants: 999, maxWaiters: 999, maxTables: 999 });
    console.log('Done!');
  } catch(e) {
    console.error(e);
  }
}
seed();
