import 'dart:typed_data';
import 'package:chat_app_project/screens/chat_screen.dart';
import 'package:chat_app_project/screens/welcome_screen.dart';
import 'package:chat_app_project/widgets/my_botton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

final storage = FirebaseStorage.instance;

class RegistrationScreen extends StatefulWidget {
  static const String screenRoute = 'registration_screen';

  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final ImagePicker _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;

  late String email;
  late String password;

  bool spinner = false;

  Uint8List? imageBytes;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register New User'),
        leading: IconButton(
          icon: Icon(
            Icons.home,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()));
          },
        ),
      ),

      backgroundColor: Colors.white,

      body: Container(
        padding: EdgeInsets.only(left: 15, top: 20, right: 15),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              imageProfile(),
              SizedBox(height: 50),

              //email text field
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                //Enter Your Email
                decoration: InputDecoration(
                  hintText: 'Enter Your Email',
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )),
                ),
              ),
              SizedBox(height: 15),

              //password field
              TextField(
                obscureText: true, //make text dots
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                //Enter Your Password
                decoration: InputDecoration(
                  hintText: 'Enter Your Password',
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      )),
                ),
              ),
              SizedBox(height: 15),
              MyButton(
                color: Colors.blue[800]!,
                title: 'Register',
                onPressed: () async {
                  //print(email);
                  //print(password);
                  setState(() {
                    spinner = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser.user == null) {
                      return;
                    }
                    if (imageBytes != null) {
                      Reference ref = FirebaseStorage.instance.ref().child(
                          newUser.user!.uid);
                      try {
                        await ref.putData(imageBytes!);
                        final value = ref.getDownloadURL();
                        print(value);
                      } catch (error) {
                        print(error);
                      }
                    }
                    Navigator.pushNamed(context, ChatScreen.screenRoute);
                    setState(() {
                      spinner = false;
                    });
                  } catch (error) {
                    print(error);
                    spinner = false;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget imageProfile() {
    return Center(
        child: Stack(
          children: <Widget>[
            Container(
              width: 150,
              height: 150,
              child: CircleAvatar(
                radius: 100,
                child:
                imageBytes == null
                    ? Image.asset('images/unknown.png')
                    : Image.memory(imageBytes!),


              ),
            ),
        /*
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(width: 4, color: Colors.white),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1))
            ],
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('images/unknown.png'),
            ),
          ),
        ),
        
         */
            Positioned(
                bottom: 0,
                right: 0,
                child:
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 4, color: Colors.white),
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt),
                    color: Colors.white,
                    onPressed: () {
                      pickUploadImage();
                      showModalBottomSheet(
                        context: context,
                        builder: ((builder) => bottomSheet()),
                      );
                    },
                  ),
                )
            ),
          ],
        )
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 50,
        vertical: 50,
      ),
      child: Column(
        children: <Widget>[
          Text("Choose Profile Photo",
            style: TextStyle(
              fontSize: 25,
              color: Colors.blue,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.camera, color: Colors.green,),
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
              ),
              Text('Camera', style: TextStyle(
                color: Colors.green,
              ),),
              IconButton(
                icon: Icon(Icons.image, color: Colors.red,),
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
              ),
              Text('Gallery', style: TextStyle(
                color: Colors.red,
              ),),
            ],
          )
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(
      source: source,
    );
    setState(() {
      imageBytes = pickedFile?.readAsBytes() as Uint8List?;
    });
  }



  void pickUploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );
    imageBytes = await image?.readAsBytes();
  }


}
