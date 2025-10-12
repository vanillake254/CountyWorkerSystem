import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Navigate after animation
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3B5998),
              const Color(0xFF2C4373),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildGovernmentIcon(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // App Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'County Worker Platform',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              
              // Subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Government Worker Management System',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
              
              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 80),
              
              // Powered by
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'Powered by',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ).createShader(bounds),
                      child: const Text(
                        'VANILLA SOFTWARES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGovernmentIcon() {
    return CustomPaint(
      painter: GovernmentIconPainter(),
    );
  }
}

class GovernmentIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final blue = const Color(0xFF3B5998);
    final darkBlue = const Color(0xFF2C4373);
    final white = Colors.white;

    final scale = size.width / 200;
    final offsetX = (size.width - 100 * scale) / 2;
    final offsetY = (size.height - 110 * scale) / 2;

    // Building body
    paint.color = blue;
    canvas.drawRect(
      Rect.fromLTWH(
        offsetX + 50 * scale,
        offsetY + 60 * scale,
        100 * scale,
        80 * scale,
      ),
      paint,
    );

    // Columns (white pillars)
    paint.color = white;
    for (var x in [60.0, 85.0, 110.0, 135.0]) {
      canvas.drawRect(
        Rect.fromLTWH(
          offsetX + x * scale,
          offsetY + 70 * scale,
          10 * scale,
          60 * scale,
        ),
        paint,
      );
    }

    // Roof (triangle)
    paint.color = darkBlue;
    final roofPath = Path()
      ..moveTo(offsetX + 100 * scale, offsetY + 40 * scale) // top
      ..lineTo(offsetX + 40 * scale, offsetY + 60 * scale) // left
      ..lineTo(offsetX + 160 * scale, offsetY + 60 * scale) // right
      ..close();
    canvas.drawPath(roofPath, paint);

    // Base
    canvas.drawRect(
      Rect.fromLTWH(
        offsetX + 40 * scale,
        offsetY + 140 * scale,
        120 * scale,
        10 * scale,
      ),
      paint,
    );

    // Door
    canvas.drawRect(
      Rect.fromLTWH(
        offsetX + 85 * scale,
        offsetY + 110 * scale,
        30 * scale,
        30 * scale,
      ),
      paint,
    );

    // Border
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * scale;
    paint.color = darkBlue;
    canvas.drawRect(
      Rect.fromLTWH(
        offsetX + 50 * scale,
        offsetY + 60 * scale,
        100 * scale,
        80 * scale,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
