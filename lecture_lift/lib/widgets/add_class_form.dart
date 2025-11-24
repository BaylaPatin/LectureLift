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
        const SnackBar(content: Text('Class added successfully!')),
      );
    } else if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
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
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Class',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 20),
              
              // Class Name
              TextFormField(
                controller: _classNameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Days Selection
              Text('Days', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _daysOfWeek.map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text('Start: ${_startTime.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectTime(false),
                      icon: const Icon(Icons.access_time),
                      label: Text('End: ${_endTime.format(context)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              
              // Save Button
              ElevatedButton.icon(
                onPressed: _saveClass,
                icon: const Icon(Icons.add),
                label: const Text('Add Class'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
