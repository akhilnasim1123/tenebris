import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tenebris/providers/app_provider.dart';
import 'package:intl/intl.dart';
import 'package:tenebris/widgets/common/ConfirmationDialog.dart';

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
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Reminder',
                style: GoogleFonts.medievalSharp(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Reminder Title',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff947a57))),
                ),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() { _selectedDate = date; });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                    child: Text(
                      _selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() { _selectedTime = time; });
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                    child: Text(
                      _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff947a57),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Add Reminder', style: GoogleFonts.medievalSharp(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders', style: GoogleFonts.medievalSharp()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          provider.reminders.isEmpty
              ? Center(
                  child: Text(
                    'No reminders. Enjoy the silence!',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: provider.reminders.length,
                  itemBuilder: (context, index) {
                    final rmd = provider.reminders[index];
                    final isCompleted = rmd['is_completed'] == 1;
                    final datetime = DateTime.parse(rmd['datetime']);
                    final formattedDate =
                        DateFormat('MMM dd, yyyy - hh:mm a').format(datetime);
    
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: isCompleted,
                          activeColor: const Color(0xff947a57),
                          onChanged: provider.isBusy ? null : (val) {
                            if (val != null) {
                              provider.toggleReminder(rmd['id'].toString(), val ? 1 : 0);
                            }
                          },
                        ),
                        title: Text(
                          rmd['title'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.grey : Colors.white,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                          onPressed: provider.isBusy ? null : () {
                            ConfirmationDialog.show(
                              context,
                              title: 'Delete Reminder',
                              message: 'Are you sure you want to permanently delete this reminder?',
                              confirmColor: Colors.redAccent,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff947a57),
        onPressed: _showAddReminderSheet,
        child: Icon(Icons.add, color: Colors.black),
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
