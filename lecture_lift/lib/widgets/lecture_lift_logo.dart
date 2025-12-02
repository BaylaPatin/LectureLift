import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LectureLiftLogo extends StatelessWidget {
  final double height;
  
  const LectureLiftLogo({
    super.key,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(), // Explicitly no border
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end, // Align baselines
            children: [
              Text(
                'Lecture',
                style: TextStyle(
                  fontSize: height * 0.5,
                  fontWeight: FontWeight.w500, // Medium weight
                  letterSpacing: -1.5,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.lsuGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  'Lift',
                  style: TextStyle(
                    fontSize: height * 0.5,
                    fontWeight: FontWeight.w900, // Extra Bold/Black weight
                    letterSpacing: -1.5,
                    color: Colors.white, // Required for ShaderMask
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
