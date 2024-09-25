import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_service.dart';
import '../services/commerce_service.dart';
import '../screens/map_screen.dart';
import 'sub_tabs/avatar_section.dart';
import 'sub_tabs/background_image_carousel.dart';
import 'sub_tabs/time_picker_section.dart';
import 'package:flutter/services.dart';

class Tab3 extends StatefulWidget {
  final Map<String, dynamic> entity;

  Tab3({required this.entity});

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
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
    _plzController = TextEditingController(text: widget.entity['plz'].toString());
    _latitudeController = TextEditingController(text: widget.entity['latitude'].toString());
    _longitudeController = TextEditingController(text: widget.entity['longitude'].toString());
    _avatarController = TextEditingController(text: widget.entity['avatar']);
    _percentController = TextEditingController(text: widget.entity['percent']?.toString() ?? '');

    _backgroundImages.add(widget.entity['background_image']);
    _openingTime = _parseTime(widget.entity['opening_time']);
    _closingTime = _parseTime(widget.entity['closing_time']);
  }

  TimeOfDay _parseTime(String? time) {
    if (time != null && time.isNotEmpty) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return TimeOfDay.now();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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
          title: Text('Ingresar URL del Avatar'),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(hintText: 'https://example.com/avatar.png'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _avatarController.text = urlController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
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
          title: Text('Ingresar URL de la Imagen de Fondo'),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(hintText: 'https://example.com/fondo.png'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _backgroundImages.add(urlController.text);
                });
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
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

  Future<void> _saveCommerce() async {
    if (_formKey.currentState?.validate() ?? false) {
      final commerceData = {
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
      };

      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token != null) {
        final success = await CommerceService().updateCommerce(token, widget.entity['id'], commerceData);
        if (success) {
          showDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Comercio actualizado'),
                content: Text('El comercio ha sido actualizado exitosamente.'),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Editar Comercio'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Sección de Avatar
              AvatarSection(
                avatarController: _avatarController,
                onPickImage: _pickImage,
                onEnterAvatarUrl: _enterAvatarUrl,
              ),
              SizedBox(height: 16),

              _buildTextFieldWithLabel(label: 'Nombre:', controller: _nameController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(label: 'Dirección:', controller: _addressController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(label: 'Ciudad:', controller: _cityController),
              SizedBox(height: 16),
              _buildTextFieldWithLabel(label: 'PLZ:', controller: _plzController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              SizedBox(height: 16),

              // Latitud y Longitud con botón de selección en el mapa
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

              // Carrusel de Imágenes de Fondo
              BackgroundImageCarousel(
                backgroundImages: _backgroundImages,
                currentIndex: _currentBackgroundIndex,
                onAddImage: _pickBackgroundImage,
                onAddImageUrl: _enterBackgroundImageUrl,
                onSelectImage: (index) {
                  setState(() {
                    _currentBackgroundIndex = index;
                  });
                },
              ),
              SizedBox(height: 16),

              _buildTextFieldWithLabel(label: 'Percent:', controller: _percentController, readOnly: true),
              SizedBox(height: 16),

              // Sección de Selección de Horarios
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
                child: Text('Guardar Cambios'),
                onPressed: _saveCommerce,
              ),

              if (widget.entity['accepted'] == true)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CupertinoButton.filled(
                    child: Text(widget.entity['active'] ? 'Desactivar Comercio' : 'Activar Comercio'),
                    onPressed: () async {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final token = await authService.getToken();

                      if (token != null) {
                        final success = widget.entity['active']
                            ? await CommerceService().deactivateCommerce(token, widget.entity['id'])
                            : await CommerceService().activateCommerce(token, widget.entity['id']);

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

  Widget _buildTextFieldWithLabel({required String label, required TextEditingController controller, bool readOnly = false, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
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
