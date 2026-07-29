import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import 'parcel_summary_screen.dart';

class ParcelSenderDetailScreen extends StatefulWidget {
  const ParcelSenderDetailScreen({super.key});

  @override
  State<ParcelSenderDetailScreen> createState() => _ParcelSenderDetailScreenState();
}

class _ParcelSenderDetailScreenState extends State<ParcelSenderDetailScreen> {
  String selectedDate = 'Choose date';
  String selectedTime = 'Choose time';
  String? selectedSendingGov;
  final List<String> governorates = ['Kirkuk', 'Bagdad', 'Erbil', 'Basra', 'Najaf', 'Karbala', 'Mosul'];

  // Recipient fields
  final TextEditingController _recipientNameCtrl = TextEditingController();
  final TextEditingController _recipientPhoneCtrl = TextEditingController();

  // Sender phone — change option
  final TextEditingController _senderPhoneCtrl = TextEditingController(text: '');
  bool _editingSenderPhone = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => selectedDate = "${picked.day}/${picked.month}/${picked.year}");
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => selectedTime = picked.format(context));
    }
  }

  @override
  void dispose() {
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _senderPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header
              FadeInDown(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Sending',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Form
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date & Time
                      const Text('Date & Time',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _buildActionButton(selectedDate, () => _selectDate(context))),
                          const SizedBox(width: 15),
                          Expanded(child: _buildActionButton(selectedTime, () => _selectTime(context))),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Recipient Information
                      const Text('Recipient Information',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 15),
                      _buildTextField('Recipient name', controller: _recipientNameCtrl),
                      const SizedBox(height: 15),
                      _buildTextField('Recipient number', controller: _recipientPhoneCtrl, keyboardType: TextInputType.phone),
                      const SizedBox(height: 15),
                      _buildDropdown('Choose the Sending governorate', selectedSendingGov,
                          governorates, (val) => setState(() => selectedSendingGov = val!)),
                      const SizedBox(height: 15),
                      _buildTextField('Choose sending region'),
                      const SizedBox(height: 25),

                      // Sender phone change — "Sending mail 2" feature
                      const Text('Sender Phone',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _editingSenderPhone
                                  ? TextField(
                                      controller: _senderPhoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter sender phone number',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.black38),
                                      ),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    )
                                  : Text(
                                      _senderPhoneCtrl.text.isEmpty
                                          ? 'Your phone number'
                                          : _senderPhoneCtrl.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _senderPhoneCtrl.text.isEmpty
                                            ? Colors.black38
                                            : Colors.black,
                                      ),
                                    ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _editingSenderPhone = !_editingSenderPhone),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _editingSenderPhone ? 'Save' : 'Change',
                                  style: const TextStyle(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Next Button
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 8,
                      shadowColor: Colors.black26,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ParcelSummaryScreen()));
                    },
                    child: const Text('Next', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Center(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {TextEditingController? controller, TextInputType? keyboardType}) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(fontSize: 16, color: Colors.black26),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 15, color: Colors.black45)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 28),
          style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
