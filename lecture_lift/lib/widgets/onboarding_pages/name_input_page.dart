import 'package:flutter/material.dart';

class NameInputPage extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onNameChanged;

  const NameInputPage({
    super.key,
    required this.nameController,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_outline,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 48),
          const Text(
            "What's your name?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "This will be shown to other users",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Full Name",
              hintText: "Enter your full name",
              prefixIcon: const Icon(Icons.person, color: Colors.white70),
            ),
            onChanged: (value) => onNameChanged(), // Calls setState in parent
          ),
        ],
      ),
    );
  }
}