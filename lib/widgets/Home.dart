import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_dot/providers/app_provider.dart';
import 'package:wallet_dot/widgets/AddExpense.dart';
import 'package:wallet_dot/widgets/LedgerManagement.dart';
import 'package:wallet_dot/widgets/RemindersManagement.dart';

import 'package:wallet_dot/widgets/NotesManagement.dart';
import 'package:wallet_dot/widgets/FullReport.dart';
import 'package:wallet_dot/widgets/PersonalManagement.dart';
import 'package:wallet_dot/widgets/SalaryManagement.dart';
import 'package:wallet_dot/widgets/common/ConfirmationDialog.dart';
import 'package:wallet_dot/widgets/ProfileSettings.dart';

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
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -120,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2DD4BF).withOpacity(0.04),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0EA5E9).withOpacity(0.03),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () => provider.loadData(),
              color: const Color(0xFF2DD4BF),
              backgroundColor: const Color(0xFF080C14),
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
                            Row(
                              children: [
                                Text(
                                  'wallet',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                Text(
                                  'Dot',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: const Color(0xFF2DD4BF),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Welcome back, ${provider.username ?? 'Guest'}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Total Net Worth & Assets Overview',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileSettings(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF2DD4BF), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2DD4BF).withOpacity(0.2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: AvatarWidget(
                                  profilePicture: provider.profilePicture,
                                  radius: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => ConfirmationDialog.show(
                                context,
                                title: 'Log Out',
                                message: 'Are you sure you wish to log out from walletDot?',
                                confirmColor: Colors.redAccent,
                                onConfirm: () async {
                                  await provider.logout();
                                  if (context.mounted) {
                                    Navigator.popUntil(context, (route) => route.isFirst);
                                  }
                                },
                              ),
                              icon: const Icon(Icons.logout_rounded, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main Balance Card
                    _buildBalanceCard(provider),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _InteractiveActionButton(
                            icon: Icons.add_rounded,
                            label: 'Add Record',
                            color: const Color(0xFF2DD4BF),
                            textColor: Colors.black,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddExpense()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InteractiveActionButton(
                            icon: Icons.notifications_active_outlined,
                            label: 'Reminders',
                            color: Colors.white.withOpacity(0.04),
                            textColor: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RemindersManagement()),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildOverviewRow(provider),

                    const SizedBox(height: 32),
                    Text(
                      'Dashboard Menu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.28,
                      children: [
                        _InteractiveMenuCard(
                          icon: Icons.collections_bookmark_outlined,
                          label: 'Smart Memos',
                          subtitle: 'Notes & Snippets',
                          color: const Color(0xFF6366F1),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotesManagement()),
                          ),
                        ),
                        _InteractiveMenuCard(
                          icon: Icons.pie_chart_outline,
                          label: 'Analytics & Reports',
                          subtitle: 'Expenses & Trends',
                          color: const Color(0xFF0EA5E9),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FullReport()),
                          ),
                        ),
                        _InteractiveMenuCard(
                          icon: Icons.compare_arrows_rounded,
                          label: 'Debts & Obligations',
                          subtitle: 'Borrow / Lend',
                          color: const Color(0xFFF43F5E),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PersonalManagement()),
                          ),
                        ),
                        _InteractiveMenuCard(
                          icon: Icons.payments_outlined,
                          label: 'Salary Tracker',
                          subtitle: 'Earning Records',
                          color: const Color(0xFF10B981),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SalaryManagement()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Adjustments Section
                    Text(
                      'Quick Adjustments',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _InteractiveSmallActionButton(
                            icon: Icons.account_balance_outlined,
                            label: 'Transfer to Savings',
                            onTap: () => _showDepositSheet(context, provider),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InteractiveSmallActionButton(
                            icon: Icons.add_circle_outline,
                            label: 'Adjust Balance',
                            onTap: () => _showAddBalanceSheet(context, provider),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LedgerManagement()),
                          ),
                          child: Text(
                            'View All',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF2DD4BF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Transactions List
                    if (provider.transactions.isEmpty)
                      _buildEmptyState()
                    else
                      ...provider.transactions
                          .take(5)
                          .map((tx) => _buildTransactionItem(tx))
                          .toList(),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),

          // Global Loading Overlay
          if (provider.isBusy) _buildLoadingOverlay(),
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
                'Loading Dashboard...',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(AppProvider provider) {
    return CustomPaint(
      painter: FintechCardPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NET WORTH',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showEditBalanceSheet(provider),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.edit_note_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '₹${provider.balance.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSmallBalance('Account', provider.accountCalculated),
                _buildSmallBalance('In Hand', provider.inHandCalculated),
                if (provider.creditCalculated != 0)
                  _buildSmallBalance('Credit', provider.creditCalculated,
                      isNegative: true),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                _buildFinanceInfo(
                  label: 'Income',
                  amount: provider.totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFF10B981),
                ),
                const Spacer(),
                _buildFinanceInfo(
                  label: 'Expense',
                  amount: provider.totalExpense,
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFFF43F5E),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBalance(String label, double amount,
      {bool isNegative = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNegative ? Icons.remove_circle_outline_rounded : Icons.account_balance_wallet_outlined,
            color: isNegative ? const Color(0xFFF43F5E) : const Color(0xFF2DD4BF),
            size: 14,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  color: isNegative
                      ? const Color(0xFFF43F5E)
                      : Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceInfo(
      {required String label,
      required double amount,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final isExpense = tx['type'] == 'expense';
    final amount = tx['amount'];
    final category = tx['category']?.toString() ?? 'General';

    IconData categoryIcon = Icons.receipt_long_outlined;
    if (category.toLowerCase().contains('food')) {
      categoryIcon = Icons.restaurant_rounded;
    } else if (category.toLowerCase().contains('salary') ||
        category.toLowerCase().contains('income')) {
      categoryIcon = Icons.payments_outlined;
    } else if (category.toLowerCase().contains('debt') ||
        category.toLowerCase().contains('loan')) {
      categoryIcon = Icons.compare_arrows_rounded;
    } else if (category.toLowerCase().contains('entertainment') ||
        category.toLowerCase().contains('fun')) {
      categoryIcon = Icons.local_play_outlined;
    } else if (isExpense) {
      categoryIcon = Icons.shopping_bag_outlined;
    } else {
      categoryIcon = Icons.account_balance_wallet_outlined;
    }

    final accentColor =
        isExpense ? const Color(0xFFF43F5E) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: accentColor,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withOpacity(0.12)),
                ),
                child: Icon(
                  categoryIcon,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'] ?? 'Record',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isExpense ? '-' : '+'} ₹$amount",
                    style: GoogleFonts.plusJakartaSans(
                      color: accentColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (tx['date'] != null)
                    Text(
                      tx['date'].toString().split('T')[0],
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withOpacity(0.25),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              color: Colors.white.withOpacity(0.15), size: 48),
          const SizedBox(height: 16),
          Text(
            'No transactions recorded yet',
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.4), fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showEditBalanceSheet(AppProvider provider) {
    final accountController =
        TextEditingController(text: provider.accountCalculated.toStringAsFixed(2));
    final inHandController =
        TextEditingController(text: provider.inHandCalculated.toStringAsFixed(2));
    final depositController =
        TextEditingController(text: provider.depositCalculated.toStringAsFixed(2));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121B2A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                  color: const Color(0xFF2DD4BF).withOpacity(0.2), width: 1.5),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sync Balances',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sync your liquid balances to match reality.',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13),
                ),
                const SizedBox(height: 24),
                Text('Bank Account Balance',
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: accountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
                    fillColor: const Color(0xFF0A0E17),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.04)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2DD4BF), width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Cash in Hand',
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: inHandController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF09090E),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.04)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFFFF9F0A), width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Deposit Account',
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: depositController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
                    fillColor: const Color(0xFF0A0E17),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.04)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF2DD4BF), width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _InteractiveModalButton(
                  label: 'Sync Balances',
                  onTap: () async {
                    final double account =
                        double.tryParse(accountController.text) ?? 0.0;
                    final double inHand =
                        double.tryParse(inHandController.text) ?? 0.0;
                    final double deposit =
                        double.tryParse(depositController.text) ?? 0.0;

                    await provider.setCurrentAccountBalance(account);
                    await provider.setCurrentInHandBalance(inHand);
                    await provider.setCurrentDepositBalance(deposit);

                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
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
      backgroundColor: const Color(0xFF121B2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121B2A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
                color: const Color(0xFF2DD4BF).withOpacity(0.2), width: 1.5),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 28),
            child: SingleChildScrollView(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transfer to Savings',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Transfer money to your separate savings portfolio',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8), fontSize: 13)),
                    const SizedBox(height: 24),

                    Text('Select Source',
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMethodOption('In Hand', 'in_hand', source,
                            (val) => setModalState(() => source = val)),
                        const SizedBox(width: 12),
                        _buildMethodOption('Account', 'account', source,
                            (val) => setModalState(() => source = val)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Subtraction Toggle
                    GestureDetector(
                      onTap: () =>
                          setModalState(() => doSubtraction = !doSubtraction),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0E17),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: doSubtraction
                                  ? const Color(0xFF2DD4BF).withOpacity(0.3)
                                  : Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                doSubtraction
                                    ? Icons.remove_circle_outline
                                    : Icons.add_circle_outline,
                                color: doSubtraction
                                    ? const Color(0xFF2DD4BF)
                                    : Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(
                                    'Subtract from ${source == 'in_hand' ? 'Cash in Hand' : 'Bank Balance'}?',
                                    style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white, fontSize: 14))),
                            Switch(
                              value: doSubtraction,
                              onChanged: (val) =>
                                  setModalState(() => doSubtraction = val),
                              activeColor: const Color(0xFF2DD4BF),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style:
                          GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.2)),
                        prefixIcon:
                            const Icon(Icons.currency_rupee, color: Colors.grey),
                        fillColor: const Color(0xFF0A0E17),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.04)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF2DD4BF), width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _InteractiveModalButton(
                      label: 'Complete Transfer',
                      isBusy: provider.isBusy,
                      onTap: () async {
                        final amount =
                            double.tryParse(amountController.text) ?? 0.0;
                        if (amount > 0) {
                          ConfirmationDialog.show(
                            context,
                            title: 'Confirm Transfer',
                            message: doSubtraction
                                ? 'Transfer ₹$amount from ${source == 'in_hand' ? 'In Hand' : 'Account'} to Savings Account?'
                                : 'Add ₹$amount to Savings Account (external source)?',
                            onConfirm: () async {
                              await provider.markAsDeposited(amount,
                                  source: source,
                                  subtractFromSource: doSubtraction);
                              if (context.mounted) Navigator.pop(context);
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
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
      backgroundColor: const Color(0xFF121B2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121B2A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
                color: const Color(0xFF2DD4BF).withOpacity(0.2), width: 1.5),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 28),
            child: SingleChildScrollView(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Adjust Balance',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 24),

                    // Add/Subtract Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: const Color(0xFF0A0E17),
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          _buildModeOption(
                              setModalState,
                              'Addition (+)',
                              false,
                              isSubtraction,
                              (val) => isSubtraction = val),
                          _buildModeOption(
                              setModalState,
                              'Subtraction (-)',
                              true,
                              isSubtraction,
                              (val) => isSubtraction = val),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        _buildMethodOption('Account', 'account', method,
                            (val) => setModalState(() => method = val)),
                        const SizedBox(width: 12),
                        _buildMethodOption('In Hand', 'in_hand', method,
                            (val) => setModalState(() => method = val)),
                        const SizedBox(width: 12),
                        _buildMethodOption('Deposit', 'deposit', method,
                            (val) => setModalState(() => method = val)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style:
                          GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.2)),
                        prefixIcon:
                            const Icon(Icons.currency_rupee, color: Colors.grey),
                        fillColor: const Color(0xFF0A0E17),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.04)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF2DD4BF), width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _InteractiveModalButton(
                      label: isSubtraction
                          ? 'Subtract from Balance'
                          : 'Add to Balance',
                      isBusy: provider.isBusy,
                      onTap: () async {
                        final amount =
                            double.tryParse(amountController.text) ?? 0.0;
                        if (amount > 0) {
                          ConfirmationDialog.show(
                            context,
                            title: isSubtraction
                                ? 'Confirm Adjustment'
                                : 'Confirm Adjustment',
                            message:
                                '${isSubtraction ? 'Subtract' : 'Add'} ₹$amount ${isSubtraction ? 'from' : 'to'} ${method == 'account' ? 'Account' : method == 'in_hand' ? 'In Hand' : 'Deposit'}?',
                            onConfirm: () async {
                              await provider.addBalance(amount, method,
                                  subtract: isSubtraction);
                              if (context.mounted) Navigator.pop(context);
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption(StateSetter setModalState, String label, bool value,
      bool current, Function(bool) onSelect) {
    final isSelected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModalState(() => onSelect(value)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2DD4BF).withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildMethodOption(String label, String value, String current,
      Function(String) onSelect) {
    final isSelected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2DD4BF).withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFF2DD4BF)
                    : Colors.white.withOpacity(0.04)),
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

  Widget _buildOverviewRow(AppProvider provider) {
    final pendingSalaries = provider.salaries
        .where((s) => (s['status'] ?? 'pending') == 'pending')
        .toList();
    final salaryTotal =
        pendingSalaries.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));

    final activeDebts = provider.personalDebts
        .where((d) => (d['status'] ?? 'active') == 'active')
        .toList();
    final creditTotal = activeDebts
        .where((d) => d['type'] == 'credit')
        .fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));
    final debitTotal = activeDebts
        .where((d) => d['type'] == 'debit')
        .fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                  'Pending Salary',
                  '₹${salaryTotal.toStringAsFixed(0)}',
                  Icons.monetization_on_outlined,
                  const Color(0xFF2DD4BF),
                  subtitle: 'Upcoming Income'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                  'Deposit Portfolio',
                  '₹${provider.depositCalculated.toStringAsFixed(0)}',
                  Icons.account_balance_outlined,
                  const Color(0xFF10B981),
                  subtitle: 'Savings Assets'),
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
                  Icons.person_add_alt_1,
                  const Color(0xFFF43F5E)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                  'They Owe',
                  '₹${creditTotal.toStringAsFixed(0)}',
                  Icons.person_remove_alt_1,
                  const Color(0xFF10B981)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String amount, IconData icon,
      Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.15), width: 1),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: color.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sleek modern card painter representing digital metal debit card
class FintechCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // Metallic gradient background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E293B),
          Color(0xFF0F172A),
          Color(0xFF020617),
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    // Subtle glows
    final goldGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2DD4BF).withOpacity(0.15),
          const Color(0xFF2DD4BF).withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width, 0), radius: size.width * 0.8));
    canvas.drawRRect(rrect, goldGlow);

    final amberGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0EA5E9).withOpacity(0.10),
          const Color(0xFF0EA5E9).withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(0, size.height), radius: size.width * 0.6));
    canvas.drawRRect(rrect, amberGlow);

    // Decorative digital connection lines in background
    final linePaint = Paint()
      ..color = const Color(0xFF2DD4BF).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.6), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width * 0.8, size.height * 0.2), linePaint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.3), 30, linePaint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.3), 50, linePaint);

    // Draw card chip in top-right quadrant area (to avoid balance texts)
    // Positioned next to Net worth title on the right
    final chipPaint = Paint()
      ..color = const Color(0xFF2DD4BF).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final chipRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 64, 72, 38, 28),
      const Radius.circular(6),
    );
    canvas.drawRRect(chipRRect, chipPaint);

    final chipLinePaint = Paint()
      ..color = const Color(0xFF2DD4BF).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(chipRRect, chipLinePaint);
    canvas.drawLine(Offset(size.width - 64 + 12, 72), Offset(size.width - 64 + 12, 72 + 28), chipLinePaint);
    canvas.drawLine(Offset(size.width - 64 + 26, 72), Offset(size.width - 64 + 26, 72 + 28), chipLinePaint);
    canvas.drawLine(Offset(size.width - 64, 72 + 14), Offset(size.width - 64 + 38, 72 + 14), chipLinePaint);

    // Thin outer card border
    final borderPaint = Paint()
      ..color = const Color(0xFF2DD4BF).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InteractiveActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _InteractiveActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.textColor = Colors.black,
    required this.onTap,
  });

  @override
  State<_InteractiveActionButton> createState() => _InteractiveActionButtonState();
}

class _InteractiveActionButtonState extends State<_InteractiveActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.color == const Color(0xFF2DD4BF)
                ? const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.color == const Color(0xFF2DD4BF) ? null : widget.color,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.textColor, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  color: widget.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveMenuCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _InteractiveMenuCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_InteractiveMenuCard> createState() => _InteractiveMenuCardState();
}

class _InteractiveMenuCardState extends State<_InteractiveMenuCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13131A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.color.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveSmallActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InteractiveSmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_InteractiveSmallActionButton> createState() => _InteractiveSmallActionButtonState();
}

class _InteractiveSmallActionButtonState extends State<_InteractiveSmallActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF121B2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: const Color(0xFF2DD4BF), size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveModalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isBusy;

  const _InteractiveModalButton({
    required this.label,
    required this.onTap,
    this.isBusy = false,
  });

  @override
  State<_InteractiveModalButton> createState() => _InteractiveModalButtonState();
}

class _InteractiveModalButtonState extends State<_InteractiveModalButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isBusy ? null : widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isBusy
                  ? [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.3)]
                  : [const Color(0xFF2DD4BF), const Color(0xFF0EA5E9)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!widget.isBusy)
                BoxShadow(
                  color: const Color(0xFF2DD4BF).withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: widget.isBusy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
