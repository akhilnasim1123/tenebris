import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_dot/providers/app_provider.dart';
import 'package:wallet_dot/widgets/common/ConfirmationDialog.dart';

class PersonalManagement extends StatefulWidget {
  const PersonalManagement({super.key});

  @override
  State<PersonalManagement> createState() => _PersonalManagementState();
}

class _PersonalManagementState extends State<PersonalManagement> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final creditTotal = provider.personalDebts
        .where((d) => d['type'] == 'credit' && (d['status'] ?? 'active') == 'active')
        .fold(0.0, (s, i) => s + (i['amount'] ?? 0.0));
    final debitTotal = provider.personalDebts
        .where((d) => d['type'] == 'debit' && (d['status'] ?? 'active') == 'active')
        .fold(0.0, (s, i) => s + (i['amount'] ?? 0.0));

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        title: Text(
          'My Debts & Credits',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF121B2A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'They Owe Me', 
                        creditTotal, 
                        const Color(0xFF10B981), 
                        Icons.south_west_rounded
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.08)),
                    Expanded(
                      child: _buildSummaryItem(
                        'I Owe Them', 
                        debitTotal, 
                        const Color(0xFFF43F5E), 
                        Icons.north_east_rounded
                      ),
                    ),
                  ],
                ),
              ),

              // List Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Records',
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => _showAddDebtSheet(context),
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF2DD4BF)),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: provider.personalDebts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: provider.personalDebts.length,
                        itemBuilder: (context, index) {
                          final debt = provider.personalDebts[index];
                          final isCredit = debt['type'] == 'credit';
                          final accentColor = isCredit ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
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
                                    color: accentColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: accentColor.withOpacity(0.12)),
                                  ),
                                  child: Icon(
                                    isCredit ? Icons.person_remove_alt_1 : Icons.person_add_alt_1,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              debt['title'] ?? 'No Title',
                                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (debt['status'] != null && debt['status'] != 'active')
                                            _buildStatusBadge(debt['status']),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        debt['person'] ?? 'Unknown',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₹${debt['amount']}",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: accentColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if ((debt['status'] ?? 'active') == 'active') ...[
                                          GestureDetector(
                                            onTap: provider.isBusy ? null : () => ConfirmationDialog.show(
                                              context,
                                              title: 'Settle Record',
                                              message: 'Mark this record as settled? This usually means the amount was paid.',
                                              onConfirm: () => provider.updatePersonalDebt(debt['id'], debt['title'], (debt['amount'] as num).toDouble(), debt['type'], debt['person'], status: 'settled'),
                                            ),
                                            child: Icon(Icons.check_circle_outline_rounded, color: const Color(0xFF10B981).withOpacity(0.6), size: 18),
                                          ),
                                          const SizedBox(width: 12),
                                          GestureDetector(
                                            onTap: provider.isBusy ? null : () => ConfirmationDialog.show(
                                              context,
                                              title: 'Reject Record',
                                              message: 'Mark this record as rejected? This means the debt/credit is no longer valid.',
                                              confirmColor: const Color(0xFF0EA5E9),
                                              onConfirm: () => provider.updatePersonalDebt(debt['id'], debt['title'], (debt['amount'] as num).toDouble(), debt['type'], debt['person'], status: 'rejected'),
                                            ),
                                            child: Icon(Icons.cancel_outlined, color: const Color(0xFF0EA5E9).withOpacity(0.6), size: 18),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        GestureDetector(
                                          onTap: provider.isBusy ? null : () => _showAddDebtSheet(context, existingDebt: debt),
                                          child: Icon(Icons.edit_outlined, color: Colors.white.withOpacity(0.4), size: 16),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: provider.isBusy ? null : () => ConfirmationDialog.show(
                                            context,
                                            title: 'Delete Record',
                                            message: 'Are you sure you want to permanently delete this record?',
                                            confirmColor: const Color(0xFFF43F5E),
                                            onConfirm: () => provider.deletePersonalDebt(debt['id']),
                                          ),
                                          child: Icon(Icons.delete_outline_rounded, color: const Color(0xFFF43F5E).withOpacity(0.5), size: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (provider.isBusy)
            _buildLoadingOverlay(),
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

  Widget _buildStatusBadge(String? status) {
    if (status == null) return const SizedBox.shrink();
    Color color = Colors.grey;
    if (status == 'settled') color = const Color(0xFF10B981);
    if (status == 'rejected') color = const Color(0xFF0EA5E9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.badge_outlined, color: Colors.white.withOpacity(0.15), size: 64),
          const SizedBox(height: 16),
          Text(
            'No personal records logged.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showAddDebtSheet(BuildContext context, {Map<String, dynamic>? existingDebt}) {
    final titleController = TextEditingController(text: existingDebt?['title'] ?? '');
    final personController = TextEditingController(text: existingDebt?['person'] ?? '');
    final amountController = TextEditingController(text: existingDebt?['amount']?.toString() ?? '');
    String selectedType = existingDebt?['type'] ?? 'credit';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121B2A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Container(
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
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24, right: 24, top: 28
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existingDebt == null ? 'Add Personal Record' : 'Edit Personal Record',
                        style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        existingDebt == null ? 'Record a new credit or debt relationship.' : 'Modify details of this credit or debt.',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      
                      // Type Switcher
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0E17),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _buildTypeOption(setModalState, 'They Owe Me', 'credit', selectedType, (val) => selectedType = val),
                            _buildTypeOption(setModalState, 'I Owe Them', 'debit', selectedType, (val) => selectedType = val),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildField('Title / Description', titleController, 'e.g., Loan for phone'),
                      const SizedBox(height: 16),
                      _buildField('Person Name', personController, 'e.g., John Doe'),
                      const SizedBox(height: 16),
                      _buildField('Amount', amountController, '0.00', isNumber: true),
                      
                      const SizedBox(height: 30),
                      Consumer<AppProvider>(
                        builder: (context, provider, _) => GestureDetector(
                          onTap: provider.isBusy ? null : () async {
                            if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                              final amount = double.tryParse(amountController.text) ?? 0.0;
                              if (existingDebt == null) {
                                await provider.addPersonalDebt(titleController.text, amount, selectedType, personController.text);
                              } else {
                                await provider.updatePersonalDebt(existingDebt['id'], titleController.text, amount, selectedType, personController.text);
                              }
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: provider.isBusy 
                                  ? [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.3)] 
                                  : [const Color(0xFF2DD4BF), const Color(0xFF0EA5E9)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                if (!provider.isBusy)
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF).withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                              ],
                            ),
                            child: Center(
                              child: provider.isBusy
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    existingDebt == null ? 'Add Record' : 'Save Changes', 
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }
          ),
        );
      }
    );
  }

  Widget _buildTypeOption(StateSetter setModalState, String label, String value, String current, Function(String) onSelect) {
    final isSelected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => onSelect(value)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2DD4BF).withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? const Color(0xFF2DD4BF) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
}
