import 'dart:async'; // Necesario para usar Timer
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<dynamic> _searchSuggestions = []; // Para almacenar las sugerencias de autocompletar
  Timer? _debounce; // Variable para manejar el temporizador
  bool _isLoading = false; // Variable para manejar el estado de carga

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancelar el temporizador al desmontar el widget
    super.dispose();
  }

  void _selectLocation() {
    setState(() {
      _pickedLocation = _mapController.center;
      print('Latitud: ${_pickedLocation.latitude}, Longitud: ${_pickedLocation.longitude}');
    });
  }

  // Método para buscar lugar por nombre usando Nominatim
  Future<void> _searchPlace(String query) async {
    setState(() {
      _isLoading = true; // Mostrar animación de carga
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
      print('Error al buscar la ubicación');
    }
    setState(() {
      _isLoading = false; // Ocultar animación de carga cuando termine la búsqueda
    });
  }

  // Método para actualizar las sugerencias de búsqueda usando Nominatim
  Future<void> _updateSearchSuggestions(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true; // Mostrar animación de carga mientras se buscan sugerencias
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
        print('Error al obtener sugerencias de búsqueda');
      }
      setState(() {
        _isLoading = false; // Ocultar animación de carga cuando termine la búsqueda
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
        title: Text('Seleccionar ubicación'),
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
          // Caja de búsqueda flotante
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
                            hintText: 'Buscar lugar...',
                            border: InputBorder.none,
                          ),
                          onChanged: _onSearchChanged, // Usar el método con debounce
                          onSubmitted: (value) {
                            _searchPlace(value);
                            _searchSuggestions.clear(); // Limpiar las sugerencias después de la búsqueda
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
                      removeBottom: true, // Eliminar el espacio en blanco al final
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
          // Controles de zoom
          Positioned(
            bottom: 50, // Separarlo de la barra inferior
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
