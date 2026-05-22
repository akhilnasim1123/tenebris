import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_provider.dart';

class AvatarWidget extends StatelessWidget {
  final String? profilePicture;
  final double radius;

  const AvatarWidget({super.key, required this.profilePicture, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    if (profilePicture == null || profilePicture!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF1E293B),
        child: Icon(
          Icons.person_rounded,
          color: const Color(0xFF94A3B8),
          size: radius * 1.2,
        ),
      );
    }

    if (profilePicture!.startsWith('avatar:')) {
      final indexStr = profilePicture!.split(':').last;
      final index = int.tryParse(indexStr) ?? 0;
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              gradient: _getAvatarGradient(index),
            ),
            alignment: Alignment.center,
            child: Icon(
              _getAvatarIcon(index),
              color: Colors.white,
              size: radius,
            ),
          ),
        ),
      );
    }

    try {
      final bytes = base64Decode(profilePicture!);
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(bytes),
      );
    } catch (e) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF1E293B),
        child: Icon(
          Icons.person_rounded,
          color: const Color(0xFF94A3B8),
          size: radius * 1.2,
        ),
      );
    }
  }

  static Gradient _getAvatarGradient(int index) {
    final gradients = [
      const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)], begin: Alignment.topLeft, end: Alignment.bottomRight), // Teal to Cyan
      const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFFB923C)], begin: Alignment.topLeft, end: Alignment.bottomRight), // Coral to Orange
      const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)], begin: Alignment.topLeft, end: Alignment.bottomRight), // Purple to Pink
      const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight), // Emerald to Blue
      const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)], begin: Alignment.topLeft, end: Alignment.bottomRight), // Yellow to Gold
    ];
    return gradients[index % gradients.length];
  }

  static IconData _getAvatarIcon(int index) {
    final icons = [
      Icons.bolt_rounded,
      Icons.auto_awesome_rounded,
      Icons.currency_bitcoin_rounded,
      Icons.rocket_launch_rounded,
      Icons.shield_rounded,
    ];
    return icons[index % icons.length];
  }
}

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  String? _selectedProfilePicture;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> _avatarOptions = [
    'avatar:0',
    'avatar:1',
    'avatar:2',
    'avatar:3',
    'avatar:4',
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.name ?? '');
    _usernameController = TextEditingController(text: provider.username ?? '');
    _passwordController = TextEditingController();
    _selectedProfilePicture = provider.profilePicture;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _selectedProfilePicture = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFF43F5E),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<AppProvider>(context, listen: false);
    final result = await provider.updateProfile(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      profilePicture: _selectedProfilePicture,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.containsKey('success')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    } else {
      final errorMsg = result['error'] ?? 'Profile update failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFF43F5E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF94A3B8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile Settings',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Preview
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2DD4BF),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2DD4BF).withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: AvatarWidget(
                          profilePicture: _selectedProfilePicture,
                          radius: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2DD4BF),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Color(0xFF080C14),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Predefined Avatars Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Predefined Premium Avatars',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Predefined Avatars List
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _avatarOptions.length + 1, // Predefined + custom photo option
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Reset to default button
                        final isSelected = _selectedProfilePicture == null || _selectedProfilePicture!.isEmpty;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedProfilePicture = '';
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2DD4BF) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 28,
                              backgroundColor: Color(0xFF1E293B),
                              child: Icon(
                                Icons.person_rounded,
                                color: Color(0xFF94A3B8),
                                size: 28 * 1.2,
                              ),
                            ),
                          ),
                        );
                      }

                      final avatarCode = _avatarOptions[index - 1];
                      final isSelected = _selectedProfilePicture == avatarCode;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedProfilePicture = avatarCode;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2DD4BF) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: AvatarWidget(
                            profilePicture: avatarCode,
                            radius: 28,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121B2A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2DD4BF).withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Username
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'Enter your username',
                        icon: Icons.alternate_email_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.trim().length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        label: 'New Password',
                        hint: 'Leave blank to keep unchanged',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                GestureDetector(
                  onTap: _isLoading ? null : _saveProfile,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2DD4BF).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF475569),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF475569), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF0A0E17),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF2DD4BF).withOpacity(0.05),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2DD4BF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFF43F5E),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFF43F5E),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
