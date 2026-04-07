class AppConstants {
  static const String appName = 'Veda Dairy System';
  static const String defaultLanguageCode = 'en';
  static const String razorpayKeyId =
      String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '');

  static const List<String> roles = <String>[
    'owner',
    'staff',
    'admin',
  ];
}
