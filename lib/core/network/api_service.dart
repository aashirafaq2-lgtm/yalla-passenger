import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();
  late final Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api-yalla.aaaj.shop/api',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => true,
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip auth token lookup for unauthenticated auth endpoints
        if (options.path.startsWith('/auth/')) {
          return handler.next(options);
        }
        if (!options.headers.containsKey('Authorization')) {
          try {
            final token = await _storageService.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
        }
        return handler.next(options);
      },
    ));
  }

  /// Helper: returns Dio Options with Authorization header
  Options authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // Auth
  Future<Response> login(String phone) async {
    return await dio.post('/auth/login', data: {
      'phone': phone,
      'role': 'PASSENGER',
    });
  }

  Future<Response> registerPassenger({
    required String phone,
    required String name,
    String? age,
  }) async {
    return await dio.post('/auth/register-passenger', data: {
      'phone': phone,
      'name': name,
      'age': age,
      'role': 'PASSENGER',
    });
  }

  Future<Response> verifyOtp(String phone, String otp) async {
    return await dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp});
  }

  // User
  Future<Response> getWallet(String token) async {
    return await dio.get('/user/wallet', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> getHistory(String token) async {
    return await dio.get('/user/history', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> getProfile(String token) async {
    return await dio.get('/user/profile', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> deleteAccount(String token) async {
    return await dio.delete('/user/profile', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> updateProfile(Map<String, dynamic> data, String token) async {
    return await dio.patch('/user/profile', data: data, options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> updateFcmToken(String fcmToken, String token) async {
    return await dio.patch('/user/device-token', data: {'deviceToken': fcmToken}, options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // Trips
  Future<Response> searchTrips(String fromGov, String toGov, String date) async {
    return await dio.get('/trips/search', queryParameters: {'from': fromGov, 'to': toGov, 'date': date});
  }

  Future<Response> createBooking(Map<String, dynamic> data, String token) async {
    return await dio.post('/bookings/create', data: data, options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> requestParcel(Map<String, dynamic> data, String token) async {
    return await dio.post('/parcels/request', data: data, options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> getMyBookings(String token) async {
    return await dio.get('/bookings/my', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // Reviews
  Future<Response> submitReview(String rideId, int rating, String comment, String token) async {
    return await dio.post('/ride/review', data: {'rideId': rideId, 'rating': rating, 'comment': comment}, options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // Rides & Active Tracking
  Future<Response> getEstimate({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    String? token,
  }) async {
    return await dio.post(
      '/ride/estimate',
      data: {
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropLat': dropLat,
        'dropLng': dropLng,
      },
      options: token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
    );
  }

  Future<Response> getActiveRide(String token) async {
    return await dio.get('/ride/active', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> getRide(String rideId, String token) async {
    return await dio.get('/ride/$rideId', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> cancelRide(String rideId, String reason, String token) async {
    return await dio.patch(
      '/ride/cancel',
      data: {'rideId': rideId, 'reason': reason},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> requestRide(Map<String, dynamic> data, String token) async {
    return await dio.post(
      '/ride/request',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> getChatMessages(String rideId, String token) async {
    return await dio.get('/chat/$rideId', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // Governorates
  Future<Response> getGovernorates() async {
    return await dio.get('/trips/governorates');
  }

  // Map & Spatial APIs
  Future<Response> searchLocation(String query, {double? lat, double? lng}) async {
    return await dio.get('/map/search', queryParameters: {
      'q': query,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
  }

  Future<Response> reverseGeocode(double lat, double lng) async {
    return await dio.get('/map/reverse-geocode', queryParameters: {
      'lat': lat,
      'lng': lng,
    });
  }

  Future<Response> getDirections({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  }) async {
    return await dio.get('/map/route', queryParameters: {
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
    });
  }

  Future<Response> getNotifications(String token) async {
    return await dio.get('/user/notifications', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> markNotificationsRead(String token) async {
    return await dio.patch('/user/notifications/mark-read', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> validatePromo(String code, String? token) async {
    return await dio.post(
      '/ride/validate-promo',
      data: {'code': code},
      options: token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
    );
  }

  Future<Response> topUpWallet(String code, String token) async {
    return await dio.post(
      '/user/wallet/topup',
      data: {'code': code},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Resolve a Google Places placeId to lat/lng, name, and address
  Future<Response> getPlaceDetails(String placeId) async {
    return await dio.get('/map/place-details', queryParameters: {
      'placeId': placeId,
    });
  }

  Future<Response> updateRideStatus(String rideId, String status, String token, {double? finalPrice}) async {
    return await dio.patch(
      '/ride/status',
      data: {
        'rideId': rideId,
        'status': status,
        if (finalPrice != null) 'finalPrice': finalPrice,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}