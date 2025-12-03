import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class GlassGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final LinearGradient? gradient;
  final double? width;
  final double height;
  final double borderRadius;

  const GlassGradientButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.width,
    this.height = 56.0,
    this.borderRadius = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? Colors.black).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Mesh gradient background
            CustomPaint(
              size: Size(width ?? double.infinity, height),
              painter: MeshGradientPainter(
                colors: gradient?.colors ?? [
                  const Color(0xFF5B0A99),
                  const Color(0xFF6A0DAD),
                  const Color(0xFFA020F0),
                  const Color(0xFFD946EF),
                  const Color(0xFFFF7F7F),
                  const Color(0xFFFFAB70),
                  const Color(0xFFFFC947),
                ],
              ),
            ),
            // Glass effect overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
            // Button material and ripple
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(borderRadius),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(
                  alignment: Alignment.center,
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MeshGradientPainter extends CustomPainter {
  final List<Color> colors;

  MeshGradientPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Draw smooth base gradient
    final baseGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: colors,
    );
    final basePaint = Paint()..shader = baseGradient.createShader(rect);
    canvas.drawRect(rect, basePaint);

    // Add subtle color depth with gentle radial overlays
    final overlayPoints = [
      (Offset(size.width * 0.3, size.height * 0.3), colors[2]),
      (Offset(size.width * 0.5, size.height * 0.5), colors[4]),
      (Offset(size.width * 0.7, size.height * 0.7), colors[colors.length - 2]),
    ];

    for (final (position, color) in overlayPoints) {
      final gradient = RadialGradient(
        center: Alignment(
          (position.dx / size.width) * 2 - 1,
          (position.dy / size.height) * 2 - 1,
        ),
        radius: 0.7,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.15),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..blendMode = BlendMode.softLight;
      
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MeshPoint {
  final Offset position;
  final double radius;
  final int colorIndex;

  MeshPoint(this.position, this.radius, this.colorIndex);
}
