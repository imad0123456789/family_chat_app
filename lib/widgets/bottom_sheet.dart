
import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class BottomSheet extends StatefulWidget {



  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {

  late PickedFile _imageFile;
  final ImagePicker _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text("choose profile photo",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  <Widget>[
              IconButton(
                icon: Icon(Icons.camera),
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
              ),
              Text('Camera'),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
              ),
              Text('Gallery'),
            ],
          )
        ],
      ),
    );
  }


  void takePhoto(ImageSource source) async{
    final pickedFile = await _picker.getImage(
      source: source,
    );
    setState(() {
      _imageFile = pickedFile!;
    });
  }




}


