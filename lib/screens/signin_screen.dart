import 'package:chat_app_project/screens/chat_screen.dart';
import 'package:chat_app_project/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../widgets/my_botton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignInScreen extends StatefulWidget {
  static const String screenRoute ='signin_screen';
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = FirebaseAuth.instance;

  late String email;
  late String password;
  bool spinner = false;
  FirebaseFirestore firebase = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sign In Page'),
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context)=> WelcomeScreen()));
          },
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 180,
                child: Image.asset('images/chatLogo.png'),
              ),
              SizedBox(height: 50),

              //email text field
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value){
                  email = value;
                } ,
                decoration: InputDecoration(
                  hintText: 'Enter Your Email',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )
                  ),
                  enabledBorder:OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange,
                          width: 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )
                  ),
                ),
              ),
              SizedBox(height: 15),

              // password text field
              TextField(
                obscureText: true, //make text dots
                textAlign: TextAlign.center,
                onChanged: (value){
                  password = value;
                } ,
                decoration: InputDecoration(
                  hintText: 'Enter Your Password',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )
                  ),
                  enabledBorder:OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange,
                          width: 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )
                  ),
                ),
              ),
              SizedBox(height: 15),
              MyButton(
                  color: Colors.yellow[900]!,
                  title: 'Sign IN',
                  onPressed: () async {
                    setState(() {
                      spinner = true ;
                    });
                    try{
                      final user = await _auth.
                      signInWithEmailAndPassword(
                          email: email,
                          password: password);
                      if( user != null){
                        CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');

                        // Query the collection to find the document with the given email
                        Query query = usersCollection.where('email', isEqualTo: email);

                        // Get the documents that match the query
                        String? ID =  await query.get().then((QuerySnapshot snapshot) {
                          if (snapshot.size > 0) {
                            // Return the document ID of the first document
                            return snapshot.docs[0].id;
                          } else {
                            // No document found with the given email
                            return null;
                          }
                        }).catchError((error) {
                          // Handle any errors that occur
                          print('Error getting user document ID: $error');
                          return null;
                        });
                        String? token = await messaging.getToken();
                        print("token=  ${token} ID= ${ID}");
                        firebase.collection("Users").doc(ID).update({"fcmToken": token})
                            .then((value) {
                          print('FCM token updated successfully');
                        })
                            .catchError((error) {
                          print('Failed to update FCM token: $error');
                        });
                        Navigator.pushNamed(context, ChatScreen.screenRoute);
                        setState(() {
                          spinner = false ;
                        });
                      }
                    }catch(error){
                      print(error);
                      spinner = false ;
                    }
                  }
              ),
            ],
          ),
        ),
      ),

    );
  }
}
