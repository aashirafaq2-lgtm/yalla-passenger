import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/sound_service.dart';
import 'passenger_main_screen.dart';
import 'active_ride_screen.dart';

enum ManualBookingType {
  findTrip,
  parcel,
  entireCar,
}

class RequestReceivedScreen extends StatefulWidget {
  final ManualBookingType bookingType;
  final String? requestId;
  final Map<String, dynamic>? extraData;

  const RequestReceivedScreen({
    super.key,
    required this.bookingType,
    this.requestId,
    this.extraData,
  });

  @override
  State<RequestReceivedScreen> createState() => _RequestReceivedScreenState();
}

class _RequestReceivedScreenState extends State<RequestReceivedScreen> {
  bool _isCancelling = false;
  bool _driverConfirmed = false;
  Map<String, dynamic>? _assignedDriverData;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _listenToDriverAssignment();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _listenToDriverAssignment() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    // Join room for this ride if requestId exists
    if (widget.requestId != null && widget.requestId!.isNotEmpty) {
      socketService.joinRide(widget.requestId!);
    }

    // Listen to ride_accepted event
    final originalOnRideAccepted = socketService.onRideAccepted;
    socketService.onRideAccepted = (data) {
      originalOnRideAccepted?.call(data);
      if (!mounted) return;

      final incomingRideId = data is Map ? (data['rideId'] ?? data['id'])?.toString() : null;
      if (widget.requestId != null && incomingRideId != null && incomingRideId != widget.requestId) {
        return;
      }

      _onDriverAssignedSuccess(data is Map ? Map<String, dynamic>.from(data) : {});
    };
  }

  void _startStatusPolling() {
    // Also poll active ride status every 5 seconds as fallback
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted || _driverConfirmed) return;
      try {
        final api = Provider.of<ApiService>(context, listen: false);
        final storage = Provider.of<StorageService>(context, listen: false);
        final token = await storage.getToken();
        if (token == null) return;

        final res = await api.getActiveRide(token);
        if (res.statusCode == 200 && res.data?['activeRide'] != null) {
          final activeRide = Map<String, dynamic>.from(res.data['activeRide']);
          final status = activeRide['status']?.toString();
          final rideId = (activeRide['id'] ?? activeRide['rideId'])?.toString();

          if (widget.requestId != null && rideId != widget.requestId) return;

          if (status == 'ACCEPTED' || status == 'ARRIVED' || status == 'PICKED_UP' || status == 'ONGOING') {
            _onDriverAssignedSuccess(activeRide);
          }
        }
      } catch (_) {}
    });
  }

  void _onDriverAssignedSuccess(Map<String, dynamic> data) {
    if (_driverConfirmed || !mounted) return;

    _pollingTimer?.cancel();
    SoundService().playRideAccepted();

    setState(() {
      _driverConfirmed = true;
      _assignedDriverData = data;
    });

    // Provide brief visual confirmation on step 3 before transitioning to live map
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final payload = Map<String, dynamic>.from(_assignedDriverData ?? {});
      payload['id'] = payload['id'] ?? payload['rideId'] ?? widget.requestId;
      payload['rideId'] = payload['id'];
      if (widget.extraData != null) {
        payload.addAll(widget.extraData!);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveRideScreen(rideData: payload),
        ),
      );
    });
  }

  String _getSubheading(bool isArabic) {
    switch (widget.bookingType) {
      case ManualBookingType.findTrip:
        return isArabic
            ? 'نبحث عن سائق مناسب لرحلتك.\nقد يستغرق إيجاد السائق المناسب عدة ساعات.'
            : "We're looking for a driver who matches your trip.\nFinding the right driver may take several hours.";
      case ManualBookingType.parcel:
        return isArabic
            ? 'يقوم فريقنا بالتنسيق مع سائق مناسب لتوصيل شحنتك.\nقد يستغرق ذلك عدة ساعات.'
            : "Our team is coordinating with a suitable driver for your delivery.\nFinding the right driver may take several hours.";
      case ManualBookingType.entireCar:
        return isArabic
            ? 'يقوم فريقنا بترتيب مركبة وسائق مناسب لحجزك.\nقد يستغرق التنسيق عدة ساعات.'
            : "Our team is arranging a suitable vehicle and driver for your booking.\nFinding the right driver may take several hours.";
    }
  }

  String _getFindingDriverText(bool isArabic) {
    switch (widget.bookingType) {
      case ManualBookingType.findTrip:
        return isArabic
            ? 'نبحث عن سائق يطابق تفاصيل رحلتك.'
            : "We're searching for a driver who matches your trip details.";
      case ManualBookingType.parcel:
        return isArabic
            ? 'نبحث عن سائق متوجه إلى نفس الوجهة لاستلام الشحنة.'
            : "We're searching for a driver heading to your parcel destination.";
      case ManualBookingType.entireCar:
        return isArabic
            ? 'نبحث عن مركبة خاصة وسائق يلائم طلبك بالكامل.'
            : "We're searching for a private vehicle & driver tailored to your request.";
    }
  }

  Future<void> _cancelRequest() async {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = locale.isArabic;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isArabic ? 'إلغاء الطلب' : 'Cancel Request',
          style: TextStyle(fontFamily: isArabic ? 'NotoKufiArabic' : null, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟'
              : 'Are you sure you want to cancel this request?',
          style: TextStyle(fontFamily: isArabic ? 'NotoKufiArabic' : null),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isArabic ? 'تراجع' : 'No', style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isArabic ? 'نعم، إلغاء' : 'Yes, Cancel', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);

    try {
      if (widget.requestId != null && widget.requestId!.isNotEmpty) {
        final api = Provider.of<ApiService>(context, listen: false);
        final storage = Provider.of<StorageService>(context, listen: false);
        final token = await storage.getToken();

        // Attempt cancel on backend
        try {
          if (widget.bookingType == ManualBookingType.parcel) {
            await api.dio.post(
              '/parcels/reject',
              data: {'parcelId': widget.requestId},
              options: Options(headers: {'Authorization': 'Bearer $token'}),
            );
          } else {
            await api.dio.post(
              '/rides/cancel',
              data: {'rideId': widget.requestId},
              options: Options(headers: {'Authorization': 'Bearer $token'}),
            );
          }
        } catch (_) {}
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isCancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم إلغاء الطلب بنجاح' : 'Request cancelled successfully'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Brand Header: Yalla | يـلّا
                const SizedBox(height: 10),
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Yalla',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'يَلّا',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryOrange,
                          fontFamily: 'NotoKufiArabic',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Illustration Banner: City skyline + Car + Map Pin
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 600),
                  child: SizedBox(
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft warm glowing gradient backdrop
                        Container(
                          width: 220,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryOrange.withOpacity(0.08),
                          ),
                        ),
                        // Car image from assets
                        Image.asset(
                          'assets/images/outside.png',
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.directions_car_filled_rounded,
                            size: 80,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        // Floating Map Pin on top
                        Positioned(
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryOrange.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title: Request Received
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    isArabic ? 'تم استلام الطلب' : 'Request Received',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1F2937),
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Dynamic Subtitle Text
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _getSubheading(isArabic),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Card: Stepper / Process Status Card
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF0EBE1)),
                    ),
                    child: Column(
                      children: [
                        // Step 1: Request submitted (Completed - Orange tick)
                        _buildStepItem(
                          icon: Icons.check,
                          iconBgColor: AppColors.primaryOrange,
                          iconColor: Colors.white,
                          title: isArabic ? 'تم إرسال الطلب' : 'Request submitted',
                          badgeText: null,
                          badgeColor: null,
                          desc: isArabic ? 'تم استلام تفاصيل طلبك بنجاح.' : 'Your request has been received.',
                          hasConnector: true,
                          connectorActive: true,
                          isArabic: isArabic,
                        ),

                        // Step 2: Finding a suitable driver
                        _buildStepItem(
                          icon: _driverConfirmed ? Icons.check : Icons.radio_button_checked,
                          iconBgColor: AppColors.primaryOrange,
                          iconColor: Colors.white,
                          title: isArabic ? 'جاري البحث عن سائق مناسب' : 'Finding a suitable driver',
                          badgeText: _driverConfirmed ? null : (isArabic ? 'قيد التنفيذ' : 'In progress'),
                          badgeColor: _driverConfirmed ? null : const Color(0xFFFEF3C7),
                          badgeTextColor: const Color(0xFFD97706),
                          desc: _driverConfirmed
                              ? (isArabic ? 'تم العثور على السائق المناسب!' : 'Matching driver found!')
                              : _getFindingDriverText(isArabic),
                          hasConnector: true,
                          connectorActive: _driverConfirmed,
                          isArabic: isArabic,
                        ),

                        // Step 3: Driver confirmed
                        _buildStepItem(
                          icon: _driverConfirmed ? Icons.check : Icons.radio_button_unchecked,
                          iconBgColor: _driverConfirmed ? AppColors.primaryOrange : Colors.white,
                          iconColor: _driverConfirmed ? Colors.white : const Color(0xFF9CA3AF),
                          title: isArabic ? 'تأكيد السائق' : 'Driver confirmed',
                          badgeText: _driverConfirmed
                              ? (isArabic ? 'تم التأكيد' : 'Confirmed')
                              : (isArabic ? 'في الانتظار' : 'Waiting'),
                          badgeColor: _driverConfirmed ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                          badgeTextColor: _driverConfirmed ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
                          desc: _driverConfirmed
                              ? (isArabic
                                  ? 'تم تأكيد السائق بنجاح! جاري الانتقال إلى الخريطة...'
                                  : 'Driver confirmed! Navigating to live map...')
                              : (isArabic
                                  ? 'سيتم تعيين السائق فور العثور على أنسب خيار.'
                                  : 'A driver will be assigned once a suitable match is found.'),
                          hasConnector: false,
                          connectorActive: false,
                          isArabic: isArabic,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Notification Alert Pill
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9EE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A).withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: AppColors.primaryOrange, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isArabic
                                ? 'سنقوم بإشعارك فور تأكيد وحجز السائق.'
                                : "We'll notify you as soon as a driver is confirmed.",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF92400E),
                              fontFamily: isArabic ? 'NotoKufiArabic' : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Trust Badges: Safe | Fast | Reliable
                FadeInUp(
                  delay: const Duration(milliseconds: 550),
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTrustBadge(Icons.shield_outlined, isArabic ? 'آمن' : 'Safe', isArabic),
                      Container(width: 1, height: 28, color: const Color(0xFFE5E7EB)),
                      _buildTrustBadge(Icons.speed_rounded, isArabic ? 'سريع' : 'Fast', isArabic),
                      Container(width: 1, height: 28, color: const Color(0xFFE5E7EB)),
                      _buildTrustBadge(Icons.star_rounded, isArabic ? 'موثوق' : 'Reliable', isArabic),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Cancel Request Button
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  duration: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEE2E2),
                        foregroundColor: const Color(0xFFDC2626),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      onPressed: _isCancelling ? null : _cancelRequest,
                      child: _isCancelling
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFDC2626)),
                            )
                          : Text(
                              isArabic ? 'إلغاء الطلب' : 'Cancel Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFDC2626),
                                fontFamily: isArabic ? 'NotoKufiArabic' : null,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Back to Home Text Button
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const PassengerMainScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    isArabic ? 'العودة إلى الصفحة الرئيسية' : 'Back to Home',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String? badgeText,
    required Color? badgeColor,
    Color? badgeTextColor,
    required String desc,
    required bool hasConnector,
    required bool connectorActive,
    required bool isArabic,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Indicator & Connector line
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconBgColor == Colors.white ? const Color(0xFFD1D5DB) : iconBgColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 14, color: iconColor),
                ),
              ),
              if (hasConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: connectorActive ? AppColors.primaryOrange : const Color(0xFFD1D5DB),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: hasConnector ? 22 : 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                          fontFamily: isArabic ? 'NotoKufiArabic' : null,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeTextColor,
                              fontFamily: isArabic ? 'NotoKufiArabic' : null,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: const Color(0xFF6B7280),
                      fontFamily: isArabic ? 'NotoKufiArabic' : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String label, bool isArabic) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFEDD5)),
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4B5563),
            fontFamily: isArabic ? 'NotoKufiArabic' : null,
          ),
        ),
      ],
    );
  }
}
