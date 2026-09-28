import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import 'passenger_success_screen.dart';

class PassengerOtpScreen extends StatefulWidget {
  const PassengerOtpScreen({super.key});

  @override
  State<PassengerOtpScreen> createState() => _PassengerOtpScreenState();
}

class _PassengerOtpScreenState extends State<PassengerOtpScreen> {
  static const int _otpLength = 4;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isLoading = false;

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _verify() async {
    if (_otp.length < _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 4-digit code.')),
      );
      return;
    }
    _dismissKeyboard();
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.verifyOtp(_otp);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PassengerSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  void _onOtpChanged(String val, int index) {
    if (val.length > 1) {
      final digits = val.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextFocus = digits.length < _otpLength ? digits.length : _otpLength - 1;
      _focusNodes[nextFocus].requestFocus();
      setState(() {});
      if (_otp.length == _otpLength) _verify();
      return;
    }

    if (val.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _dismissKeyboard();
        if (_otp.length == _otpLength) _verify();
      }
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: AppColors.primaryOrange,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // White Card at top
                        Expanded(
                          child: FadeInDown(
                            duration: const Duration(milliseconds: 600),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(50),
                                  bottomRight: Radius.circular(50),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Enter Verification Code',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'We sent a 4-digit code to your number',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  // OTP Boxes
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: List.generate(_otpLength, (i) {
                                        return _OtpBox(
                                          controller: _controllers[i],
                                          focusNode: _focusNodes[i],
                                          onChanged: (val) => _onOtpChanged(val, i),
                                          onKeyEvent: (node, event) =>
                                              _onKeyEvent(node, event, i),
                                        );
                                      }),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: _dismissKeyboard,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.keyboard_hide_rounded, size: 18, color: Colors.black38),
                                        SizedBox(width: 6),
                                        Text(
                                          'Tap anywhere to hide keyboard',
                                          style: TextStyle(fontSize: 13, color: Colors.black38),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Verify Button
                        Padding(
                          padding: EdgeInsets.fromLTRB(32, 12, 32, isKeyboardOpen ? 12 : 30),
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 8,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _verify,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryOrange,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Verify',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final FocusOnKeyEventCallback onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode.hasFocus;
    final isFilled = controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 58,
      height: 64,
      decoration: BoxDecoration(
        color: isFilled
            ? AppColors.primaryOrange.withOpacity(0.08)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused
              ? AppColors.primaryOrange
              : isFilled
                  ? AppColors.primaryOrange.withOpacity(0.5)
                  : Colors.grey.shade300,
          width: isFocused ? 2.5 : 1.5,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primaryOrange.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Center(
        child: Focus(
          onKeyEvent: onKeyEvent,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
