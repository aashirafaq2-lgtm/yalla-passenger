import 'package:flutter/material.dart';
import 'parcel_booking_model.dart';
import 'parcel_receiver_detail_screen.dart';

class ParcelSenderDetailScreen extends StatelessWidget {
  final ParcelBookingData? bookingData;

  const ParcelSenderDetailScreen({super.key, this.bookingData});

  @override
  Widget build(BuildContext context) {
    return ParcelReceiverDetailScreen(
      bookingData: bookingData ?? ParcelBookingData(),
    );
  }
}
