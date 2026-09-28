const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

initializeApp();

getAuth().getUserByEmail('chebetoa7@gmail.com')
.then(user => {
  return getAuth().updateUser(user.uid, { password: 'password123' })
    .then(() => getAuth().setCustomUserClaims(user.uid, { role: 'admin', restaurantId: 'All' }));
})
.then(() => console.log('Admin user updated successfully! Password is password123'))
.catch(e => console.error(e));
