# Veda Dairy System

Veda Dairy System is a multi-module dairy ERP built for owner, staff, and admin workflows.

## Repository structure

- `veda_app` - Flutter app for dairy owner and staff on Android and Web
- `veda_admin` - Flutter admin panel for platform-level control
- `firebase` - Firestore security rules and indexes
- `PROJECT_GUIDE.md` - architecture and folder explanation
- `ENV_SETUP.md` - local setup steps

## Core product modules

- Milk collection with liters, fat, SNF, shift, and cattle type
- 10-day billing and farmer statements
- Khata, deposits, feed, advances, and manual deductions
- Role-based owner and staff access
- Dashboard, reports, and factory sale tracking
- Offline-first storage with later sync
- PDF bill generation and sharing flows
- English and Marathi support

## Run order

1. Set up Flutter and Firebase from `ENV_SETUP.md`
2. Start `veda_app`
3. Add Firebase config files
4. Build the first production module: milk entry

## Current status

This repository now contains the production-ready starter structure and architecture files. Feature implementation is the next phase.
