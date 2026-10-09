import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/providers/locale_provider.dart';

class PassengerChatScreen extends StatefulWidget {
  final String rideId;
  final String driverName;
  final String? driverPhone;

  const PassengerChatScreen({
    super.key,
    required this.rideId,
    required this.driverName,
    this.driverPhone,
  });

  @override
  State<PassengerChatScreen> createState() => _PassengerChatScreenState();
}

class _PassengerChatScreenState extends State<PassengerChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    final api = Provider.of<ApiService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context, listen: false);

    _myUserId = await storage.getUserId();
    final token = await storage.getToken();

    // Ensure joined to ride room
    socketService.joinRide(widget.rideId);

    // Fetch message history from backend
    if (token != null) {
      try {
        final res = await api.getChatMessages(widget.rideId, token);
        if (res.statusCode == 200 && mounted) {
          final List<dynamic> history = res.data['messages'] ?? [];
          setState(() {
            _messages.addAll(history.map((m) => {
              'id': m['id'],
              'text': m['text'] ?? '',
              'isMe': m['senderId'] == _myUserId,
              'createdAt': m['createdAt'],
            }));
            _isLoading = false;
          });
          _scrollToBottom();
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }

    // Listen for incoming messages in real-time
    socketService.onNewMessage = (data) {
      if (!mounted) return;
      if (data is Map) {
        final senderId = data['senderId']?.toString();
        // If message is from other party (driver)
        if (senderId != _myUserId) {
          setState(() {
            _messages.add({
              'id': data['id'],
              'text': data['text'] ?? '',
              'isMe': false,
              'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
            });
          });
          _scrollToBottom();
        }
      }
    };
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = (presetText ?? _msgController.text).trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _msgController.clear();
    }

    // Add locally for instant UI responsiveness
    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();

    // Emit via socket to driver & database
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket?.emit('send_message', {
      'rideId': widget.rideId,
      'text': text,
      'senderId': _myUserId,
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final isArabic = locale.isArabic;

    final quickReplies = isArabic
        ? ['أنا في انتظارك في نقطة الانطلاق', 'أنا قادم الآن', 'ما هو لون السيارة؟']
        : ['I am at the pickup spot', 'Coming down now!', 'What color is your car?'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryOrange.withOpacity(0.15),
              child: const Icon(Icons.person, color: AppColors.primaryOrange, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.driverName,
                  style: GoogleFonts.outfit(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isArabic ? 'كابتن الرحلة' : 'Trip Captain',
                  style: GoogleFonts.inter(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 54, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                isArabic ? 'تواصل مباشرة مع الكابتن' : 'Send a message to your driver',
                                style: GoogleFonts.inter(fontSize: 14, color: Colors.black45),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = msg['isMe'] == true;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                decoration: BoxDecoration(
                                  color: isMe ? AppColors.primaryOrange : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(18).copyWith(
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                                    bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  msg['text'] ?? '',
                                  style: GoogleFonts.inter(
                                    color: isMe ? Colors.white : Colors.black87,
                                    fontSize: 14.5,
                                    fontWeight: isMe ? FontWeight.w600 : FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Quick Reply Chips
            Container(
              height: 38,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    label: Text(
                      quickReplies[index],
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
                    ),
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () => _sendMessage(quickReplies[index]),
                  );
                },
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _msgController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        style: GoogleFonts.inter(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: isArabic ? 'اكتب رسالة للكابتن...' : 'Type a message to captain...',
                          hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black38),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x55FF9F45),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
