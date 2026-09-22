import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/providers/locale_provider.dart';
import 'payment_method_screen.dart';
import 'language_screen.dart';
import 'support_screen.dart';
import 'passenger_trips_screen.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  dynamic _user;
  dynamic _wallet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final api     = Provider.of<ApiService>(context, listen: false);
      final storage = Provider.of<StorageService>(context, listen: false);
      final token   = await storage.getToken();
      if (token == null) { setState(() => _isLoading = false); return; }

      final results = await Future.wait([
        api.getProfile(token),
        api.getWallet(token),
      ]);

      setState(() {
        _user   = results[0].data['user'];
        _wallet = results[1].data['wallet'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Compute dynamic user name from database profile
    String displayName = '';
    if (_user != null) {
      final first = (_user['firstName'] ?? '').toString().trim();
      final last = (_user['lastName'] ?? '').toString().trim();
      if (first.isNotEmpty || last.isNotEmpty) {
        displayName = '$first $last'.trim();
      } else if (_user['phone'] != null && _user['phone'].toString().isNotEmpty) {
        displayName = _user['phone'].toString();
      }
    }
    if (displayName.isEmpty) {
      displayName = localeProvider.tr('passenger');
    }

    final totalTrips = _user?['totalRides'] != null ? '${_user!['totalRides']}' : '0';
    final activeHours = _user?['activeHours'] != null ? '${_user!['activeHours']}' : '1';
    final walletBalance = _wallet?['balance'] != null 
        ? '${_wallet!['balance']} IQD' 
        : (_user?['wallet']?['balance'] != null ? '${_user!['wallet']['balance']} IQD' : '0 IQD');

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          localeProvider.tr('profile'), 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)
                        ),
                      ),
                      const SizedBox(height: 40),
            
                      // ── Avatar + Welcome Message ─────────────────────────────
                      FadeInDown(
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: const CircleAvatar(
                                radius: 45,
                                backgroundColor: Color(0xFFF8F8F8),
                                child: Icon(Icons.person, size: 50, color: AppColors.primaryOrange),
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  localeProvider.tr('welcome'), 
                                  style: const TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.w500)
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayName, 
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
            
                      const SizedBox(height: 35),
            
                      // ── Stats Card ───────────────────────────────────────────
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(Icons.timer_outlined, activeHours, localeProvider.tr('hours')),
                              _buildStatItem(Icons.directions_car_outlined, totalTrips, localeProvider.tr('trips')),
                              _buildStatItem(Icons.wallet_outlined, walletBalance, localeProvider.tr('wallet')),
                            ],
                          ),
                        ),
                      ),
            
                      const SizedBox(height: 35),
            
                      // ── Menu Items ───────────────────────────────────────────
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            _buildFormattedMenuItem(Icons.credit_card, localeProvider.tr('payment_method'), () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodScreen()));
                            }),
                            _buildFormattedMenuItem(Icons.map_outlined, localeProvider.tr('trips'), () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerTripsScreen()));
                            }),
                            _buildFormattedMenuItem(Icons.language, localeProvider.tr('language'), () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen()));
                            }),
                            _buildFormattedMenuItem(Icons.support_agent_outlined, localeProvider.tr('support'), () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                            }),
                            const SizedBox(height: 10),
                            _buildFormattedMenuItem(Icons.logout, localeProvider.tr('sign_out'), () async {
                              final storage = Provider.of<StorageService>(context, listen: false);
                              await storage.clear();
                              if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/signin', (_) => false);
                            }),
                            _buildFormattedMenuItem(
                              Icons.delete_forever_rounded, 
                              localeProvider.tr('delete_account'), 
                              () => _showDeleteAccountDialog(context),
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ),
            
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
          ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(localeProvider.tr('delete_account'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        content: Text(
          localeProvider.isArabic
            ? 'هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟\n\n• سيتم مسح بياناتك الشخصية وسجل الرحلات.\n• سيتم إلغاء رصيد المحفظة.\n• هذا الإجراء فوري ولا يمكن التراجع عنه.'
            : 'Are you sure you want to permanently delete your account?\n\n'
              '• Your personal profile and booking history will be permanently deleted.\n'
              '• Your wallet balance and records will be removed.\n'
              '• This action is immediate and cannot be undone.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(localeProvider.tr('cancel'), style: const TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.red)),
              );

              try {
                final api = Provider.of<ApiService>(context, listen: false);
                final storage = Provider.of<StorageService>(context, listen: false);
                final token = await storage.getToken();
                if (token != null) {
                  await api.deleteAccount(token);
                }
                await storage.clear();
                if (context.mounted) {
                  Navigator.pop(context); // dismiss loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localeProvider.isArabic ? 'تم حذف حسابك بنجاح.' : 'Your account has been deleted successfully.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil('/signin', (_) => false);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // dismiss loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localeProvider.isArabic ? 'فشل حذف الحساب. حاول مرة أخرى.' : 'Failed to delete account. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(localeProvider.tr('delete_permanently'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFormattedMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDestructive ? const Color(0xFFFFF5F5) : Colors.white,
        border: Border.all(
          color: isDestructive ? Colors.red.withOpacity(0.35) : Colors.black12,
          width: isDestructive ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black, size: 22),
        title: Text(
          title, 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600, 
            color: isDestructive ? Colors.red : Colors.black,
          ),
        ),
        subtitle: isDestructive 
          ? Text(
              Provider.of<LocaleProvider>(context).isArabic ? 'حذف الحساب نهائياً' : 'Permanently delete account',
              style: const TextStyle(color: Colors.redAccent, fontSize: 11)
            ) 
          : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDestructive ? Colors.red : Colors.black),
        onTap: onTap,
      ),
    );
  }
}
