import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_service.dart';
import '../services/institution_service.dart';
import '../services/somos_service.dart';
import '../screens/map_screen.dart';
import 'sub_tabs/avatar_section.dart';
import 'sub_tabs/background_image_carousel.dart';
import 'sub_tabs/time_picker_section.dart';
import 'package:flutter/services.dart';
import '../helpers/translations_helper.dart'; // Importa el helper de traducción

class TabInstitution3 extends StatefulWidget {
  final Map<String, dynamic> entity;

  TabInstitution3({required this.entity});

  @override
  _TabInstitution3State createState() => _TabInstitution3State();
}

class _TabInstitution3State extends State<TabInstitution3> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _plzController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _avatarController;
  late TextEditingController _percentController;

  String? _selectedSomos;
  List<Map<String, dynamic>> somosOptions = [];

  List<String> _backgroundImages = [];
  int _currentBackgroundIndex = 0;

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.entity['name']);
    _addressController = TextEditingController(text: widget.entity['address']);
    _cityController = TextEditingController(text: widget.entity['city']);
    _plzController =
        TextEditingController(text: widget.entity['plz'].toString());
    _latitudeController =
        TextEditingController(text: widget.entity['latitude'].toString());
    _longitudeController =
        TextEditingController(text: widget.entity['longitude'].toString());
    _avatarController = TextEditingController(text: widget.entity['avatar']);
    _percentController =
        TextEditingController(text: widget.entity['percent']?.toString() ?? '');

    _selectedSomos = widget.entity['somos_id']?.toString();
    _backgroundImages.add(widget.entity['background_image']);
    _openingTime = _parseTime(widget.entity['opening_time']);
    _closingTime = _parseTime(widget.entity['closing_time']);

    _loadSomosOptions();
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
    }
  }

  TimeOfDay _parseTime(String? time) {
    if (time != null && time.isNotEmpty) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return TimeOfDay.now();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarController.text = pickedFile.path;
      });
    }
  }

  Future<void> _enterAvatarUrl() async {
    TextEditingController urlController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              translate(context, 'enterAvatarUrl') ?? 'Enter Avatar URL'),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(
                hintText: 'https://example.com/avatar.png'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _avatarController.text = urlController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text(translate(context, 'save') ?? 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickBackgroundImage({required ImageSource source}) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _backgroundImages.add(pickedFile.path);
      });
    }
  }

  Future<void> _enterBackgroundImageUrl() async {
    TextEditingController urlController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(translate(context, 'enterBackgroundImageUrl') ??
              'Enter Background Image URL'),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(
                hintText: 'https://example.com/background.png'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _backgroundImages.add(urlController.text);
                });
                Navigator.of(context).pop();
              },
              child: Text(translate(context, 'save') ?? 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openMap() async {
    final LatLng? selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            MapScreen(
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
        'background_image': _backgroundImages[_currentBackgroundIndex],
        'percent': double.tryParse(_percentController.text) ?? 0.0,
        'opening_time': _openingTime?.format(context),
        'closing_time': _closingTime?.format(context),
        'somos_id': _selectedSomos,
      };

      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token != null) {
        final success = await InstitutionService().updateInstitution(
            token, widget.entity['id'], institutionData);
        if (success) {
          showDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(translate(context, 'institutionUpdated') ??
                    'Institución actualizada'),
                content: Text(
                    translate(context, 'institutionUpdatedSuccessfully') ??
                        'La institución ha sido actualizada exitosamente.'),
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
  }

  Widget _buildSomosDropdown() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(translate(context, 'somos') ?? 'Somos:',
              style: TextStyle(fontSize: 14)),
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
        middle: Text(
            translate(context, 'editInstitution') ?? 'Editar Institución'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AvatarSection(
                avatarController: _avatarController,
                onPickImage: _pickImage,
                onEnterAvatarUrl: _enterAvatarUrl,
              ),
              SizedBox(height: 16),

              _buildTextFieldWithLabel(
                  label: translate(context, 'name') ?? 'Nombre:',
                  controller: _nameController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(
                  label: translate(context, 'address') ?? 'Dirección:',
                  controller: _addressController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(
                  label: translate(context, 'city') ?? 'Ciudad:',
                  controller: _cityController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(
                  label: translate(context, 'plz') ?? 'PLZ:',
                  controller: _plzController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildTextFieldWithLabel(
                        label: translate(context, 'latitude') ?? 'Latitud:',
                        controller: _latitudeController,
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ]),
                  ),
                  Expanded(
                    flex: 7,
                    child: _buildTextFieldWithLabel(
                        label: translate(context, 'longitude') ?? 'Longitud:',
                        controller: _longitudeController,
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ]),
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

              BackgroundImageCarousel(
                backgroundImages: _backgroundImages,
                currentIndex: _currentBackgroundIndex,
                entityType: 'nro',
                entityId: widget.entity['id'],
                onImageUploaded: (imageUrl) {
                  if (imageUrl != null) {
                    setState(() {
                      _backgroundImages.add(imageUrl);
                    });
                  } else {
                    print("No se subió ninguna imagen.");
                  }
                },
                onSelectImage: (index) {
                  setState(() {
                    _currentBackgroundIndex = index;
                  });
                },
              ),

              SizedBox(height: 16),

              _buildTextFieldWithLabel(
                  label: translate(context, 'percent') ?? 'Percent:',
                  controller: _percentController,
                  readOnly: true),
              SizedBox(height: 16),

              TimePickerSection(
                openingTime: _openingTime,
                closingTime: _closingTime,
                onSelectOpeningTime: (newTime) {
                  setState(() {
                    _openingTime = newTime;
                  });
                },
                onSelectClosingTime: (newTime) {
                  setState(() {
                    _closingTime = newTime;
                  });
                },
              ),
              SizedBox(height: 20),

              CupertinoButton.filled(
                child: Text(
                    translate(context, 'saveChanges') ?? 'Guardar Cambios'),
                onPressed: _saveInstitution,
              ),

              if (widget.entity['accepted'] == true)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CupertinoButton.filled(
                    child: Text(widget.entity['active']
                        ? translate(context, 'deactivateInstitution') ??
                        'Desactivar Institución'
                        : translate(context, 'activateInstitution') ??
                        'Activar Institución'),
                    onPressed: () async {
                      final authService = Provider.of<AuthService>(
                          context, listen: false);
                      final token = await authService.getToken();

                      if (token != null) {
                        final success = widget.entity['active']
                            ? await InstitutionService().deactivateInstitution(
                            token, widget.entity['id'])
                            : await InstitutionService().activateInstitution(
                            token, widget.entity['id']);

                        if (success) {
                          setState(() {
                            widget.entity['active'] = !widget.entity['active'];
                          });
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

  Widget _buildTextFieldWithLabel(
      {required String label, required TextEditingController controller, bool readOnly = false, TextInputType? keyboardType, List<
          TextInputFormatter>? inputFormatters}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: TextStyle(fontSize: 14)),
        ),
        Expanded(
          flex: 7,
          child: CupertinoTextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }
}
