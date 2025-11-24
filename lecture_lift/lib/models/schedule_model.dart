import 'package:flutter/material.dart';

class ClassSession {
  final String className;
  final String dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;

  ClassSession({
    required this.className,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  @override
  String toString() {
    return '$className ($dayOfWeek ${startTime.format(UniqueKey() as BuildContext)} - ${endTime.format(UniqueKey() as BuildContext)}) @ $location';
  }
}
