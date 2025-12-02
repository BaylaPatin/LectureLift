import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Smaller height
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20), // Reduced bottom margin
      decoration: BoxDecoration(
        gradient: AppTheme.purpleGradient, // Gradient background
        borderRadius: BorderRadius.circular(20), // Slightly less rounded
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.map_outlined, Icons.map, 0, 'Map'),
            _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today, 1, 'Schedule'),
            _buildNavItem(Icons.directions_car_outlined, Icons.directions_car, 2, 'Rides'),
            _buildNavItem(Icons.person_outline, Icons.person, 3, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, int index, String label) {
    final isSelected = selectedIndex == index;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemTapped(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: double.infinity,
            alignment: Alignment.center,
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              size: 24, // Optimized icon size
            ),
          ),
        ),
      ),
    );
  }
}
