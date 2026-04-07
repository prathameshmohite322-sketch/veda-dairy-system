import 'package:flutter/material.dart';

import '../l10n/translations.dart';

class AppLocalizations extends InheritedWidget {
  const AppLocalizations({
    super.key,
    required this.localeCode,
    required this.onLocaleChanged,
    required super.child,
  });

  final String localeCode;
  final ValueChanged<Locale> onLocaleChanged;

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result =
        context.dependOnInheritedWidgetOfExactType<AppLocalizations>();
    assert(result != null, 'AppLocalizations not found');
    return result!;
  }

  String t(String key, [Map<String, String> params = const <String, String>{}]) {
    String value = translations[localeCode]?[key] ?? translations['en']?[key] ?? key;
    params.forEach((String paramKey, String paramValue) {
      value = value.replaceAll('{$paramKey}', paramValue);
    });
    return value;
  }

  void setLocale(Locale locale) {
    onLocaleChanged(locale);
  }

  @override
  bool updateShouldNotify(AppLocalizations oldWidget) {
    return localeCode != oldWidget.localeCode;
  }
}
