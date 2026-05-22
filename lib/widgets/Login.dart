import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_dot/providers/app_provider.dart';
import 'package:wallet_dot/widgets/Home.dart';
import 'package:wallet_dot/widgets/Signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
    });

    final provider = Provider.of<AppProvider>(context, listen: false);
    try {
      await provider.login(_usernameController.text.trim(), _passwordController.text);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
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
                color: const Color(0xFF2DD4BF).withOpacity(0.04),
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
                color: const Color(0xFF0EA5E9).withOpacity(0.03),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      // Header Logo & Branding
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
                              color: const Color(0xFF2DD4BF),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Access your dashboard to manage assets',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Glassmorphic Card Container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(28.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF121B2A).withOpacity(0.65),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF2DD4BF).withOpacity(0.12),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_errorMessage != null) ...[
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
                                            _errorMessage!,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.redAccent, 
                                              fontSize: 13, 
                                              height: 1.3
                                            ),
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
                                     color: const Color(0xFF2DD4BF),
                                     fontSize: 11,
                                     fontWeight: FontWeight.bold,
                                     letterSpacing: 1.5,
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 TextFormField(
                                   controller: _usernameController,
                                   style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15),
                                   decoration: InputDecoration(
                                     hintText: 'Enter your username',
                                     hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.18)),
                                     filled: true,
                                     fillColor: const Color(0xFF0A0E17),
                                     prefixIcon: const Icon(Icons.person_outline_rounded),
                                     prefixIconColor: WidgetStateColor.resolveWith((states) {
                                       if (states.contains(WidgetState.focused)) return const Color(0xFF2DD4BF);
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
                                       borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 1.2),
                                     ),
                                   ),
                                   validator: (value) {
                                     if (value == null || value.trim().isEmpty) {
                                       return 'Please enter your username';
                                     }
                                     return null;
                                   },
                                 ),
                                 const SizedBox(height: 20),
 
                                 // Password field
                                 Text(
                                   'PASSWORD',
                                   style: GoogleFonts.plusJakartaSans(
                                     color: const Color(0xFF2DD4BF),
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
                                     hintText: 'Enter your password',
                                     hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.18)),
                                     filled: true,
                                     fillColor: const Color(0xFF0A0E17),
                                     prefixIcon: const Icon(Icons.lock_outline_rounded),
                                     prefixIconColor: WidgetStateColor.resolveWith((states) {
                                       if (states.contains(WidgetState.focused)) return const Color(0xFF2DD4BF);
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
                                       borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 1.2),
                                     ),
                                   ),
                                   validator: (value) {
                                     if (value == null || value.isEmpty) {
                                       return 'Please enter your password';
                                     }
                                     return null;
                                   },
                                 ),
                                const SizedBox(height: 32),

                                // Login Button
                                _InteractiveLoginButton(
                                  isBusy: provider.isBusy,
                                  onTap: provider.isBusy ? null : _handleLogin,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Signup link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const Signup()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF2DD4BF),
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
          ),
        ],
      ),
    );
  }
}

class _InteractiveLoginButton extends StatefulWidget {
  final bool isBusy;
  final VoidCallback? onTap;

  const _InteractiveLoginButton({required this.isBusy, required this.onTap});

  @override
  State<_InteractiveLoginButton> createState() => _InteractiveLoginButtonState();
}

class _InteractiveLoginButtonState extends State<_InteractiveLoginButton> {
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
                  : [const Color(0xFF2DD4BF), const Color(0xFF0EA5E9)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!widget.isBusy)
                BoxShadow(
                  color: const Color(0xFF2DD4BF).withOpacity(0.25),
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
                    'Sign In',
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
