import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:wallet_dot/widgets/common/GradientScaffold.dart';
import 'package:wallet_dot/widgets/common/GlassCard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  // Cache pages to prevent rebuilding on tab switch
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardTab(),
      const LedgerManagement(),
      const FullReport(),
      const NotesManagement(),
      const ProfileSettings(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return GradientScaffold(
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
                color: const Color(0xFFFED7B8).withOpacity(0.04),
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
                color: const Color(0xFF677DAA).withOpacity(0.03),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(),
              ),
            ),
          ),

          // Active Page Content
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),

          // Floating Glassmorphic Bottom Navigation Bar
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1F30).withOpacity(0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFFED7B8).withOpacity(0.12),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavBarItem(0, Icons.home_rounded, 'Home'),
                      _buildNavBarItem(1, Icons.receipt_long_rounded, 'Ledger'),
                      _buildNavBarItem(2, null, 'Profile', avatar: provider.profilePicture),
                      _buildNavBarItem(3, Icons.insights_rounded, 'Reports'),
                      _buildNavBarItem(4, Icons.collections_bookmark_rounded, 'Memos'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Global Busy Overlay
          if (provider.isBusy)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFED7B8),
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData? icon, String label, {String? avatar}) {
    final isSelected = _currentIndex == index;
    final activeColor = const Color(0xFFFED7B8);
    final inactiveColor = const Color(0xFF677DAA);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon == null) ...[
            // Central Avatar tab item
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.25),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: AvatarWidget(
                profilePicture: avatar,
                radius: 16,
              ),
            ),
          ] else ...[
            // Normal Icon item
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// REDESIGNED MAIN DASHBOARD TAB VIEW
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _goalTitle = "Ev Car";
  double _goalTarget = 800000.0;

  @override
  void initState() {
    super.initState();
    _loadGoalData();
  }

  Future<void> _loadGoalData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _goalTitle = prefs.getString('financial_goal_title') ?? "Ev Car";
      _goalTarget = prefs.getDouble('financial_goal_target') ?? 800000.0;
    });
  }

  Future<void> _saveGoalData(String title, double target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('financial_goal_title', title);
    await prefs.setDouble('financial_goal_target', target);
    setState(() {
      _goalTitle = title;
      _goalTarget = target;
    });
  }

  double _calculateTodayIncome(List<Map<String, dynamic>> transactions) {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    return transactions
        .where((t) => t['type'] == 'income' && t['date'].startsWith(todayStr))
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
  }

  String _calculateSpendingChange(List<Map<String, dynamic>> transactions) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

    double currentMonthExpenses = 0.0;
    double lastMonthExpenses = 0.0;

    for (var t in transactions.where((tx) => tx['type'] == 'expense' && tx['exclude'] != true)) {
      final date = DateTime.parse(t['date']);
      if (date.isAfter(currentMonthStart) || date.isAtSameMomentAs(currentMonthStart)) {
        currentMonthExpenses += (t['amount'] as num).toDouble();
      } else if ((date.isAfter(lastMonthStart) || date.isAtSameMomentAs(lastMonthStart)) && date.isBefore(lastMonthEnd)) {
        lastMonthExpenses += (t['amount'] as num).toDouble();
      }
    }

    if (lastMonthExpenses == 0) {
      return currentMonthExpenses > 0 ? "+100%" : "0%";
    }
    final change = ((currentMonthExpenses - lastMonthExpenses) / lastMonthExpenses) * 100;
    final prefix = change >= 0 ? "+" : "";
    return "$prefix${change.toStringAsFixed(0)}%";
  }

  void _showEditGoalDialog() {
    final titleController = TextEditingController(text: _goalTitle);
    final targetController = TextEditingController(text: _goalTarget.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1F30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Financial Goal',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Goal Title',
                labelStyle: const TextStyle(color: Color(0xFF677DAA)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFED7B8))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Target Amount (INR)',
                labelStyle: const TextStyle(color: Color(0xFF677DAA)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFED7B8))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF677DAA))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFED7B8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final double target = double.tryParse(targetController.text) ?? _goalTarget;
              _saveGoalData(titleController.text.trim(), target);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final name = provider.name ?? provider.username ?? 'Guest';
    final todayAdded = _calculateTodayIncome(provider.transactions);
    final spendingChange = _calculateSpendingChange(provider.transactions);

    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      color: const Color(0xFFFED7B8),
      backgroundColor: const Color(0xFF000000),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Top Header: "Hello, Divyansh" & Quick Action Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: const Color(0xFF677DAA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildHeaderIconButton(Icons.settings_outlined, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileSettings()),
                      );
                    }),
                    const SizedBox(width: 8),
                    _buildHeaderIconButton(Icons.search_rounded, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LedgerManagement()),
                      );
                    }),
                    const SizedBox(width: 8),
                    _buildHeaderIconButton(Icons.notifications_none_rounded, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RemindersManagement()),
                      );
                    }),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 1. Current Balance Card
            _buildCurrentBalanceCard(provider, todayAdded),
            const SizedBox(height: 16),

            // 2. Row of stats: Spending Change & Income
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'SPENDING CHANGE',
                    spendingChange,
                    subtext: 'vs previous month',
                    color: spendingChange.startsWith('-') ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'INCOME',
                    '₹${provider.totalIncome.toStringAsFixed(0)}',
                    subtext: '₹${provider.totalExpense.toStringAsFixed(0)} Spent',
                    color: const Color(0xFFFED7B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Wide "Pay" Action Button
            _buildPayButton(),
            const SizedBox(height: 28),

            // 4. "Your Cards" Horizontal List
            Text(
              'YOUR CARDS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF677DAA),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildCardsSlider(provider),
            const SizedBox(height: 28),

            // 5. "Spending Breakdown" Donut Chart
            _buildSpendingBreakdownSection(provider),
            const SizedBox(height: 28),

            // 6. "Financial Goal" Tracker
            _buildGoalTrackerSection(provider),
            const SizedBox(height: 28),

            // 7. "Other Modules" circular quick action buttons
            _buildQuickModulesSection(),

            const SizedBox(height: 110), // Padding to prevent navigation overlap
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1F30).withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBalanceCard(AppProvider provider, double todayAdded) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderColor: const Color(0xFFFED7B8).withOpacity(0.14),
      borderRadius: 24,
      blur: 22,
      backgroundColor: const Color(0xFF0A1F30).withOpacity(0.5),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFED7B8).withOpacity(0.05),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT BALANCE',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF677DAA),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'INR ${provider.balance.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+ INR ${todayAdded.toStringAsFixed(0)} Today Added',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _showAddBalanceSheet(context, provider),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, {required String subtext, required Color color}) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      blur: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF677DAA),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.35),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddExpense()),
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: 18,
        blur: 16,
        borderColor: const Color(0xFFFED7B8).withOpacity(0.2),
        borderWidth: 1.5,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFED7B8).withOpacity(0.04),
            blurRadius: 18,
          ),
        ],
          child: Center(
            child: Text(
              'Pay',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildCardsSlider(AppProvider provider) {
    final List<Map<String, dynamic>> cardData = [
      {
        'name': 'Bank Account',
        'balance': provider.accountCalculated,
        'gradient': const [Color(0xFF053B5B), Color(0xFF0A1F30)],
        'cardType': 'VISA',
      },
      {
        'name': 'Cash In Hand',
        'balance': provider.inHandCalculated,
        'gradient': const [Color(0xFFFED7B8), Color(0xFF677DAA)],
        'cardType': 'MASTER',
        'darkText': true,
      },
      {
        'name': 'Savings Portfolio',
        'balance': provider.depositCalculated,
        'gradient': const [Color(0xFF02101C), Color(0xFF0F3B5F)],
        'cardType': 'RUPAY',
      },
      {
        'name': 'Credit Card Owed',
        'balance': provider.creditCalculated,
        'gradient': const [Color(0xFFF43F5E), Color(0xFF0A1F30)],
        'cardType': 'VISA',
        'isNegative': true,
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cardData.length,
        itemBuilder: (context, index) {
          final card = cardData[index];
          final gradientColors = card['gradient'] as List<Color>;
          final isDarkText = card['darkText'] == true;
          final balance = card['balance'] as double;
          final isNegative = card['isNegative'] == true;

          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card['name'],
                      style: GoogleFonts.plusJakartaSans(
                        color: isDarkText ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.credit_card_rounded,
                      color: isDarkText ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
                      size: 20,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${balance.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        color: isDarkText ? Colors.black : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isNegative)
                      Text(
                        'Total debt outstanding',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDarkText ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
                          fontSize: 9,
                        ),
                      )
                    else
                      Text(
                        'Available Balance',
                        style: GoogleFonts.plusJakartaSans(
                          color: isDarkText ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
                          fontSize: 9,
                        ),
                      )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '•••• 4022',
                      style: GoogleFonts.plusJakartaSans(
                        color: isDarkText ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      card['cardType'],
                      style: GoogleFonts.plusJakartaSans(
                        color: isDarkText ? Colors.black : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpendingBreakdownSection(AppProvider provider) {
    // Generate actual breakdown from transactions
    final breakdown = _getExpenseBreakdown(provider.transactions);

    if (breakdown.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1F30).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Center(
          child: Text(
            'No expense data to display spending breakdown.',
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF677DAA), fontSize: 13),
          ),
        ),
      );
    }

    final totalVal = breakdown.values.fold(0.0, (s, v) => s + v);

    // Map categories to colors
    final List<Color> colors = [
      const Color(0xFFE52E71), // Pink - Rent and Utilities
      const Color(0xFF3B82F6), // Blue - Loan
      const Color(0xFFFED7B8), // Peach/Yellow - Food
      const Color(0xFFFB923C), // Orange - Health
      const Color(0xFF10B981), // Green - Transport
      const Color(0xFF8B5CF6), // Purple - Personal
      const Color(0xFF06B6D4), // Cyan - Other
    ];

    int i = 0;
    final List<PieChartSectionData> sections = [];
    final List<Widget> legendItems = [];

    breakdown.forEach((cat, amt) {
      final color = colors[i % colors.length];
      sections.add(
        PieChartSectionData(
          value: amt,
          color: color,
          radius: 12,
          title: '',
        ),
      );

      final percentage = (amt / totalVal) * 100;
      legendItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cat,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF677DAA), fontSize: 11),
              ),
            ],
          ),
        ),
      );
      i++;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F30).withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPENDING BREAKDOWN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF677DAA),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 46,
                        sectionsSpace: 3,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${totalVal.toStringAsFixed(0)}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'This month',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF677DAA),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: legendItems,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, double> _getExpenseBreakdown(List<Map<String, dynamic>> transactions) {
    final Map<String, double> breakdown = {};
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);

    for (var t in transactions.where((tx) => tx['type'] == 'expense' && tx['exclude'] != true)) {
      final date = DateTime.parse(t['date']);
      if (date.isAfter(currentMonthStart) || date.isAtSameMomentAs(currentMonthStart)) {
        final category = t['category'] ?? 'Other';
        breakdown[category] = (breakdown[category] ?? 0.0) + (t['amount'] as num).toDouble();
      }
    }
    return breakdown;
  }

  Widget _buildGoalTrackerSection(AppProvider provider) {
    // Current goal savings matches the user's Deposit / Savings Balance
    final double savings = provider.depositCalculated;
    final double progressPercent = (savings / _goalTarget).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F30).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FINANCIAL GOAL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF677DAA),
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: _showEditGoalDialog,
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFFFED7B8),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _goalTitle,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Rs ${savings.toStringAsFixed(0)} / Rs ${_goalTarget.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFFED7B8),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 10,
              width: double.infinity,
              child: LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: const Color(0xFF02101C),
                color: const Color(0xFFFED7B8),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progressPercent * 100).toStringAsFixed(0)}% Completed',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF677DAA),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickModulesSection() {
    final List<Map<String, dynamic>> modules = [
      {
        'label': 'Salaries',
        'icon': Icons.payments_outlined,
        'widget': const SalaryManagement(),
      },
      {
        'label': 'Obligations',
        'icon': Icons.compare_arrows_rounded,
        'widget': const PersonalManagement(),
      },
      {
        'label': 'Reminders',
        'icon': Icons.alarm_rounded,
        'widget': const RemindersManagement(),
      },
      {
        'label': 'Memos',
        'icon': Icons.collections_bookmark_outlined,
        'widget': const NotesManagement(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OTHER MODULES',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF677DAA),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: modules.map((m) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => m['widget']),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1F30).withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Icon(m['icon'], color: const Color(0xFFFED7B8), size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    m['label'],
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showAddBalanceSheet(BuildContext context, AppProvider provider) {
    final amountController = TextEditingController();
    String method = 'account';
    bool isSubtraction = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A1F30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1F30),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFFED7B8).withOpacity(0.2),
              width: 1.5,
            ),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 28,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adjust Balance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mode Switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02101C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isSubtraction = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isSubtraction ? const Color(0xFFFED7B8).withOpacity(0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Addition (+)',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: !isSubtraction ? const Color(0xFFFED7B8) : Colors.grey,
                                    fontWeight: !isSubtraction ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isSubtraction = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSubtraction ? const Color(0xFFFED7B8).withOpacity(0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Subtraction (-)',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isSubtraction ? const Color(0xFFFED7B8) : Colors.grey,
                                    fontWeight: isSubtraction ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Card Selector Options
                  Row(
                    children: [
                      _buildMethodOption('Account', 'account', method, (val) => setModalState(() => method = val)),
                      const SizedBox(width: 8),
                      _buildMethodOption('In Hand', 'in_hand', method, (val) => setModalState(() => method = val)),
                      const SizedBox(width: 8),
                      _buildMethodOption('Deposit', 'deposit', method, (val) => setModalState(() => method = val)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Amount TextField
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.2)),
                      prefixIcon: const Icon(Icons.currency_rupee, color: Colors.grey),
                      fillColor: const Color(0xFF02101C),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFFED7B8), width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Button
                  GestureDetector(
                    onTap: () async {
                      final amount = double.tryParse(amountController.text) ?? 0.0;
                      if (amount > 0) {
                        ConfirmationDialog.show(
                          context,
                          title: 'Confirm Adjustment',
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
                        gradient: const LinearGradient(colors: [Color(0xFFFED7B8), Color(0xFF677DAA)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFED7B8).withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isSubtraction ? 'Subtract from Balance' : 'Add to Balance',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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

  Widget _buildMethodOption(String label, String value, String current, Function(String) onSelect) {
    final isSelected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFED7B8).withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFFFED7B8) : Colors.white.withOpacity(0.04)),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? const Color(0xFFFED7B8) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
