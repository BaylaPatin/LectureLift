//import 'package:flutter/material.dart';
//import '../services/auth_service.dart';
/// connection to reset-password': (context) => const ResetPasswordPage() for "main"
/// Users are resetting their password 
/// Firebase sends a password reset link to LSU email.
/// Maybe for a reset password button???? ("Navigator.pushNamed(context, "/reset-password");
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // syncing user input
  final TextEditingController emailController = TextEditingController();

  // displaying error in password
  String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // instructions
            const Text(
              "Enter your email address to receive a password reset link.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // email input
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // reset link
            ElevatedButton(
              onPressed: () async {
                final authService = AuthService();

                // reset email using Firebase
                String? error =
                    await authService.resetPassword(emailController.text);

                // success or failure message
                setState(() {
                  message = error ?? "Password reset link has been sent!";
                });
              },
              child: const Text("Send Reset Link"),
            ),

            const SizedBox(height: 20),

            // password reset message
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message == "Password reset link has been sent!"
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
