import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../services/auth_state.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import '../widgets/glass_gradient_button.dart';
import 'map_screen.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'chat_screen.dart';
import '../widgets/rating_dialog.dart';

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

  // Current location
  Map<String, double>? _currentLocation;
  final LocationService _locationService = LocationService();

  Future<void> _initialize() async {
    try {
      final userId = await AuthState.getCurrentUserId();
      if (userId != null) {
        // Fetch current location
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          _currentLocation = {
            'latitude': position.latitude,
            'longitude': position.longitude,
          };
        }

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

  // Rider Tab State
  int _riderTabIndex = 0;

  Widget _buildRiderView() {
    return Column(
      children: [
        // Rider Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _riderTabIndex = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _riderTabIndex == 0 ? AppTheme.primaryPurple.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: _riderTabIndex == 0 ? Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)) : null,
                    ),
                    child: Text(
                      'Active',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _riderTabIndex == 0 ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _riderTabIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _riderTabIndex == 1 ? AppTheme.primaryPurple.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: _riderTabIndex == 1 ? Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)) : null,
                    ),
                    child: Text(
                      'Previous',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _riderTabIndex == 1 ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _riderTabIndex == 0
              ? _buildRiderActiveView()
              : _buildRiderPreviousView(),
        ),
      ],
    );
  }

  Widget _buildRiderActiveView() {
    return Column(
      children: [
        // Active Requests Section
        if (_currentUserId != null)
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _dbService.getRiderRequests(_currentUserId!),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
              
              final requests = snapshot.data!;
              return Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Active Requests',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: requests.length,
                        itemBuilder: (context, index) => _buildRiderRequestCard(requests[index]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        // Matching Drivers Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Matching Drivers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: _matchingDrivers.isEmpty
                    ? _buildEmptyState('No matching drivers found', 'Try updating your schedule or checking back later.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _matchingDrivers.length,
                        itemBuilder: (context, index) {
                          final driver = _matchingDrivers[index];
                          return _buildDriverCard(driver);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiderPreviousView() {
    if (_currentUserId == null) return const SizedBox();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.getRiderHistory(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return _buildEmptyState('No ride history', 'Completed and rejected rides will appear here.');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final status = request['status'];
            final isCompleted = status == 'completed';
            final hasRated = request['riderHasRated'] == true;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: AppTheme.darkSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isCompleted ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          child: Icon(
                            isCompleted ? Icons.check : Icons.close,
                            color: isCompleted ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['driverName'],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCompleted ? 'Ride Completed' : 'Request Rejected',
                                    style: TextStyle(color: isCompleted ? Colors.green : Colors.red),
                                  ),
                                  Text(
                                    _formatDate(request['timestamp']),
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isCompleted && !hasRated) ...[
                      const SizedBox(height: 12),
                      GlassGradientButton(
                        onPressed: () => _showRatingDialog(request, 'driver'),
                        gradient: AppTheme.purpleGradient,
                        height: 36,
                        child: const Text('Rate Driver', style: TextStyle(color: Colors.white)),
                      ),
                    ] else if (isCompleted) ...[
                      const SizedBox(height: 8),
                      const Text('You rated this driver', style: TextStyle(color: Colors.white30, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRiderRequestCard(Map<String, dynamic> request) {
    final status = request['status'];
    final isAccepted = ['accepted', 'on_route', 'arrived'].contains(status);
    
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Accepted';
        break;
      case 'on_route':
        statusColor = Colors.blue;
        statusText = 'Driver on Route';
        break;
      case 'arrived':
        statusColor = AppTheme.primaryPurple;
        statusText = 'Driver Arrived';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.toString().toUpperCase();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.2),
                  radius: 20,
                  child: Icon(Icons.directions_car, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['driverName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAccepted)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                    onPressed: () => _openChat(request, request['driverName']),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Driver Tab State
  int _driverTabIndex = 0;

  Widget _buildDriverView() {
    if (_currentUserId == null) return const SizedBox();

    return Column(
      children: [
        // Driver Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _driverTabIndex = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _driverTabIndex == 0 ? AppTheme.primaryPurple.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: _driverTabIndex == 0 ? Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)) : null,
                    ),
                    child: Text(
                      'Active',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _driverTabIndex == 0 ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _driverTabIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _driverTabIndex == 1 ? AppTheme.primaryPurple.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: _driverTabIndex == 1 ? Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)) : null,
                    ),
                    child: Text(
                      'Previous',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _driverTabIndex == 1 ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _driverTabIndex == 0
              ? _buildDriverActiveRequests()
              : _buildDriverPreviousRequests(),
        ),
      ],
    );
  }

  Widget _buildDriverActiveRequests() {
    return StreamBuilder<List<Map<String, dynamic>>>(
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
          return _buildEmptyState('No active requests', 'New requests will appear here.');
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
    );
  }

  void _showRatingDialog(Map<String, dynamic> request, String roleToRate) {
    // roleToRate is the role of the person being rated.
    // If I am the Driver, I rate the Rider (roleToRate = 'rider').
    // If I am the Rider, I rate the Driver (roleToRate = 'driver').
    
    final nameToRate = roleToRate == 'rider' ? request['riderName'] : request['driverName'];
    final idToRate = roleToRate == 'rider' ? request['riderId'] : request['driverId'];
    
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        ratedName: nameToRate,
        role: roleToRate,
        onSubmit: (overall, criteria, comment) async {
          try {
            await _dbService.submitRating(
              rideId: request['requestId'],
              raterId: _currentUserId!,
              ratedId: idToRate,
              role: roleToRate,
              overallRating: overall,
              criteriaRatings: criteria,
              comment: comment,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rating submitted!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error submitting rating: $e')),
            );
          }
        },
      ),
    );
  }

  Widget _buildDriverPreviousRequests() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.getCompletedRequests(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return _buildEmptyState('No completed rides', 'Completed rides will appear here.');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final hasRated = request['driverHasRated'] == true;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: AppTheme.darkSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.2),
                          child: const Icon(Icons.check, color: Colors.green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['riderName'],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Completed on ${_formatDate(request['timestamp'])}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!hasRated) ...[
                      const SizedBox(height: 12),
                      GlassGradientButton(
                        onPressed: () => _showRatingDialog(request, 'rider'),
                        gradient: AppTheme.purpleGradient,
                        height: 36,
                        child: const Text('Rate Rider', style: TextStyle(color: Colors.white)),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Text('You rated this rider', style: TextStyle(color: Colors.white30, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  // ... existing _formatDate and _buildEmptyState ...

  // ... existing _buildDriverCard and _buildRequestCard ...
  // Note: I need to make sure _updateRequestStatus calls _showRatingDialog when completing
  
  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _dbService.updateRequestStatus(requestId, newStatus);
      
      // If completing the ride, show rating dialog immediately
      // Note: We need the request object to show the dialog.
      // However, since this is called from the UI where we have the request,
      // we can just handle the dialog showing in the UI callback.
      // So this method just updates the status.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }


  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            driver['displayName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_currentLocation != null && driver['location'] != null)
                            Text(
                              '${_calculateDistanceString(_currentLocation!, driver['location'])}',
                              style: const TextStyle(
                                color: AppTheme.primaryYellow,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
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
    final status = request['status'];
    final isAccepted = ['accepted', 'on_route', 'arrived'].contains(status);
    
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            request['riderName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_currentLocation != null && request['riderLocation'] != null)
                            Text(
                              '${_calculateDistanceString(_currentLocation!, request['riderLocation'])} away',
                              style: const TextStyle(
                                color: AppTheme.primaryYellow,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        isAccepted ? 'Ride in Progress' : 'Requesting a ride',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAccepted)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble, color: AppTheme.primaryPurple),
                    onPressed: () => _openChat(request, request['riderName']),
                  ),
              ],
            ),
            const Divider(height: 24, color: Colors.white24),
            
            // Matches (Collapsible if accepted? No, keep it visible for context)
            if (!isAccepted) ...[
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
            ],

            // View Route Button (Always show if location available)
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

            // Action Buttons
            if (status == 'pending')
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
                      gradient: AppTheme.driverGradient,
                      height: 40,
                      child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else if (status == 'accepted')
              GlassGradientButton(
                onPressed: () => _updateRequestStatus(request['requestId'], 'on_route'),
                gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                height: 40,
                child: const Text('OTW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            else if (status == 'on_route')
              GlassGradientButton(
                onPressed: () => _updateRequestStatus(request['requestId'], 'arrived'),
                gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
                height: 40,
                child: const Text('Arrived', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            else if (status == 'arrived')
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'Waiting for rider...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GlassGradientButton(
                    onPressed: () async {
                      await _updateRequestStatus(request['requestId'], 'completed');
                      if (mounted) {
                        _showRatingDialog(request, 'rider');
                      }
                    },
                    gradient: const LinearGradient(colors: [AppTheme.primaryPurple, Colors.deepPurple]),
                    height: 40,
                    child: const Text('Complete Ride', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  void _openChat(Map<String, dynamic> request, String otherUserName) {
    if (_currentUserId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          requestId: request['requestId'],
          currentUserId: _currentUserId!,
          otherUserName: otherUserName,
        ),
      ),
    );
  }

  String _calculateDistanceString(Map<String, dynamic> loc1, Map<String, dynamic> loc2) {
    // Extract coordinates, handling both Map<String, double> and Map<String, dynamic>
    final lat1 = (loc1['latitude'] ?? loc1['exactLatitude'] ?? loc1['approximateLatitude']) as double;
    final lng1 = (loc1['longitude'] ?? loc1['exactLongitude'] ?? loc1['approximateLongitude']) as double;
    
    final lat2 = (loc2['latitude'] ?? loc2['exactLatitude'] ?? loc2['approximateLatitude']) as double;
    final lng2 = (loc2['longitude'] ?? loc2['exactLongitude'] ?? loc2['approximateLongitude']) as double;
    
    // Calculate distance in km
    final distKm = _dbService.calculateDistance(lat1, lng1, lat2, lng2);
    
    // Convert to miles (1 km = 0.621371 miles)
    final distMiles = distKm * 0.621371;
    
    return '${distMiles.toStringAsFixed(1)} mi';
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
