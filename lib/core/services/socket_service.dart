import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/storage_service.dart';

class SocketService {
  late IO.Socket socket;
  final StorageService _storageService;

  SocketService(this._storageService);

  // Callbacks – set by screens that need them
  Function(dynamic)? onRideAccepted;
  Function(dynamic)? onDriverMoved;
  Function(dynamic)? onNewRideRequest; // for driver app if ever shared

  void connect() async {
    final token = await _storageService.getToken();

    socket = IO.io('http://76.13.3.121:4000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token ?? ''})
          .build());

    socket.connect();

    socket.onConnect((_) => print('[Socket] Connected'));

    socket.on('ride_accepted', (data) {
      onRideAccepted?.call(data);
    });

    socket.on('driver_moved', (data) {
      onDriverMoved?.call(data);
    });

    socket.on('new_ride_request', (data) {
      onNewRideRequest?.call(data);
    });

    socket.on('notification', (data) {
      print('[Socket] Global Notification received: $data');
      // Logic to show local notification can be added here or via callback
      onDriverMoved?.call(data); // Reusing for generic notification or creating new callback
    });

    socket.onDisconnect((_) => print('[Socket] Disconnected'));
  }

  /// Passenger emits their position (for driver tracking)
  void updateLocation(double lat, double lng, {String? rideId}) {
    socket.emit('update_location', {'lat': lat, 'lng': lng, 'rideId': rideId});
  }

  void joinRide(String rideId) {
    socket.emit('join_ride', {'rideId': rideId});
  }

  void disconnect() => socket.disconnect();
}
