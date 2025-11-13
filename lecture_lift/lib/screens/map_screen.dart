import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(30.4102, -91.1857),
    zoom: 11.5,
  );

  GoogleMapController? _googleMapController;
  int _selectedIndex = 0;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LatLng? _startLocation;
  LatLng? _endLocation;

  final TextEditingController _searchController = TextEditingController();

  //Google Places API key
  final String _googleApiKey = "AIzaSyAQ18lWuqBtVspF_CDWaW5ska2-Zev8GrE";

  @override
  void dispose() {
    _googleMapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _goToInitialPosition() {
    if (_googleMapController != null) {
      _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(_initialCameraPosition),
      );
    }
  }

  void _onPlaceSelected(Prediction prediction) async {
    // Get place details to get coordinates
    if (prediction.lat != null && prediction.lng != null) {
      double lat = double.parse(prediction.lat!);
      double lng = double.parse(prediction.lng!);
      LatLng destination = LatLng(lat, lng);

      setState(() {
        // Clear previous route
        _markers.clear();
        _polylines.clear();

        // Set current location as start
        _startLocation = _initialCameraPosition.target;
        _markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: _startLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Start'),
          ),
        );

        // Set searched location as destination
        _endLocation = destination;
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: destination,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: prediction.description ?? 'Destination',
            ),
          ),
        );

        _drawRoute();
      });

      // Fit bounds to show both points
      Future.delayed(const Duration(milliseconds: 300), () {
        _fitBounds();
      });

      // Clear the search field
      _searchController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Route to: ${prediction.description}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      if (_startLocation == null) {
        _startLocation = location;
        _markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: location,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Start'),
          ),
        );
      } else if (_endLocation == null) {
        _endLocation = location;
        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: location,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
        _drawRoute();
      } else {
        _markers.clear();
        _polylines.clear();
        _startLocation = location;
        _endLocation = null;
        _markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: location,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Start'),
          ),
        );
      }
    });
  }

  void _drawRoute() {
    if (_startLocation != null && _endLocation != null) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [_startLocation!, _endLocation!],
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    }
  }

  void _fitBounds() {
    if (_startLocation != null &&
        _endLocation != null &&
        _googleMapController != null) {
      double minLat = _startLocation!.latitude < _endLocation!.latitude
          ? _startLocation!.latitude
          : _endLocation!.latitude;
      double maxLat = _startLocation!.latitude > _endLocation!.latitude
          ? _startLocation!.latitude
          : _endLocation!.latitude;
      double minLng = _startLocation!.longitude < _endLocation!.longitude
          ? _startLocation!.longitude
          : _endLocation!.longitude;
      double maxLng = _startLocation!.longitude > _endLocation!.longitude
          ? _startLocation!.longitude
          : _endLocation!.longitude;

      _googleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - 0.01, minLng - 0.01),
            northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
          ),
          100,
        ),
      );
    }
  }

  void _clearRoute() {
    setState(() {
      _markers.clear();
      _polylines.clear();
      _startLocation = null;
      _endLocation = null;
      _searchController.clear();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        print('Navigate to Search');
        break;
      case 2:
        print('Navigate to Favorites');
        break;
      case 3:
        print('Navigate to Profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('Map Navigation'),
        actions: [
          if (_markers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearRoute,
              tooltip: 'Clear Route',
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              print('Settings pressed');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              setState(() {
                _googleMapController = controller;
              });
            },
            onTap: _onMapTapped,
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: _searchController,
              googleAPIKey: _googleApiKey,
              inputDecoration: InputDecoration(
                hintText: 'Search for a place',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              debounceTime: 800,
              countries: const [
                "us",
              ], // Restrict to US, remove to search worldwide
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                _onPlaceSelected(prediction);
              },
              itemClick: (Prediction prediction) {
                _searchController.text = prediction.description ?? "";
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description?.length ?? 0),
                );
              },
              seperatedBuilder: const Divider(),
              containerHorizontalPadding: 10,
              itemBuilder: (context, index, Prediction prediction) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          prediction.description ?? "",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_markers.isEmpty)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Search for a place or tap on the map to set start/destination',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: _goToInitialPosition,
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
