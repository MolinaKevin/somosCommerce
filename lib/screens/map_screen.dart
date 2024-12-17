import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/translations_helper.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialLocation;

  MapScreen({required this.initialLocation});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _pickedLocation;
  MapController _mapController = MapController();
  TextEditingController _searchController = TextEditingController();
  double _currentZoom = 13.0;
  List<dynamic> _searchSuggestions = [];
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _selectLocation() {
    setState(() {
      _pickedLocation = _mapController.center;
      print('Latitude: ${_pickedLocation.latitude}, Longitude: ${_pickedLocation.longitude}');
    });
  }

  Future<void> _searchPlace(String query) async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      if (results.isNotEmpty) {
        final location = results.first;
        final lat = double.parse(location['lat']);
        final lon = double.parse(location['lon']);
        _mapController.move(LatLng(lat, lon), _currentZoom);
      }
    } else {
      print('Error searching location');
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateSearchSuggestions(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        setState(() {
          _searchSuggestions = results;
        });
      } else {
        print('Error fetching search suggestions');
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchSuggestions.clear();
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      _updateSearchSuggestions(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'map.selectLocation') ?? 'Select location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _selectLocation();
              Navigator.of(context).pop(_pickedLocation);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _pickedLocation,
              zoom: _currentZoom,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _pickedLocation = _mapController.center;
                    _currentZoom = position.zoom ?? _currentZoom;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          Center(
            child: Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 40,
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: translate(context, 'map.searchPlace') ?? 'Search place...',
                            border: InputBorder.none,
                          ),
                          onChanged: _onSearchChanged,
                          onSubmitted: (value) {
                            _searchPlace(value);
                            _searchSuggestions.clear();
                          },
                        ),
                      ),
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        ),
                      Icon(Icons.search),
                    ],
                  ),
                ),
                if (_searchSuggestions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _searchSuggestions[index];
                          return ListTile(
                            title: Text(suggestion['display_name']),
                            onTap: () {
                              setState(() {
                                _searchController.text = suggestion['display_name'];
                                _searchPlace(suggestion['display_name']);
                                _searchSuggestions.clear();
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  child: Icon(Icons.zoom_in),
                  onPressed: () {
                    setState(() {
                      _currentZoom += 1;
                      _mapController.move(_pickedLocation, _currentZoom);
                    });
                  },
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  child: Icon(Icons.zoom_out),
                  onPressed: () {
                    setState(() {
                      _currentZoom -= 1;
                      _mapController.move(_pickedLocation, _currentZoom);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
