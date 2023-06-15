const functions = require("firebase-functions");
const admin = require("firebase-admin");
// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
admin.initializeApp();

 exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
   response.send("Hello from Firebase!");
 });



 exports.createUserDocumentOnSignUP = functions.auth.user()
     .onCreate(async (user) => {
       const userData = {
        email: user.email,
        fcmToken: ""
  };
  const userDocRef = admin.firestore().collection("Users").doc(user.uid);
  await userDocRef.set(userData);
  }
  );

  exports.sendNotificationWhenNewMessageSent = functions.firestore
    .document('messages/{messageID}')
    .onCreate(async (snap, context) => {
      const payload = {
        notification: {
          title: 'Message received',
          body: 'You have a new message'
        }
      };

      const usersSnapshot = await admin.firestore().collection('Users').get();

      const allFcmTokens = [];
      usersSnapshot.forEach(user => {
        console.log(user.data().fcmToken);
        allFcmTokens.push(user.data().fcmToken);
      });
      console.log("ALLFCM");
      console.log(allFcmTokens[0]);
      console.log(payload);
      const response = await admin.messaging().sendToDevice(allFcmTokens, payload);


  });
