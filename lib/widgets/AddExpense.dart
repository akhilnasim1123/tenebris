import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:tenebris/providers/app_provider.dart';
import 'package:tenebris/widgets/common/ConfirmationDialog.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Food';
  String _type = 'expense';
  String _paymentMethod = 'account';
  bool _excludeFromBalance = false;
  
  final List<String> _categories = [
    'Food', 'Travel', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Income', 'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('Add Record', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Switcher
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() { _type = 'expense'; });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _type == 'expense' ? Colors.redAccent.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(BootstrapIcons.arrow_up_right, color: _type == 'expense' ? Colors.redAccent : Colors.grey, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expense',
                                    style: GoogleFonts.outfit(
                                      color: _type == 'expense' ? Colors.redAccent : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() { _type = 'income'; _category = 'Income'; });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _type == 'income' ? Colors.greenAccent.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(BootstrapIcons.arrow_down_left, color: _type == 'income' ? Colors.greenAccent : Colors.grey, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Income',
                                    style: GoogleFonts.outfit(
                                      color: _type == 'income' ? Colors.greenAccent : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title Field
                  Text('Title / Description', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'e.g., Grocery Shopping',
                      hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
                      filled: true,
                      fillColor: const Color(0xFF161616),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: const Color(0xFF947A57))),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount Field
                  Text('Amount', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.medievalSharp(color: Colors.white, fontSize: 24),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: GoogleFonts.medievalSharp(color: Colors.white.withOpacity(0.2)),
                      prefixIcon: const Icon(Icons.currency_rupee, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF161616),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: const Color(0xFF947A57))),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Selector
                  if (_type == 'expense') ...[
                    Text('Category', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _category == 'Income' ? 'Food' : _category,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF161616),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          items: _categories.where((c) => c != 'Income').map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() { _category = newValue!; });
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Payment Method Selector
                  Text('Payment Method', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _paymentMethod,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF161616),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        items: const [
                          DropdownMenuItem(value: 'account', child: Text('Account Balance')),
                          DropdownMenuItem(value: 'in_hand', child: Text('In Hand')),
                          DropdownMenuItem(value: 'deposit', child: Text('Deposit')),
                          DropdownMenuItem(value: 'credit', child: Text('Credit (Debt)')),
                        ],
                        onChanged: (String? newValue) {
                          setState(() { _paymentMethod = newValue!; });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exclude Toggle
                  GestureDetector(
                    onTap: () => setState(() => _excludeFromBalance = !_excludeFromBalance),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _excludeFromBalance ? const Color(0xFF947A57).withOpacity(0.3) : Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _excludeFromBalance ? BootstrapIcons.eye_slash : BootstrapIcons.eye,
                            color: _excludeFromBalance ? const Color(0xFF947A57) : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Affect Balance Calculation?',
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _excludeFromBalance ? 'Record only (Doesn\'t change balance)' : 'Normal (Updates the balance)',
                                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: !_excludeFromBalance,
                            onChanged: (val) => setState(() => _excludeFromBalance = !val),
                            activeColor: const Color(0xFF947A57),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Save Button
                  GestureDetector(
                    onTap: provider.isBusy ? null : () async {
                      if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                        final amount = double.tryParse(_amountController.text) ?? 0.0;
                        ConfirmationDialog.show(
                          context,
                          title: 'Confirm Record',
                          message: 'Add ${_type} of ₹$amount for ${_titleController.text}?',
                          onConfirm: () async {
                            final date = DateTime.now().toIso8601String();
                            await provider.addTransaction(
                              _titleController.text, 
                              amount, 
                              _category, 
                              date, 
                              _type,
                              _paymentMethod,
                              exclude: _excludeFromBalance
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: provider.isBusy 
                            ? [Colors.grey, Colors.grey] 
                            : [const Color(0xFF947A57), const Color(0xFF7D6442)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!provider.isBusy)
                            BoxShadow(
                              color: const Color(0xFF947A57).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                        ],
                      ),
                      child: Center(
                        child: provider.isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            )
                          : Text(
                              'Save Record',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          if (provider.isBusy)
            _buildLoadingOverlay(),
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
