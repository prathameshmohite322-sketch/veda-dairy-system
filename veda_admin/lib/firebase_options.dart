import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC2Qx4NQ1t7FUWyrqzkm9UBJlENqIoWMVc',
    appId: '1:36694539178:web:c734556e13a8bafe1b89d3',
    messagingSenderId: '36694539178',
    projectId: 'veda-dairy-system',
    authDomain: 'veda-dairy-system.firebaseapp.com',
    storageBucket: 'veda-dairy-system.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdQkJcBg89KPRWRW9QRTMBRyfWYdjVpbg',
    appId: '1:36694539178:android:36132b1ae21d53f81b89d3',
    messagingSenderId: '36694539178',
    projectId: 'veda-dairy-system',
    storageBucket: 'veda-dairy-system.firebasestorage.app',
  );
}
