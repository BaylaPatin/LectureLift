import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_gradient_button.dart';
import '../widgets/lecture_lift_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              
              // Centered Logo - responsive size
              Center(
                child: LectureLiftLogo(
                  height: MediaQuery.of(context).size.width * 0.30, // 30% of screen width - reduced from 40%
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              Text(
                'YOUR CAMPUS COMPANION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.0,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Sign Up Button
              GlassGradientButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                },
                gradient: AppTheme.purpleGradient,
                child: const Text('Sign Up'),
              ),
              
              const SizedBox(height: 16),
              
              // Log In Button
              GlassGradientButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                gradient: AppTheme.purpleGradient.scale(0.5),
                child: const Text('Log In'),
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
