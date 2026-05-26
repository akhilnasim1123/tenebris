import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_dot/providers/app_provider.dart';
import 'package:wallet_dot/services/database_service.dart';
import 'package:wallet_dot/widgets/Home.dart';
import 'package:wallet_dot/widgets/common/GradientScaffold.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _usernameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  String? _usernameError;
  String? _phoneError;
  String? _generalError;
  List<String> _usernameSuggestions = [];
  bool _checkingUsername = false;
  bool _checkingPhone = false;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(_onUsernameFocusChange);
    _phoneFocusNode.addListener(_onPhoneFocusChange);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _usernameFocusNode.removeListener(_onUsernameFocusChange);
    _phoneFocusNode.removeListener(_onPhoneFocusChange);
    _usernameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onUsernameFocusChange() {
    if (!_usernameFocusNode.hasFocus) {
      _checkUsernameAvailability();
    }
  }

  void _onPhoneFocusChange() {
    if (!_phoneFocusNode.hasFocus) {
      _checkPhoneAvailability();
    }
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _checkingUsername = true;
      _usernameError = null;
      _usernameSuggestions = [];
    });

    try {
      final result = await DatabaseService().checkAvailability(username: username);
      if (mounted) {
        setState(() {
          if (result['username_available'] == false) {
            _usernameError = 'Username is already taken';
            _usernameSuggestions = List<String>.from(result['suggestions'] ?? []);
          } else {
            _usernameError = null;
          }
        });
      }
    } catch (e) {
      debugPrint("Error checking username availability: $e");
    } finally {
      if (mounted) {
        setState(() {
          _checkingUsername = false;
        });
      }
    }
  }

  Future<void> _checkPhoneAvailability() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      _checkingPhone = true;
      _phoneError = null;
    });

    try {
      final result = await DatabaseService().checkAvailability(phoneNumber: phone);
      if (mounted) {
        setState(() {
          if (result['phone_number_available'] == false) {
            _phoneError = 'Phone number is already registered';
          } else {
            _phoneError = null;
          }
        });
      }
    } catch (e) {
      debugPrint("Error checking phone availability: $e");
    } finally {
      if (mounted) {
        setState(() {
          _checkingPhone = false;
        });
      }
    }
  }

  Future<void> _handleSignup() async {
    await _checkUsernameAvailability();
    await _checkPhoneAvailability();

    if (!_formKey.currentState!.validate() || _usernameError != null || _phoneError != null) {
      return;
    }

    setState(() {
      _generalError = null;
    });

    final provider = Provider.of<AppProvider>(context, listen: false);
    try {
      final result = await provider.signup(
        _usernameController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
      );

      if (mounted) {
        if (result['success'] == true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Home()),
            (route) => false,
          );
        } else {
          setState(() {
            final field = result['field'];
            final err = result['error'];
            if (field == 'username') {
              _usernameError = err;
              _usernameSuggestions = List<String>.from(result['suggestions'] ?? []);
            } else if (field == 'phone_number') {
              _phoneError = err;
            } else {
              _generalError = err;
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _generalError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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

          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'wallet',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Dot',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFED7B8),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a new account to get started',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF677DAA),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Glassmorphic Card Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(28.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1F30).withOpacity(0.65),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: const Color(0xFFFED7B8).withOpacity(0.15),
                                width: 1.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_generalError != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _generalError!,
                                          style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontSize: 13, height: 1.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // Username field
                              Text(
                                'USERNAME',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFFED7B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                focusNode: _usernameFocusNode,
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'Choose a unique username',
                                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.18)),
                                  filled: true,
                                  fillColor: const Color(0xFF02101C),
                                  prefixIcon: const Icon(Icons.person_outline_rounded),
                                  prefixIconColor: WidgetStateColor.resolveWith((states) {
                                    if (states.contains(WidgetState.focused)) return const Color(0xFFFED7B8);
                                    return Colors.white.withOpacity(0.3);
                                  }),
                                  suffixIcon: _checkingUsername
                                      ? const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(color: Color(0xFFFED7B8), strokeWidth: 2),
                                          ),
                                        )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFFED7B8), width: 1.2),
                                  ),
                                  errorText: _usernameError,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                              ),

                              // Username suggestions
                              if (_usernameSuggestions.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'SUGGESTIONS:',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withOpacity(0.4), 
                                    fontSize: 11, 
                                    fontWeight: FontWeight.bold, 
                                    letterSpacing: 0.5
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 38,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _usernameSuggestions.length,
                                    itemBuilder: (context, index) {
                                      final suggestion = _usernameSuggestions[index];
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: ChoiceChip(
                                          label: Text(suggestion),
                                          labelStyle: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFFFED7B8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          selected: false,
                                          onSelected: (_) {
                                            setState(() {
                                              _usernameController.text = suggestion;
                                              _usernameError = null;
                                              _usernameSuggestions = [];
                                            });
                                            FocusScope.of(context).unfocus();
                                          },
                                          backgroundColor: const Color(0xFFFED7B8).withOpacity(0.1),
                                          side: const BorderSide(color: Color(0xFFFED7B8), width: 1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),

                              // Password field
                              Text(
                                'PASSWORD',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFFED7B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'Choose a strong password',
                                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.18)),
                                  filled: true,
                                  fillColor: const Color(0xFF02101C),
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  prefixIconColor: WidgetStateColor.resolveWith((states) {
                                    if (states.contains(WidgetState.focused)) return const Color(0xFFFED7B8);
                                    return Colors.white.withOpacity(0.3);
                                  }),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFFED7B8), width: 1.2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Phone Number field
                              Text(
                                'PHONE NUMBER',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFFED7B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'Enter your phone number',
                                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.18)),
                                  filled: true,
                                  fillColor: const Color(0xFF02101C),
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  prefixIconColor: WidgetStateColor.resolveWith((states) {
                                    if (states.contains(WidgetState.focused)) return const Color(0xFFFED7B8);
                                    return Colors.white.withOpacity(0.3);
                                  }),
                                  suffixIcon: _checkingPhone
                                      ? const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(color: Color(0xFFFED7B8), strokeWidth: 2),
                                          ),
                                        )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.04)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Color(0xFFFED7B8), width: 1.2),
                                  ),
                                  errorText: _phoneError,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Sign Up button
                              _InteractiveSignupButton(
                                isBusy: provider.isBusy || _checkingUsername || _checkingPhone,
                                onTap: provider.isBusy || _checkingUsername || _checkingPhone ? null : _handleSignup,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFFED7B8),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveSignupButton extends StatefulWidget {
  final bool isBusy;
  final VoidCallback? onTap;

  const _InteractiveSignupButton({required this.isBusy, required this.onTap});

  @override
  State<_InteractiveSignupButton> createState() => _InteractiveSignupButtonState();
}

class _InteractiveSignupButtonState extends State<_InteractiveSignupButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isBusy
                  ? [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.3)]
                  : [const Color(0xFFFED7B8), const Color(0xFF677DAA)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!widget.isBusy)
                BoxShadow(
                  color: const Color(0xFFFED7B8).withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: Center(
            child: widget.isBusy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Sign Up',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
