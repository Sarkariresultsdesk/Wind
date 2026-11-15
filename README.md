# WIND — Android MVP Starter

Brand: WIND
Tagline: Your World. Your People. Your Vibe.
Visual style: premium black + gold
Registration: public; mobile number + OTP

## Included
- Flutter Android project starter
- Luxury-themed welcome/login screen
- Firebase Phone Authentication integration points
- Home feed with sample demo posts and story row
- Search, Create, Activity, Profile tabs
- Like interaction on sample posts
- Sign-out support after Firebase is configured

## Important limitations
This is source code, not a ready-to-install APK. Firebase Phone Auth requires your own
Firebase project, Android app registration, and enabling Phone sign-in. The demo feed,
stories, search, uploads, comments, notifications, and profiles are not yet connected to
a live database. Do not launch publicly until Firestore/Storage, security rules,
moderation/report/block, privacy policy, terms, and account deletion are implemented.

## Build from an Android phone
A phone-only workflow is possible but more involved:
1. Use a browser-based cloud development environment that supports Flutter and Android builds.
2. Upload/extract this project.
3. Run `flutter pub get`.
4. Configure Firebase with FlutterFire (`flutterfire configure`) and enable Phone Authentication.
5. Build an APK with `flutter build apk --release`.
6. Download and install the APK on your Android phone.

The easiest route for a beginner is to use a cloud IDE/build service that supports Flutter.
This ZIP does not itself create an APK.

## Firebase note
The code catches missing Firebase initialization so the preview UI can open before Firebase
is configured. For a production build, initialize Firebase using generated platform options.
