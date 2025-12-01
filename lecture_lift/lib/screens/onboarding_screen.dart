import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/auth_state.dart';
import '../services/location_service.dart';
import '../widgets/onboarding_pages/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  final String? userId;
  
  const OnboardingScreen({
    super.key,
    this.userId,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final DatabaseService _dbService = DatabaseService();

  int _currentPage = 0;
  bool _isSaving = false;

  // User data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _userRole = ''; // 'driver' or 'rider'

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Back to Welcome button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      tooltip: 'Back to Welcome',
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      NameInputPage( // Index 0
                        nameController: _nameController,
                        onNameChanged: () => setState(() {}),
                      ),
                      EmailInputPage( // Index 1
                        emailController: _emailController,
                        onEmailChanged: () => setState(() {}),
                      ),
                      PasswordInputPage( // Index 2
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        onPasswordChanged: () => setState(() {}),
                      ),
                      PhoneInputPage( // Index 3
                        phoneController: _phoneController,
                        onPhoneChanged: () => setState(() {}),
                      ),
                      RoleSelectionPage( // Index 4
                        userRole: _userRole,
                        onRoleSelected: (role) {
                          setState(() {
                            _userRole = role;
                          });
                        },
                      ),
                      LocationPermissionPage( // Index 5
                        onPermissionGranted: () async {
                          // Save location to Firestore when permission is granted
                          final userId = _emailController.text.trim();
                          final locationService = LocationService();
                          await locationService.updateUserLocation(userId);
                          
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        onPermissionSkipped: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      CompletePage( // Index 6
                        userName: _nameController.text.trim(),
                        userRole: _userRole,
                      ),
                    ],
                  ),
                ),

                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    7,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),

                const SizedBox(height: 32),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      if (_currentPage > 0 && _currentPage < 7)
                        TextButton(
                          onPressed: _isSaving ? null : _previousPage,
                          child: const Text(
                            "Back",
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        )
                      else
                        const SizedBox(width: 60),

                      // Next/Get Started button
                      GlassGradientButton(
                        onPressed: (_canProceed() && !_isSaving)
                            ? (_isLastPage ? _completeOnboarding : _nextPage)
                            : null,
                        width: 140,
                        gradient: AppTheme.purpleGradient,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isLastPage ? "Complete" : "Next",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
            
            // Loading overlay
            if (_isSaving)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  bool get _isLastPage => _currentPage == 6;

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _nameController.text.trim().isNotEmpty; // Name
      case 1:
        return _emailController.text.trim().isNotEmpty && 
               _emailController.text.contains('@'); // Email
      case 2:
        return _passwordController.text.length >= 6 && 
               _passwordController.text == _confirmPasswordController.text; // Password
      case 3:
        final digitsOnly = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
        return digitsOnly.length == 10; // Phone
      case 4:
        return _userRole.isNotEmpty; // Role
      case 5:
        return true; // Location Permission (can skip)
      case 6:
        return true; // Complete Screen
      default:
        return false;
    }
  }

  void _nextPage() {
    if (_canProceed()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  //AI generated try catch block
  Future<void> _completeOnboarding() async {
    // 1. START LOADING STATE
    setState(() {
      _isSaving = true;
    });

    try {
      // 2. DATA PROCESSING AND DB OPERATION
      final userId = widget.userId ?? _emailController.text.trim();
      
      // Save user profile to Firestore
      print('Saving user profile: userId=$userId');
      
      await _dbService.saveUserProfile(
        userId,
        {
          'email': _emailController.text.trim(),
          'displayName': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'role': _userRole,
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': false,
        },
      );

      // Save user session
      await AuthState.saveUserSession(
        userId: userId,
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
      );

      // 3. SUCCESSFUL COMPLETION: NAVIGATE
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
      }
    } catch (e) {
      // 4. ERROR HANDLING
      print('Error during onboarding save: $e'); 

      if (mounted) {
        // Show error dialog to the user
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Saving Profile'),
            content: Text('Failed to save your information. Please check your connection and try again. Error details: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      // 5. GUARANTEE STATE RESET (This prevents the stuck loading screen)
      // We only reset if the widget is still in the tree and navigation hasn't occurred.
      if (mounted && _isSaving) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

