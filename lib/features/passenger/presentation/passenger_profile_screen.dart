import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
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
    final firstName = _user?['firstName'] ?? 'Yasser!';
    final walletBalance = _wallet?['balance'] != null ? '${_wallet!['balance']}' : '10';

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
                      const Center(
                        child: Text('Profile', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)
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
                                radius: 55,
                                backgroundColor: Color(0xFFF8F8F8),
                                child: Icon(Icons.person, size: 60, color: Colors.black),
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Welcome', style: TextStyle(fontSize: 22, color: Colors.black54, fontWeight: FontWeight.w500)),
                                Text('$firstName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black)),
                              ],
                            ),
                          ],
                        ),
                      ),
            
                      const SizedBox(height: 40),
            
                      // ── Stats Card ───────────────────────────────────────────
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(Icons.timer_outlined, '10', 'Hours'),
                              _buildStatItem(Icons.directions_car_outlined, '10', 'Trips'),
                              _buildStatItem(Icons.wallet_outlined, walletBalance, 'Wallet'),
                            ],
                          ),
                        ),
                      ),
            
                      const SizedBox(height: 40),
            
                      // ── Menu Items ───────────────────────────────────────────
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            _buildFormattedMenuItem(Icons.credit_card, 'Payment method', () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodScreen()));
                            }),
                            _buildFormattedMenuItem(Icons.map_outlined, 'Trips', () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerTripsScreen()));
                            }),
                            _buildFormattedMenuItem(Icons.language, 'Language', () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen()));
                            }),
                            _buildFormattedMenuItem(Icons.support_agent_outlined, 'Support', () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                            }),
                            const SizedBox(height: 20),
                            _buildFormattedMenuItem(Icons.logout, 'Sign Out', () async {
                              final storage = Provider.of<StorageService>(context, listen: false);
                              await storage.clear();
                              if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/signin', (_) => false);
                            }, isDestructive: true),
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

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFormattedMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.primaryOrange, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.withOpacity(0.08) : AppColors.primaryOrange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : AppColors.primaryOrange, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDestructive ? Colors.red : Colors.black87)),
        trailing: Icon(Icons.arrow_forward_ios, size: 13, color: isDestructive ? Colors.red.withOpacity(0.4) : Colors.black26),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTxTile(dynamic tx) {
    final amount = tx['amount'] != null ? '${tx['amount']} IQD' : '--';
    final type   = tx['type'] ?? 'DEBIT';
    final isCredit = type == 'CREDIT';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? Colors.green : Colors.red, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(tx['description'] ?? type, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isCredit ? Colors.green : Colors.red)),
      ]),
    );
  }
}
