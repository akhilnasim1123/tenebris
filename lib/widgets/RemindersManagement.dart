import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_dot/providers/app_provider.dart';
import 'package:intl/intl.dart';
import 'package:wallet_dot/widgets/common/ConfirmationDialog.dart';

class RemindersManagement extends StatefulWidget {
  const RemindersManagement({super.key});

  @override
  State<RemindersManagement> createState() => _RemindersManagementState();
}

class _RemindersManagementState extends State<RemindersManagement> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _showAddReminderSheet() {
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
                  left: 24,
                  right: 24,
                  top: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Reminder',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Schedule a push notification reminder.',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text('Reminder Title', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g., Pay rent bill',
                        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.2)),
                        filled: true,
                        fillColor: const Color(0xFF0A0E17),
                        contentPadding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFF2DD4BF),
                                        onPrimary: Colors.black,
                                        surface: Color(0xFF121B2A),
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                setModalState(() {
                                  _selectedDate = date;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF2DD4BF), size: 16),
                            label: Text(
                              _selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.06)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: const Color(0xFF0A0E17),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFF2DD4BF),
                                        onPrimary: Colors.black,
                                        surface: Color(0xFF121B2A),
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setModalState(() {
                                  _selectedTime = time;
                                });
                              }
                            },
                            icon: const Icon(Icons.access_time_rounded, color: Color(0xFF2DD4BF), size: 16),
                            label: Text(
                              _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.06)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: const Color(0xFF0A0E17),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        if (_titleController.text.isNotEmpty && _selectedDate != null && _selectedTime != null) {
                          final dt = DateTime(
                            _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
                            _selectedTime!.hour, _selectedTime!.minute,
                          );
                          Provider.of<AppProvider>(context, listen: false).addReminder(
                            _titleController.text, 
                            dt.toIso8601String(),
                          );
                          _titleController.clear();
                          _selectedDate = null;
                          _selectedTime = null;
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2DD4BF).withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Add Reminder',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        title: Text(
          'Reminders',
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
          provider.reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white.withOpacity(0.15),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reminders. Enjoy the silence!',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.reminders.length,
                  itemBuilder: (context, index) {
                    final rmd = provider.reminders[index];
                    final isCompleted = rmd['is_completed'] == 1;
                    final datetime = DateTime.parse(rmd['datetime']);
                    final formattedDate =
                        DateFormat('MMM dd, yyyy - hh:mm a').format(datetime);
        
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121B2A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Checkbox(
                          value: isCompleted,
                          activeColor: const Color(0xFF2DD4BF),
                          checkColor: Colors.black,
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          onChanged: provider.isBusy ? null : (val) {
                            if (val != null) {
                              provider.toggleReminder(rmd['id'].toString(), val ? 1 : 0);
                            }
                          },
                        ),
                        title: Text(
                          rmd['title'],
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isCompleted ? Colors.grey : Colors.white,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            formattedDate,
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF43F5E), size: 20),
                          onPressed: provider.isBusy ? null : () {
                            ConfirmationDialog.show(
                              context,
                              title: 'Delete Reminder',
                              message: 'Are you sure you want to permanently delete this reminder?',
                              confirmColor: const Color(0xFFF43F5E),
                              onConfirm: () => provider.deleteReminder(rmd['id'].toString()),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
          if (provider.isBusy)
            _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2DD4BF).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          onPressed: _showAddReminderSheet,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
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
}
