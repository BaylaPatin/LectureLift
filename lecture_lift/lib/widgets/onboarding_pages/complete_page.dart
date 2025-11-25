import 'package:flutter/material.dart';

class CompletePage extends StatelessWidget {
  final String userName;
  final String userRole;

  const CompletePage({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final displayRole = userRole == 'driver' ? 'Driver' : 'Rider';

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 120,
            color: Colors.green,
          ),
          const SizedBox(height: 48),
          const Text(
            "You're all set!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Welcome, $userName!",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "You're registered as a $displayRole",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            "Woohoo!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}