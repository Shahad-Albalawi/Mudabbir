import 'dart:math';
import 'package:flutter/material.dart';

/// Confetti celebration widget
class ConfettiWidget extends StatefulWidget {
  final bool isPlaying;
  final Duration duration;

  const ConfettiWidget({
    super.key,
    this.isPlaying = false,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    if (widget.isPlaying) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startConfetti();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _stopConfetti();
    }
  }

  void _startConfetti() {
    _particles.clear();
    // Generate particles
    for (int i = 0; i < 50; i++) {
      _particles.add(
        ConfettiParticle(
          color: _getRandomColor(),
          x: _random.nextDouble(),
          y: -0.1,
          velocityX: _random.nextDouble() * 2 - 1,
          velocityY: _random.nextDouble() * 2 + 3,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: _random.nextDouble() * 0.2 - 0.1,
        ),
      );
    }
    _controller.forward(from: 0.0);
  }

  void _stopConfetti() {
    _controller.stop();
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  final Color color;
  double x;
  double y;
  final double velocityX;
  final double velocityY;
  double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update(double deltaTime) {
    x += velocityX * deltaTime * 0.02;
    y += velocityY * deltaTime * 0.02;
    rotation += rotationSpeed;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double animationValue;

  ConfettiPainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(animationValue * 100);

      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - animationValue)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      // Skip particles that are off screen
      if (y > size.height) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation);

      // Draw confetti piece (rectangle)
      canvas.drawRect(const Rect.fromLTWH(-5, -10, 10, 20), paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

/// Simple overlay to show confetti on top of content
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool showConfetti;
  final VoidCallback? onConfettiComplete;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.showConfetti = false,
    this.onConfettiComplete,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  bool _isPlaying = false;

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      setState(() => _isPlaying = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _isPlaying = false);
          widget.onConfettiComplete?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isPlaying)
          Positioned.fill(
            child: IgnorePointer(child: ConfettiWidget(isPlaying: _isPlaying)),
          ),
      ],
    );
  }
}
