import 'package:flutter_test/flutter_test.dart';

import 'package:veda_admin/firebase_options.dart';

void main() {
  test('firebase options expose the expected project id', () {
    expect(DefaultFirebaseOptions.web.projectId, 'veda-dairy-system');
  });
}
