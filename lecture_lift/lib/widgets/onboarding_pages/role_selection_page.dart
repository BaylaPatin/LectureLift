import 'package:flutter/material.dart';

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
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You can change this later",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
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
                color: userRole == 'driver' ? Colors.blue.shade50 : Colors.white,
                border: Border.all(
                  color: userRole == 'driver' ? Colors.blue : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.drive_eta,
                    size: 60,
                    color: userRole == 'driver' ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Driver",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: userRole == 'driver' ? Colors.blue : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "I have a car and can offer rides",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
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
                color: userRole == 'rider' ? Colors.green.shade50 : Colors.white,
                border: Border.all(
                  color: userRole == 'rider' ? Colors.green : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    size: 60,
                    color: userRole == 'rider' ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Rider",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: userRole == 'rider' ? Colors.green : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "I am only looking for rides.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
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