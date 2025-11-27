import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save entire schedule
  Future<void> saveSchedule(String userId, List<ClassSession> schedule) async {
    final batch = _db.batch();
    final scheduleRef = _db.collection('schedules').doc(userId).collection('classes');

    // Delete existing classes
    final existing = await scheduleRef.get();
    for (var doc in existing.docs) {
      batch.delete(doc.reference);
    }

    // Add new classes
    for (var session in schedule) {
      final docRef = scheduleRef.doc();
      batch.set(docRef, _classToMap(session));
    }

    // Generate and save schedule summary to user document
    // Format: "Day_HHmm" (e.g., "Monday_0900")
    final summary = schedule.map((s) {
      final hour = s.startTime.hour.toString().padLeft(2, '0');
      final minute = s.startTime.minute.toString().padLeft(2, '0');
      return '${s.dayOfWeek}_$hour$minute';
    }).toList();

    final userRef = _db.collection('users').doc(userId);
    batch.set(userRef, {'scheduleSummary': summary}, SetOptions(merge: true));

    await batch.commit();
  }

  // Get user's schedule
  Future<List<ClassSession>> getSchedule(String userId) async {
    final snapshot = await _db
        .collection('schedules')
        .doc(userId)
        .collection('classes')
        .get();

    return snapshot.docs.map((doc) => _mapToClass(doc.data())).toList();
  }

  // Add single class
  Future<void> addClass(String userId, ClassSession session) async {
    await _db
        .collection('schedules')
        .doc(userId)
        .collection('classes')
        .add(_classToMap(session));
  }

  // Delete class
  Future<void> deleteClass(String userId, String classId) async {
    await _db
        .collection('schedules')
        .doc(userId)
        .collection('classes')
        .doc(classId)
        .delete();
  }

  // Stream of schedule changes
  Stream<List<ClassSession>> scheduleStream(String userId) {
    return _db
        .collection('schedules')
        .doc(userId)
        .collection('classes')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _mapToClass(doc.data())).toList());
  }

  // Convert ClassSession to Map
  Map<String, dynamic> _classToMap(ClassSession session) {
    return {
      'className': session.className,
      'dayOfWeek': session.dayOfWeek,
      'startTime': '${session.startTime.hour}:${session.startTime.minute}',
      'endTime': '${session.endTime.hour}:${session.endTime.minute}',
      'location': session.location,
    };
  }

  // Convert Map to ClassSession
  ClassSession _mapToClass(Map<String, dynamic> data) {
    final startParts = data['startTime'].split(':');
    final endParts = data['endTime'].split(':');

    return ClassSession(
      className: data['className'],
      dayOfWeek: data['dayOfWeek'],
      startTime: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      location: data['location'],
    );
  }

  // Save user profile
  Future<void> saveUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    await _db.collection('users').doc(userId).update({'role': role});
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }

  // Update user location (both exact and approximate)
  Future<void> updateUserLocation(
    String userId, {
    required double exactLat,
    required double exactLng,
    required double approxLat,
    required double approxLng,
    required DateTime timestamp,
  }) async {
    await _db.collection('users').doc(userId).update({
      'location': {
        // Exact location for directions (only shared when user accepts ride)
        'exactLatitude': exactLat,
        'exactLongitude': exactLng,
        // Approximate location for map display (privacy-protected)
        'approximateLatitude': approxLat,
        'approximateLongitude': approxLng,
        'lastUpdated': Timestamp.fromDate(timestamp),
      },
    });
  }

  // Get nearby users within radius (in kilometers)
  // Note: This is a simplified version. For production, use GeoFlutterFire or similar
  Future<List<Map<String, dynamic>>> getNearbyUsers(
    String currentUserId,
    double centerLat,
    double centerLng,
    double? radiusKm, // Made nullable
  ) async {
    try {
      print('DEBUG: getNearbyUsers called for $currentUserId at $centerLat, $centerLng radius: $radiusKm');
      // Get all users (in production, use geo-queries)
      final snapshot = await _db.collection('users').get();
      print('DEBUG: Total users in DB: ${snapshot.docs.length}');
      
      final List<Map<String, dynamic>> nearbyUsers = [];
      
      for (var doc in snapshot.docs) {
        // Skip current user
        if (doc.id == currentUserId) continue;
        
        final data = doc.data();
        final location = data['location'];
        
        if (location == null) {
          print('DEBUG: User ${doc.id} skipped: No location data');
          continue;
        }
        
        // Check if location was updated recently (within last 60 minutes)
        final lastUpdated = (location['lastUpdated'] as Timestamp?)?.toDate();
        if (lastUpdated == null) {
          print('DEBUG: User ${doc.id} skipped: No lastUpdated timestamp');
          continue;
        }
        
        final now = DateTime.now();
        final minutesDiff = now.difference(lastUpdated).inMinutes;
        print('DEBUG: User ${doc.id} last updated $minutesDiff minutes ago');
        
        if (minutesDiff > 60) {
          print('DEBUG: User ${doc.id} skipped: Last updated too long ago (>60m)');
          // User hasn't updated location recently, skip
          continue;
        }
        
        // Use approximate coordinates for map display (privacy-protected)
        final double? approxLat = location['approximateLatitude'];
        final double? approxLng = location['approximateLongitude'];
        
        if (approxLat == null || approxLng == null) {
           print('DEBUG: User ${doc.id} skipped: Missing approximate coordinates');
           continue;
        }
        
        // Calculate distance using approximate location
        final distance = _calculateDistance(centerLat, centerLng, approxLat, approxLng);
        print('DEBUG: User ${doc.id} distance: $distance km');
        
        // If radiusKm is null, include everyone. Otherwise check distance.
        if (radiusKm == null || distance <= radiusKm) {
          nearbyUsers.add({
            'userId': doc.id,
            'displayName': data['displayName'] ?? 'User',
            'role': data['role'] ?? 'student',
            'latitude': approxLat,  // Approximate for map display
            'longitude': approxLng,  // Approximate for map display
            'distance': distance,
            'lastUpdated': lastUpdated,
          });
        } else {
          print('DEBUG: User ${doc.id} skipped: Too far ($distance km > $radiusKm km)');
        }
      }
      
      // Sort by distance
      nearbyUsers.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      
      return nearbyUsers;
    } catch (e) {
      print('Error getting nearby users: $e');
      return [];
    }
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadiusKm = 6371.0;
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Get user's exact location (only when they accept a ride for directions)
  Future<Map<String, double>?> getUserExactLocation(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      final data = doc.data();
      
      if (data == null) return null;
      
      final location = data['location'];
      if (location == null) return null;
      
      final exactLat = location['exactLatitude'];
      final exactLng = location['exactLongitude'];
      
      if (exactLat == null || exactLng == null) return null;
      
      return {
        'latitude': exactLat,
        'longitude': exactLng,
      };
    } catch (e) {
      print('Error getting exact location: $e');
      return null;
    }
  }

  // Find matching drivers based on schedule (Optimized)
  Future<List<Map<String, dynamic>>> findMatchingDrivers(String riderId) async {
    try {
      // 1. Get rider's schedule
      final riderSchedule = await getSchedule(riderId);
      if (riderSchedule.isEmpty) return [];

      // 2. Get all drivers
      final driversSnapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .get();

      final List<Map<String, dynamic>> matchingDrivers = [];

      // 3. Check each driver using schedule summary
      for (var doc in driversSnapshot.docs) {
        // Skip self
        if (doc.id == riderId) continue;

        final driverData = doc.data();
        final List<dynamic>? driverSummary = driverData['scheduleSummary'];
        
        // Skip if driver has no schedule
        if (driverSummary == null || driverSummary.isEmpty) continue;

        // 4. Compare schedules using summary
        final matches = _findSummaryOverlaps(riderSchedule, driverSummary.cast<String>());
        
        if (matches.isNotEmpty) {
          matchingDrivers.add({
            'driverId': doc.id,
            'displayName': driverData['displayName'] ?? 'Driver',
            'phoneNumber': driverData['phoneNumber'],
            'matches': matches,
            'location': driverData['location'],
          });
        }
      }

      return matchingDrivers;
    } catch (e) {
      print('Error finding matching drivers: $e');
      return [];
    }
  }

  // Helper to find overlaps using summaries
  List<String> _findSummaryOverlaps(List<ClassSession> riderSchedule, List<String> driverSummary) {
    final List<String> matches = [];

    for (var riderClass in riderSchedule) {
      final riderHour = riderClass.startTime.hour;
      final riderMinute = riderClass.startTime.minute;
      
      for (var driverTimeStr in driverSummary) {
        // Format: "Day_HHmm"
        final parts = driverTimeStr.split('_');
        if (parts.length != 2) continue;
        
        final driverDay = parts[0];
        final timePart = parts[1]; // HHmm
        
        if (riderClass.dayOfWeek == driverDay) {
          final driverHour = int.parse(timePart.substring(0, 2));
          final driverMinute = int.parse(timePart.substring(2, 4));
          
          // Check if times are close (within 30 mins)
          final m1 = riderHour * 60 + riderMinute;
          final m2 = driverHour * 60 + driverMinute;
          
          if ((m1 - m2).abs() <= 30) {
            final timeStr = '${riderClass.startTime.hour}:${riderClass.startTime.minute.toString().padLeft(2, '0')}';
            matches.add('${riderClass.dayOfWeek}: ${riderClass.className} ($timeStr)');
            break; 
          }
        }
      }
    }
    return matches;
  }

  // Helper to find overlaps
  List<String> _findScheduleOverlaps(List<ClassSession> riderSchedule, List<ClassSession> driverSchedule) {
    final List<String> matches = [];

    for (var riderClass in riderSchedule) {
      for (var driverClass in driverSchedule) {
        // Check if same day
        if (riderClass.dayOfWeek == driverClass.dayOfWeek) {
          // Check if times are similar (within 30 mins)
          if (_isTimeClose(riderClass.startTime, driverClass.startTime) ||
              _isTimeClose(riderClass.endTime, driverClass.endTime)) {
            final timeStr = '${riderClass.startTime.hour}:${riderClass.startTime.minute.toString().padLeft(2, '0')}';
            matches.add('${riderClass.dayOfWeek}: ${riderClass.className} ($timeStr)');
            // Break inner loop to avoid double counting same class match
            break; 
          }
        }
      }
    }
    return matches;
  }

  bool _isTimeClose(TimeOfDay t1, TimeOfDay t2) {
    final m1 = t1.hour * 60 + t1.minute;
    final m2 = t2.hour * 60 + t2.minute;
    return (m1 - m2).abs() <= 30; // Within 30 minutes
  }

  // --- Ride Requests ---

  // Create a new ride request
  Future<void> createRideRequest(String riderId, String driverId, Map<String, dynamic> driverData) async {
    print('DEBUG: createRideRequest called: rider=$riderId, driver=$driverId');
    await _db.collection('ride_requests').add({
      'riderId': riderId,
      'driverId': driverId,
      'driverName': driverData['displayName'],
      'status': 'pending', // pending, accepted, rejected
      'timestamp': FieldValue.serverTimestamp(),
      'matches': driverData['matches'], // List of matching classes
    });
    print('DEBUG: Ride request created successfully');
  }

  // Stream of incoming requests for a driver
  Stream<List<Map<String, dynamic>>> getIncomingRequests(String driverId) {
    print('DEBUG: getIncomingRequests stream started for driver: $driverId');
    return _db
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'pending')
        // .orderBy('timestamp', descending: true) // Removed to avoid index issues
        .snapshots()
        .asyncMap((snapshot) async {
          print('DEBUG: Received snapshot with ${snapshot.docs.length} docs');
          final requests = <Map<String, dynamic>>[];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            print('DEBUG: Processing request ${doc.id}: $data');
            // Fetch rider details
            final riderProfile = await getUserProfile(data['riderId']);
            final riderLocation = riderProfile?['location'];
            
            requests.add({
              'requestId': doc.id,
              ...data,
              'riderName': riderProfile?['displayName'] ?? 'Unknown Rider',
              'riderPhone': riderProfile?['phoneNumber'],
              'riderLocation': riderLocation != null ? {
                'latitude': riderLocation['exactLatitude'] ?? riderLocation['approximateLatitude'],
                'longitude': riderLocation['exactLongitude'] ?? riderLocation['approximateLongitude'],
              } : null,
            });
          }
          
          // Sort in memory
          requests.sort((a, b) {
            final t1 = a['timestamp'] as Timestamp?;
            final t2 = b['timestamp'] as Timestamp?;
            if (t1 == null || t2 == null) return 0;
            return t2.compareTo(t1); // Descending
          });
          
          return requests;
        });
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    await _db.collection('ride_requests').doc(requestId).update({
      'status': newStatus,
    });
  }
}
