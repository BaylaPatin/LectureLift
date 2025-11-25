import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../widgets/onboarding_pages/index.dart';


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
  final TextEditingController _phoneController = TextEditingController();
  String _userRole = ''; // 'driver' or 'rider'

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Skip button (only show on first page)
                if (_currentPage == 0)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton(
                        onPressed: _skipToHome,
                        child: const Text(
                          "Skip",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 60),

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
                      PhoneInputPage( // Index 2
                        phoneController: _phoneController,
                        onPhoneChanged: () => setState(() {}),
                      ),
                      RoleSelectionPage( // Index 3
                        userRole: _userRole,
                        onRoleSelected: (role) {
                          setState(() {
                            _userRole = role;
                          });
                        },
                      ),
                      CompletePage( // Index 4
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
                    6,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),

                const SizedBox(height: 32),

                // Navigation buttons (remains the same)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      if (_currentPage > 0 && _currentPage < 5)
                        TextButton(
                          onPressed: _isSaving ? null : _previousPage,
                          child: const Text(
                            "Back",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      else
                        const SizedBox(width: 60),

                      // Next/Get Started button
                      ElevatedButton(
                        onPressed: (_canProceed() && !_isSaving)
                            ? (_isLastPage ? _completeOnboarding : _nextPage)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
            
            // Loading overlay (remains the same)
            if (_isSaving)
              Container(
                color: Colors.black26,
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

  bool get _isLastPage => _currentPage == 4;

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _nameController.text.trim().isNotEmpty; // Name
      case 1:
        return _emailController.text.trim().isNotEmpty && 
               _emailController.text.contains('@'); // Email
      case 2:
        final digitsOnly = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
        return digitsOnly.length == 10; // Phone
      case 3:
        return _userRole.isNotEmpty; // Role
      case 4:
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
      MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    
    // Save user profile to Firestore (This is the operation that might fail)
    await _dbService.saveUserProfile(
      userId,
      _emailController.text.trim(),
      _nameController.text.trim(),
    );

    // TODO: Do somethinmg with role?

    // 3. SUCCESSFUL COMPLETION: NAVIGATE
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restart Onboarding Demo'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Just a placeholder screen so i can show you guys onboarding. This would prob be edit/confirm profile screen.',
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}