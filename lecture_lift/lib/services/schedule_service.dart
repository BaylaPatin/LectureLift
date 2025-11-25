import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  Future<List<ClassSession>> pickAndParseSchedule() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true, // Required for Web to get bytes
    );

    if (result != null) {
      List<int>? bytes = result.files.single.bytes;
      if (bytes == null && result.files.single.path != null) {
        bytes = File(result.files.single.path!).readAsBytesSync();
      }

      if (bytes != null) {
        var excel = Excel.decodeBytes(bytes);

      List<ClassSession> schedule = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        int meetingPatternsIndex = -1;
        int classNameIndex = -1;

        // Find headers in the first few rows
        for (int r = 0; r < 5; r++) {
          var row = sheet.rows[r];
          for (int c = 0; c < row.length; c++) {
            var cellValue = row[c]?.value?.toString().toLowerCase() ?? '';
            if (cellValue.contains('meeting patterns') || cellValue.contains('meeting pattern')) {
              meetingPatternsIndex = c;
            }
            if (cellValue.contains('course') || cellValue.contains('class') || cellValue.contains('subject')) {
              classNameIndex = c;
            }
          }
          if (meetingPatternsIndex != -1) break;
        }

        // Default to first columns if headers not found (fallback)
        if (meetingPatternsIndex == -1) meetingPatternsIndex = 1; 
        if (classNameIndex == -1) classNameIndex = 0;

        // Parse rows
        for (var row in sheet.rows.skip(1)) {
          if (row.length <= meetingPatternsIndex) continue;

          try {
            String className = row[classNameIndex]?.value?.toString() ?? 'Unknown Class';
            String meetingPattern = row[meetingPatternsIndex]?.value?.toString() ?? '';
            
            // Expected format example: "Mon, Wed 9:00 AM - 10:15 AM Building 101"
            // Regex to capture: (Days) (StartTime) - (EndTime) (Location)
            // This regex is flexible to handle various formats
            final regex = RegExp(r'([A-Za-z,\s]+)\s+(\d{1,2}:\d{2}\s*[APap][Mm])\s*-\s*(\d{1,2}:\d{2}\s*[APap][Mm])\s+(.*)');
            final match = regex.firstMatch(meetingPattern);

            if (match != null) {
              String days = match.group(1)?.trim() ?? 'TBD';
              String startStr = match.group(2)?.trim() ?? '09:00 AM';
              String endStr = match.group(3)?.trim() ?? '10:00 AM';
              String location = match.group(4)?.trim() ?? 'TBD';

              schedule.add(
                ClassSession(
                  className: className,
                  dayOfWeek: days,
                  startTime: _parseTime(startStr),
                  endTime: _parseTime(endStr),
                  location: location,
                ),
              );
            } else {
               // Fallback or log if pattern doesn't match
               print('Could not parse meeting pattern: $meetingPattern');
            }

          } catch (e) {
            print('Error parsing row: $e');
          }
        }
      }
      return schedule;
    }
    return [];
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      // Normalize string
      timeStr = timeStr.toUpperCase().replaceAll(' ', '');
      bool isPm = timeStr.contains('PM');
      timeStr = timeStr.replaceAll('AM', '').replaceAll('PM', '');
      
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Error parsing time: $timeStr');
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  List<String> findMatches(List<ClassSession> mySchedule) {
    // Mock logic: Return fake users if schedule is not empty
    if (mySchedule.isNotEmpty) {
      return [
        'Sarah (Biology 101 @ 10:00 AM)',
        'Mike (CS 202 @ 1:00 PM)',
        'Jessica (History @ 9:00 AM)',
      ];
    }
    return [];
  }
}
