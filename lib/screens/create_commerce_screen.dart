import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/commerce_service.dart';
import '../helpers/translations_helper.dart'; // Importa el helper de traducción

class CreateCommerceScreen extends StatefulWidget {
  @override
  _CreateCommerceScreenState createState() => _CreateCommerceScreenState();
}

class _CreateCommerceScreenState extends State<CreateCommerceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _plzController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();
  final TextEditingController _backgroundImageController = TextEditingController();
  final TextEditingController _percentController = TextEditingController();

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _plzController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _avatarController.dispose();
    _backgroundImageController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpeningTime ? (_openingTime ?? TimeOfDay.now()) : (_closingTime ?? TimeOfDay.now()),
    );
    if (picked != null && picked != (isOpeningTime ? _openingTime : _closingTime)) {
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
        final success = await CommerceService().createCommerce(token, commerceData);

        if (success != null) {
          // Comercio creado exitosamente
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(translate(context, 'businessCreated') ?? 'Comercio creado'),
                content: Text(translate(context, 'businessCreatedSuccessfully') ?? 'El comercio ha sido creado exitosamente.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Regresa a la pantalla anterior
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Error al crear comercio
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(translate(context, 'error') ?? 'Error'),
                content: Text(translate(context, 'errorCreatingBusiness') ?? 'Hubo un problema al crear el comercio.'),
                actions: <Widget>[
                  TextButton(
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
            return AlertDialog(
              title: Text(translate(context, 'authError') ?? 'Error de autenticación'),
              content: Text(translate(context, 'tokenNotFound') ?? 'No se pudo obtener el token de autenticación.'),
              actions: <Widget>[
                TextButton(
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
    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'createNewBusiness') ?? 'Crear Nuevo Comercio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: translate(context, 'name') ?? 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'pleaseEnterName') ?? 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: translate(context, 'address') ?? 'Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'pleaseEnterAddress') ?? 'Por favor ingresa una dirección';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: translate(context, 'city') ?? 'Ciudad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'pleaseEnterCity') ?? 'Por favor ingresa una ciudad';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _plzController,
                decoration: InputDecoration(labelText: translate(context, 'plz') ?? 'PLZ'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'pleaseEnterPLZ') ?? 'Por favor ingresa el código postal (PLZ)';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: InputDecoration(labelText: translate(context, 'latitude') ?? 'Latitud'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return translate(context, 'pleaseEnterLatitude') ?? 'Por favor ingresa la latitud';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: InputDecoration(labelText: translate(context, 'longitude') ?? 'Longitud'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return translate(context, 'pleaseEnterLongitude') ?? 'Por favor ingresa la longitud';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _avatarController,
                decoration: InputDecoration(labelText: translate(context, 'avatarUrl') ?? 'Avatar (URL)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'pleaseEnterAvatarUrl') ?? 'Por favor ingresa la URL del avatar';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _backgroundImageController,
                decoration: InputDecoration(labelText: translate(context, 'backgroundImageUrl') ?? 'Imagen de Fondo (URL)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'pleaseEnterBackgroundImageUrl') ?? 'Por favor ingresa la URL de la imagen de fondo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _percentController,
                decoration: InputDecoration(labelText: translate(context, 'percent') ?? 'Percent'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'pleaseEnterPercent') ?? 'Por favor ingresa un porcentaje';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _openingTime != null
                        ? '${translate(context, 'openingTime') ?? 'Apertura'}: ${_openingTime!.format(context)}'
                        : translate(context, 'selectOpeningTime') ?? 'Selecciona hora de apertura',
                  ),
                  CupertinoButton(
                    child: Text(translate(context, 'choose') ?? 'Elegir'),
                    onPressed: () => _selectTime(context, true),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _closingTime != null
                        ? '${translate(context, 'closingTime') ?? 'Cierre'}: ${_closingTime!.format(context)}'
                        : translate(context, 'selectClosingTime') ?? 'Selecciona hora de cierre',
                  ),
                  CupertinoButton(
                    child: Text(translate(context, 'choose') ?? 'Elegir'),
                    onPressed: () => _selectTime(context, false),
                  ),
                ],
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text(translate(context, 'saveBusiness') ?? 'Guardar Comercio'),
                onPressed: _saveCommerce,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
