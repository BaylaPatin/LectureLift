import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Mesh gradient background
            CustomPaint(
              size: const Size(double.infinity, 60),
              painter: _NavMeshGradientPainter(
                colors: AppTheme.purpleGradient.colors,
              ),
            ),
            // Glass effect overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Navigation items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.map_outlined, Icons.map, 0, 'Map'),
                _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today, 1, 'Schedule'),
                _buildNavItem(Icons.directions_car_outlined, Icons.directions_car, 2, 'Rides'),
                _buildNavItem(Icons.person_outline, Icons.person, 3, 'Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, int index, String label) {
    final isSelected = selectedIndex == index;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemTapped(index),
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            height: double.infinity,
            alignment: Alignment.center,
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              size: 24,
              shadows: isSelected ? [
                const Shadow(
                  color: Colors.black38,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ] : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavMeshGradientPainter extends CustomPainter {
  final List<Color> colors;

  _NavMeshGradientPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Draw smooth base gradient without mesh points
    final baseGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: colors,
    );
    final basePaint = Paint()..shader = baseGradient.createShader(rect);
    canvas.drawRect(rect, basePaint);

    // Add subtle color variations with very gentle radial overlays
    final overlayPoints = [
      (Offset(size.width * 0.2, size.height * 0.5), colors[2]),
      (Offset(size.width * 0.5, size.height * 0.5), colors[4]),
      (Offset(size.width * 0.8, size.height * 0.5), colors[colors.length - 2]),
    ];

    for (final (position, color) in overlayPoints) {
      final gradient = RadialGradient(
        center: Alignment(
          (position.dx / size.width) * 2 - 1,
          (position.dy / size.height) * 2 - 1,
        ),
        radius: 0.6,
        colors: [
          color.withOpacity(0.25),
          color.withOpacity(0.1),
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

class _MeshPoint {
  final Offset position;
  final double radius;
  final int colorIndex;

  _MeshPoint(this.position, this.radius, this.colorIndex);
}
