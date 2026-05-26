import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_dot/providers/app_provider.dart';
import 'package:wallet_dot/widgets/common/GradientScaffold.dart';
import 'package:fl_chart/fl_chart.dart';

class FullReport extends StatelessWidget {
  const FullReport({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final transactions = provider.transactions;

    // Calculate category breakdown
    final Map<String, double> categoryData = {};
    for (var tx in transactions.where((t) => t['type'] == 'expense')) {
      final category = tx['category'] ?? 'Other';
      final amount = (tx['amount'] as num).toDouble();
      categoryData[category] = (categoryData[category] ?? 0.0) + amount;
    }

    // Calculate payment method breakdown
    final Map<String, double> paymentData = {
      'account': 0.0,
      'in_hand': 0.0,
      'deposit': 0.0,
      'credit': 0.0,
    };
    for (var tx in transactions) {
      final method = tx['payment_method'] ?? 'account';
      final amount = (tx['amount'] as num).toDouble();
      final type = tx['type'];
      if (type == 'income') {
        paymentData[method] = (paymentData[method] ?? 0.0) + amount;
      } else {
        paymentData[method] = (paymentData[method] ?? 0.0) - amount;
      }
    }

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Financial Report',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(provider),
            const SizedBox(height: 30),
            Text('Expense Breakdown', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPieChart(categoryData),
            const SizedBox(height: 30),
            Text('Expense by Category', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildCategoryBreakdown(categoryData),
            const SizedBox(height: 30),
            Text('Net by Payment Method', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPaymentMethodBreakdown(paymentData),
          ],
        ),
      )),
    );
  }

  Widget _buildSummaryCard(AppProvider provider) {
    final netSavings = provider.totalIncome - provider.totalExpense;
    final isPositive = netSavings >= 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Total Income', provider.totalIncome, const Color(0xFF10B981)),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.08)),
              _buildStat('Total Expense', provider.totalExpense, const Color(0xFFF43F5E)),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 20),
          Text(
            'Net Savings',
            style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${netSavings.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    if (data.isEmpty) return _buildNoData();
    
    final List<Color> colors = [
      const Color(0xFFFED7B8),
      const Color(0xFF10B981),
      const Color(0xFF677DAA),
      const Color(0xFF6366F1),
      const Color(0xFF3B82F6),
      const Color(0xFF06B6D4),
      const Color(0xFF14B8A6),
      const Color(0xFF8B5CF6),
    ];

    int i = 0;
    final sections = data.entries.map((e) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        value: e.value,
        title: '', // Hide title in pie
        color: color,
        radius: 20,
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 4,
              centerSpaceRadius: 60,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Expenses', style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('₹${data.values.fold(0.0, (s, v) => s + v).toStringAsFixed(0)}', 
                   style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: GoogleFonts.plusJakartaSans(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(Map<String, double> data) {
    if (data.isEmpty) return _buildNoData();
    
    return Column(
      children: data.entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1F30),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key, style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600)),
              Text(
                '₹${e.value.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodBreakdown(Map<String, double> data) {
    return Column(
      children: [
        _buildMethodRow('Account Balance', data['account']!, const Color(0xFFFED7B8)),
        _buildMethodRow('In Hand Cash', data['in_hand']!, const Color(0xFF10B981)),
        _buildMethodRow('Deposit Account', data['deposit']!, const Color(0xFF06B6D4)),
        _buildMethodRow('Credit / Debt', data['credit']!, const Color(0xFFF43F5E)),
      ],
    );
  }

  Widget _buildMethodRow(String label, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              color: amount >= 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Center(child: Text('No data for this period', style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.2)))),
    );
  }
}
