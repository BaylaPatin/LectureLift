# Firebase Setup Guide for LectureLift

## Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: **LectureLift**
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Firebase to Your App

### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Configure Firebase
Run this command in your project directory:
```bash
cd /Users/baylapatin/Documents/GitHub/LectureLift/lecture_lift
flutterfire configure
```

This will:
- Prompt you to select your Firebase project
- Generate `firebase_options.dart`
- Configure Firebase for iOS, Android, and Web

### Update main.dart
After running `flutterfire configure`, uncomment this line in `lib/main.dart`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

And add this import at the top:
```dart
import 'firebase_options.dart';
```

## Step 3: Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Email/Password** sign-in method

## Step 4: Set Up Firestore
1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose **Start in test mode** (for development)
4. Select a location (e.g., `us-central`)
5. Click "Enable"

## Step 5: Test the App
```bash
flutter run
```

You should now see the login screen!

## Security Rules (Production)
Before deploying, update Firestore rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /schedules/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
