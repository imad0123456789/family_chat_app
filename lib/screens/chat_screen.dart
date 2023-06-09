import 'package:chat_app_project/location.dart';
import 'package:chat_app_project/screens/welcome_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  File? imageFile;

// get Image from gallery
  Future getImage() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null){
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }
// get Image from camera
  Future takeImage() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.camera).then((xFile) {
      if (xFile != null){
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }


  Future uploadImage() async{
    String fileName = Uuid().v1();
    int status = 1;
    var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!).catchError((error) async{
      await  _firestore.collection('messages').doc(fileName).delete();
      status = 0;
    });
    if(status ==1){
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await  _firestore.collection('messages').doc(fileName).set({
        'text': imageUrl,
        'sender': signedInUser.email,
        'type': "img",
        'time': FieldValue.serverTimestamp(),
      });
      print(imageUrl);
    }
  }

  Widget addButton() {
    return Container(
        height: 150,
        //width: 20,
        margin: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: <Widget>[
            //get location button
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => LocationPage()));
                  },
                  icon: Icon(Icons.location_on),
                  color: Colors.blue[800],
                ),
                Text('Location', style: TextStyle(
                  color: Colors.black,
                  //fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),),
              ],
            ),

            //get image button
            Row(
              children: [
                IconButton(
                  onPressed: () => getImage(),
                  icon: Icon(Icons.image),
                  color: Colors.blue[800],
                ),
                Text('Gallery', style: TextStyle(
                  color: Colors.black,
                  //fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),),
              ],
            ),
                 //get camera button
            Row(
              children: [
                IconButton(
                  onPressed: () => takeImage(),
                  icon: Icon(Icons.camera_alt),
                  color: Colors.blue[800],
                ),
                Text('Camera', style: TextStyle(
                  color: Colors.black,
                  //fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),),
              ],
            ),
          ],
        )
    );
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
          ],
        ));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.yellow[900],
        title:
            //display imageProfile and email
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              child: CircleAvatar(
                radius: 20,
                child: Image.asset('images/unknown.png'),
              ),
            ),
            //imageProfile(),
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
                  //
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
                          Navigator.push(context,MaterialPageRoute(builder: (context) => WelcomeScreen()));
                        },
                        child: Text('Sign Out'),
                      ),
                    ],
                  );
                },
              );
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
                    width: 5,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Add button
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        //backgroundColor: Color.fromARGB(100, 255, 100, 100),
                        builder: ((builder) => addButton()),
                      );
                    },
                    icon: Icon(Icons.add),
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

//get message from firestore by update
class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({Key? key}) : super(key: key);

  // to get messages from database
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('time').snapshots(),
      builder: (context, snapshot) {
        List<MessageLine> messageWidgets = [];
        //test if i have data in snapshot
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
            ),
          );
        }
        //to display messages on screen
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
  const MessageLine({
    this.text,this.sender,this.type,required this.time, required this.isMe,
        Key? key})
      : super(key: key);

  final String? sender;
  final String? text;
  final String? type;
  final Timestamp? time;
  final bool isMe;



  //to display message
  @override
  Widget build(BuildContext context) {
    return type == "img" ? Padding(
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
            height: 150,
            width: 150,
            child: Image.network(text!),
          ),
          Text(
            '${time?.toDate().hour}:${time?.toDate().minute}',
            //"${DateTime.now().hour}:${DateTime.now().minute}",
            style: TextStyle(fontSize: 10, color: Colors.red),
          ),
        ],
      ),
    )
        // if type not img
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
            // check who send the message
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

