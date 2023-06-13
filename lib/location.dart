import 'package:chat_app_project/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

final _firestore = FirebaseFirestore.instance; // cloud

class LocationPage extends StatefulWidget {
  static const String screenRoute ='location_page';

  const LocationPage({Key? key}) : super(key: key);


  @override
  State<LocationPage> createState() => _LocationPageState();
}


class _LocationPageState extends State<LocationPage> {
  String? _currentAddress;
  Position? _currentPosition;

// ask to take permission to use loaction from mobile
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }


  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        '${place.street}, ${place.postalCode} '; //${place.subLocality}, ${place.subAdministrativeArea}, ${place.subLocality},
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _sendLocation() async{
    setState(() {});
    _firestore.collection('messages').add({
      'text':"ADDRESS: ${_currentAddress ?? ""}. LAT:${_currentPosition?.latitude ?? ""},LNG: ${_currentPosition?.longitude ?? ""}",
      'sender': signedInUser.email,
      'time': FieldValue.serverTimestamp(),
      'type': "location",
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Page")),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 180,
                child: Image.asset('images/googlemap.png'),
              ),
              Text('LAT: ${_currentPosition?.latitude ?? ""}'),
              Text('LNG: ${_currentPosition?.longitude ?? ""}'),
              Text('ADDRESS: ${_currentAddress ?? ""}'),
              const SizedBox(height: 32),
              //Get Current Location button
              ElevatedButton(
                onPressed: _getCurrentPosition,
                child: const Text("Get Current Location"),

              ),

              // send location button
              TextButton(
                onPressed: (){
                  _sendLocation();
                  Navigator.push(context,MaterialPageRoute(builder: (context) => ChatScreen()));
                },
                child: const Text("Send Current Location", style: TextStyle(
                  color: Colors.white
                ),),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red[900]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}




