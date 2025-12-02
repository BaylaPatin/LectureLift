import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/schedule_model.dart';
import '../widgets/add_class_form.dart';
import '../widgets/calendar_import_widget.dart';
import '../theme/app_theme.dart';
import '../services/auth_state.dart';
import '../services/database_service.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import 'map_screen.dart';
import 'find_ride_screen.dart';
import 'profile_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ClassSession> _schedule = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _dbService = DatabaseService();
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = _focusedDay;
    _loadSchedule();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    // Get userId from AuthState
    _userId = await AuthState.getCurrentUserId();
    
    if (_userId != null) {
      try {
        final schedule = await _dbService.getSchedule(_userId!);
        setState(() {
          _schedule = schedule;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading schedule: $e');
        setState(() => _isLoading = false);
      }
    } else {
      print('No user logged in');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSchedule() async {
    if (_userId != null) {
      try {
        await _dbService.saveSchedule(_userId!, _schedule);
        print('Schedule saved successfully for user: $_userId');
      } catch (e) {
        print('Error saving schedule: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving schedule: $e')),
        );
      }
    } else {
      print('Cannot save: No user logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save your schedule')),
      );
    }
  }

  void _addClass(ClassSession session) async {
    setState(() {
      _schedule.add(session);
    });
    await _saveSchedule();
    _tabController.animateTo(0); // Switch to schedule view
  }

  void _importClasses(List<ClassSession> sessions) async {
    setState(() {
      _schedule.addAll(sessions);
    });
    await _saveSchedule();
    _tabController.animateTo(0); // Switch to schedule view
  }

  List<ClassSession> _getClassesForDay(DateTime day) {
    final dayName = _getDayName(day.weekday);
    return _schedule.where((session) {
      return session.dayOfWeek.contains(dayName);
    }).toList();
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('My Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.primaryPurple,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Schedule'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Add Class'),
            Tab(icon: Icon(Icons.upload), text: 'Import'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Schedule View
          _buildScheduleView(),
          
          // Add Class Form
          SingleChildScrollView(
            child: AddClassForm(onClassAdded: _addClass),
          ),
          
          // Import Calendar
          SingleChildScrollView(
            child: CalendarImportWidget(onClassesImported: _importClasses),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: 1, // Schedule tab
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) return; // Already on Schedule

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
        break;
      case 1:
        // Already here
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FindRideScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Widget _buildScheduleView() {
    if (_schedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              'No classes yet',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a class or import your calendar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white38,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: Colors.white),
            weekendTextStyle: const TextStyle(color: Colors.white70),
            outsideTextStyle: const TextStyle(color: Colors.white24),
            selectedDecoration: BoxDecoration(
              color: AppTheme.primaryPurple,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppTheme.primaryYellow,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
          ),
        ),
        const Divider(color: Colors.white24),
        Expanded(
          child: _buildClassList(),
        ),
      ],
    );
  }

  Widget _buildClassList() {
    final classesForDay = _getClassesForDay(_selectedDay ?? _focusedDay);

    if (classesForDay.isEmpty) {
      return Center(
        child: Text(
          'No classes on ${_getDayName((_selectedDay ?? _focusedDay).weekday)}',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classesForDay.length,
      itemBuilder: (context, index) {
        final session = classesForDay[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          color: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
              child: Text(
                session.className.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              session.className,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${session.startTime.format(context)} - ${session.endTime.format(context)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(session.location, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                setState(() {
                  _schedule.remove(session);
                });
                await _saveSchedule();
              },
            ),
          ),
        );
      },
    );
  }
}
