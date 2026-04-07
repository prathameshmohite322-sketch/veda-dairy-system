# Release Checklist

## 1. Firebase

- Confirm Firestore rules are deployed
- Confirm Authentication providers are enabled
- Confirm both `veda_app` and `veda_admin` use the correct Firebase project

## 2. Payments

- Obtain valid Razorpay KYC and live/test key
- Run `veda_app` with:

```powershell
flutter run -d android --dart-define=RAZORPAY_KEY_ID=rzp_test_your_key
```

- Verify subscription request creation
- Verify payment success/failure status updates in Firestore
- Verify `veda_admin` can review requests

## 3. Android Signing

- Copy `veda_app/android/key.properties.example` to `veda_app/android/key.properties`
- Add the real keystore values
- Keep keystore files out of git
- Build a signed release:

```powershell
cd veda_app
flutter build apk --release --dart-define=RAZORPAY_KEY_ID=rzp_test_your_key
```

## 4. Web Build

### veda_app

```powershell
cd veda_app
flutter build web
```

### veda_admin

```powershell
cd veda_admin
flutter build web
```

## 5. Smoke Testing

- Login works
- Farmer add/list/detail works
- Milk entry works
- Khata entry works
- Billing summary/detail works
- PDF generation/share works
- Offline cache works
- Auto-sync works after reconnect
- Factory sales work
- Admin dashboard loads
- Admin users/payments/reports load

## 6. Before Public Use

- Replace all test payment values with production values when ready
- Test on a real Android device
- Review Firestore costs and indexes
- Review role assignments in `users`
- Make sure only true admins have role `admin`
