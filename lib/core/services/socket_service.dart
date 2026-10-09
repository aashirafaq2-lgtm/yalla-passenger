import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/storage_service.dart';

class SocketService {
  IO.Socket? socket;
  final StorageService _storageService;
  bool _isConnected = false;
  String? _currentRideId;
  Future<void>? _connectFuture;

  SocketService(this._storageService);

  bool get isConnected => _isConnected;

  Function(dynamic)? onRideAccepted;
  Function(dynamic)? onDriverMoved;
  Function(dynamic)? onRideStatusUpdate;
  Function(dynamic)? onNewMessage;
  Function(dynamic)? onRideCancelled;
  Function(dynamic)? onNewRideRequest;

  Future<void> connect() {
    if (socket?.connected == true) return Future.value();
    return _connectFuture ??= _connect();
  }

  Future<void> _connect() async {
    try {
      if (socket != null) {
        if (!socket!.connected) socket!.connect();
        return;
      }
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) return;

      var userId = await _storageService.getUserId();
      if (userId == null || userId.isEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final normalized = base64Url.normalize(parts[1]);
            final payloadStr = utf8.decode(base64Url.decode(normalized));
            final payload = jsonDecode(payloadStr);
            final extracted = (payload['userId'] ?? payload['id'])?.toString();
            if (extracted != null && extracted.isNotEmpty) {
              await _storageService.saveUserId(extracted);
            }
          }
        } catch (_) {}
      }

      final nextSocket = IO.io(
        'https://api-yalla.aaaj.shop',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(double.maxFinite.toInt())
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(15000)
            .build(),
      );
      socket = nextSocket;
      final connected = Completer<void>();

      nextSocket.onConnect((_) {
        _isConnected = true;
        if (!connected.isCompleted) connected.complete();
        if (_currentRideId != null) joinRide(_currentRideId!);
      });
      nextSocket.onReconnect((_) {
        _isConnected = true;
        if (_currentRideId != null) joinRide(_currentRideId!);
      });
      nextSocket.onDisconnect((_) => _isConnected = false);
      nextSocket.on('connect_error', (err) => print('[Socket] Connect Error: $err'));
      nextSocket.on('ride_accepted', (data) => onRideAccepted?.call(data));
      nextSocket.on('driver_moved', (data) => onDriverMoved?.call(data));
      nextSocket.on('ride_status_update', (data) => onRideStatusUpdate?.call(data));
      nextSocket.on('new_message', (data) => onNewMessage?.call(data));
      nextSocket.on('receive_message', (data) => onNewMessage?.call(data));
      nextSocket.on('new_ride_request', (data) => onNewRideRequest?.call(data));
      nextSocket.on('ride_cancelled', (data) => onRideCancelled?.call(data));
      nextSocket.on('notification', (data) {
        if (data is! Map) return;
        final payload = data['data'] is Map ? data['data'] : data;
        switch (payload['type'] ?? data['type']) {
          case 'RIDE_ACCEPTED':
            onRideAccepted?.call(payload);
            break;
          case 'RIDE_STATUS':
            onRideStatusUpdate?.call(payload);
            break;
          case 'RIDE_CANCELLED':
            onRideCancelled?.call(payload);
            break;
        }
      });

      nextSocket.connect();
      await connected.future.timeout(const Duration(seconds: 8), onTimeout: () {});
    } finally {
      _connectFuture = null;
    }
  }

  void updateLocation(double lat, double lng, {String? rideId}) {
    socket?.emit('update_location', {'lat': lat, 'lng': lng, 'rideId': rideId});
  }

  void requestRide(Map<String, dynamic> rideData) {
    socket?.emit('request_ride', rideData);
  }

  void changeStatus({required String rideId, required String status, Map<String, dynamic>? payload}) {
    socket?.emit('status_change', {'rideId': rideId, 'status': status, 'payload': payload ?? {}});
  }

  void joinRide(String rideId) {
    _currentRideId = rideId;
    if (_isConnected) socket?.emit('join_ride', {'rideId': rideId});
  }

  void disconnect() {
    _currentRideId = null;
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    _isConnected = false;
  }
}
