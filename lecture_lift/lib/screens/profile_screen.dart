import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/auth_state.dart';
import '../models/schedule_model.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import 'welcome_screen.dart';
import 'schedule_screen.dart';
import 'map_screen.dart';
import 'find_ride_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  
  const ProfileScreen({
    super.key,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _dbService = DatabaseService();
  
  Map<String, dynamic>? _userProfile;
  List<ClassSession> _schedule = [];
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 3; // Profile tab

  // --- UPDATED FOR BLENDING ---
  // Setting card color to transparent to blend with AppTheme.backgroundColor, 
  // relying on borders for separation.
  final Color _cardColor = Colors.transparent; 
  final Color _textColor = Colors.white; 
  final Color _subTextColor = Colors.grey[400]!; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = widget.userId ?? await AuthState.getCurrentUserId() ?? 'demo_user';
      final profile = await _dbService.getUserProfile(userId);
      final schedule = await _dbService.getSchedule(userId);
      
      setState(() {
        _userProfile = profile;
        _schedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, 
      appBar: AppBar(
        title: const Text('Profile'), 
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                      const SizedBox(height: 16),
                      Text('Error loading profile: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        _buildScheduleSection(),
                        const SizedBox(height: 40),
                        _buildLogoutButton(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildProfileHeader() {
    final displayName = _userProfile?['displayName'] ?? 'User';
    final email = _userProfile?['email'] ?? 'No email';
    final phoneNumber = _userProfile?['phoneNumber'] ?? 'No phone';
    final role = _userProfile?['role'] ?? 'Student';

    return Card(
      elevation: 0,
      color: _cardColor, // Now transparent
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.05)), // Subtle border remains
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            // Profile Icon
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cardColor,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.purpleGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Name
            Text(
              displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _textColor, 
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Rating
            if (_userProfile != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber[400], size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${(_userProfile!['averageRating'] ?? 0.0).toStringAsFixed(1)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800, 
                        color: Colors.amber[300],
                        fontSize: 15
                      ),
                    ),
                    Text(
                      '  •  ${_userProfile!['ratingCount'] ?? 0} reviews',
                      style: TextStyle(color: Colors.amber[200], fontSize: 13),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            
            // Role toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRoleButton('rider', role == 'rider'),
                  _buildRoleButton('driver', role == 'driver'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 20),
            
            _buildInfoRow(Icons.email_outlined, email),
            if (phoneNumber != 'No phone') ...[
              const SizedBox(height: 16),
              _buildInfoRow(Icons.phone_outlined, phoneNumber),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryPurple),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _subTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Class Schedule',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                );
              },
              child: const Text('Edit Schedule'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_schedule.isEmpty)
          _buildEmptySchedule()
        else
          _buildScheduleList(),
      ],
    );
  }

  Widget _buildEmptySchedule() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardColor, // Transparent
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'No classes yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _subTextColor,
                  fontWeight: FontWeight.w600
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your classes to find rides easier',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final Map<String, List<ClassSession>> groupedClasses = {};
    for (var classSession in _schedule) {
      if (!groupedClasses.containsKey(classSession.dayOfWeek)) {
        groupedClasses[classSession.dayOfWeek] = [];
      }
      groupedClasses[classSession.dayOfWeek]!.add(classSession);
    }

    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final sortedDays = daysOfWeek.where((day) => groupedClasses.containsKey(day)).toList();

    return Column(
      children: sortedDays.map((day) {
        final classes = groupedClasses[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                day,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            ...classes.map((classSession) => _buildClassCard(classSession)),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildClassCard(ClassSession classSession) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor, // Transparent
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_outlined,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classSession.className,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _textColor,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: _subTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatTime(classSession.startTime)} - ${_formatTime(classSession.endTime)}',
                        style: TextStyle(color: _subTextColor, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined, size: 14, color: _subTextColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          classSession.location,
                          style: TextStyle(color: _subTextColor, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: _cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Log Out', style: TextStyle(color: Colors.white)),
              content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          );

          if (shouldLogout == true && mounted) {
            await AuthState.clearUserSession();
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            }
          }
        },
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          // Set to a low-opacity black/dark color to blend subtly
          backgroundColor: Colors.black38, 
          foregroundColor: Colors.redAccent, 
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.3), width: 1),
          ),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ScheduleScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FindRideScreen()),
        );
        break;
      case 3:
        break;
    }
  }

  Widget _buildRoleButton(String role, bool isSelected) {
    return GestureDetector(
      onTap: () => _updateRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          // Role button active color is still dark grey for contrast against the black54 toggle track
          color: isSelected ? const Color(0xFF2C2C2E) : Colors.transparent, 
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected 
            ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
            : [],
        ),
        child: Text(
          role == 'rider' ? 'Rider' : 'Driver',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[500],
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Future<void> _updateRole(String newRole) async {
    if (_userProfile?['role'] == newRole) return;

    try {
      final userId = widget.userId ?? await AuthState.getCurrentUserId();
      if (userId != null) {
        await _dbService.updateUserRole(userId, newRole);
        setState(() {
          _userProfile?['role'] = newRole;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${newRole == 'rider' ? 'Rider' : 'Driver'} mode'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2C2C2E), // Using a dark solid color for snackbar
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating role: $e')),
      );
    }
  }
}
