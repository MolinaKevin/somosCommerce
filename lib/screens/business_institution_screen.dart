import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/commerce_service.dart';
import 'create_commerce_screen.dart';
import 'create_nro_screen.dart';
import 'login_screen.dart';
import '../edit_page.dart';
import '../edit_institution_page.dart';
import '../helpers/translations_helper.dart';
import '../providers/language_provider.dart';

class BusinessInstitutionScreen extends StatefulWidget {
  @override
  _BusinessInstitutionScreenState createState() => _BusinessInstitutionScreenState();
}

class _BusinessInstitutionScreenState extends State<BusinessInstitutionScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedSegment = 0;
  List<bool> _isTileExpanded = [];
  String? _tempSelectedLanguage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeTileExpansionState();
  }

  void _initializeTileExpansionState() {
    _isTileExpanded =
        List.filled(Provider.of<AuthService>(context, listen: false).commerces.length, false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTileExpansionState();
  }

  void _confirmLanguageChange() {
    if (_tempSelectedLanguage != null) {
      print('Confirming language change to: $_tempSelectedLanguage');
      Provider.of<LanguageProvider>(context, listen: false)
          .updateLanguage(_tempSelectedLanguage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authService = Provider.of<AuthService>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    print(
        'Rebuilding BusinessInstitutionScreen with language: ${languageProvider.currentLanguage}');

    List<Map<String, dynamic>> _currentList =
    _selectedSegment == 0 ? authService.commerces : authService.institutions;

    if (_isTileExpanded.length != _currentList.length) {
      _initializeTileExpansionState();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'entity.myEntities') ?? 'My Entities'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                translate(context, 'entity.menu') ?? 'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text(translate(context, 'entity.businessAndInstitutions') ??
                  'Businesses and Institutions'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(translate(context, 'auth.logout') ?? 'Logout'),
              onTap: () async {
                await authService.logout();
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate(context, 'language.selectLanguage') ?? 'Select Language'),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _tempSelectedLanguage ?? languageProvider.currentLanguage,
                          onChanged: (newLanguage) {
                            setState(() {
                              _tempSelectedLanguage = newLanguage;
                            });
                          },
                          items: ['es', 'en', 'de'].map((code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Text(
                                translate(context, 'languages.$code') ?? code.toUpperCase(),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _confirmLanguageChange,
                        child: Text(translate(context, 'forms.confirm') ?? 'Confirm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoSegmentedControl<int>(
              children: {
                0: Text(translate(context, 'entity.businesses') ?? 'Businesses'),
                1: Text(translate(context, 'entity.institutions') ?? 'Institutions'),
              },
              onValueChanged: (int value) {
                setState(() {
                  _selectedSegment = value;
                  _initializeTileExpansionState();
                });
              },
              groupValue: _selectedSegment,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _currentList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _currentList[index];
                final bool isActive = item['active'] ?? true;

                return Card(
                  color: isActive ? Colors.white : Colors.grey[300],
                  child: ExpansionTile(
                    initiallyExpanded: _isTileExpanded[index],
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _isTileExpanded[index] = expanded;
                      });
                    },
                    leading: Image.asset(
                      item['avatar_url'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${translate(context, 'entity_fields.address') ?? 'Address'}: ${item['address'] ?? ''}'),
                        Text(
                            '${translate(context, 'entity_fields.phone') ?? 'Phone'}: ${item['phone'] ?? ''}'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              label: Text(translate(context, 'forms.edit') ?? 'Edit'),
                              onPressed: () {
                                if (_selectedSegment == 0) {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => EditPage(entity: item),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          EditInstitutionPage(entity: item),
                                    ),
                                  );
                                }
                              },
                            ),
                            ElevatedButton.icon(
                              icon: Icon(
                                isActive ? Icons.cancel : Icons.check_circle,
                                color: Colors.orange,
                              ),
                              label: Text(
                                isActive
                                    ? translate(context, 'forms.deactivate') ??
                                    'Deactivate'
                                    : translate(context, 'forms.activate') ??
                                    'Activate',
                              ),
                              onPressed: () async {
                                final token = await authService.getToken();
                                final commerceService = CommerceService();
                                final commerceId = item['id'] as int;

                                if (item['accepted'] == false) {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                        title: Text(translate(context, 'entity.notAccepted') ??
                                            'Not accepted'),
                                        content: Text(
                                            '${translate(context, 'entity.theBusiness') ?? 'The business'} ${item['name']} ${translate(context, 'entity.isNotAccepted') ?? 'is not yet accepted, please wait.'}'),
                                        actions: <CupertinoDialogAction>[
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
                                  bool success = false;
                                  if (isActive) {
                                    success = await commerceService.deactivateCommerce(
                                        token!, commerceId);
                                  } else {
                                    success = await commerceService.activateCommerce(
                                        token!, commerceId);
                                  }

                                  if (success) {
                                    setState(() {
                                      item['active'] = !isActive;
                                    });
                                  } else {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title: Text('Error'),
                                          content: Text(
                                              '${translate(context, 'errors.problem') ?? 'There was a problem'} ${isActive ? translate(context, 'forms.deactivating') : translate(context, 'forms.activating')} ${translate(context, 'entity.theBusiness')}'),
                                          actions: <CupertinoDialogAction>[
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
                              },
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.delete, color: Colors.red),
                              label: Text(translate(context, 'forms.delete') ?? 'Delete'),
                              onPressed: () {
                                print(
                                    '${translate(context, 'forms.deleting')} ${item['name']}');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoButton.filled(
              onPressed: () {
                if (_selectedSegment == 0) {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => CreateCommerceScreen(),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => CreateInstitutionScreen(),
                    ),
                  );
                }
              },
              child: Text(
                _selectedSegment == 0
                    ? translate(context, 'business.createNewBusiness') ??
                    'Create new business'
                    : translate(context, 'institution.createNewInstitution') ??
                    'Create new institution',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
