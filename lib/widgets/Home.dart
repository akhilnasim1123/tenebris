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
import 'package:tenebris/widgets/PersonalManagement.dart';
import 'package:tenebris/widgets/SalaryManagement.dart';
import 'package:tenebris/widgets/common/ConfirmationDialog.dart';

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
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () => provider.loadData(),
              color: const Color(0xFF947A57),
              backgroundColor: const Color(0xFF161616),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                      const SizedBox(height: 20),
                  
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
                  _buildOverviewRow(provider),
              
                  const SizedBox(height: 40),
                  Text(
                    'Dashboard Menu',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildMenuCard(
                        icon: BootstrapIcons.journal_bookmark,
                        label: 'Knowledge',
                        subtitle: 'Notes & Drops',
                        color: const Color(0xFF947A57),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesManagement())),
                      ),
                      _buildMenuCard(
                        icon: BootstrapIcons.pie_chart,
                        label: 'Reports',
                        subtitle: 'Insights',
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FullReport())),
                      ),
                      _buildMenuCard(
                        icon: BootstrapIcons.person_badge,
                        label: 'Debts',
                        subtitle: 'I Owe / They Owe',
                        color: Colors.orangeAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalManagement())),
                      ),
                      _buildMenuCard(
                        icon: BootstrapIcons.cash_stack,
                        label: 'Salaries',
                        subtitle: 'Track Earnings',
                        color: Colors.greenAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalaryManagement())),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Quick Adjustments Section
                  Text(
                    'Quick Adjustments',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallActionButton(
                          icon: BootstrapIcons.bank,
                          label: 'Deposit Cash',
                          onTap: () => _showDepositSheet(context, provider),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSmallActionButton(
                          icon: BootstrapIcons.plus_circle,
                          label: 'Add Balance',
                          onTap: () => _showAddBalanceSheet(context, provider),
                        ),
                      ),
                    ],
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
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        
        // Global Loading Overlay
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
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildMenuCard({required IconData icon, required String label, required String subtitle, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.3),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
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
    final accountController = TextEditingController(text: provider.accountCalculated.toStringAsFixed(2));
    final inHandController = TextEditingController(text: provider.inHandCalculated.toStringAsFixed(2));
    final depositController = TextEditingController(text: provider.depositCalculated.toStringAsFixed(2));

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
                'Sync Current Balance',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sync your liquid balances with reality.',
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Text('Current Account Balance', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
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
              Text('Current In-Hand Cash', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
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
              const SizedBox(height: 20),
              Text('Current Deposit Balance', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: depositController,
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
                  final double deposit = double.tryParse(depositController.text) ?? 0.0;
                  
                  await provider.setCurrentAccountBalance(account);
                  await provider.setCurrentInHandBalance(inHand);
                  await provider.setCurrentDepositBalance(deposit);
                  
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
                    child: Text('Sync Reality', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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
  void _showDepositSheet(BuildContext context, AppProvider provider) {
    final amountController = TextEditingController();
    String source = 'in_hand';
    bool doSubtraction = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Consumer<AppProvider>(
              builder: (context, provider, _) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Move to Deposit', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text('Transfer money to your separate Deposit account', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 24),
                  
                  Text('Select Source', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMethodOption('In Hand', 'in_hand', source, (val) => setModalState(() => source = val)),
                      const SizedBox(width: 12),
                      _buildMethodOption('Account', 'account', source, (val) => setModalState(() => source = val)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Subtraction Toggle
                  GestureDetector(
                    onTap: () => setModalState(() => doSubtraction = !doSubtraction),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: doSubtraction ? const Color(0xFF947A57).withOpacity(0.3) : Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Icon(doSubtraction ? BootstrapIcons.dash_circle : BootstrapIcons.plus_circle, color: doSubtraction ? const Color(0xFF947A57) : Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Subtract from ${source == 'in_hand' ? 'Cash in Hand' : 'Bank Balance'}?', style: GoogleFonts.outfit(color: Colors.white))),
                          Switch(
                            value: doSubtraction, 
                            onChanged: (val) => setModalState(() => doSubtraction = val),
                            activeColor: const Color(0xFF947A57),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
                      prefixIcon: const Icon(Icons.currency_rupee, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF0A0A0A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: provider.isBusy ? null : () async {
                      final amount = double.tryParse(amountController.text) ?? 0.0;
                      if (amount > 0) {
                        ConfirmationDialog.show(
                          context,
                          title: 'Confirm Deposit',
                          message: doSubtraction 
                            ? 'Transfer ₹$amount from ${source == 'in_hand' ? 'In Hand' : 'Account'} to Deposit Account?'
                            : 'Add ₹$amount to Deposit Account (External source)?',
                          onConfirm: () async {
                            await provider.markAsDeposited(amount, source: source, subtractFromSource: doSubtraction);
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: provider.isBusy ? Colors.grey : const Color(0xFF947A57), 
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Center(
                        child: provider.isBusy
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Text('Complete Deposit', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
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

  void _showAddBalanceSheet(BuildContext context, AppProvider provider) {
    final amountController = TextEditingController();
    String method = 'account';
    bool isSubtraction = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Consumer<AppProvider>(
              builder: (context, provider, _) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Adjust Balance', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  
                  // Add/Subtract Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        _buildModeOption(setModalState, 'Addition (+)', false, isSubtraction, (val) => isSubtraction = val),
                        _buildModeOption(setModalState, 'Subtraction (-)', true, isSubtraction, (val) => isSubtraction = val),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      _buildMethodOption('Account', 'account', method, (val) => setModalState(() => method = val)),
                      const SizedBox(width: 12),
                      _buildMethodOption('In Hand', 'in_hand', method, (val) => setModalState(() => method = val)),
                      const SizedBox(width: 12),
                      _buildMethodOption('Deposit', 'deposit', method, (val) => setModalState(() => method = val)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
                      prefixIcon: const Icon(Icons.currency_rupee, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF0A0A0A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: provider.isBusy ? null : () async {
                      final amount = double.tryParse(amountController.text) ?? 0.0;
                      if (amount > 0) {
                        ConfirmationDialog.show(
                          context,
                            title: isSubtraction ? 'Confirm Subtraction' : 'Confirm Addition',
                            message: '${isSubtraction ? 'Subtract' : 'Add'} ₹$amount ${isSubtraction ? 'from' : 'to'} ${method == 'account' ? 'Account' : method == 'in_hand' ? 'In Hand' : 'Deposit'}?',
                          onConfirm: () async {
                            await provider.addBalance(amount, method, subtract: isSubtraction);
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: provider.isBusy ? Colors.grey : const Color(0xFF947A57), 
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Center(
                        child: provider.isBusy
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Text(isSubtraction ? 'Subtract from Balance' : 'Add to Balance', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
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

  Widget _buildModeOption(StateSetter setModalState, String label, bool value, bool current, Function(bool) onSelect) {
    final isSelected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => onSelect(value)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF947A57).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? const Color(0xFF947A57) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
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
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? const Color(0xFF947A57) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF947A57), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewRow(AppProvider provider) {
    final pendingSalaries = provider.salaries.where((s) => (s['status'] ?? 'pending') == 'pending').toList();
    final salaryTotal = pendingSalaries.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));
    
    final activeDebts = provider.personalDebts.where((d) => (d['status'] ?? 'active') == 'active').toList();
    final creditTotal = activeDebts.where((d) => d['type'] == 'credit').fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));
    final debitTotal = activeDebts.where((d) => d['type'] == 'debit').fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'Pending Salary', 
                  '₹${salaryTotal.toStringAsFixed(0)}', 
                  BootstrapIcons.cash_stack, 
                  Colors.blueAccent,
                  subtitle: 'Upcoming Income'
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'Deposit', 
                  '₹${provider.depositCalculated.toStringAsFixed(0)}', 
                  BootstrapIcons.bank, 
                  const Color(0xFFE2B05E),
                  subtitle: 'Savings Portfolio'
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'I Owe', 
                  '₹${debitTotal.toStringAsFixed(0)}', 
                  BootstrapIcons.person_up, 
                  Colors.redAccent
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'They Owe', 
                  '₹${creditTotal.toStringAsFixed(0)}', 
                  BootstrapIcons.person_down, 
                  Colors.greenAccent
                ),
              ),
            ],
          ),
         
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, String amount, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        spacing: 10,
        children: [

          Icon(icon, color: color, size: 20),
          // const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              const SizedBox(height: 4),
              Text(amount, style: GoogleFonts.medievalSharp(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.outfit(color: color.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
