import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/socket_service.dart';
import 'core/network/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/deferred_link_service.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'core/providers/locale_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final apiService = ApiService();
  final storageService = StorageService();
  final authRepository = AuthRepository(apiService, storageService);
  final notificationService = NotificationService(apiService, storageService);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiService),
        Provider.value(value: storageService),
        ChangeNotifierProvider(
            create: (_) => AuthProvider(authRepository, apiService)),
        Provider(create: (_) => SocketService(storageService)),
        Provider.value(value: notificationService),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const YallaApp(),
    ),
  );

  // Notifications and Firebase token lookup must never hold the first frame.
  // A slow or unavailable FCM/network request used to leave users on the logo.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(Future<void>.delayed(const Duration(seconds: 3), () async {
      try {
        await NotificationService.initialize(apiService, storageService)
            .timeout(const Duration(seconds: 15));
      } catch (error) {
        debugPrint('[Startup] Notification setup deferred: $error');
      }
    }));
    unawaited(DeferredLinkService.resolveOnStartup()
        .timeout(const Duration(seconds: 6))
        .then<void>((_) {})
        .catchError((Object error) {
      debugPrint('[Startup] Deferred link lookup skipped: $error');
    }));
  });
}

class YallaApp extends StatelessWidget {
  const YallaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Directionality(
      textDirection:
          localeProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: MaterialApp(
        title: 'Yalla',
        debugShowCheckedModeBanner: false,
        locale: localeProvider.locale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: AppColors.primaryOrange,
          scaffoldBackgroundColor: AppColors.offWhite,
          textTheme: GoogleFonts.outfitTextTheme(),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
