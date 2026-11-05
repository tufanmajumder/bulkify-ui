// File generated for Bulkify Firebase configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCan0xVEBdWQysN0Tbf9YASAzBbi-qHS6Q',
    appId: '1:304750331007:android:5cfe774fc867024329ab4a',
    messagingSenderId: '304750331007',
    projectId: 'bulkify-70c28',
    storageBucket: 'bulkify-70c28.firebasestorage.app',
  );
}

