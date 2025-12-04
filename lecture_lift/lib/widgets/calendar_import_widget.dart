import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import '../models/schedule_model.dart';
import '../theme/app_theme.dart';
import 'glass_gradient_button.dart';

class CalendarImportWidget extends StatelessWidget {
  final Function(List<ClassSession>) onClassesImported;

  const CalendarImportWidget({Key? key, required this.onClassesImported})
      : super(key: key);

  Future<void> _importCalendar(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ics'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final icsString = String.fromCharCodes(bytes);
        
        print('DEBUG: ICS file content preview: ${icsString.substring(0, 200.clamp(0, icsString.length))}');
        
        final iCalendar = ICalendar.fromString(icsString);
        print('DEBUG: Parsed ${iCalendar.data.length} calendar entries');
        
        final List<ClassSession> sessions = [];

        for (var event in iCalendar.data) {
          print('DEBUG: Event type: ${event['type']}, summary: ${event['summary']}');
          
          if (event['type'] == 'VEVENT') {
            try {
              final summary = event['summary'] ?? 'Untitled Event';
              final location = event['location'] ?? 'TBD';
              
              // Handle both DateTime objects and String dates
              DateTime? dtStart;
              DateTime? dtEnd;
              
              final startValue = event['dtstart']?.dt;
              final endValue = event['dtend']?.dt;
              
              if (startValue is DateTime) {
                dtStart = startValue;
              } else if (startValue is String) {
                dtStart = _parseIcsDateTime(startValue);
              }
              
              if (endValue is DateTime) {
                dtEnd = endValue;
              } else if (endValue is String) {
                dtEnd = _parseIcsDateTime(endValue);
              }

              print('DEBUG: Processing event "$summary" - Start: $dtStart, End: $dtEnd');

              if (dtStart != null && dtEnd != null) {
                // Filter logic: Only import classes from recent past or future
                final now = DateTime.now();
                final sixMonthsAgo = now.subtract(const Duration(days: 180));
                
                if (dtStart.isBefore(sixMonthsAgo)) {
                  print('DEBUG: Skipping old event "$summary" from ${dtStart.year}-${dtStart.month}-${dtStart.day}');
                  continue;
                }
                
                print('DEBUG: Including event "$summary" from ${dtStart.year}-${dtStart.month}-${dtStart.day}');
                
                // Extract day(s) of week from RRULE if present
                String dayOfWeek = _getDayName(dtStart.weekday);
                final rrule = event['rrule']?.toString();
                
                if (rrule != null && rrule.contains('BYDAY=')) {
                  print('DEBUG: Found RRULE: $rrule');
                  // Extract BYDAY parameter (e.g., "MO,WE,FR" or "TU,TH")
                  final byDayMatch = RegExp(r'BYDAY=([A-Z,]+)').firstMatch(rrule);
                  if (byDayMatch != null) {
                    final byDayStr = byDayMatch.group(1)!;
                    dayOfWeek = _convertRRuleDays(byDayStr);
                    print('DEBUG: Converted RRULE days "$byDayStr" to "$dayOfWeek"');
                  }
                }
                
                sessions.add(
                  ClassSession(
                    className: summary,
                    dayOfWeek: dayOfWeek,
                    startTime: TimeOfDay.fromDateTime(dtStart),
                    endTime: TimeOfDay.fromDateTime(dtEnd),
                    location: location,
                  ),
                );
                print('DEBUG: Added class session: $summary on $dayOfWeek');
              } else {
                print('DEBUG: Skipping event "$summary" - missing start or end time');
              }
            } catch (e) {
              print('Error parsing event: $e');
            }
          }
        }

        print('DEBUG: Total sessions parsed: ${sessions.length}');

        // Group sessions by class name, time, and location to combine days
        final Map<String, ClassSession> groupedSessions = {};
        
        for (var session in sessions) {
          // Create a unique key based on class name, start time, end time, and location
          final key = '${session.className}_${session.startTime.hour}:${session.startTime.minute}_${session.endTime.hour}:${session.endTime.minute}_${session.location}';
          
          print('DEBUG: Processing session "${session.className}" on ${session.dayOfWeek} - Key: $key');
          
          if (groupedSessions.containsKey(key)) {
            // Combine days if the same class at same time already exists
            final existing = groupedSessions[key]!;
            final days = existing.dayOfWeek.split(', ');
            print('DEBUG: Found duplicate! Existing days: ${existing.dayOfWeek}, Adding: ${session.dayOfWeek}');
            if (!days.contains(session.dayOfWeek)) {
              groupedSessions[key] = ClassSession(
                className: existing.className,
                dayOfWeek: '${existing.dayOfWeek}, ${session.dayOfWeek}',
                startTime: existing.startTime,
                endTime: existing.endTime,
                location: existing.location,
              );
              print('DEBUG: Combined into: ${groupedSessions[key]!.dayOfWeek}');
            }
          } else {
            groupedSessions[key] = session;
            print('DEBUG: New class added: "${session.className}" on ${session.dayOfWeek}');
          }
        }
        
        final finalSessions = groupedSessions.values.toList();
        print('DEBUG: After grouping: ${finalSessions.length} unique classes');
        
        for (var session in finalSessions) {
          print('DEBUG: Final class: "${session.className}" - Days: ${session.dayOfWeek}');
        }


        if (finalSessions.isNotEmpty) {
          onClassesImported(finalSessions);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported ${finalSessions.length} classes successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No events found. Found ${iCalendar.data.length} entries but none had valid date/time.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('ERROR importing calendar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing calendar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  DateTime? _parseIcsDateTime(String dateString) {
    try {
      // Remove 'Z' suffix if present (UTC indicator)
      final cleanDate = dateString.replaceAll('Z', '');
      
      // Parse format: YYYYMMDDTHHmmss
      if (cleanDate.length >= 15 && cleanDate.contains('T')) {
        final year = int.parse(cleanDate.substring(0, 4));
        final month = int.parse(cleanDate.substring(4, 6));
        final day = int.parse(cleanDate.substring(6, 8));
        final hour = int.parse(cleanDate.substring(9, 11));
        final minute = int.parse(cleanDate.substring(11, 13));
        final second = int.parse(cleanDate.substring(13, 15));
        
        return DateTime(year, month, day, hour, minute, second);
      }
    } catch (e) {
      print('Error parsing date string "$dateString": $e');
    }
    return null;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _convertRRuleDays(String byDayStr) {
    // Convert RRULE BYDAY codes (MO,WE,FR) to our format (Mon, Wed, Fri)
    final dayMap = {
      'MO': 'Mon',
      'TU': 'Tue',
      'WE': 'Wed',
      'TH': 'Thu',
      'FR': 'Fri',
      'SA': 'Sat',
      'SU': 'Sun',
    };
    
    final days = byDayStr.split(',').map((code) => dayMap[code] ?? code).toList();
    return days.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Import from Calendar',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Import your class schedule from Google Calendar, Apple Calendar, or any .ics file',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlassGradientButton(
              onPressed: () => _importCalendar(context),
              gradient: AppTheme.yellowGradient,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.upload_file, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Choose .ics File',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: Export your calendar as .ics from Google Calendar or Apple Calendar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
