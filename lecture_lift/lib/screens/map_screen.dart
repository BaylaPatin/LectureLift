
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'schedule_screen.dart';
import 'find_ride_screen.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/auth_state.dart';

class MapScreen extends StatefulWidget {
  final LatLng? destination;
  final String? destinationName;

  const MapScreen({
    Key? key,
    this.destination,
    this.destinationName,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(30.4102, -91.1857),
    zoom: 11.5,
  );

  GoogleMapController? _googleMapController;
  int _selectedIndex = 0;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LatLng? _startLocation;
  LatLng? _endLocation;

  final TextEditingController _searchController = TextEditingController();

  //Google Places API key
  final String _googleApiKey = "AIzaSyAQ18lWuqBtVspF_CDWaW5ska2-Zev8GrE";

  // Services
  final DatabaseService _dbService = DatabaseService();
  final LocationService _locationService = LocationService();
  
  // Nearby users
  List<Map<String, dynamic>> _nearbyUsers = [];
  Timer? _locationUpdateTimer;
  String? _currentUserId;
  String? _userRole; // Add user role
  double _searchRadiusKm = 3.2; // Default 2 miles

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    _currentUserId = await AuthState.getCurrentUserId();
    if (_currentUserId != null) {
      // Get user profile to check role
      final profile = await _dbService.getUserProfile(_currentUserId!);
      print('DEBUG: User profile fetched: $profile'); // Debug print
      
      if (mounted) {
        setState(() {
          _userRole = profile?['role'];
          print('DEBUG: Set _userRole to: $_userRole'); // Debug print
        });
      }

      // Update current user's location
      await _locationService.updateUserLocation(_currentUserId!);
      
      // Move camera to current location
      final position = await _locationService.getCurrentLocation();
      if (position != null && _googleMapController != null) {
        _googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14.0,
            ),
          ),
        );
      }
      
      // Handle passed destination
      if (widget.destination != null && position != null) {
        _startLocation = LatLng(position.latitude, position.longitude);
        _endLocation = widget.destination;
        
        _markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: _startLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Start'),
          ),
        );
        
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: _endLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: widget.destinationName ?? 'Destination'),
          ),
        );
        
        _drawRoute();
        
        // Fit bounds after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _fitBounds();
        });
      }
      
      // Fetch nearby users
      await _fetchNearbyUsers();
      
      // Start periodic updates every 30 seconds
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _updateLocationAndUsers(),
      );
    }
  }

  Future<void> _updateLocationAndUsers() async {
    if (_currentUserId == null) return;
    
    // Update own location
    await _locationService.updateUserLocation(_currentUserId!);
    
    // Refresh nearby users
    await _fetchNearbyUsers();
  }

  Future<void> _fetchNearbyUsers() async {
    if (_currentUserId == null) {
      print('DEBUG: No current user ID');
      return;
    }
    
    try {
      // Get current location to use as center of search
      final position = await _locationService.getCurrentLocation();
      final centerLat = position?.latitude ?? _initialCameraPosition.target.latitude;
      final centerLng = position?.longitude ?? _initialCameraPosition.target.longitude;
      
      print('DEBUG: Fetching all users around $centerLat, $centerLng...');
      
      final users = await _dbService.getNearbyUsers(
        _currentUserId!,
        centerLat,
        centerLng,
        null, // Pass null to get all users regardless of distance
      );
      
      print('DEBUG: Found ${users.length} nearby users');
      for (var user in users) {
        print('  - ${user['displayName']} (${user['role']}) at ${user['latitude']}, ${user['longitude']}');
      }
      
      setState(() {
        _nearbyUsers = users;
      });
      _updateUserMarkers();
    } catch (e) {
      print('Error fetching nearby users: $e');
    }
  }

  void _updateUserMarkers() {
    print('DEBUG: Updating user markers, total nearby users: ${_nearbyUsers.length}');
    
    // Clear existing user markers (keep route markers if any)
    _markers.removeWhere((marker) => 
      marker.markerId.value.startsWith('user_'));
    
    // Add user markers
    for (var user in _nearbyUsers) {
      final userId = user['userId'] as String;
      final role = user['role'] as String;
      final lat = user['latitude'] as double;
      final lng = user['longitude'] as double;
      final name = user['displayName'] as String;
      
      print('DEBUG: Adding marker for $name at $lat, $lng');
      
      _markers.add(
        Marker(
          markerId: MarkerId('user_$userId'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            role == 'driver' ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: name,
            snippet: role == 'driver' ? '🚗 Driver' : '🎒 Rider',
          ),
        ),
      );
    }
    
    print('DEBUG: Total markers now: ${_markers.length}');
    setState(() {}); // Force rebuild to show markers
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _searchController.dispose();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void _goToInitialPosition() {
    if (_googleMapController != null) {
      _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(_initialCameraPosition),
      );
    }
  }

  void _onPlaceSelected(Prediction prediction) async {
    // Get place details to get coordinates
    if (prediction.lat != null && prediction.lng != null) {
      double lat = double.parse(prediction.lat!);
      double lng = double.parse(prediction.lng!);
      LatLng destination = LatLng(lat, lng);

      setState(() {
        // Clear previous route
        _markers.clear();
        _polylines.clear();

        // Set current location as start
        _startLocation = _initialCameraPosition.target;
        _markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: _startLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Start'),
          ),
        );

        // Set searched location as destination
        _endLocation = destination;
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: destination,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: prediction.description ?? 'Destination',
            ),
          ),
        );

        _drawRoute();
      });

      // Fit bounds to show both points
      Future.delayed(const Duration(milliseconds: 300), () {
        _fitBounds();
      });

      // Clear the search field
      _searchController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Route to: ${prediction.description}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _drawRoute() async {
    if (_startLocation != null && _endLocation != null) {
      PolylinePoints polylinePoints = PolylinePoints(apiKey: _googleApiKey);
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(
            _startLocation!.latitude,
            _startLocation!.longitude,
          ),
          destination: PointLatLng(
            _endLocation!.latitude,
            _endLocation!.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points:
                  result.points
                      .map((point) => LatLng(point.latitude, point.longitude))
                      .toList(),
              color: Colors.blue,
              width: 5,
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Failed to fetch route'),
          ),
        );
      }
    }
  }

  void _fitBounds() {
    if (_startLocation != null &&
        _endLocation != null &&
        _googleMapController != null) {
      double minLat = _startLocation!.latitude < _endLocation!.latitude
          ? _startLocation!.latitude
          : _endLocation!.latitude;
      double maxLat = _startLocation!.latitude > _endLocation!.latitude
          ? _startLocation!.latitude
          : _endLocation!.latitude;
      double minLng = _startLocation!.longitude < _endLocation!.longitude
          ? _startLocation!.longitude
          : _endLocation!.longitude;
      double maxLng = _startLocation!.longitude > _endLocation!.longitude
          ? _startLocation!.longitude
          : _endLocation!.longitude;

      _googleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - 0.01, minLng - 0.01),
            northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
          ),
          100,
        ),
      );
    }
  }

  void _clearRoute() {
    setState(() {
      _markers.clear();
      _polylines.clear();
      _startLocation = null;
      _endLocation = null;
      _searchController.clear();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        // Map - already here
        break;
      case 1:
        // Navigate to Schedule
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScheduleScreen()),
        );
        break;
      case 2:
        // Navigate to Rides
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FindRideScreen()),
        );
        break;
      case 3:
        // Navigate to Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Future<void> _zoomIn() async {
    final controller = _googleMapController;
    if (controller != null) {
      await controller.animateCamera(CameraUpdate.zoomIn());
    }
  }

  Future<void> _zoomOut() async {
    final controller = _googleMapController;
    if (controller != null) {
      await controller.animateCamera(CameraUpdate.zoomOut());
    }
  }

  Future<void> _goToMyLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && _googleMapController != null) {
      _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('Map Navigation'),
        actions: [
          if (_markers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearRoute,
              tooltip: 'Clear Route',
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              print('Settings pressed');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) async {
              setState(() {
                _googleMapController = controller;
              });
              
              // Load map style
              DefaultAssetBundle.of(context)
                  .loadString('assets/map_style.json')
                  .then((style) {
                _googleMapController!.setMapStyle(style);
              }).catchError((error) {
                print("Error loading map style: $error");
              });
              
              // Move to current location immediately when map is ready
              final position = await _locationService.getCurrentLocation();
              if (position != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 14.0,
                    ),
                  ),
                );
              }
            },
            mapType: MapType.normal,
          ),
          MapSearchBar(
            searchController: _searchController,
            googleApiKey: _googleApiKey,
            onPlaceSelected: _onPlaceSelected,
            onClear: () {
              _searchController.clear();
              setState(() {});
            },
          ),
          
          // Find Ride Button (Only for Riders)
          if (_userRole == 'rider') // Support both for backward compatibility
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindRideScreen()),
                    );
                  },
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Find a Ride'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            onPressed: _zoomIn,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            onPressed: _zoomOut,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "my_location",
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            onPressed: _goToMyLocation,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
