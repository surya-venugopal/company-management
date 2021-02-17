const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.resetOffice= functions.pubsub.schedule('0 1 * * *').timeZone('Asia/Kolkata').onRun(async(context) => {
  await db.collection("asian").doc("asian").collection("asian1").doc("asian1").collection('Office').doc('office').set({"isOpen":false,"machine":"Off"});
  await db.collection("asian").doc("asian").collection("asian2").doc("asian2").collection('Office').doc('office').set({"isOpen":false,"machine":"Off"});

  return null;
});

