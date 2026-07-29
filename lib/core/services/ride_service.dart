import '../network/api_service.dart';

class RideService {
  // Get available car types and prices
  static Future<List<dynamic>> getFareEstimates(double lat, double lng) async {
    try {
      final response = await ApiService.get('/passenger/trips/calculate', queryParameters: {
        'lat': lat,
        'lng': lng,
      });
      return response.data['estimates'];
    } catch (e) {
      rethrow;
    }
  }

  // Book a ride
  static Future<Map<String, dynamic>> bookRide(Map<String, dynamic> rideData) async {
    try {
      final response = await ApiService.post('/passenger/book-car', data: rideData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Get Trip History
  static Future<List<dynamic>> getTripHistory() async {
    try {
      final response = await ApiService.get('/passenger/trips');
      return response.data['trips'];
    } catch (e) {
      rethrow;
    }
  }
}
