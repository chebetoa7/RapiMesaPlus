const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

initializeApp();

getAuth().createUser({email: 'test@example.com', password: 'password123'})
  .then(r => console.log(r))
  .catch(e => console.error(e));
