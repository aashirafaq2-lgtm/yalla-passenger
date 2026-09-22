import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_language';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey) ?? 'en';
      _locale = Locale(code);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!['en', 'ar'].contains(newLocale.languageCode)) return;
    _locale = newLocale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
    } catch (_) {}
  }

  void toggleLocale() {
    setLocale(_locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Yalla',
      'welcome': 'Welcome',
      'profile': 'Profile',
      'payment_method': 'Payment method',
      'trips': 'Trips',
      'my_trips': 'My trips',
      'home': 'Home',
      'language': 'Language',
      'support': 'Support',
      'sign_out': 'Sign Out',
      'delete_account': 'Delete Account',
      'hours': 'Hours',
      'wallet': 'Wallet',
      'where_to': 'Where to?',
      'search': 'Search destination',
      'book_now': 'Book Now',
      'passenger': 'Passenger',
      'driver': 'Driver',
      'welcome_to_yalla': 'Welcome to Yalla',
      'enter_phone': 'Enter your phone number to continue.',
      'send_otp': 'Send OTP Code',
      'confirm_code': 'Confirm Code',
      'verify_phone': 'Verify Phone',
      'enter_verification': 'We sent a verification code to your number.',
      'english': 'English',
      'arabic': 'العربية (Arabic)',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete_permanently': 'Delete Permanently',
      'warning': 'Warning',
      'next': 'Next',
      'sign_in': 'Sign in',
      'sign_up': 'Sign Up',
      'driver_portal': 'Driver Portal',
      'trip_history': 'Trip History',
      'scheduled_trips': 'My Scheduled Trips',
      'mail_parcel': 'Mail & Parcel',
      'support_help': 'Support & Help',
      'account_management': 'ACCOUNT MANAGEMENT',
      'log_out': 'Log Out',
    },
    'ar': {
      'app_name': 'يَلَّا',
      'welcome': 'أهلاً بك',
      'profile': 'الملف الشخصي',
      'payment_method': 'طريقة الدفع',
      'trips': 'الرحلات',
      'my_trips': 'رحلاتي',
      'home': 'الرئيسية',
      'language': 'اللغة',
      'support': 'الدعم الفني',
      'sign_out': 'تسجيل الخروج',
      'delete_account': 'حذف الحساب',
      'hours': 'ساعات',
      'wallet': 'المحفظة',
      'where_to': 'إلى أين تريد الذهاب؟',
      'search': 'ابحث عن وجهتك',
      'book_now': 'احجز الآن',
      'passenger': 'الراكب',
      'driver': 'السائق',
      'welcome_to_yalla': 'مرحباً بك في يَلَّا',
      'enter_phone': 'أدخل رقم هاتفك للمتابعة.',
      'send_otp': 'إرسال رمز التحقق',
      'confirm_code': 'تأكيد الرمز',
      'verify_phone': 'تأكيد رقم الهاتف',
      'enter_verification': 'أرسلنا رمز تحقق إلى رقم هاتفك.',
      'english': 'English (الإنجليزية)',
      'arabic': 'العربية',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete_permanently': 'حذف نهائياً',
      'warning': 'تنبيه',
      'next': 'التالي',
      'sign_in': 'تسجيل الدخول',
      'sign_up': 'إنشاء حساب جديد',
      'driver_portal': 'بوابة السائق',
      'trip_history': 'سجل الرحلات',
      'scheduled_trips': 'رحلاتي المجدولة',
      'mail_parcel': 'الطرود والبريد',
      'support_help': 'المساعدة والدعم',
      'account_management': 'إدارة الحساب',
      'log_out': 'تسجيل الخروج',
    },
  };

  String tr(String key) {
    final lang = _locale.languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  static String text(BuildContext context, String key) {
    try {
      final provider = Provider.of<LocaleProvider>(context, listen: false);
      return provider.tr(key);
    } catch (_) {
      return key;
    }
  }
}

extension TranslationExtension on BuildContext {
  String tr(String key) {
    final provider = Provider.of<LocaleProvider>(this);
    return provider.tr(key);
  }
}
