import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration loaded from --dart-define environment variables.
/// Run with:
/// flutter run \
///   --dart-define=FIREBASE_API_KEY=your_key \
///   --dart-define=FIREBASE_APP_ID=your_app_id \
///   --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
///   --dart-define=FIREBASE_PROJECT_ID=your_project_id \
///   --dart-define=FIREBASE_STORAGE_BUCKET=your_bucket \
///   --dart-define=FIREBASE_AUTH_DOMAIN=your_auth_domain \
///   --dart-define=FIREBASE_MEASUREMENT_ID=your_measurement_id \
///   --dart-define=FIREBASE_IOS_BUNDLE_ID=your_bundle_id
class DefaultFirebaseOptions {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'AIzaSyANQRI1DZSgfjy34m_uTCCbHdhWFsEeLLE');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '1:1041511948149:web:d5c4cd4a2ca4dccd58fd3c');
  static const _messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '1041511948149');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'budgettrack-449eb');
  static const _storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'budgettrack-449eb.firebasestorage.app');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: 'budgettrack-449eb.firebaseapp.com');
  static const _measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID', defaultValue: 'G-70K19L8MWP');
  static const _iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID', defaultValue: 'com.example.budgetTrackingApp');

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    authDomain: _authDomain,
    measurementId: _measurementId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: _iosBundleId,
  );
}
