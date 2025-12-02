import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/auth_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import '../widgets/glass_gradient_button.dart';
import 'map_screen.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindRideScreen extends StatefulWidget {
  const FindRideScreen({Key? key}) : super(key: key);

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  final DatabaseService _dbService = DatabaseService();
  String? _userRole;
  String? _currentUserId;
  List<Map<String, dynamic>> _matchingDrivers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final userId = await AuthState.getCurrentUserId();
      if (userId != null) {
        final profile = await _dbService.getUserProfile(userId);
        setState(() {
          _currentUserId = userId;
          _userRole = profile?['role'];
        });

        if (_userRole == 'rider') {
          _findDrivers();
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _findDrivers() async {
    try {
      if (_currentUserId != null) {
        final drivers = await _dbService.findMatchingDrivers(_currentUserId!);
        setState(() {
          _matchingDrivers = drivers;
          _isLoading = false;
        });
      }
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
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          _userRole == 'driver' ? 'Ride Requests' : 'Find a Ride',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : _userRole == 'driver'
                  ? _buildDriverView()
                  : _buildRiderView(),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: 2, // Rides tab
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) return; // Already on Rides

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
        // Already here
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Widget _buildRiderView() {
    if (_matchingDrivers.isEmpty) {
      return _buildEmptyState('No matching drivers found', 'Try updating your schedule or checking back later.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _matchingDrivers.length,
      itemBuilder: (context, index) {
        final driver = _matchingDrivers[index];
        return _buildDriverCard(driver);
      },
    );
  }

  Widget _buildDriverView() {
    if (_currentUserId == null) return const SizedBox();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Debug: Listening for requests for $_currentUserId', style: const TextStyle(fontSize: 10, color: Colors.white30)),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _dbService.getIncomingRequests(_currentUserId!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return _buildEmptyState('No ride requests yet', 'Requests from riders will appear here.');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildRequestCard(request);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    final matches = driver['matches'] as List<String>;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['displayName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${matches.length} matching classes',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassGradientButton(
              onPressed: () => _requestRide(driver),
              gradient: AppTheme.riderGradient,
              height: 40,
              child: const Text(
                'Request Ride',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const Divider(height: 24, color: Colors.white24),
            const Text(
              'Matching Schedule:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            ...matches.map((match) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppTheme.primaryYellow),
                  const SizedBox(width: 8),
                  Text(match, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final matches = request['matches'] as List<dynamic>;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['riderName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Requesting a ride',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Colors.white24),
            const Text(
              'Matching Schedule:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            ...matches.map((match) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppTheme.primaryYellow),
                  const SizedBox(width: 8),
                  Text(match.toString(), style: const TextStyle(color: Colors.white70)),
                ],
              ),
            )).toList(),
            const SizedBox(height: 16),
            // View Route Button
            if (request['riderLocation'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassGradientButton(
                  onPressed: () => _viewRoute(request),
                  gradient: AppTheme.driverGradient,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.directions, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('View Route', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateRequestStatus(request['requestId'], 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassGradientButton(
                    onPressed: () => _updateRequestStatus(request['requestId'], 'accepted'),
                    gradient: AppTheme.driverGradient, // Or maybe a green gradient if available, but staying consistent
                    height: 40,
                    child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    try {
      await _dbService.updateRequestStatus(requestId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _requestRide(Map<String, dynamic> driver) async {
    if (_currentUserId == null) return;

    try {
      await _dbService.createRideRequest(
        _currentUserId!,
        driver['driverId'],
        driver,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent to ${driver['displayName']}!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending request: $e')),
        );
      }
    }
  }

  void _viewRoute(Map<String, dynamic> request) {
    final riderLocation = request['riderLocation'];
    if (riderLocation == null) return;

    final destination = LatLng(
      riderLocation['latitude'],
      riderLocation['longitude'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          destination: destination,
          destinationName: request['riderName'],
        ),
      ),
    );
  }
}
