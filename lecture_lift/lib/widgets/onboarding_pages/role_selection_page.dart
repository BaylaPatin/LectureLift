import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RoleSelectionPage extends StatelessWidget {
  final String userRole;
  final Function(String role) onRoleSelected;

  const RoleSelectionPage({
    super.key,
    required this.userRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Can you drive?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You can change this later",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 48),

          // Driver option
          GestureDetector(
            onTap: () => onRoleSelected('driver'), // Calls setState in parent
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: userRole == 'driver' ? AppTheme.driverGradient : null,
                color: userRole == 'driver' ? null : AppTheme.darkSurface,
                border: Border.all(
                  color: userRole == 'driver' ? Colors.transparent : Colors.white24,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: userRole == 'driver' ? [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ] : null,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.drive_eta,
                    size: 60,
                    color: userRole == 'driver' ? Colors.white : Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Driver",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: userRole == 'driver' ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "I have a car and can offer rides",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: userRole == 'driver' ? Colors.white.withOpacity(0.9) : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Rider option
          GestureDetector(
            onTap: () => onRoleSelected('rider'), // Calls setState in parent
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: userRole == 'rider' ? AppTheme.riderGradient : null,
                color: userRole == 'rider' ? null : AppTheme.darkSurface,
                border: Border.all(
                  color: userRole == 'rider' ? Colors.transparent : Colors.white24,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: userRole == 'rider' ? [
                  BoxShadow(
                    color: AppTheme.primaryYellow.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ] : null,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    size: 60,
                    color: userRole == 'rider' ? Colors.white : Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Rider",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: userRole == 'rider' ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "I am only looking for rides.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: userRole == 'rider' ? Colors.white.withOpacity(0.9) : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}