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
  Future<void> saveUserProfile(String userId, String email, String displayName, String phoneNumber, String role) async {
    await _db.collection('users').doc(userId).set({
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'isVerified': false,
    });
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }
}
