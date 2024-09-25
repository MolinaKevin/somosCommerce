import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_service.dart';
import '../services/institution_service.dart';
import '../services/somos_service.dart'; // Importar SomosService
import '../screens/map_screen.dart';

class TabInstitution3 extends StatefulWidget {
  final Map<String, dynamic> entity;

  TabInstitution3({required this.entity});

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<TabInstitution3> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _plzController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _avatarController;
  late TextEditingController _backgroundImageController;
  late TextEditingController _percentController;

  String? _selectedSomos; // Controlador para el "Somos" seleccionado
  List<Map<String, dynamic>> somosOptions = []; // Lista de opciones de "Somos"

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

  @override
  void initState() {
    super.initState();

    // Inicializar los controladores con los datos de la institución existente
    _nameController = TextEditingController(text: widget.entity['name']);
    _addressController = TextEditingController(text: widget.entity['address']);
    _cityController = TextEditingController(text: widget.entity['city']);
    _plzController = TextEditingController(text: widget.entity['plz'].toString());
    _latitudeController = TextEditingController(text: widget.entity['latitude'].toString());
    _longitudeController = TextEditingController(text: widget.entity['longitude'].toString());
    _avatarController = TextEditingController(text: widget.entity['avatar']);
    _backgroundImageController = TextEditingController(text: widget.entity['background_image']);
    _percentController = TextEditingController(text: widget.entity['percent']?.toString() ?? '');
    _selectedSomos = widget.entity['somos_id']?.toString();

    _openingTime = _parseTime(widget.entity['opening_time']);
    _closingTime = _parseTime(widget.entity['closing_time']);

    _loadSomosOptions(); // Cargar las opciones de "Somos"
  }

  Future<void> _loadSomosOptions() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = await authService.getToken();

    if (token != null) {
      final somosService = SomosService();
      final options = await somosService.fetchSomosOptions(token);

      setState(() {
        somosOptions = options;
      });
    } else {
      print('No se pudo obtener el token de autenticación');
    }
  }

  TimeOfDay _parseTime(String? time) {
    if (time != null && time.isNotEmpty) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return TimeOfDay.now();
  }

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpeningTime ? (_openingTime ?? TimeOfDay.now()) : (_closingTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isOpeningTime) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  Future<void> _openMap() async {
    final LatLng? selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: LatLng(
            double.tryParse(_latitudeController.text) ?? 0.0,
            double.tryParse(_longitudeController.text) ?? 0.0,
          ),
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _latitudeController.text = selectedLocation.latitude.toString();
        _longitudeController.text = selectedLocation.longitude.toString();
      });
    }
  }

  Future<void> _saveInstitution() async {
    if (_formKey.currentState?.validate() ?? false) {
      final institutionData = {
        'name': _nameController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'plz': _plzController.text,
        'latitude': _latitudeController.text,
        'longitude': _longitudeController.text,
        'avatar': _avatarController.text,
        'background_image': _backgroundImageController.text,
        'percent': double.tryParse(_percentController.text) ?? 0.0,
        'opening_time': _openingTime?.format(context),
        'closing_time': _closingTime?.format(context),
        'somos_id': _selectedSomos, // Guardar el "Somos" seleccionado
      };

      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token != null) {
        final success = await InstitutionService().updateInstitution(token, widget.entity['id'], institutionData);

        if (success) {
          // Institución actualizada exitosamente
          showDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Institución actualizada'),
                content: Text('La institución ha sido actualizada exitosamente.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Error al actualizar institución
          showDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Error'),
                content: Text('Hubo un problema al actualizar la institución.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        // No se pudo obtener el token
        showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Error de autenticación'),
              content: Text('No se pudo obtener el token de autenticación.'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Widget _buildTextFieldWithLabel({required String label, required TextEditingController controller, bool readOnly = false, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(fontSize: 14), // Tamaño de fuente más pequeño
          ),
        ),
        Expanded(
          flex: 7,
          child: CupertinoTextField(
            controller: controller,
            placeholder: label,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(fontSize: 14), // Tamaño de fuente más pequeño
          ),
        ),
      ],
    );
  }

  Widget _buildSomosDropdown() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'Somos:',
            style: TextStyle(fontSize: 14),
          ),
        ),
        Expanded(
          flex: 7,
          child: Material(
            child: DropdownButton<String>(
              value: _selectedSomos,
              onChanged: (newValue) {
                setState(() {
                  _selectedSomos = newValue;
                });
              },
              items: somosOptions.map<DropdownMenuItem<String>>((somos) {
                return DropdownMenuItem<String>(
                  value: somos['id'].toString(),
                  child: Text(somos['name']),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Editar Institución'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFieldWithLabel(label: 'Nombre:', controller: _nameController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(label: 'Dirección:', controller: _addressController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(label: 'Ciudad:', controller: _cityController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(label: 'PLZ:', controller: _plzController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildTextFieldWithLabel(label: 'Latitud:', controller: _latitudeController, keyboardType: TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]),
                  ),
                  Expanded(
                    flex: 7,
                    child: _buildTextFieldWithLabel(label: 'Longitud:', controller: _longitudeController, keyboardType: TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]),
                  ),
                  IconButton(
                    icon: Icon(Icons.map),
                    onPressed: _openMap,
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildSomosDropdown(),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(label: 'Avatar (URL):', controller: _avatarController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(label: 'Imagen de Fondo (URL):', controller: _backgroundImageController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(label: 'Percent:', controller: _percentController, readOnly: true, keyboardType: TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]),
              SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _openingTime != null
                            ? 'Apertura: ${_openingTime!.format(context)}'
                            : 'Selecciona hora de apertura',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Elegir',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () => _selectTime(context, true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _closingTime != null
                            ? 'Cierre: ${_closingTime!.format(context)}'
                            : 'Selecciona hora de cierre',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Elegir',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () => _selectTime(context, false),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text('Guardar Cambios', style: TextStyle(fontSize: 14)),
                onPressed: _saveInstitution,
              ),
              if (widget.entity['accepted'] == true)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CupertinoButton.filled(
                    child: Text(widget.entity['active'] ? 'Desactivar Institución' : 'Activar Institución', style: TextStyle(fontSize: 14)),
                    onPressed: () async {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final token = await authService.getToken();

                      if (token != null) {
                        final success = widget.entity['active']
                            ? await InstitutionService().deactivateInstitution(token, widget.entity['id'])
                            : await InstitutionService().activateInstitution(token, widget.entity['id']);

                        if (success) {
                          setState(() {
                            widget.entity['active'] = !widget.entity['active'];
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.entity['active']
                                  ? 'Institución activada'
                                  : 'Institución desactivada'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al cambiar el estado de la institución'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
