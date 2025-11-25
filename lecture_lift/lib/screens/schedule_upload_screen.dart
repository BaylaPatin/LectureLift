import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';
import '../theme/app_theme.dart';

class ScheduleUploadScreen extends StatefulWidget {
  const ScheduleUploadScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleUploadScreen> createState() => _ScheduleUploadScreenState();
}

class _ScheduleUploadScreenState extends State<ScheduleUploadScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  List<ClassSession> _schedule = [];
  List<String> _matches = [];
  bool _isLoading = false;

  void _uploadSchedule() async {
    setState(() => _isLoading = true);
    List<ClassSession> parsedSchedule =
        await _scheduleService.pickAndParseSchedule();
    setState(() {
      _schedule = parsedSchedule;
      _isLoading = false;
      _matches = []; // Reset matches on new upload
    });
  }

  void _findMatches() {
    setState(() {
      _matches = _scheduleService.findMatches(_schedule);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _uploadSchedule,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Excel Schedule (.xlsx)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            if (_schedule.isNotEmpty) ...[
              Text(
                'Your Schedule',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _schedule.length,
                  itemBuilder: (context, index) {
                    final session = _schedule[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.1,
                          ),
                          child: Text(
                            session.dayOfWeek.substring(0, 1),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(session.className),
                        subtitle: Text(
                          '${session.startTime.format(context)} - ${session.endTime.format(context)} @ ${session.location}',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _findMatches,
                child: const Text('Find Ride Matches'),
              ),
            ],
            if (_matches.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Matches Found!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.green.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.green),
                        title: Text(_matches[index]),
                        trailing: const Icon(Icons.chat),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_schedule.isEmpty && !_isLoading)
              const Expanded(
                child: Center(
                  child: Text(
                    'Upload your schedule to find matches.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
