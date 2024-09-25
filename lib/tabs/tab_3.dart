import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Para subir una imagen desde el dispositivo
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_service.dart';
import '../services/commerce_service.dart';
import '../screens/map_screen.dart';

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

  List<String> _backgroundImages = []; // Lista de imágenes de fondo
  int _currentBackgroundIndex = 0; // Índice de la imagen de fondo actual

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  final ImagePicker _picker = ImagePicker(); // Instancia para seleccionar imágenes

  @override
  void initState() {
    super.initState();

    // Inicializar los controladores con los datos del comercio existente
    _nameController = TextEditingController(text: widget.entity['name']);
    _addressController = TextEditingController(text: widget.entity['address']);
    _cityController = TextEditingController(text: widget.entity['city']);
    _plzController = TextEditingController(text: widget.entity['plz'].toString());
    _latitudeController = TextEditingController(text: widget.entity['latitude'].toString());
    _longitudeController = TextEditingController(text: widget.entity['longitude'].toString());
    _avatarController = TextEditingController(text: widget.entity['avatar']);
    _percentController = TextEditingController(text: widget.entity['percent']?.toString() ?? '');

    _backgroundImages.add(widget.entity['background_image'] ?? ''); // Inicializa la lista de imágenes de fondo
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
        _backgroundImages.add(pickedFile.path); // Agregar nueva imagen al carrusel
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
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Error'),
                content: Text('Hubo un problema al actualizar el comercio.'),
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

  Widget _buildBackgroundImageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _backgroundImages.map((imagePath) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 150, // Cuadrado perfecto
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Text('Error al cargar'));
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 8),
        CupertinoButton.filled(
          child: Text('Agregar Imagen de Fondo'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Subir desde la galería'),
                        onTap: () {
                          _pickBackgroundImage(source: ImageSource.gallery);
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text('Tomar una foto'),
                        onTap: () {
                          _pickBackgroundImage(source: ImageSource.camera);
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text('Ingresar URL'),
                        onTap: () {
                          _enterBackgroundImageUrl();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _avatarController.text.isNotEmpty
              ? NetworkImage(_avatarController.text)
              : AssetImage('assets/default_avatar.png') as ImageProvider,
        ),
        SizedBox(height: 8),
        CupertinoButton.filled(
          child: Text('Cambiar Avatar'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.photo),
                        title: Text('Subir desde la galería'),
                        onTap: () {
                          _pickImage();
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text('Ingresar URL'),
                        onTap: () {
                          _enterAvatarUrl();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
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
            placeholder: label,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
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
              _buildAvatarSection(),
              SizedBox(height: 16),
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
              _buildBackgroundImageCarousel(),
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
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Elegir',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
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
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Elegir',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                        onPressed: () => _selectTime(context, false),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              CupertinoButton.filled(
                child: Text('Guardar Cambios', style: TextStyle(fontSize: 14)),
                onPressed: _saveCommerce,
              ),
              if (widget.entity['accepted'] == true)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CupertinoButton.filled(
                    child: Text(widget.entity['active'] ? 'Desactivar Comercio' : 'Activar Comercio', style: TextStyle(fontSize: 14)),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.entity['active']
                                  ? 'Comercio activado'
                                  : 'Comercio desactivado'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al cambiar el estado del comercio'),
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
