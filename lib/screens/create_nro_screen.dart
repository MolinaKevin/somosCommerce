import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/translations_helper.dart';

class CreateInstitutionScreen extends StatefulWidget {
  @override
  _CreateInstitutionScreenState createState() => _CreateInstitutionScreenState();
}

class _CreateInstitutionScreenState extends State<CreateInstitutionScreen> {
  final _formKey = GlobalKey<FormState>();

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
            title: Text(translate(context, 'institution.institutionCreated') ?? 'Institution created'),
            content: Text(
                '${translate(context, 'entity_fields.name')}: ${_nameController.text}\n'
                    '${translate(context, 'entity_fields.address')}: ${_addressController.text}\n'
                    '${translate(context, 'entity_fields.city')}: ${_cityController.text}\n'
                    '${translate(context, 'entity_fields.plz')}: ${_plzController.text}\n'
                    '${translate(context, 'time.schedule')}: ${_openingTime?.format(context)} - ${_closingTime?.format(context)}\n'
                    '${translate(context, 'entity_fields.latitude')}: ${_latitudeController.text}\n'
                    '${translate(context, 'entity_fields.longitude')}: ${_longitudeController.text}\n'
                    '${translate(context, 'entity_fields.avatarUrl')}: ${_avatarController.text}\n'
                    '${translate(context, 'entity_fields.backgroundImageUrl')}: ${_backgroundImageController.text}\n'
                    '${translate(context, 'entity_fields.percent')}: ${_percentController.text}%\n'
                    '${translate(context, 'institution.somos')}: $_selectedSomos'),
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
        title: Text(translate(context, 'institution.createNewInstitution') ?? 'Create new institution'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: translate(context, 'entity_fields.name') ?? 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'placeholders.pleaseEnterName') ?? 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: translate(context, 'entity_fields.address') ?? 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'placeholders.pleaseEnterAddress') ?? 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: translate(context, 'entity_fields.city') ?? 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'placeholders.pleaseEnterCity') ?? 'Please enter a city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _plzController,
                decoration: InputDecoration(labelText: translate(context, 'entity_fields.plz') ?? 'PLZ'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'placeholders.pleaseEnterPLZ') ?? 'Please enter the postal code (PLZ)';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: InputDecoration(labelText: translate(context, 'entity_fields.latitude') ?? 'Latitude'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return translate(context, 'placeholders.pleaseEnterLatitude') ?? 'Please enter the latitude';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: InputDecoration(labelText: translate(context, 'entity_fields.longitude') ?? 'Longitude'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return translate(context, 'placeholders.pleaseEnterLongitude') ?? 'Please enter the longitude';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _avatarController,
                decoration: InputDecoration(labelText: translate(context, 'entity_fields.avatarUrl') ?? 'Avatar (URL)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'placeholders.pleaseEnterAvatarUrl') ?? 'Please enter the avatar URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _backgroundImageController,
                decoration: InputDecoration(labelText: translate(context, 'entity_fields.backgroundImageUrl') ?? 'Background Image (URL)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'placeholders.pleaseEnterBackgroundImageUrl') ?? 'Please enter the background image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _percentController,
                decoration: InputDecoration(labelText: translate(context, 'entity_fields.percent') ?? 'Percent'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translate(context, 'placeholders.pleaseEnterPercent') ?? 'Please enter a percentage';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: translate(context, 'institution.somos') ?? 'Somos'),
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
                    return translate(context, 'institution.pleaseSelectSomos') ?? 'Please select a Somos option';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _openingTime != null
                        ? '${translate(context, 'time.openingTime') ?? 'Opening time'}: ${_openingTime!.format(context)}'
                        : translate(context, 'time.selectOpeningTime') ?? 'Select opening time',
                  ),
                  CupertinoButton(
                    child: Text(translate(context, 'time.choose') ?? 'Choose'),
                    onPressed: () => _selectTime(context, true),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _closingTime != null
                        ? '${translate(context, 'time.closingTime') ?? 'Closing time'}: ${_closingTime!.format(context)}'
                        : translate(context, 'time.selectClosingTime') ?? 'Select closing time',
                  ),
                  CupertinoButton(
                    child: Text(translate(context, 'time.choose') ?? 'Choose'),
                    onPressed: () => _selectTime(context, false),
                  ),
                ],
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text(translate(context, 'institution.saveInstitution') ?? 'Save Institution'),
                onPressed: _saveInstitution,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
