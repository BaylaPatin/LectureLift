import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../theme/app_theme.dart';

class AddClassForm extends StatefulWidget {
  final Function(ClassSession) onClassAdded;

  const AddClassForm({Key? key, required this.onClassAdded}) : super(key: key);

  @override
  State<AddClassForm> createState() => _AddClassFormState();
}

class _AddClassFormState extends State<AddClassForm> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _locationController = TextEditingController();
  
  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> _selectedDays = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _classNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveClass() {
    if (_formKey.currentState!.validate() && _selectedDays.isNotEmpty) {
      final session = ClassSession(
        className: _classNameController.text,
        dayOfWeek: _selectedDays.join(', '),
        startTime: _startTime,
        endTime: _endTime,
        location: _locationController.text,
      );
      widget.onClassAdded(session);
      
      // Reset form
      _classNameController.clear();
      _locationController.clear();
      setState(() {
        _selectedDays.clear();
        _startTime = const TimeOfDay(hour: 9, minute: 0);
        _endTime = const TimeOfDay(hour: 10, minute: 0);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Class added successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select at least one day'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              surface: AppTheme.darkSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkSurface,
            AppTheme.darkSurface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Add New Class',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              
              // Class Name
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: TextFormField(
                  controller: _classNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Class Name',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.book, color: AppTheme.primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 20),
              
              // Days Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Days',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50, // slightly bigger to give padding
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _daysOfWeek.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final day = _daysOfWeek[index];
                        final isSelected = _selectedDays.contains(day);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedDays.remove(day);
                              } else {
                                _selectedDays.add(day);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryPurple : Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              
              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: _buildTimeButton(
                      context: context,
                      icon: Icons.schedule,
                      label: 'Start Time',
                      time: _startTime.format(context),
                      onTap: () => _selectTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeButton(
                      context: context,
                      icon: Icons.schedule,
                      label: 'End Time',
                      time: _endTime.format(context),
                      onTap: () => _selectTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Location
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: TextFormField(
                  controller: _locationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 28),
              
              // Save Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryPurple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _saveClass,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add_circle, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Add Class',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
