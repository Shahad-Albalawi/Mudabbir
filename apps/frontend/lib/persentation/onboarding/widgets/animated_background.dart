import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final int currentIndex;
  final int totalPages;

  const AnimatedBackground({
    super.key,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particles = _generateParticles();
    _backgroundController.forward();
  }

  @override
  void didUpdateWidget(AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _backgroundController.reset();
      _backgroundController.forward();
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  List<Particle> _generateParticles() {
    return List.generate(20, (index) {
      return Particle(
        x: (index * 50.0) % 400,
        y: (index * 80.0) % 800,
        size: 2.0 + (index % 3),
        opacity: 0.1 + (index % 3) * 0.1,
        speed: 0.5 + (index % 3) * 0.5,
      );
    });
  }

  Color _getBackgroundColor() {
    final colors = [
      const Color(0xFFF8FAF7),
      const Color(0xFFF1F5F2),
      const Color(0xFFEAF1EC),
    ];
    return colors[widget.currentIndex % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getBackgroundColor(),
            _getBackgroundColor().withOpacity(0.92),
            ColorManager.primary.withOpacity(0.05),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(
                  particles: _particles,
                  animation: _particleController,
                ),
              );
            },
          ),

          // Gradient overlay
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      ColorManager.primary.withOpacity(
                        0.06 * _backgroundController.value,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _getBackgroundColor().withOpacity(0.8),
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

class Particle {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double speed;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorManager.primaryWithOpacity10
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final animatedY =
          (particle.y + animation.value * particle.speed * 100) % size.height;

      paint.color = ColorManager.primary.withOpacity(particle.opacity * 0.3);

      canvas.drawCircle(Offset(particle.x, animatedY), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}
