# Environment Setup

## Required tools

- Flutter SDK
- Dart SDK
- Android Studio or Android SDK tools
- Chrome for Flutter Web
- Firebase CLI

## Project bootstrap

### veda_app

```bash
cd veda_app
flutter pub get
flutter run -d chrome
```

### veda_admin

```bash
cd veda_admin
flutter pub get
flutter run -d chrome
```

## Firebase steps

1. Create a Firebase project
2. Enable Authentication and Firestore
3. Add Android and Web apps
4. Ensure `lib/firebase_options.dart` is present in both apps
5. Deploy rules from the `firebase` folder

## Firestore rules deploy

If `firebase` is not on PATH in PowerShell, use:

```powershell
$env:Path = "C:\Program Files\nodejs;C:\Users\PRATHAMESH\AppData\Roaming\npm;" + $env:Path
& "C:\Program Files\nodejs\npm.cmd" exec --package firebase-tools -- firebase deploy --only firestore:rules
```

## Payment setup note

- `veda_app` already contains the Razorpay mobile checkout foundation
- pass the real key at runtime using `--dart-define=RAZORPAY_KEY_ID=your_key_id`
- do not attempt live onboarding without valid KYC details

## Android release setup

1. Copy `veda_app/android/key.properties.example` to `veda_app/android/key.properties`
2. Fill in the real keystore values
3. Keep `key.properties` and keystore files out of git
4. Use `--dart-define=RAZORPAY_KEY_ID=your_key_id` for payment-enabled builds

Example:

```powershell
cd veda_app
flutter run -d android --dart-define=RAZORPAY_KEY_ID=rzp_test_your_key
```

## Notes

- Keep secrets out of git
- Add production config per environment later
- Prefer real device testing for billing and sharing flows
