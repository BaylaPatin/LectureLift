import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                style: GoogleFonts.poppins(
                  fontSize: height * 0.5,
                  fontWeight: FontWeight.w300, // Light weight for thin lettering
                  letterSpacing: -1.5,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.purpleGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  'Lift',
                  style: GoogleFonts.poppins(
                    fontSize: height * 0.5,
                    fontWeight: FontWeight.w900, // Extra Bold for thick lettering
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

