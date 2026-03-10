import 'dart:ui';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tenebris/providers/app_provider.dart';
import 'package:tenebris/widgets/AddExpense.dart';
import 'package:tenebris/widgets/LedgerManagement.dart';
import 'package:tenebris/widgets/RemindersManagement.dart';

import 'package:tenebris/widgets/NotesManagement.dart';
import 'package:tenebris/widgets/FullReport.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF947A57).withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TENEBRIS',
                            style: GoogleFonts.medievalSharp(
                              fontSize: 14,
                              letterSpacing: 4,
                              color: const Color(0xFF947A57),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Welcome back, Akhil',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF947A57), width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundImage: const AssetImage('assets/images/profile.jpeg'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Main Balance Card
                  _buildBalanceCard(provider),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.add_rounded,
                          label: 'Add Record',
                          color: const Color(0xFF947A57),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpense())),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.notifications_active_outlined,
                          label: 'Reminders',
                          color: Colors.white.withOpacity(0.05),
                          textColor: Colors.white,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersManagement())),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  _buildActionButton(
                    icon: BootstrapIcons.journal_bookmark,
                    label: 'Knowledge Base',
                    color: Colors.white.withOpacity(0.05),
                    textColor: Colors.white,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesManagement())),
                  ),
                  
                  const SizedBox(height: 15),

                  _buildActionButton(
                    icon: BootstrapIcons.pie_chart,
                    label: 'Financial Report',
                    color: Colors.white.withOpacity(0.05),
                    textColor: Colors.white,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FullReport())),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LedgerManagement())),
                        child: Text(
                          'View All',
                          style: GoogleFonts.outfit(color: const Color(0xFF947A57)),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Transactions List
                  if (provider.transactions.isEmpty)
                    _buildEmptyState()
                  else
                    ...provider.transactions.take(5).map((tx) => _buildTransactionItem(tx)).toList(),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(AppProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E1E),
            const Color(0xFF121212),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditBalanceSheet(provider),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF947A57).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(BootstrapIcons.pencil_square, color: Color(0xFF947A57), size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${provider.balance.toStringAsFixed(2)}',
            style: GoogleFonts.medievalSharp(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSmallBalance('Account', provider.accountCalculated),
              const SizedBox(width: 15),
              _buildSmallBalance('In Hand', provider.inHandCalculated),
              if (provider.creditCalculated != 0) ...[
                const SizedBox(width: 15),
                _buildSmallBalance('Credit', provider.creditCalculated, isNegative: true),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildFinanceInfo(
                label: 'Income',
                amount: provider.totalIncome,
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xFF4CAF50),
              ),
              const Spacer(),
              _buildFinanceInfo(
                label: 'Expenses',
                amount: provider.totalExpense,
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFFE57373),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBalance(String label, double amount, {bool isNegative = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 10),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            color: isNegative ? Colors.redAccent.withOpacity(0.7) : Colors.white.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceInfo({required String label, required double amount, required IconData icon, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, Color textColor = Colors.black, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final isExpense = tx['type'] == 'expense';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isExpense ? Colors.redAccent : Colors.greenAccent).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isExpense ? BootstrapIcons.arrow_up_right : BootstrapIcons.arrow_down_left,
              color: isExpense ? Colors.redAccent : Colors.greenAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['title'],
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  tx['category'],
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isExpense ? '-' : '+'} ₹${tx['amount']}",
            style: GoogleFonts.medievalSharp(
              color: isExpense ? Colors.redAccent : Colors.greenAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(BootstrapIcons.receipt, color: Colors.white.withOpacity(0.1), size: 48),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  void _showEditBalanceSheet(AppProvider provider) {
    final accountController = TextEditingController(text: provider.accountBalance.toString());
    final inHandController = TextEditingController(text: provider.inHandBalance.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Initial Balance',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text('Account Balance', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: accountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.outfit(color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Text('In-Hand Cash', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: inHandController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.outfit(color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  final double account = double.tryParse(accountController.text) ?? 0.0;
                  final double inHand = double.tryParse(inHandController.text) ?? 0.0;
                  await provider.updateBalances(account, inHand);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF947A57),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('Update Balance', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
