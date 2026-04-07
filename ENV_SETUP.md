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
4. Place generated Firebase config files into each Flutter app
5. Deploy rules from the `firebase` folder

## Notes

- Keep secrets out of git
- Add production config per environment later
- Prefer real device testing for billing and sharing flows
