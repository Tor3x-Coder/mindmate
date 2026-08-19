import 'dart:math';
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<Map<String, dynamic>> _slides = [
    {
      'title': "Your mind's new best friend.",
      'description':
          "Discover tools and techniques to nurture your mental wellbeing every day.",
      'image': 'assets/illustrations/illustration_mind.png',
    },
    {
      'title': "Track vibes. Build habits.",
      'description':
          "Log your emotions daily to identify patterns and cultivate positive routines.",
      'image': 'assets/illustrations/illustration_mood.png',
    },
    {
      'title': "Breathe in. Reach out.",
      'description':
          "Access guided meditations and connect with a supportive community to grow together.",
      'image': 'assets/illustrations/illustration_meditate.png',
    },
  ];

  static const Color _accentColor = Color(0xFF71B7A6);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGray = Color(0xFF6B7280);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage >= 3) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _skipToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildSlide(0),
          _buildSlide(1),
          _buildSlide(2),
          _buildWelcomeScreen(),
        ],
      ),
    );
  }

  Widget _buildSlide(int index) {
    final slide = _slides[index];

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (index > 0)
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      color: _textGray,
                    )
                  else
                    const SizedBox(width: 48),
                  TextButton(
                    onPressed: _skipToLogin,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _textGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset(
                      slide['image'] as String,
                      width: 320,
                      height: 320,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      slide['title'] as String,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      slide['description'] as String,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 16,
                        color: _textGray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? _accentColor
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: _textDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _goBack,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  color: _textGray,
                ),
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Sunrise illustration drawn with CustomPainter
                    SizedBox(
                      width: 280,
                      height: 220,
                      child: CustomPaint(
                        painter: _SunrisePainter(color: _accentColor),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Title with teal dot
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'MindMate',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: -1,
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(left: 2),
                          decoration: const BoxDecoration(
                            color: _accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ready to build a better headspace?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _textGray,
                      ),
                    ),
                    const SizedBox(height: 56),
                    // Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _goToRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _textDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Log In text link
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            fontSize: 15,
                            color: _textGray,
                          ),
                          children: [
                            TextSpan(
                              text: 'Log In',
                              style: TextStyle(
                                fontSize: 15,
                                color: _accentColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: _accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Footer disclaimer
                    const Text(
                      'By continuing, you agree to our Terms of\nService and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: _textGray,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter that draws the teal sunrise over water
class _SunrisePainter extends CustomPainter {
  final Color color;

  _SunrisePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final horizonY = size.height * 0.55;
    final sunRadius = size.width * 0.22;

    // Draw sun rays (lines radiating from top of sun)
    const rayCount = 9;
    final rayStartRadius = sunRadius + 12;
    final rayEndRadius = sunRadius + 30;
    for (int i = 0; i < rayCount; i++) {
      final angle = -3.14159 / 2 +
          (i - (rayCount - 1) / 2) * (3.14159 / (rayCount + 1));
      final startX = centerX + rayStartRadius * cos(angle);
      final startY = horizonY + rayStartRadius * sin(angle);
      final endX = centerX + rayEndRadius * cos(angle);
      final endY = horizonY + rayEndRadius * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // Draw the sun (half circle arc from pi to 2*pi, which is the top half)
    final sunRect = Rect.fromCircle(
      center: Offset(centerX, horizonY),
      radius: sunRadius,
    );
    canvas.drawArc(
      sunRect,
      3.14159, // start at left (pi radians)
      3.14159, // sweep to right (pi radians, completing top half)
      false,
      paint,
    );

    // Draw horizon line (full width)
    final horizonPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      horizonPaint,
    );

    // Draw water waves (three wavy lines below horizon)
    const waveSpacing = 14.0;
    for (int wave = 0; wave < 3; wave++) {
      final waveY = horizonY + (wave + 1) * waveSpacing;
      final path = Path();
      path.moveTo(0, waveY);
      // Draw a sine wave across the width
      final waveWidth = size.width;
      const waveAmplitude = 4.0;
      const waveLength = 60.0;
      for (double x = 0; x <= waveWidth; x += 2) {
        final y = waveY +
            sin((x / waveLength) * 2 * 3.14159 + wave * 0.5) *
                waveAmplitude *
                (1 - wave * 0.2);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunrisePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}