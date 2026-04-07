# Veda Dairy System

Veda Dairy System is a multi-module dairy ERP built for owner, staff, and admin workflows.

## Repository structure

- `veda_app` - Flutter app for dairy owner and staff on Android and Web
- `veda_admin` - Flutter admin panel for platform-level control
- `firebase` - Firestore security rules and indexes
- `PROJECT_GUIDE.md` - architecture and folder explanation
- `ENV_SETUP.md` - local setup steps
- `PROJECT_STATUS.md` - current build status and remaining work

## Core product modules

- Milk collection with liters, fat, SNF, shift, and cattle type
- 10-day billing and farmer statements
- Khata, deposits, feed, advances, and manual deductions
- Role-based owner and staff access
- Dashboard, reports, and factory sale tracking
- Offline-first storage with later sync
- PDF bill generation and sharing flows
- English and Marathi support
- Admin payment review and dairy-level reporting

## Current build status

- operational Flutter apps and Firebase integration are already in place
- core dairy workflows are implemented in `veda_app`
- admin review/reporting workflows are implemented in `veda_admin`
- Firestore rules have been tightened and deployed

See `PROJECT_STATUS.md` for the latest completed modules and remaining work.

## Run locally

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
