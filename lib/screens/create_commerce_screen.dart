import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/commerce_service.dart';
import '../helpers/translations_helper.dart';

class CreateCommerceScreen extends StatefulWidget {
  @override
  _CreateCommerceScreenState createState() => _CreateCommerceScreenState();
}

class _CreateCommerceScreenState extends State<CreateCommerceScreen> {
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
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(translate(context, 'business.businessCreated') ?? 'Business created'),
                content: Text(translate(context, 'business.businessCreatedSuccessfully') ?? 'The business has been successfully created.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
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
              return AlertDialog(
                title: Text(translate(context, 'errors.error') ?? 'Error'),
                content: Text(translate(context, 'auth.errorCreatingBusiness') ?? 'There was a problem creating the business.'),
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
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(translate(context, 'auth.authError') ?? 'Authentication error'),
              content: Text(translate(context, 'auth.tokenNotFound') ?? 'Authentication token could not be obtained.'),
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
        title: Text(translate(context, 'business.createNewBusiness') ?? 'Create new business'),
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
                child: Text(translate(context, 'business.saveBusiness') ?? 'Save Business'),
                onPressed: _saveCommerce,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
