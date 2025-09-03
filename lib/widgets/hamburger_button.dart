import 'package:flutter/material.dart';

class HamburgerButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isOpen;

  const HamburgerButton({
    super.key,
    required this.onPressed,
    this.isOpen = false,
  });

  @override
  State<HamburgerButton> createState() => _HamburgerButtonState();
}

class _HamburgerButtonState extends State<HamburgerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(HamburgerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(20, 16),
                painter: HamburgerPainter(
                  progress: _animation.value,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HamburgerPainter extends CustomPainter {
  final double progress;

  HamburgerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B46C1)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Top line
    final topY = centerY - 4;
    final topStartX = centerX - 6;
    final topEndX = centerX + 6;

    // Middle line
    final middleY = centerY;
    final middleStartX = centerX - 6;
    final middleEndX = centerX + 6;

    // Bottom line
    final bottomY = centerY + 4;
    final bottomStartX = centerX - 6;
    final bottomEndX = centerX + 6;

    if (progress == 0.0) {
      // Draw hamburger lines
      canvas.drawLine(
        Offset(topStartX, topY),
        Offset(topEndX, topY),
        paint,
      );
      canvas.drawLine(
        Offset(middleStartX, middleY),
        Offset(middleEndX, middleY),
        paint,
      );
      canvas.drawLine(
        Offset(bottomStartX, bottomY),
        Offset(bottomEndX, bottomY),
        paint,
      );
    } else if (progress == 1.0) {
      // Draw X lines
      canvas.drawLine(
        Offset(topStartX, topY),
        Offset(bottomEndX, bottomY),
        paint,
      );
      canvas.drawLine(
        Offset(topEndX, topY),
        Offset(bottomStartX, bottomY),
        paint,
      );
    } else {
      // Animate between hamburger and X
      final topLineStart = Offset(
        topStartX + (topEndX - topStartX) * progress,
        topY,
      );
      final topLineEnd = Offset(
        topEndX - (topEndX - topStartX) * progress,
        topY,
      );

      final bottomLineStart = Offset(
        bottomStartX + (bottomEndX - bottomStartX) * progress,
        bottomY,
      );
      final bottomLineEnd = Offset(
        bottomEndX - (bottomEndX - bottomStartX) * progress,
        bottomY,
      );

      // Top line animation
      canvas.drawLine(
        topLineStart,
        topLineEnd,
        paint,
      );

      // Bottom line animation
      canvas.drawLine(
        bottomLineStart,
        bottomLineEnd,
        paint,
      );

      // Middle line fades out
      final middleOpacity = 1.0 - progress;
      final middlePaint = Paint()
        ..color = const Color(0xFF6B46C1).withValues(alpha: middleOpacity)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(middleStartX, middleY),
        Offset(middleEndX, middleY),
        middlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(HamburgerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
