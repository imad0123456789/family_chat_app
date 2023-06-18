import 'package:chat_app_project/screens/chat_screen.dart';
import 'package:chat_app_project/screens/registration_screen.dart';
import 'package:chat_app_project/screens/signin_screen.dart';
import 'package:chat_app_project/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'location.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await _initializeFirebase();
  await _setupFirebaseMessaging();
  // Run with emulators
  await _runWithEmulators(true);


  runApp(MyApp());
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

//messaging
Future<void> _setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('User has denied notification permissions.');
  } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    await _setupNotifications(messaging);
  }
}
//set up Notifications
Future<void> _setupNotifications(FirebaseMessaging messaging) async {
  //Foreground
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // const AndroidInitializationSettings initializationSettingsAndroid =
  // AndroidInitializationSettings('app_icon');
  var initializationSettingsAndroid =
  new AndroidInitializationSettings('@mipmap/ic_launcher');

  InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _handleIncomingMessage(message, flutterLocalNotificationsPlugin);
  });
}

void _handleIncomingMessage(RemoteMessage message, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  if (message.notification != null) {
    var notification = message.notification!;

    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: 'app_icon',
          ),
        )
    );
  }
}

const firestoreEmulatorPort = 8080;
const storageEmulatorPort = 9199;
const authEmulatorPort = 9099;

Future<void> _runWithEmulators(bool emulators) async {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', firestoreEmulatorPort);
  await FirebaseStorage.instance.useStorageEmulator('localhost', storageEmulatorPort);
  await FirebaseAuth.instance.useAuthEmulator('localhost', authEmulatorPort);
}


class MyApp extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: LocationPage(),
      initialRoute: _auth.currentUser!= null ? ChatScreen.screenRoute : WelcomeScreen.screenRoute,
      routes: {
        WelcomeScreen.screenRoute: (context) => WelcomeScreen(),
        SignInScreen.screenRoute: (context) => SignInScreen(),
        RegistrationScreen.screenRoute: (context) => RegistrationScreen(),
        ChatScreen.screenRoute: (context) => ChatScreen(),
        LocationPage.screenRoute: (context) => LocationPage(),

      },
    );
  }
}


//firebase emulators:start