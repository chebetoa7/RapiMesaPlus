const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

initializeApp();

getAuth().createUser({
  email: 'chebetoa7@gmail.com',
  password: '123456',
  displayName: 'Jose Alberto de la Cruz Solano'
})
.then(user => getAuth().setCustomUserClaims(user.uid, { role: 'admin', restaurantId: 'All' }))
.then(() => console.log('Admin user created successfully!'))
.catch(e => console.error(e));
