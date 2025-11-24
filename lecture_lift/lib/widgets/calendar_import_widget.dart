import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import '../models/schedule_model.dart';
import '../theme/app_theme.dart';

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
        
        final iCalendar = ICalendar.fromString(icsString);
        final List<ClassSession> sessions = [];

        for (var event in iCalendar.data) {
          if (event['type'] == 'VEVENT') {
            try {
              final summary = event['summary'] ?? 'Untitled Event';
              final location = event['location'] ?? 'TBD';
              final dtStart = event['dtstart']?.dt;
              final dtEnd = event['dtend']?.dt;

              if (dtStart != null && dtEnd != null) {
                // Extract day of week
                final dayOfWeek = _getDayName(dtStart.weekday);
                
                sessions.add(
                  ClassSession(
                    className: summary,
                    dayOfWeek: dayOfWeek,
                    startTime: TimeOfDay.fromDateTime(dtStart),
                    endTime: TimeOfDay.fromDateTime(dtEnd),
                    location: location,
                  ),
                );
              }
            } catch (e) {
              print('Error parsing event: $e');
            }
          }
        }

        if (sessions.isNotEmpty) {
          onClassesImported(sessions);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported ${sessions.length} classes successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No events found in calendar file')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing calendar: $e')),
      );
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
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
            ElevatedButton.icon(
              onPressed: () => _importCalendar(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose .ics File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.black,
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
