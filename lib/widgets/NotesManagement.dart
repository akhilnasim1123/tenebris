import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:tenebris/providers/app_provider.dart';
import 'package:tenebris/widgets/common/ConfirmationDialog.dart';

class NotesManagement extends StatefulWidget {
  const NotesManagement({super.key});

  @override
  State<NotesManagement> createState() => _NotesManagementState();
}

class _NotesManagementState extends State<NotesManagement> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  
  String? _selectedFilterId; // null = All
  String? _selectedCategoryId; // For adding note

  void _showAddNoteSheet(List<Map<String, dynamic>> categories) {
    if (categories.isNotEmpty) {
      _selectedCategoryId = categories.first['id'].toString();
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                    'Add Knowledge / Note',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Category Dropdown
                  Text('Category', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0A0A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: categories.isEmpty 
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text('No categories available', style: GoogleFonts.outfit(color: Colors.grey)),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCategoryId,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF161616),
                                    items: categories.map((cat) {
                                      return DropdownMenuItem<String>(
                                        value: cat['id'].toString(),
                                        child: Text(cat['name'], style: GoogleFonts.outfit(color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setSheetState(() { _selectedCategoryId = val; });
                                    },
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showAddCategorySheet();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF947A57).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(BootstrapIcons.plus, color: Color(0xFF947A57)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text('Title', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'e.g., SQLite FFI Logic',
                      hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
                      filled: true,
                      fillColor: const Color(0xFF0A0A0A),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content
                  Text('Body / Content', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Brain dump here...',
                      hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
                      filled: true,
                      fillColor: const Color(0xFF0A0A0A),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () {
                      if (_titleController.text.isNotEmpty && _selectedCategoryId != null) {
                        Provider.of<AppProvider>(context, listen: false).addNote(
                          _titleController.text, 
                          _contentController.text, 
                          _selectedCategoryId!, 
                          DateTime.now().toIso8601String(),
                        );
                        _titleController.clear();
                        _contentController.clear();
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF947A57),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Save Knowledge',
                          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showAddCategorySheet() {
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
              Text('New Category', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              TextField(
                controller: _categoryController,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'e.g., Coding',
                  hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.2)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  if (_categoryController.text.isNotEmpty) {
                    await Provider.of<AppProvider>(context, listen: false).addNoteCategory(_categoryController.text);
                    _categoryController.clear();
                    if (context.mounted) {
                      Navigator.pop(context);
                      final cats = Provider.of<AppProvider>(context, listen: false).noteCategories;
                      _showAddNoteSheet(cats); // Open add note back up
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF947A57),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('Create & Continue', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final notes = _selectedFilterId == null 
        ? provider.notes 
        : provider.notes.where((n) => n['category_id'] == _selectedFilterId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('Knowledge Base', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    _buildFilterChip(null, 'All Categories', _selectedFilterId == null),
                    ...provider.noteCategories.map((cat) {
                      return _buildFilterChip(cat['id'].toString(), cat['name'], _selectedFilterId == cat['id']?.toString());
                    }),
                  ],
                ),
              ),
              
              Expanded(
                child: notes.isEmpty
                    ? Center(
                        child: Text('No knowledge drops yet.', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4))),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          final dt = DateTime.parse(note['date']);
                          return _buildNoteCard(note, provider, dt);
                        },
                      ),
              ),
            ],
          ),
          if (provider.isBusy)
            _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF947A57),
        onPressed: () => _showAddNoteSheet(provider.noteCategories),
        child: const Icon(BootstrapIcons.plus, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _buildFilterChip(String? id, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() { _selectedFilterId = id; });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF947A57) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF947A57) : Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white.withOpacity(0.6),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, AppProvider provider, DateTime dt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF947A57).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note['category_name'] ?? 'Unknown',
                  style: GoogleFonts.outfit(color: const Color(0xFF947A57), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ConfirmationDialog.show(
                    context,
                    title: 'Delete Note',
                    message: 'Are you sure you want to permanently delete this knowledge drop?',
                    confirmColor: Colors.redAccent,
                    onConfirm: () => provider.deleteNote(note['id'].toString()),
                  );
                },
                child: Icon(BootstrapIcons.trash, color: Colors.grey.withOpacity(0.5), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note['title'],
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            note['content'],
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            DateFormat('MMMM dd, yyyy - hh:mm a').format(dt),
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.3), fontSize: 11),
          ),
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
