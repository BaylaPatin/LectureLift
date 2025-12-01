import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_gradient_button.dart';

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
              const Spacer(),
              
              // App Logo/Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.purpleGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 72,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // App Name
              const Text(
                'LectureLift',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Tagline
              Text(
                'Your campus companion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const Spacer(),
              
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
                gradient: AppTheme.purpleGradient.scale(0.5), // Slightly dimmer or just outline effect? 
                // Actually, let's just use the same button but maybe different gradient or just standard
                // User asked for "purple and pink gradient" for these screens.
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
