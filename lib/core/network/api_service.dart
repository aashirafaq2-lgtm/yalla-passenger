import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://76.13.3.121:4000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  ApiService() {
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  // Auth
  Future<Response> login(String phone) async {
    return await dio.post('/auth/login', data: {
      'phone': phone,
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

  Future<Response> updateFcmToken(String fcmToken, String token) async {
    return await dio.patch('/user/fcm-token', data: {'fcmToken': fcmToken}, options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // Trips
  Future<Response> searchTrips(String fromGov, String toGov, String date) async {
    return await dio.get('/trips/search', queryParameters: {'from': fromGov, 'to': toGov, 'date': date});
  }

  Future<Response> createBooking(Map<String, dynamic> data, String token) async {
    return await dio.post('/bookings/create', data: data, options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Response> requestParcel(Map<String, dynamic> data, String token) async {
    return await dio.post('/parcel/request', data: data, options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // Reviews
  Future<Response> submitReview(String rideId, int rating, String comment, String token) async {
    return await dio.post('/ride/review', data: {'rideId': rideId, 'rating': rating, 'comment': comment}, options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  // Governorates
  Future<Response> getGovernorates() async {
    return await dio.get('/trips/governorates');
  }
}
