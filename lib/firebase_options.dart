// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCppYpqWWt4k8LYUSTH1VJcmoBzfpMg_E0',
    appId: '1:647528735948:web:986a1b4fb1cd56c4a70e69',
    messagingSenderId: '647528735948',
    projectId: 'chatapp-fb6b3',
    authDomain: 'chatapp-fb6b3.firebaseapp.com',
    databaseURL: 'https://chatapp-fb6b3-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chatapp-fb6b3.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUp_eQ3RcNsw_4n5j2OtgzboSGuNopjy8',
    appId: '1:647528735948:android:c1b64d82433da95ea70e69',
    messagingSenderId: '647528735948',
    projectId: 'chatapp-fb6b3',
    databaseURL: 'https://chatapp-fb6b3-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chatapp-fb6b3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBupDX7OcOV4Z6DGgcf75wEA13BDzbvFeU',
    appId: '1:647528735948:ios:dd172a1337cd6128a70e69',
    messagingSenderId: '647528735948',
    projectId: 'chatapp-fb6b3',
    databaseURL: 'https://chatapp-fb6b3-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chatapp-fb6b3.appspot.com',
    iosClientId: '647528735948-1qa19kb0efnadc833ci2cu3o2qgqg870.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatAppProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBupDX7OcOV4Z6DGgcf75wEA13BDzbvFeU',
    appId: '1:647528735948:ios:dd172a1337cd6128a70e69',
    messagingSenderId: '647528735948',
    projectId: 'chatapp-fb6b3',
    databaseURL: 'https://chatapp-fb6b3-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chatapp-fb6b3.appspot.com',
    iosClientId: '647528735948-1qa19kb0efnadc833ci2cu3o2qgqg870.apps.googleusercontent.com',
    iosBundleId: 'com.example.chatAppProject',
  );
}
