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
  late AnimationController _cardSlideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _pulseAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: _cardSlideController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardSlideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _cardSlideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // ── Background: layered radial glows ──
          Positioned(
            top: -size.height * 0.08,
            left: -size.width * 0.25,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFFED7B8).withOpacity(0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.05,
            right: -size.width * 0.25,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF677DAA).withOpacity(0.06),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Main Content ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // ── Top Brand Logo ──
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFED7B8),
                                Color(0xFF677DAA),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'wallet',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Dot',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFED7B8),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Hero Card ──
                  SlideTransition(
                    position: _cardSlideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildHeroCard(),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Onboarding Content ──
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      height: 200,
                      child: _buildOnboardingContent(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Dot Indicators ──
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildDotIndicators(),
                  ),

                  const SizedBox(height: 28),

                  // ── CTA Button ──
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildCTAButton(provider),
                  ),

                  const SizedBox(height: 16),

                  // ── Terms text ──
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'By continuing you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF677DAA).withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Hero Card — realistic glassmorphic bank card
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildHeroCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Shadow card behind (offset)
        Positioned(
          left: 16,
          right: 16,
          top: 14,
          child: Container(
            height: 195,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF0A1F30).withOpacity(0.6),
            ),
          ),
        ),

        // Main card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2B42), Color(0xFF0A1F30)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFED7B8).withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFED7B8).withOpacity(0.06),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row — chip + brand
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // EMV chip
                  Container(
                    width: 44,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD4A76A),
                          Color(0xFFFED7B8),
                          Color(0xFFD4A76A),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: const Color(0xFFB8860B).withOpacity(0.5),
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Contactless icon + logo
                  Row(
                    children: [
                      Icon(
                        Icons.wifi_rounded,
                        color: Colors.white.withOpacity(0.3),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'VISA',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Card number
              Text(
                '4532  ••••  ••••  7892',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 17,
                  letterSpacing: 3.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Bottom row — holder + expiry
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARD HOLDER',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF677DAA).withOpacity(0.7),
                          fontSize: 8,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AKHIL KUMAR',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'VALID THRU',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF677DAA).withOpacity(0.7),
                          fontSize: 8,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '12/28',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  // walletDot mini branding
                  Row(
                    children: [
                      Text(
                        'w',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'D',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFFED7B8).withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Floating stat badges ──

        // Income badge (top right)
        Positioned(
          top: -12,
          right: -6,
          child: _buildFloatingBadge(
            icon: Icons.trending_up_rounded,
            label: '+₹24.5K',
            color: const Color(0xFF10B981),
          ),
        ),

        // Expense badge (bottom left)
        Positioned(
          bottom: -12,
          left: -6,
          child: _buildFloatingBadge(
            icon: Icons.pie_chart_rounded,
            label: '₹12.3K',
            color: const Color(0xFFFED7B8),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1F30).withOpacity(0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08 + _pulseAnimation.value * 0.07),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Onboarding Content PageView
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildOnboardingContent() {
    final slides = [
      {
        'title': 'Your finances,\none dashboard.',
        'desc':
            'See bank accounts, cash, savings and credit cards — all in a single, beautiful view.',
      },
      {
        'title': 'Spending insights\nthat matter.',
        'desc':
            'Automatic category breakdowns and trend analysis so you always know where your money goes.',
      },
      {
        'title': 'Set goals.\nTrack progress.',
        'desc':
            'Create savings targets and watch them grow in real-time with intuitive visual tracking.',
      },
    ];

    return PageView.builder(
      controller: _pageController,
      itemCount: slides.length,
      onPageChanged: (i) => setState(() => _currentPage = i),
      itemBuilder: (context, index) {
        final slide = slides[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slide['title']!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                slide['desc']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF677DAA),
                  height: 1.6,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? const Color(0xFFFED7B8)
                : const Color(0xFF677DAA).withOpacity(0.2),
          ),
        );
      }),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CTA Button — animated shimmer gradient with pulsing glow
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildCTAButton(AppProvider provider) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _pulseController]),
      builder: (context, child) {
        final shimmer = _shimmerController.value;
        final pulse = _pulseAnimation.value;

        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    provider.isLoggedIn ? const Home() : const Login(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.5 + shimmer * 3.0, 0),
                end: Alignment(0.5 + shimmer * 3.0, 0),
                colors: const [
                  Color(0xFFFED7B8),
                  Color(0xFF677DAA),
                  Color(0xFFFED7B8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFED7B8)
                      .withOpacity(0.10 + pulse * 0.15),
                  blurRadius: 16 + pulse * 12,
                  spreadRadius: pulse * 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
