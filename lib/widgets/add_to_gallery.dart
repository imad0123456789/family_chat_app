

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:convert';


class AddToGallery extends StatefulWidget {
  static const String screenRoute = 'add_to_gallery';
  const AddToGallery({Key? key}) : super(key: key);

  @override
  State<AddToGallery> createState() => _AddToGalleryState();
}

class _AddToGalleryState extends State<AddToGallery> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      child: Column(
        children:<Widget> [
          Image.network( 'https://www.pngall.com/wp-content/uploads/5/User-Profile-Transparent.png',
        height: 350,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
          ElevatedButton(
              child:  Text('Download'),
              onPressed: () async{
                String url =  'https://www.pngall.com/wp-content/uploads/5/User-Profile-Transparent.png';

                //await Dio().download(url, path);
                await GallerySaver.saveImage(url);
              },
              )
        ],
      ),
    )
    );
  }
}
