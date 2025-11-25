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
            color: Colors.blue,
          ),
          const SizedBox(height: 48),
          const Text(
            "What's your phone number?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "For coordinating pickups",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              UsPhoneNumberFormatter(),
            ],
            decoration: InputDecoration(
              labelText: "Phone Number",
              hintText: "(123) 456-7890",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.phone),
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