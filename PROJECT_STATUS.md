# Project Status

## Completed

- `veda_app` Flutter platform scaffolding for Android, Web, iOS, desktop targets
- Firebase Auth login and owner account flow
- Farmer management with add, list, and detail screens
- Milk entry with liters, fat, SNF, shift, cattle type, and auto calculation
- Khata ledger with deposit, feed, advance, and deduction flows
- 10-day billing summaries and bill detail screen
- Bill PDF generation and share/export flow
- Dashboard totals and recent activity
- English and Marathi switching in the main app
- Hive cache for offline reads
- Offline write queue and automatic sync behavior
- Factory sales module with reports
- Subscription request flow and Android Razorpay checkout foundation
- `veda_admin` shell, Firestore-backed dashboard, payments, reports, and users
- Admin payment review actions
- Admin role-based access protection
- Stricter Firestore rules deployed to Firebase

## In Progress / Foundation Ready

- Razorpay live key setup
- Production deployment configuration

## Remaining

- Real live Razorpay key and full payment verification flow
- WhatsApp-specific sharing polish
- Final settings/profile management screens
- Production Android signing and release setup
- Web deployment configuration for both apps
- Optional deeper admin actions and reporting exports

## Latest Guidance

- Use `veda_app` for dairy operations
- Use `veda_admin` only with accounts having role `admin`
- Do not use fake KYC details for live Razorpay onboarding
