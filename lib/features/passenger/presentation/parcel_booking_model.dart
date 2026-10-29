import 'dart:typed_data';

class ParcelBookingData {
  // Sender Details (Page 1)
  String senderName;
  String senderPhone;
  String documentType;
  String? senderGovernorate;
  String senderRegion;
  String senderLocationName;
  double? senderLat;
  double? senderLng;
  Uint8List? documentImageBytes;
  String paymentMethod;

  // Receiver Details (Page 2)
  String receiverName;
  String receiverPhone;
  String? receiverGovernorate;
  String receiverArea;
  String receiverAddress;

  // Pricing & Meta
  int deliveryPrice;
  DateTime dateTime;

  ParcelBookingData({
    this.senderName = 'Sender',
    this.senderPhone = '',
    this.documentType = '',
    this.senderGovernorate,
    this.senderRegion = '',
    this.senderLocationName = '',
    this.senderLat,
    this.senderLng,
    this.documentImageBytes,
    this.paymentMethod = 'Sender (Pay in advance)',
    this.receiverName = '',
    this.receiverPhone = '',
    this.receiverGovernorate,
    this.receiverArea = '',
    this.receiverAddress = '',
    this.deliveryPrice = 10000,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();
}

