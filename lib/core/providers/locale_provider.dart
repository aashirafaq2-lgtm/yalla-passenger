import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'ar'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }

  static Map<String, Map<String, String>> localizedValues = {
    'en': {
      'welcome': 'Welcome to Yalla',
      'passenger': 'Passenger',
      'driver': 'Driver Portal',
      'go_online': 'GO ONLINE',
      'where_to': 'Where to?',
    },
    'ar': {
      'welcome': 'أهلاً بك في يَلَّا',
      'passenger': 'رايدر',
      'driver': 'بوابة السائق',
      'go_online': 'ابدأ القيادة',
      'where_to': 'إلى أين؟',
    },
  };

  static String getString(String key, BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    return localizedValues[locale.languageCode]?[key] ?? key;
  }
}
