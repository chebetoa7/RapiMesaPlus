import { adminDc } from './firebase.js';
import { listAllUsers } from '@dataconnect/admin-generated';

async function main() {
  const users = await listAllUsers(adminDc);
  console.log('--- ALL USERS IN DB ---');
  for (const u of users.data.users) {
    console.log(`- Name: ${u.name} | Email: ${u.email} | Role: ${u.role} | ID: ${u.id}`);
  }
}

main().catch(console.error);
