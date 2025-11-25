import 'package:flutter/material.dart';

class EmailInputPage extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onEmailChanged;

  const EmailInputPage({
    super.key,
    required this.emailController,
    required this.onEmailChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.email_outlined,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 48),
          const Text(
            "What's your email?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "It must be a valid LSU email address. This is to confirm you are a student.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "example@lsu.edu",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
            onChanged: (value) => onEmailChanged(), // Calls setState in parent
          ),
        ],
      ),
    );
  }
}