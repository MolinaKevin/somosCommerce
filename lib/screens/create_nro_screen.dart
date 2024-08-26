import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  String? _selectedSomos; // Variable para almacenar el valor seleccionado

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
      // Aquí puedes manejar la lógica para guardar la institución
      // Ejemplo: enviar los datos a una API o guardar en una base de datos local

      // Para fines de demostración, solo mostramos un diálogo con los datos ingresados
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Institución creada'),
            content: Text('Nombre: ${_nameController.text}\n'
                'Dirección: ${_addressController.text}\n'
                'Ciudad: ${_cityController.text}\n'
                'PLZ: ${_plzController.text}\n'
                'Horario: ${_openingTime?.format(context)} - ${_closingTime?.format(context)}\n'
                'Latitud: ${_latitudeController.text}\n'
                'Longitud: ${_longitudeController.text}\n'
                'Avatar: ${_avatarController.text}\n'
                'Background Image: ${_backgroundImageController.text}\n'
                'Percent: ${_percentController.text}%\n'
                'Somos: $_selectedSomos'),
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
        title: Text('Crear Nueva Institución'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una dirección';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'Ciudad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una ciudad';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _plzController,
                decoration: InputDecoration(labelText: 'PLZ'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el código postal (PLZ)';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: InputDecoration(labelText: 'Latitud'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la latitud';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: InputDecoration(labelText: 'Longitud'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la longitud';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _avatarController,
                decoration: InputDecoration(labelText: 'Avatar (URL)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la URL del avatar';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _backgroundImageController,
                decoration: InputDecoration(labelText: 'Imagen de Fondo (URL)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la URL de la imagen de fondo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _percentController,
                decoration: InputDecoration(labelText: 'Percent'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un porcentaje';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Somos'),
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
                    return 'Por favor selecciona una opción de Somos';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _openingTime != null
                        ? 'Apertura: ${_openingTime!.format(context)}'
                        : 'Selecciona hora de apertura',
                  ),
                  CupertinoButton(
                    child: Text('Elegir'),
                    onPressed: () => _selectTime(context, true),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _closingTime != null
                        ? 'Cierre: ${_closingTime!.format(context)}'
                        : 'Selecciona hora de cierre',
                  ),
                  CupertinoButton(
                    child: Text('Elegir'),
                    onPressed: () => _selectTime(context, false),
                  ),
                ],
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text('Guardar Institución'),
                onPressed: _saveInstitution,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
