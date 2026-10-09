import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/api_service.dart';
import 'storage_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('[FCM Background] Passenger received message: ${message.messageId}');
  } catch (_) {}
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Channels
  static const String channelRideStatus = 'yalla_ride_status';
  static const String channelScheduled = 'yalla_scheduled';
  static const String channelGeneral = 'yalla_general';

  // Deterministic Notification IDs
  static const int idRideAccepted = 201;
  static const int idDriverArrived = 202;
  static const int idTripStarted = 203;
  static const int idTripCompleted = 204;
  static const int idRideCancelled = 205;
  static const int idParcelAccepted = 206;
  static const int idParcelDelivered = 207;
  static const int idScheduledBase = 300;

  // Allow legacy instance usage in main.dart
  NotificationService([dynamic api, dynamic storage]);

  // ── Initialize ─────────────────────────────────────────────────────────────
  static Future<void> initialize([
    ApiService? apiService,
    StorageService? storageService,
  ]) async {
    if (_initialized) return;
    if (kIsWeb) return;

    try {
      tz.initializeTimeZones();
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      // Fallback if timezone fails
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse resp) {
        debugPrint('[Notification] Passenger tapped: ${resp.payload}');
      },
    );

    // Create Android notification channels
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        AndroidNotificationChannel(
          channelRideStatus,
          'Ride & Delivery Updates',
          description: 'Real-time ride progress, arrival, and delivery alerts',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 300, 200, 300]),
        ),
      );

      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          channelScheduled,
          'Scheduled Ride Reminders',
          description: 'Upcoming scheduled trips reminders',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          channelGeneral,
          'General Notifications',
          description: 'General system announcements and account updates',
          importance: Importance.defaultImportance,
        ),
      );

      try {
        await androidImpl.requestNotificationsPermission();
      } catch (e) {
        debugPrint('[NotificationService] Android notification permission request: $e');
      }
    }

    _initialized = true;
    debugPrint('[NotificationService] Passenger local notifications ready');

    // ── Firebase Cloud Messaging ───────────────────────────────────────────
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final fcmToken = await messaging.getToken();
      debugPrint('[FCM] Passenger Token: $fcmToken');

      // Register token with backend
      if (fcmToken != null && apiService != null && storageService != null) {
          final authToken = await storageService.getToken();
          if (authToken != null && authToken.isNotEmpty) {
            try {
              await apiService.updateFcmToken(fcmToken, authToken);
            } catch (_) {}
        }
      }

      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('[FCM] Passenger Token Refreshed: $newToken');
        if (apiService != null && storageService != null) {
          final authToken = await storageService.getToken();
          if (authToken != null && authToken.isNotEmpty) {
            try {
              await apiService.updateFcmToken(newToken, authToken);
            } catch (_) {}
          }
        }
      });

      // Handle FCM foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final data = message.data;
        final type = data['type']?.toString();

        // In foreground, socket event already triggers in-app state updates
        // Only show heads-up banner if not currently on active ride screen or if explicitly needed
        if (notification != null) {
          showNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: notification.title ?? 'Yalla',
            body: notification.body ?? '',
            channelId: type == 'RIDE_CANCELLED' ? channelRideStatus : channelRideStatus,
          );
        }
      });
    } catch (e) {
      debugPrint('[FCM] Passenger init note: $e');
    }
  }

  static Future<void> syncDeviceToken(ApiService apiService, String authToken) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await apiService.updateFcmToken(token, authToken);
      }
    } catch (e) {
      debugPrint('[FCM] Passenger token registration failed: $e');
    }
  }

  // ── Show Local Notification ───────────────────────────────────────────────
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = channelRideStatus,
  }) async {
    if (kIsWeb || !_initialized) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelId == channelRideStatus ? 'Ride & Delivery Updates' : 'Scheduled Reminders',
      channelDescription: 'Real-time ride and status notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 200, 300]),
      icon: '@mipmap/ic_launcher',
      category: AndroidNotificationCategory.status,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  // ── Convenience helpers (called from socket events) ────────────────────────
  static Future<void> notifyRideAccepted({
    String? driverName,
    String? carModel,
    String? plate,
  }) async {
    await showNotification(
      id: idRideAccepted,
      title: '✅ Driver Accepted Your Ride!',
      body:
          '${driverName ?? "Driver"} is on the way · ${carModel ?? ""} ${plate ?? ""}',
      payload: 'ride_accepted',
    );
  }

  static Future<void> notifyRideCancelled({String? reason}) async {
    await showNotification(
      id: idRideCancelled,
      title: '❌ Ride Cancelled',
      body: reason?.isNotEmpty == true
          ? 'Reason: $reason'
          : 'The driver cancelled your ride.',
      payload: 'ride_cancelled',
    );
  }

  static Future<void> notifyDriverArrived() async {
    await showNotification(
      id: idDriverArrived,
      title: '📍 Driver Has Arrived!',
      body: 'Your driver is waiting at the pickup location.',
      payload: 'driver_arrived',
    );
  }

  static Future<void> notifyTripStarted() async {
    await showNotification(
      id: idTripStarted,
      title: '🚗 Trip Started!',
      body: 'Your trip is now in progress. Enjoy your ride!',
      payload: 'trip_started',
    );
  }

  static Future<void> notifyTripCompleted() async {
    await showNotification(
      id: idTripCompleted,
      title: '🎉 Trip Completed!',
      body: 'You have arrived at your destination. Rate your driver!',
      payload: 'trip_completed',
    );
  }

  static Future<void> notifyParcelAccepted({String? driverName}) async {
    await showNotification(
      id: idParcelAccepted,
      title: '📦 Parcel Accepted!',
      body: '${driverName ?? "A driver"} is on the way to pick up your parcel.',
      payload: 'parcel_accepted',
    );
  }

  static Future<void> notifyParcelDelivered() async {
    await showNotification(
      id: idParcelDelivered,
      title: '📦 Parcel Delivered!',
      body: 'Your parcel has been delivered successfully.',
      payload: 'parcel_delivered',
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // ── Scheduled Reminders ──────────────────────────────────────────────────
  static Future<void> scheduleRideReminders(DateTime rideTime, String rideId) async {
    if (kIsWeb || !_initialized) return;

    final now = DateTime.now();
    final androidDetails = const AndroidNotificationDetails(
      channelScheduled,
      'Scheduled Reminders',
      channelDescription: 'Reminders for your upcoming scheduled rides',
      importance: Importance.high,
      priority: Priority.high,
    );
    final iosDetails = const DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final intervals = [
      {'minutes': 60, 'message': 'Your scheduled ride is in 1 hour.'},
      {'minutes': 30, 'message': 'Your scheduled ride is in 30 minutes.'},
      {'minutes': 15, 'message': 'Your scheduled ride is in 15 minutes.'},
      {'minutes': 5, 'message': 'Your scheduled ride is in 5 minutes!'},
    ];

    int offset = 0;
    for (final interval in intervals) {
      final mins = interval['minutes'] as int;
      final msg = interval['message'] as String;
      final reminderTime = rideTime.subtract(Duration(minutes: mins));
      
      if (reminderTime.isAfter(now)) {
        try {
          await _notificationsPlugin.zonedSchedule(
            idScheduledBase + offset + rideId.hashCode.abs() % 10000,
            'Upcoming Ride Reminder',
            msg,
            tz.TZDateTime.from(reminderTime, tz.local),
            details,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (_) {}
      }
      offset++;
    }
  }
}
