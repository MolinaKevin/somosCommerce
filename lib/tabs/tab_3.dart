import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/commerce_service.dart';

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
  late TextEditingController _backgroundImageController;
  late TextEditingController _percentController;

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

  @override
  void initState() {
    super.initState();

    // Imprimir detalles del comercio en la consola
    print('Detalles del comercio: ${widget.entity}');

    // Inicializar los controladores con los datos del comercio existente
    _nameController = TextEditingController(text: widget.entity['name']);
    _addressController = TextEditingController(text: widget.entity['address']);
    _cityController = TextEditingController(text: widget.entity['city']);
    _plzController = TextEditingController(text: widget.entity['plz'].toString());
    _latitudeController = TextEditingController(text: widget.entity['latitude'].toString());
    _longitudeController = TextEditingController(text: widget.entity['longitude'].toString());
    _avatarController = TextEditingController(text: widget.entity['avatar']);
    _backgroundImageController = TextEditingController(text: widget.entity['background_image']);
    _percentController = TextEditingController(text: widget.entity['percent']?.toString() ?? '');

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
        'background_image': _backgroundImageController.text,
        'percent': double.tryParse(_percentController.text) ?? 0.0,
        'opening_time': _openingTime?.format(context),
        'closing_time': _closingTime?.format(context),
      };

      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token != null) {
        final success = await CommerceService().updateCommerce(token, widget.entity['id'], commerceData);

        if (success) {
          // Comercio actualizado exitosamente
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
          // Error al actualizar comercio
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
              CupertinoTextField(
                controller: _nameController,
                placeholder: 'Nombre',
                readOnly: false,
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _addressController,
                placeholder: 'Dirección',
                readOnly: false,
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _cityController,
                placeholder: 'Ciudad',
                readOnly: false,
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _plzController,
                placeholder: 'PLZ',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                readOnly: false,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _latitudeController,
                      placeholder: 'Latitud',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      readOnly: false,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _longitudeController,
                      placeholder: 'Longitud',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      readOnly: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _avatarController,
                placeholder: 'Avatar (URL)',
                readOnly: false,
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _backgroundImageController,
                placeholder: 'Imagen de Fondo (URL)',
                readOnly: false,
              ),
              SizedBox(height: 16),
              CupertinoTextField(
                controller: _percentController,
                placeholder: 'Percent',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                readOnly: true, // Hacer que el campo sea de solo lectura
              ),
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
                          fontSize: 16, // Tamaño de fuente más pequeño
                          fontWeight: FontWeight.w500, // Peso de fuente moderado
                          color: Colors.black87, // Color de texto más suave
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Elegir',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue, // Color para resaltar el botón
                          ),
                        ),
                        onPressed: () => _selectTime(context, true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Espacio entre las filas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _closingTime != null
                            ? 'Cierre: ${_closingTime!.format(context)}'
                            : 'Selecciona hora de cierre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Elegir',
                          style: TextStyle(
                            fontSize: 16,
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
