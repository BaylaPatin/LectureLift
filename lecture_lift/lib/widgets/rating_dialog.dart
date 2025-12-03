import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_gradient_button.dart';

class RatingDialog extends StatefulWidget {
  final String ratedName;
  final String role; // 'driver' or 'rider' (the role of the person being rated)
  final Function(double overall, Map<String, double> criteria, String comment) onSubmit;

  const RatingDialog({
    Key? key,
    required this.ratedName,
    required this.role,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _overallRating = 0;
  final Map<String, double> _criteriaRatings = {};
  final TextEditingController _commentController = TextEditingController();

  late List<String> _criteria;

  @override
  void initState() {
    super.initState();
    if (widget.role == 'driver') {
      _criteria = ['Punctuality', 'Safety', 'Friendliness', 'Speed Limit'];
    } else {
      _criteria = ['Punctuality', 'Friendliness', 'Respectfulness'];
    }
    
    for (var c in _criteria) {
      _criteriaRatings[c] = 0;
    }
  }

  void _updateOverallRating() {
    double total = 0;
    int count = 0;
    _criteriaRatings.forEach((key, value) {
      if (value > 0) {
        total += value;
        count++;
      }
    });
    
    if (count > 0) {
      _overallRating = total / count;
    } else {
      _overallRating = 0;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget _buildStarRating(double rating, Function(double) onRatingChanged, {double size = 32}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => onRatingChanged(index + 1.0),
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: AppTheme.primaryYellow,
            size: size,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate ${widget.ratedName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Calculated Overall Rating Display
            Center(
              child: Column(
                children: [
                  const Text(
                    'Overall Rating',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _overallRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStarRating(_overallRating, (_) {}, size: 24), // Read-only stars
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            ..._criteria.map((criterion) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    criterion,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: _buildStarRating(_criteriaRatings[criterion]!, (rating) {
                      setState(() {
                        _criteriaRatings[criterion] = rating;
                        _updateOverallRating();
                      });
                    }, size: 36),
                  ),
                ],
              ),
            )).toList(),
            
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a comment (optional)',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            GlassGradientButton(
              onPressed: _overallRating > 0 ? () {
                widget.onSubmit(
                  _overallRating,
                  _criteriaRatings,
                  _commentController.text,
                );
                Navigator.of(context).pop();
              } : null, // Disable if no rating
              gradient: AppTheme.purpleGradient,
              height: 48,
              child: const Text(
                'Submit Rating',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
