import 'package:flutter/material.dart';
import 'dart:ui';

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
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? Colors.black).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
