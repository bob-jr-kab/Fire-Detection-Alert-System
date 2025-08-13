const admin = require("firebase-admin");
const serviceAccount = require("./firebase-key.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // 👇 NO NEED for databaseURL if you're using Firestore
});

const firestore = admin.firestore();
module.exports = firestore;
