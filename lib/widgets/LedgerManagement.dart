import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tenebris/providers/app_provider.dart';
import 'package:intl/intl.dart';

class LedgerManagement extends StatelessWidget {
  const LedgerManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ledger Management', style: GoogleFonts.medievalSharp()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.transactions.isEmpty
          ? Center(
              child: Text(
                'No transactions. Start spending!',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final tx = provider.transactions[index];
                final isExpense = tx['type'] == 'expense';
                final date = DateTime.parse(tx['date']);
                final formattedDate =
                    DateFormat('MMM dd, yyyy - hh:mm a').format(date);

                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isExpense ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                      child: Icon(
                        isExpense ? Icons.arrow_outward : Icons.arrow_downward,
                        color: isExpense ? Colors.redAccent : Colors.greenAccent,
                      ),
                    ),
                    title: Text(tx['title'],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formattedDate, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                        Text('Method: ${tx['payment_method'] ?? 'Account'}', style: GoogleFonts.poppins(color: Colors.grey.withOpacity(0.6), fontSize: 10)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${isExpense ? '-' : '+'} ₹${tx['amount']}',
                          style: GoogleFonts.medievalSharp(
                            color: isExpense ? Colors.redAccent : Colors.greenAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.grey, size: 20),
                          onPressed: () {
                            provider.deleteTransaction(tx['id'].toString());
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
