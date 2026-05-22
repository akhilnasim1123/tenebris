import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet_dot/providers/app_provider.dart';
import 'package:wallet_dot/widgets/Home.dart';
import 'package:wallet_dot/widgets/Login.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          // Background subtle ambient glows
          Positioned(
            top: size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2DD4BF).withOpacity(0.04),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.2,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0EA5E9).withOpacity(0.04),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(),
              ),
            ),
          ),

          // Central Fintech Digital Orb Visual
          Positioned(
            top: size.height * 0.18,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background glowing circle
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2DD4BF).withOpacity(0.03),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2DD4BF).withOpacity(0.15),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Outer rotating rings painter
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(240, 240),
                              painter: FintechOrbPainter(
                                rotationValue: _rotationController.value,
                              ),
                            );
                          },
                        ),
                        // Central sleek glowing gradient micro-chip icon or core
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2DD4BF), Color(0xFF0EA5E9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2DD4BF).withOpacity(0.5),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Spacer(),
                    
                    // Glassmorphic Details Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                              // Sleek App Brand Name
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'wallet',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    'Dot',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF2DD4BF),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'SMART ASSET MANAGEMENT',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2DD4BF),
                                  letterSpacing: 2.5,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Take control of your expenses, analyze your earnings, and track your obligations in a sleek, secure dashboard.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF94A3B8),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 36),
                              
                              // Shimmer Button
                              ShimmerButton(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => 
                                          provider.isLoggedIn ? const Home() : const Login(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(opacity: animation, child: child);
                                      },
                                      transitionDuration: const Duration(milliseconds: 600),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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

// Custom Painter for a modern concentric/orbit fintech orb
class FintechOrbPainter extends CustomPainter {
  final double rotationValue;

  FintechOrbPainter({required this.rotationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Radius sizes
    final r1 = size.width * 0.46;
    final r2 = size.width * 0.36;
    final r3 = size.width * 0.26;

    // 1. Draw outer glowing ring (slow rotation)
    paint.color = const Color(0xFF2DD4BF).withOpacity(0.15);
    canvas.drawCircle(center, r1, paint);

    // 2. Draw middle ring (fast dashed or dotted rotation)
    paint.color = const Color(0xFF2DD4BF).withOpacity(0.25);
    paint.strokeWidth = 1.2;
    _drawDashedCircle(canvas, center, r2, 28, paint);

    // 3. Draw inner ring
    paint.color = const Color(0xFF0EA5E9).withOpacity(0.4);
    paint.strokeWidth = 1.0;
    canvas.drawCircle(center, r3, paint);

    // 4. Draw Orbiting Nodes
    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2DD4BF);

    // Node 1 on Outer Ring
    final angle1 = rotationValue * 2 * 3.14159265;
    final node1 = Offset(
      center.dx + r1 * MathHelper.cos(angle1),
      center.dy + r1 * MathHelper.sin(angle1),
    );
    canvas.drawCircle(node1, 6.0, nodePaint);
    canvas.drawCircle(node1, 10.0, Paint()..color = const Color(0xFF2DD4BF).withOpacity(0.25)..style = PaintingStyle.fill);

    // Node 2 on Middle Ring (rotates opposite direction)
    final angle2 = -rotationValue * 4 * 3.14159265;
    final node2 = Offset(
      center.dx + r2 * MathHelper.cos(angle2),
      center.dy + r2 * MathHelper.sin(angle2),
    );
    nodePaint.color = const Color(0xFF2DD4BF);
    canvas.drawCircle(node2, 4.0, nodePaint);

    // Node 3 on Inner Ring
    final angle3 = rotationValue * 3 * 3.14159265 + 1.2;
    final node3 = Offset(
      center.dx + r3 * MathHelper.cos(angle3),
      center.dy + r3 * MathHelper.sin(angle3),
    );
    nodePaint.color = const Color(0xFF0EA5E9);
    canvas.drawCircle(node3, 5.0, nodePaint);
    canvas.drawCircle(node3, 8.0, Paint()..color = const Color(0xFF0EA5E9).withOpacity(0.35)..style = PaintingStyle.fill);

    // Connect node 1 and center with a faint trace line
    canvas.drawLine(
      center,
      node1,
      Paint()
        ..color = const Color(0xFF2DD4BF).withOpacity(0.10)
        ..strokeWidth = 1.0,
    );
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, int segments, Paint paint) {
    const double doublePi = 2 * 3.1415926535;
    final double segmentAngle = doublePi / (segments * 2);
    for (int i = 0; i < segments * 2; i += 2) {
      final double startAngle = i * segmentAngle + (rotationValue * 0.5);
      final double endAngle = (i + 1) * segmentAngle + (rotationValue * 0.5);
      
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startAngle, endAngle - startAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Simple Math helper to avoid external dependencies
class MathHelper {
  static double sin(double radians) {
    double x = radians % (2 * 3.1415926535);
    if (x < 0) x += 2 * 3.1415926535;
    double term = x;
    double sum = x;
    double x2 = x * x;
    for (int i = 1; i <= 6; i++) {
      term *= -x2 / ((2 * i) * (2 * i + 1));
      sum += term;
    }
    return sum;
  }

  static double cos(double radians) {
    return sin(radians + 3.1415926535 / 2);
  }
}

class ShimmerButton extends StatefulWidget {
  final VoidCallback onTap;
  const ShimmerButton({super.key, required this.onTap});

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3500 ~/ 1000), // ~3.5s
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          final double value = _shimmerController.value;
          return GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-2.0 + value * 4.0, -1.0),
                  end: Alignment(0.0 + value * 4.0, 1.0),
                  colors: const [
                    Color(0xFF2DD4BF),
                    Color(0xFF0EA5E9),
                    Color(0xFF0D9488),
                    Color(0xFF2DD4BF),
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2DD4BF).withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Get Started',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
