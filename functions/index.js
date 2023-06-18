const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./chatapp-fb6b3-firebase-adminsdk-bcfo5-108f75a16c.json");
// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
//fam-chap-app-firebase-adminsdk-3gl9w-984d3164ee.json
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://chatapp-fb6b3-default-rtdb.europe-west1.firebasedatabase.app",
  messagingSenderId: 647528735948
});

 exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
   response.send("Hello from Firebase!");
 });



 exports.createUserDocumentOnSignUP = functions.auth.user()
     .onCreate(async (user) => {
       const userData = {
        email: user.email,
        fcmToken: "",
        lastSignIn: ""

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
          title: 'Family Chat App',
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

