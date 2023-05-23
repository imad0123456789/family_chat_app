import 'dart:ffi';

import 'package:chat_app_project/location.dart';
import 'package:chat_app_project/screens/registration_screen.dart';
import 'package:chat_app_project/widgets/add_to_gallery.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:chat_app_project/screens/registration_screen.dart';
import 'package:uuid/uuid.dart';

final _firestore = FirebaseFirestore.instance; // cloud
late User signedInUser; // this will give as the email

class ChatScreen extends StatefulWidget {
  static const String screenRoute = 'chat_screen';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
final _auth = FirebaseAuth.instance;



class _ChatScreenState extends State<ChatScreen> {

  final _authE = FirebaseAuth.instance.currentUser?.email;
  late final Position loc;
  var msgController = TextEditingController();


  String? messageText; // this will give as the message
  String? location = ""; // this will give as the location
  String? _currentAddress;


  File? imageFile;


  Future getImage() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null){
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async{
    String fileName = Uuid().v1();
    int status = 1;
    await  _firestore.collection('messages').doc(fileName).set({
      'text': "",
      'sender': signedInUser.email,
      'type': "img",
      'time': FieldValue.serverTimestamp(),
    });
    var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!).catchError((error) async{
      await  _firestore.collection('messages').doc(fileName).delete();
      status = 0;
    });

    if(status ==1){
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await  _firestore.collection('messages').doc(fileName).update({
        'text': imageUrl
      });
      print(imageUrl);
    }
  }



  @override
  void initState() {
    super.initState();
    getCurrentUser();

  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email);
      }
    } catch (error) {
      print(error);
    }
  }

  Widget imageProfile() {
    return Center(
        child: Stack(
          children: <Widget>[
            FutureBuilder(
              initialData: null,
              future: getProfileImage(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return Text('Image not found');
                }
                return CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(snapshot.data!),
                );
              },
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: InkWell(
                onTap: () {},
              ),
            ),
          ],
        ));
  }

  // AppBar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[900],
        title: Row(
          children: [
            imageProfile(),
            SizedBox(
              width: 10,
            ),
            Text('$_authE'),
          ],
        ),
        actions: [
          //sign out button
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Sign Out !'),
                    content: Text('Are you sure you want to sign out?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Perform sign out operation here
                          Navigator.of(context).pop(true);
                          _auth.signOut();
                          Navigator.pop(context);
                        },
                        child: Text('Sign Out'),
                      ),
                    ],
                  );
                },
              );
              //messagesStreams();
              //  _auth.signOut();
              //  Navigator.pop(context);
            }, // log out function
            icon: Icon(Icons.login_outlined),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStreamBuilder(),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //location button
                  IconButton(
                    onPressed: () async {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => LocationPage()));
                    },
                    icon: Icon(Icons.location_on),
                    color: Colors.blue[800],
                  ),
                  //get image button
                  IconButton(
                    onPressed: () => getImage(),
                    icon: Icon(Icons.image),
                    color: Colors.blue[800],
                  ),
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          hintText: 'Write your message here...',
                          border: InputBorder.none),
                    ),
                  ),
                  // send Button
                  TextButton(
                    onPressed: () {
                      msgController.clear();
                      setState(() {});
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': signedInUser.email,
                        'time': FieldValue.serverTimestamp(),
                        'type': "text",
                      });
                    },
                    child: Text(
                      'send',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<String> getProfileImage() async {
    try {
      return await FirebaseStorage.instance.ref().child(
          _auth.currentUser!.uid).getDownloadURL();
    }
    catch (error) {
      return await FirebaseStorage.instance.ref().child('unknown.png').getDownloadURL();
    }
  }
}

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('time').snapshots(),
      builder: (context, snapshot) {
        List<MessageLine> messageWidgets = [];
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
            ),
          );
        }
        final messages = snapshot.data!.docs.reversed;
        for (var message in messages) {
          final messagesText = message.get('text');
          final messagesSender = message.get('sender');
          final messagesTime = message.get('time');
          final messagesType = message.get('type');//
          final currentUser = signedInUser.email;

          final messageWidget = MessageLine(
            sender: messagesSender,
            text: messagesText,
            type: messagesType,
            time: messagesTime,
            //
            isMe: currentUser == messagesSender,
          );
          messageWidgets.add(messageWidget);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageLine extends StatelessWidget {
  const MessageLine(
      {this.text,
        this.sender,
        this.type,
        required this.time,
        required this.isMe,
        Key? key})
      : super(key: key);

  final String? sender;
  final String? text;
  final String? type;
  final Timestamp? time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return 'type' == "img" ? Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$sender',
            style: TextStyle(
              fontSize: 12,
              color: Colors.yellow[900],
            ),
          ),
          Container(
            child: Image.network('text'),
          ),
          Text(
            '${time?.toDate().hour}:${time?.toDate().minute}',
            //"${DateTime.now().hour}:${DateTime.now().minute}",
            style: TextStyle(fontSize: 10, color: Colors.red),
          ),
        ],
      ),
    )
        // if type = text
        : Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$sender',
            style: TextStyle(
              fontSize: 12,
              color: Colors.yellow[900],
            ),
          ),

          Material(
            elevation: 5,
            borderRadius: isMe
                ? BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            )
                : BorderRadius.only(
              topRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            color: isMe ? Colors.blue[800] : Colors.white,
            // cheack who sende the message
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(
                    fontSize: 15, color: isMe ? Colors.white : Colors.black45),
              ),
            ),
          ),
          Text(
            '${time?.toDate().hour}:${time?.toDate().minute}',
            //"${DateTime.now().hour}:${DateTime.now().minute}",
            style: TextStyle(fontSize: 10, color: Colors.red),
          ),
        ],
      ),
    );

  }
}

/*
: Container(
        height: 2.5,
        width:2.5,
        alignment:  'sender'== _auth.currentUser!.displayName
        ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Container(
        height: 2.5,
        width: 2.5,
        child: 'text' != "" ? Image.network('text')
        : CircularProgressIndicator(),
    ),
 */