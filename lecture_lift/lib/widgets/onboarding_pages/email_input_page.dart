import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class EmailInputPage extends StatefulWidget {
  final TextEditingController emailController;
  final VoidCallback onEmailChanged;

  const EmailInputPage({
    super.key,
    required this.emailController,
    required this.onEmailChanged,
  });

  @override
  State<EmailInputPage> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  bool _showValidation = false;

  bool get _isValidLSUEmail {
    return AuthService.isValidLSUEmail(widget.emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.emailController.text.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.email_outlined,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 48),
          const Text(
            "What's your email?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You must use your LSU email address to sign up.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "example@lsu.edu",
              prefixIcon: const Icon(Icons.email, color: Colors.white70),
              suffixIcon: hasText
                  ? Icon(
                      _isValidLSUEmail ? Icons.check_circle : Icons.error,
                      color: _isValidLSUEmail ? Colors.green : Colors.red,
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _showValidation = true;
              });
              widget.onEmailChanged();
            },
          ),
          if (_showValidation && hasText && !_isValidLSUEmail) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.error, color: Colors.red, size: 16),
                SizedBox(width: 4),
                Text(
                  'Must be a valid @lsu.edu email address',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
          if (_showValidation && _isValidLSUEmail) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  'Valid LSU email',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}