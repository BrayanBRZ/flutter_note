import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Client identifiers for the registered Agenda Escolar Android and web apps.
/// Firestore rules, rather than these public identifiers, protect the backups.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (defaultTargetPlatform == TargetPlatform.android) return android;
    throw UnsupportedError(
      'O backup Firebase está configurado para Android e web.',
    );
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyBp5d5pIH2asHut2_skH5Lg7MsRANdLyB0',
    appId: '1:533959181832:web:0110eb1bb41cd8f406b3bd',
    messagingSenderId: '533959181832',
    projectId: 'agenda-escolar-1bae1',
    authDomain: 'agenda-escolar-1bae1.firebaseapp.com',
    storageBucket: 'agenda-escolar-1bae1.firebasestorage.app',
  );

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyBcSdJc54d1HjNWW8QRBCNx153C-f594pE',
    appId: '1:533959181832:android:2e26fd17d6a54ea906b3bd',
    messagingSenderId: '533959181832',
    projectId: 'agenda-escolar-1bae1',
    storageBucket: 'agenda-escolar-1bae1.firebasestorage.app',
  );
}
