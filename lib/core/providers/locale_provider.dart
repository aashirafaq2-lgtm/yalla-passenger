import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_language';
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey) ?? 'ar';
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
      'finding_ride': 'Finding your Ride...',
      'please_wait': 'Please wait while we connect you to nearby drivers',
      'driver_on_way': 'Driver is on the way',
      'driver_arrived': 'Driver has arrived at pickup!',
      'trip_in_progress': 'Trip in progress',
      'trip_completed': 'Trip Completed! 🎉',
      'rate_driver': 'Rate Your Driver',
      'submit_review': 'Submit Review',
      'cancel_ride': 'Cancel Request',
      'pickup_location': 'Pickup Location',
      'destination': 'Destination',
      'estimated_fare': 'Estimated Fare',
      'economy': 'Economy',
      'comfort': 'Comfort',
      'luxury': 'VIP Luxury',
      'family_van': 'Family Van',
      'cash': 'Cash',
      'wallet_balance': 'Wallet Balance',
      'retry_search': 'Retry Search',
      'no_drivers': 'No Drivers Available',
      'security_pin': 'Security PIN',
      'give_pin_to_driver': 'Share this 4-digit PIN with your driver',
      'emergency_sos': 'Emergency SOS',
      'share_trip': 'Share Trip',
      'call_driver': 'Call Driver',
      'chat_with_driver': 'Chat with Driver',
      'type_message': 'Type a message...',
      'min': 'min',
      'km': 'km',
      'iqd': 'IQD',
      // Home Screen
      'find_trip': 'Find a Trip',
      'find_trip_subtitle': 'Find nearby rides\nand book instantly',
      'find_trip_now': 'Find a Trip now',
      'find_trip_title': 'Find a\nTrip now!',
      'schedule_trip': 'Schedule a trip',
      'schedule_trip_subtitle': 'Plan your trip in advance\nand we\'ll handle the rest.',
      'send_mail_parcel': 'Sending mail\nor parcels',
      'send_mail_subtitle': 'Fast and reliable delivery\nfor your letters and parcels.',
      'book_entire': 'Book the\nentire car',
      'book_entire_subtitle': 'Book the whole car for\nyou and your group.',
      // Parcel
      'parcel_type': 'Parcel Type',
      'sender_details': 'Sender Details',
      'receiver_details': 'Receiver Details',
      'parcel_summary': 'Parcel Summary',
      'parcel_success': 'Parcel Sent!',
      'from': 'From',
      'to': 'To',
      'date': 'Date',
      'price': 'Price',
      'seats': 'Seats',
      'per_seat': 'per seat',
      'status': 'Status',
      'confirm': 'Confirm',
      'ok': 'OK',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'resend_code': 'Resend Code',
      'back': 'Back',
      'submit': 'Submit',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'email': 'Email Address',
      'phone': 'Phone Number',
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
      'finding_ride': 'جاري البحث عن كابتن...',
      'please_wait': 'يرجى الانتظار، نقوم بالتواصل مع أقرب كابتن لك',
      'driver_on_way': 'الكابتن في طريقه إليك',
      'driver_arrived': 'وصل الكابتن إلى نقطة الانطلاق!',
      'trip_in_progress': 'الرحلة قيد التنفيذ',
      'trip_completed': 'اكتملت الرحلة بنجاح! 🎉',
      'rate_driver': 'تقييم الكابتن',
      'submit_review': 'إرسال التقييم',
      'cancel_ride': 'إلغاء الطلب',
      'pickup_location': 'نقطة الانطلاق',
      'destination': 'الوجهة',
      'estimated_fare': 'الأجرة التقديرية',
      'economy': 'اقتصادي',
      'comfort': 'مريح',
      'luxury': 'فاخر VIP',
      'family_van': 'عائلي فان',
      'cash': 'نقداً (كاش)',
      'wallet_balance': 'رصيد المحفظة',
      'retry_search': 'إعادة المحاولة',
      'no_drivers': 'لا يوجد كباتن متاحين حالياً',
      'security_pin': 'رمز الأمان (PIN)',
      'give_pin_to_driver': 'شارك رمز الأمان المكون من 4 أرقام مع الكابتن',
      'emergency_sos': 'طوارئ SOS',
      'share_trip': 'مشاركة مسار الرحلة',
      'call_driver': 'الاتصال بالكابتن',
      'chat_with_driver': 'مراسلة الكابتن',
      'type_message': 'اكتب رسالة...',
      'min': 'دقيقة',
      'km': 'كم',
      'iqd': 'د.ع',
      // Home Screen
      'find_trip': 'ابحث عن رحلة',
      'find_trip_subtitle': 'ابحث عن رحلات قريبة\nواحجز فوراً',
      'find_trip_now': 'ابحث عن رحلة الآن',
      'find_trip_title': 'ابحث عن\nرحلة الآن!',
      'schedule_trip': 'رحلة مجدولة',
      'schedule_trip_subtitle': 'خطط لرحلتك مسبقاً\nونحن نتكفل بالباقي.',
      'send_mail_parcel': 'إرسال بريد\nأو طرود',
      'send_mail_subtitle': 'توصيل سريع وموثوق\nلرسائلك وطرودك.',
      'book_entire': 'حجز\nسيارة كاملة',
      'book_entire_subtitle': 'احجز السيارة بالكامل\nلك ولمجموعتك.',
      // Parcel
      'parcel_type': 'نوع الطرد',
      'sender_details': 'تفاصيل المرسل',
      'receiver_details': 'تفاصيل المستلم',
      'parcel_summary': 'ملخص الطرد',
      'parcel_success': 'تم إرسال الطرد!',
      'from': 'من',
      'to': 'إلى',
      'date': 'التاريخ',
      'price': 'السعر',
      'seats': 'المقاعد',
      'per_seat': 'لكل مقعد',
      'status': 'الحالة',
      'confirm': 'تأكيد',
      'ok': 'موافق',
      'close': 'إغلاق',
      'yes': 'نعم',
      'no': 'لا',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجاح',
      'resend_code': 'إعادة إرسال الرمز',
      'back': 'رجوع',
      'submit': 'إرسال',
      'first_name': 'الاسم الأول',
      'last_name': 'اسم العائلة',
      'email': 'البريد الإلكتروني',
      'phone': 'رقم الهاتف',
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
