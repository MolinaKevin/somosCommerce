import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/translations_helper.dart'; // Importa el helper de traducción

class CreateInstitutionScreen extends StatefulWidget {
  @override
  _CreateInstitutionScreenState createState() => _CreateInstitutionScreenState();
}

class _CreateInstitutionScreenState extends State<CreateInstitutionScreen> {
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

  String? _selectedSomos;

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

  void _saveInstitution() {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(translate(context, 'institutionCreated') ?? 'Institución creada'),
            content: Text(
                '${translate(context, 'name')}: ${_nameController.text}\n'
                    '${translate(context, 'address')}: ${_addressController.text}\n'
                    '${translate(context, 'city')}: ${_cityController.text}\n'
                    '${translate(context, 'plz')}: ${_plzController.text}\n'
                    '${translate(context, 'schedule')}: ${_openingTime?.format(context)} - ${_closingTime?.format(context)}\n'
                    '${translate(context, 'latitude')}: ${_latitudeController.text}\n'
                    '${translate(context, 'longitude')}: ${_longitudeController.text}\n'
                    '${translate(context, 'avatarUrl')}: ${_avatarController.text}\n'
                    '${translate(context, 'backgroundImageUrl')}: ${_backgroundImageController.text}\n'
                    '${translate(context, 'percent')}: ${_percentController.text}%\n'
                    '${translate(context, 'somos')}: $_selectedSomos'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'createNewInstitution') ?? 'Crear Nueva Institución'),
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
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: translate(context, 'somos') ?? 'Somos'),
                value: _selectedSomos,
                items: [
                  DropdownMenuItem(value: 'Lübeck', child: Text('Lübeck')),
                  DropdownMenuItem(value: 'Göttingen', child: Text('Göttingen')),
                  DropdownMenuItem(value: 'Potsdam', child: Text('Potsdam')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSomos = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'pleaseSelectSomos') ?? 'Por favor selecciona una opción de Somos';
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
                child: Text(translate(context, 'saveInstitution') ?? 'Guardar Institución'),
                onPressed: _saveInstitution,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
