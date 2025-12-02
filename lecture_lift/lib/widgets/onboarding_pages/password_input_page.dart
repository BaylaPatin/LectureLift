import 'package:flutter/material.dart';

class PasswordInputPage extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onPasswordChanged;

  const PasswordInputPage({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onPasswordChanged,
  });

  @override
  State<PasswordInputPage> createState() => _PasswordInputPageState();
}

class _PasswordInputPageState extends State<PasswordInputPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String _getPasswordStrength() {
    final password = widget.passwordController.text;
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Weak';
    if (password.length < 10) return 'Medium';
    return 'Strong';
  }

  Color _getPasswordStrengthColor() {
    final strength = _getPasswordStrength();
    switch (strength) {
      case 'Weak':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordsMatch = widget.passwordController.text.isNotEmpty &&
        widget.passwordController.text == widget.confirmPasswordController.text;
    final passwordsDontMatch = widget.confirmPasswordController.text.isNotEmpty &&
        widget.passwordController.text != widget.confirmPasswordController.text;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 48),
          const Text(
            "Create a password",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Choose a strong password to secure your account",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            onChanged: (value) => widget.onPasswordChanged(),
          ),
          if (widget.passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Strength: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  _getPasswordStrength(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getPasswordStrengthColor(),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          TextField(
            controller: widget.confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Confirm Password",
              hintText: "Re-enter your password",
              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            onChanged: (value) => widget.onPasswordChanged(),
          ),
          if (passwordsMatch) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Passwords match',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
          if (passwordsDontMatch) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Passwords do not match',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
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
