import 'package:chat_app_project/screens/chat_screen.dart';
import 'package:chat_app_project/screens/registration_screen.dart';
import 'package:chat_app_project/screens/signin_screen.dart';
import 'package:chat_app_project/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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
