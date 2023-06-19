const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./chatapp-fb6b3-firebase-adminsdk-bcfo5-e531f928df.json");
// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
//fam-chap-app-firebase-adminsdk-3gl9w-984d3164ee.json

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://chatapp-fb6b3-default-rtdb.europe-west1.firebasedatabase.app",
  messagingSenderId: 647528735948
});

//Hello
 exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
   response.send("Hello from Firebase!");
 });


// Sign up
 exports.createUserDocumentOnSignUP = functions.auth.user()
     .onCreate(async (user) => {
       const userData = {
        email: user.email,
        fcmToken: "",
        lastMessage: "",
        lastSeen: "",
        messagesCount: 0

  };
  const userDocRef = admin.firestore().collection("Users").doc(user.uid);
  await userDocRef.set(userData);
  }
  );

/*
  //send notification
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
*/

exports.updateLastMessageFieldWhenNEwMessage = functions.firestore
    .document('messages/{messageID}')
    .onCreate(async (message) => {
      const senderValue = message.get('sender');
 const userQuerySnapshot = await admin.firestore().collection("Users")
  .where('email', '==', senderValue).get();
  userID ="";
    userQuerySnapshot.forEach(doc => {
      const documentId = doc.id;
      // Use the documentId as needed
      userID = documentId;
    });
    console.log(userID);
      const date = new Date();
      const userDocRef = admin.firestore().collection("Users").doc(userID);
      await userDocRef.update("lastMessage", date);
    } );


//message Count
// Firestore trigger function for counting user messages
exports.countUserMessages = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (message) => {
    const messagesCollection = admin.firestore().collection('messages');
    const usersCollection = admin.firestore().collection('Users');
    const userEmail = message.get('sender');

      // Count the number of messages sent by the user
      const userMessagesSnapshot = await messagesCollection
        .where('sender', '==', userEmail)
        .get();
      const messageCount = userMessagesSnapshot.size;
      console.log("Message count");
      console.log(messageCount);
      const userQuerySnapshot = await admin.firestore().collection("Users")
      .where('email', '==', userEmail).get();
      userID ="";
        userQuerySnapshot.forEach(doc => {
          const documentId = doc.id;
          // Use the documentId as needed
          userID = documentId;
        });
       const userDocRef = admin.firestore().collection("Users").doc(userID);
       await userDocRef.update("messagesCount", messageCount);

  });