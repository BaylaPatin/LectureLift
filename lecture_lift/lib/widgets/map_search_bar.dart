import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../theme/app_theme.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String googleApiKey;
  final Function(Prediction) onPlaceSelected;
  final Function() onClear;

  const MapSearchBar({
    Key? key,
    required this.searchController,
    required this.googleApiKey,
    required this.onPlaceSelected,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50, // Moved down for better spacing
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: searchController,
          googleAPIKey: googleApiKey,
          inputDecoration: InputDecoration(
            hintText: 'Search destination...',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryPurple),
            suffixIcon:
                searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: onClear,
                    )
                    : null,
          ),
          textStyle: const TextStyle(color: Colors.white),
          debounceTime: 800,
          countries: const ["us"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: onPlaceSelected,
          itemClick: (Prediction prediction) {
            searchController.text = prediction.description ?? "";
            searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0),
            );
          },
          seperatedBuilder: const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.white24),
          containerHorizontalPadding: 0,
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              color: AppTheme.darkSurface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white54, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      prediction.description ?? "",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
