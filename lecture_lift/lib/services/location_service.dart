import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_service.dart';

class LocationService {
  final DatabaseService _dbService = DatabaseService();
  
  // Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
  
  // Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }
  
  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error get location: $e');
      return null;
    }
  }
  
  // Approximate location for privacy (add random offset 50-200 meters)
  Map<String, double> approximateLocation(double lat, double lng) {
    final random = Random();
    
    // Random offset between 50-200 meters
    // 1 degree latitude ≈ 111 km
    // So 0.0005 degree ≈ 55m, 0.0018 degree ≈ 200m
    final offsetDistance = 0.0005 + random.nextDouble() * 0.0013; // ~50-200m
    final angle = random.nextDouble() * 2 * pi;
    
    final approxLat = lat + offsetDistance * cos(angle);
    final approxLng = lng + offsetDistance * sin(angle);
    
    return {
      'latitude': approxLat,
      'longitude': approxLng,
    };
  }
  
  // Update user location in database (with both exact and approximate)
  Future<bool> updateUserLocation(String userId) async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        print('Could not get location');
        return false;
      }
      
      // Approximate location for privacy (map display)
      final approxLocation = approximateLocation(
        position.latitude,
        position.longitude,
      );
      
      // Save both exact (for directions) and approximate (for map) to Firestore
      await _dbService.updateUserLocation(
        userId,
        exactLat: position.latitude,
        exactLng: position.longitude,
        approxLat: approxLocation['latitude']!,
        approxLng: approxLocation['longitude']!,
        timestamp: DateTime.now(),
      );
      
      print('Location updated for user $userId - exact and approximate saved');
      return true;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }
  
  // Open app settings for location permission
  Future<void> openLocationSettings() async {
    await openAppSettings();
  }
}
