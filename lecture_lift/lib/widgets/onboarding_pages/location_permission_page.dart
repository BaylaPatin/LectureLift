import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';
import '../glass_gradient_button.dart';

class LocationPermissionPage extends StatefulWidget {
  final VoidCallback onPermissionGranted;
  final VoidCallback onPermissionSkipped;
  
  const LocationPermissionPage({
    super.key,
    required this.onPermissionGranted,
    required this.onPermissionSkipped,
  });

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final status = await Permission.location.request();
      
      if (status.isGranted) {
        widget.onPermissionGranted();
      } else if (status.isDenied) {
        _showPermissionDeniedDialog();
      } else if (status.isPermanentlyDenied) {
        _showPermanentlyDeniedDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Location Permission Needed', style: TextStyle(color: Colors.white)),
        content: const Text(
          'LectureLift needs location permission to show you nearby students and help you carpool. Your exact location is never shared - we approximate it for privacy.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPermissionSkipped();
            },
            child: const Text('Skip for now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestPermission();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Enable Location in Settings', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Location permission was permanently denied. You can enable it in your device settings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPermissionSkipped();
            },
            child: const Text('Skip for now'),
          ),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 48),
          const Text(
            "Enable Location",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Find nearby students and connect for carpooling",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Privacy note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.shield, color: AppTheme.primaryPurple, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Privacy Protected',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Your exact location is never shown\n'
                  '• We approximate within 50-200 meters\n'
                  '• Location shared only when app is open\n'
                  '• You control who sees you',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Allow button
          GlassGradientButton(
            onPressed: _isRequesting ? null : _requestPermission,
            gradient: AppTheme.purpleGradient,
            child: _isRequesting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Allow Location Access',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // Skip button
          TextButton(
            onPressed: widget.onPermissionSkipped,
            child: const Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
