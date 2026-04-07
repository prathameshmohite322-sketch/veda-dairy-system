# Project Guide

## Architecture

This repository is a monorepo with separate application surfaces and shared backend rules.

- `veda_app`: primary operational app used by dairy owner and staff
- `veda_admin`: admin dashboard for platform management, payments, and reports
- `firebase`: Firestore rules and indexes that enforce dairy-level data isolation

## veda_app structure

- `lib/main.dart`: application entry point
- `lib/core`: shared constants, calculations, app config, and localization helpers
- `lib/models`: domain entities such as customer, milk entry, and transaction records
- `lib/services`: auth, customer data, transactions, sync, offline, and notifications
- `lib/features`: user-facing modules such as dashboard, customer, milk entry, billing, and settings
- `lib/utils`: PDF, bill, and account helper logic
- `lib/l10n`: language map and translation helpers

## veda_admin structure

- `lib/main.dart`: admin app entry point
- `lib/dashboard`: business overview screens
- `lib/users`: dairy, staff, and role management
- `lib/payments`: subscriptions and payment operations
- `lib/reports`: aggregated reporting

## Data isolation approach

All tenant-owned records must include `dairyId`. Firestore queries and rules should only allow access to records within the authenticated user's dairy.

## Recommended next implementation order

Completed core order:

1. Authentication and role model
2. Customer and farmer master data
3. Milk entry and rate calculation
4. Billing and khata ledger
5. Offline queue and sync logic
6. PDF generation and sharing flow
7. Admin dashboard and subscriptions

Recommended next order:

1. Live payment key setup
2. Production release configuration
3. WhatsApp-specific share polish
4. Final settings and profile screens
5. Optional reporting exports
