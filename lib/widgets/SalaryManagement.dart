import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_dot/providers/app_provider.dart';
import 'package:wallet_dot/widgets/common/ConfirmationDialog.dart';

class SalaryManagement extends StatefulWidget {
  const SalaryManagement({super.key});

  @override
  State<SalaryManagement> createState() => _SalaryManagementState();
}

class _SalaryManagementState extends State<SalaryManagement> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final pendingSalaries = provider.salaries.where((s) => s['status'] == 'pending').toList();
    final recievedSalaries = provider.salaries.where((s) => s['status'] == 'recieved').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Salary Tracking',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _showAddSalarySheet(context, provider),
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF2DD4BF)),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              if (pendingSalaries.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildSectionTitle('Pending Salaries'),
                const SizedBox(height: 15),
                ...pendingSalaries.map((s) => _buildSalaryCard(s, provider, true)).toList(),
              ],
              if (recievedSalaries.isNotEmpty) ...[
                const SizedBox(height: 30),
                _buildSectionTitle('Received Salaries'),
                const SizedBox(height: 15),
                ...recievedSalaries.map((s) => _buildSalaryCard(s, provider, false)).toList(),
              ],
              if (provider.salaries.isEmpty)
                _buildEmptyState(),
              const SizedBox(height: 100),
            ],
          ),
          if (provider.isBusy)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
    );
  }

  Widget _buildSalaryCard(Map<String, dynamic> salary, AppProvider provider, bool isPending) {
    final statusColor = isPending ? const Color(0xFF2DD4BF) : const Color(0xFF10B981);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: statusColor.withOpacity(0.12)),
            ),
            child: Icon(
              isPending ? Icons.history_toggle_off_rounded : Icons.check_circle_outline_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(salary['title'] ?? 'Salary', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(salary['month'] ?? 'N/A', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${salary['amount']}',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (isPending) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 20),
                      onPressed: () => _showSettleSalarySheet(context, provider, salary),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                      onPressed: () => ConfirmationDialog.show(
                        context,
                        title: 'Delete Salary Entry',
                        message: 'Are you sure you want to delete this salary record?',
                        confirmColor: const Color(0xFFF43F5E),
                        onConfirm: () => provider.deleteSalary(salary['id']),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSalarySheet(BuildContext context, AppProvider provider) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final monthController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121B2A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121B2A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF2DD4BF).withOpacity(0.2),
              width: 1.5,
            ),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Salary Expectation', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Add a pending expectation to track your incoming salary.', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13)),
                  const SizedBox(height: 24),
                  _buildField('Company / Source', titleController, 'e.g., Company X Salary'),
                  const SizedBox(height: 16),
                  _buildField('For Month', monthController, 'e.g., October 2023'),
                  const SizedBox(height: 16),
                  _buildField('Expected Amount', amountController, '0.00', isNumber: true),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () async {
                      if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                        final amount = double.tryParse(amountController.text) ?? 0.0;
                        await provider.addSalary(
                          titleController.text,
                          amount,
                          monthController.text,
                          DateTime.now().toIso8601String()
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2DD4BF).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Center(child: Text('Add Pending Salary', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettleSalarySheet(BuildContext context, AppProvider provider, Map<String, dynamic> salary) {
    String paymentMethod = 'account';
    final amountController = TextEditingController(text: salary['amount'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121B2A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121B2A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF2DD4BF).withOpacity(0.2),
              width: 1.5,
            ),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Receive Salary', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Settling salary for ${salary['month']}', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13)),
                  const SizedBox(height: 24),
                  _buildField('Final Received Amount', amountController, '0.00', isNumber: true),
                  const SizedBox(height: 24),
                  Text('Receive in:', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMethodOption('Account', 'account', paymentMethod, (val) => setModalState(() => paymentMethod = val)),
                      const SizedBox(width: 12),
                      _buildMethodOption('In Hand', 'in_hand', paymentMethod, (val) => setModalState(() => paymentMethod = val)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () async {
                      final amount = double.tryParse(amountController.text) ?? 0.0;
                      await provider.settleSalary(salary['id'], amount, paymentMethod);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2DD4BF).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Center(child: Text('Confirm Receipt', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.2)),
            filled: true,
            fillColor: const Color(0xFF0A0E17),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodOption(String label, String value, String current, Function(String) onSelect) {
    final isSelected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.04),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? const Color(0xFF2DD4BF) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.monetization_on_outlined, color: Colors.white.withOpacity(0.15), size: 64),
          const SizedBox(height: 16),
          Text('No salary history.', style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF121B2A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF2DD4BF),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Processing...',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
