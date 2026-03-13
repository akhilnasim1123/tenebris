import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tenebris/providers/app_provider.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('Financial Report', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(provider),
            const SizedBox(height: 30),
            Text('Expense Breakdown', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPieChart(categoryData),
            const SizedBox(height: 30),
            Text('Expense by Category', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildCategoryBreakdown(categoryData),
            const SizedBox(height: 30),
            Text('Net by Payment Method', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPaymentMethodBreakdown(paymentData),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Total Income', provider.totalIncome, Colors.greenAccent),
              Container(width: 1, height: 40, color: Colors.white10),
              _buildStat('Total Expense', provider.totalExpense, Colors.redAccent),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          Text(
            'Net Savings',
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
          ),
          Text(
            '₹${(provider.totalIncome - provider.totalExpense).toStringAsFixed(2)}',
            style: GoogleFonts.medievalSharp(
              color: (provider.totalIncome - provider.totalExpense) >= 0 ? Colors.greenAccent : Colors.redAccent,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    final List<Color> colors = [
      Colors.redAccent, Colors.blueAccent, Colors.greenAccent, 
      Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent,
      Colors.pinkAccent, Colors.yellowAccent
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
              Text('Expenses', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
              Text('₹${data.values.fold(0.0, (s, v) => s + v).toStringAsFixed(0)}', 
                   style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: GoogleFonts.outfit(color: color, fontSize: 20, fontWeight: FontWeight.bold),
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
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.02)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key, style: GoogleFonts.outfit(color: Colors.white70)),
              Text(
                '₹${e.value.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
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
        _buildMethodRow('Account Balance', data['account']!, Colors.blueAccent),
        _buildMethodRow('In Hand Cash', data['in_hand']!, Colors.orangeAccent),
        _buildMethodRow('Deposit Account', data['deposit']!, const Color(0xFFE2B05E)),
        _buildMethodRow('Credit / Debt', data['credit']!, Colors.purpleAccent),
      ],
    );
  }

  Widget _buildMethodRow(String label, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.outfit(color: Colors.white70)),
          const Spacer(),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.medievalSharp(
              color: amount >= 0 ? Colors.greenAccent.withOpacity(0.8) : Colors.redAccent.withOpacity(0.8),
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
      decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(16)),
      child: Center(child: Text('No data for this period', style: GoogleFonts.outfit(color: Colors.white24))),
    );
  }
}
