# Authy

A complete authentication example for Flutter and Firebase

## Getting Started

Authy contains multiple methods of authentication, each with their own requirments.  

Minimum Requirements

### Add Firebase
- Create a Firebase project
- Add your own google-services.json file by following https://firebase.flutter.dev/docs/installation/android
- Add your own GoogleService-Info.plist by following https://firebase.flutter.dev/docs/installation/ios
- Enable Cloud Firestore on your firebase project panel and set database rules to allow read, write: if request.auth.uid != null;

Feature Requirements (Still under construction).

### Email/Password Authentication
- From the Authentication portion of your firebase project panel, enable email/password authentication under the sign-in method tab.

### Facebook Authentication
- From the Authentication portion of your firebase project panel, enable Facebook authentication under the sign-in method tab.
- Fill in App ID and App Secret with Values from your Facebook App.

### Apple Sign In

### Phone Auth
- Enable Apple Push Notifications
- Create FCM Key
