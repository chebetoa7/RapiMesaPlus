const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const fetch = require('node-fetch');

// We can just use the Data Connect REST API if we know the endpoint, but it's easier to just use the generated SDK.
// Let's create a quick script using our express app or SDK directly.
