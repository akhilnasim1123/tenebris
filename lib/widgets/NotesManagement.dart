import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wallet_dot/providers/app_provider.dart';
import 'package:wallet_dot/widgets/common/ConfirmationDialog.dart';
import 'package:wallet_dot/widgets/common/GradientScaffold.dart';

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
      backgroundColor: const Color(0xFF0A1F30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
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
                      'Add Knowledge / Note',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Document important information in your knowledge base.',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF677DAA),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Category Dropdown
                    Text('Category', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF02101C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.04)),
                            ),
                            child: categories.isEmpty 
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Text('No categories available', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                                  )
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategoryId,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF0A1F30),
                                      items: categories.map((cat) {
                                        return DropdownMenuItem<String>(
                                          value: cat['id'].toString(),
                                          child: Text(cat['name'], style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setSheetState(() { _selectedCategoryId = val; });
                                      },
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showAddCategorySheet();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFED7B8).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFED7B8).withOpacity(0.15)),
                            ),
                            child: const Icon(Icons.add, color: Color(0xFFFED7B8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text('Title', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'e.g., SQLite FFI Logic',
                        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.2)),
                        filled: true,
                        fillColor: const Color(0xFF02101C),
                        contentPadding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 20),

                    // Content
                    Text('Body / Content', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Brain dump here...',
                        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.2)),
                        filled: true,
                        fillColor: const Color(0xFF02101C),
                        contentPadding: const EdgeInsets.all(16),
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
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFED7B8), Color(0xFF677DAA)],
                          ),
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
                            'Save Knowledge',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
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
      backgroundColor: const Color(0xFF0A1F30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
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
                Text('New Category',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Group your knowledge base notes.',
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF677DAA), fontSize: 13)),
                const SizedBox(height: 24),
                TextField(
                  controller: _categoryController,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'e.g., Coding',
                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.2)),
                    filled: true,
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFED7B8), Color(0xFF677DAA)],
                      ),
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
                      child: Text('Create & Continue',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
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

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Knowledge Base',
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.collections_bookmark_outlined,
                              color: Colors.white.withOpacity(0.15),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No knowledge drops yet.',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFED7B8), Color(0xFF677DAA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFED7B8).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          onPressed: () => _showAddNoteSheet(provider.noteCategories),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
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
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFFFED7B8), Color(0xFF677DAA)])
              : null,
          color: isSelected ? null : const Color(0xFF0A1F30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
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
        color: const Color(0xFF0A1F30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
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
                  color: const Color(0xFFFED7B8).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFED7B8).withOpacity(0.15)),
                ),
                child: Text(
                  note['category_name'] ?? 'Unknown',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFED7B8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ConfirmationDialog.show(
                    context,
                    title: 'Delete Note',
                    message: 'Are you sure you want to permanently delete this knowledge drop?',
                    confirmColor: const Color(0xFFF43F5E),
                    onConfirm: () => provider.deleteNote(note['id'].toString()),
                  );
                },
                child: Icon(Icons.delete_outline_rounded, color: Colors.grey.withOpacity(0.5), size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note['title'],
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            note['content'],
            style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            DateFormat('MMMM dd, yyyy - hh:mm a').format(dt),
            style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.3), fontSize: 11),
          ),
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
            color: const Color(0xFF0A1F30),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFED7B8).withOpacity(0.3)),
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
                color: Color(0xFFFED7B8),
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
