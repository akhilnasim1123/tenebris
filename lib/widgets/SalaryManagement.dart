import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tenebris/providers/app_provider.dart';
import 'package:tenebris/widgets/common/ConfirmationDialog.dart';

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
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Salary Tracking', style: GoogleFonts.medievalSharp(letterSpacing: 2)),
        actions: [
          IconButton(
            onPressed: () => _showAddSalarySheet(context, provider),
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF947A57)),
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
                _buildSectionTitle('Recieved Salaries'),
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
      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
    );
  }

  Widget _buildSalaryCard(Map<String, dynamic> salary, AppProvider provider, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending ? BootstrapIcons.clock_history : BootstrapIcons.check2_circle,
              color: isPending ? Colors.orangeAccent : Colors.greenAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(salary['title'] ?? 'Salary', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(salary['month'] ?? 'N/A', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${salary['amount']}',
                style: GoogleFonts.medievalSharp(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isPending)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(BootstrapIcons.check2_circle, color: Colors.greenAccent, size: 20),
                      onPressed: () => _showSettleSalarySheet(context, provider, salary),
                    ),
                    IconButton(
                      icon: const Icon(BootstrapIcons.trash, color: Colors.grey, size: 18),
                      onPressed: () => ConfirmationDialog.show(
                        context,
                        title: 'Delete Salary Entry',
                        message: 'Are you sure you want to delete this salary record?',
                        confirmColor: Colors.redAccent,
                        onConfirm: () => provider.deleteSalary(salary['id']),
                      ),
                    ),
                  ],
                ),
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
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Salary Expectation', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 24),
                _buildField('Company / Source', titleController, 'e.g., Company X Salary'),
                const SizedBox(height: 16),
                _buildField('For Month', monthController, 'e.g., October 2023'),
                const SizedBox(height: 16),
                _buildField('Expected Amount', amountController, '0.00', isNumber: true),
                const SizedBox(height: 32),
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
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF947A57), Color(0xFF7D6442)]), borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Text('Add Pending Salary', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Receive Salary', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Settling salary for ${salary['month']}', style: GoogleFonts.outfit(color: Colors.grey)),
                const SizedBox(height: 24),
                _buildField('Final Received Amount', amountController, '0.00', isNumber: true),
                const SizedBox(height: 24),
                Text('Receive in:', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12)),
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
                    decoration: BoxDecoration(color: const Color(0xFF947A57), borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Text('Confirm Receipt', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
        Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: GoogleFonts.outfit(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.1)),
            filled: true,
            fillColor: const Color(0xFF0A0A0A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
            color: isSelected ? const Color(0xFF947A57).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFF947A57) : Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.outfit(color: isSelected ? const Color(0xFF947A57) : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
          Icon(BootstrapIcons.cash_stack, color: Colors.white.withOpacity(0.05), size: 64),
          const SizedBox(height: 16),
          Text('No salary history.', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2))),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF947A57).withOpacity(0.3)),
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
                color: Color(0xFF947A57),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Processing...',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
