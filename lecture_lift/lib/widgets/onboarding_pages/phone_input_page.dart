import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/phone_formatter.dart';

class PhoneInputPage extends StatelessWidget {
  final TextEditingController phoneController;
  final VoidCallback onPhoneChanged; // Callback to trigger setState in parent

  const PhoneInputPage({
    super.key,
    required this.phoneController,
    required this.onPhoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.phone_outlined,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 48),
          const Text(
            "What's your phone number?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "For coordinating pickups",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            inputFormatters: [
              UsPhoneNumberFormatter(),
            ],
            decoration: InputDecoration(
              labelText: "Phone Number",
              hintText: "(123) 456-7890",
              prefixIcon: const Icon(Icons.phone, color: Colors.white70),
            ),
            onChanged: (value) {
              // Now call the passed-in callback
              onPhoneChanged(); 
            },
          ),
        ],
      ),
    );
  }
}