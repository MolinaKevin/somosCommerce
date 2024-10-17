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
  String? _tempSelectedLanguage; // Variable para almacenar el idioma temporalmente

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeTileExpansionState();
  }

  void _initializeTileExpansionState() {
    _isTileExpanded = List.filled(Provider.of<AuthService>(context, listen: false).commerces.length, false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTileExpansionState();
  }

  // Función para confirmar el cambio de idioma
  void _confirmLanguageChange() {
    if (_tempSelectedLanguage != null) {
      Provider.of<LanguageProvider>(context, listen: false)
          .updateLanguage(_tempSelectedLanguage!); // Cambiar idioma
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authService = Provider.of<AuthService>(context);
    final languageProvider = Provider.of<LanguageProvider>(context); // Accedemos al idioma actual

    List<Map<String, dynamic>> _currentList = _selectedSegment == 0
        ? authService.commerces
        : authService.institutions;

    if (_isTileExpanded.length != _currentList.length) {
      _initializeTileExpansionState();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'myEntities') ?? 'Mis Entidades'),
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
                translate(context, 'menu') ?? 'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text(translate(context, 'businessAndInstitutions') ?? 'Comercios e Instituciones'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(translate(context, 'logout') ?? 'Logout'),
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
                  Text(translate(context, 'selectLanguage') ?? 'Seleccionar idioma'),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _tempSelectedLanguage ?? languageProvider.currentLanguage, // Usamos el idioma temporal o el actual
                          onChanged: (newLanguage) {
                            setState(() {
                              _tempSelectedLanguage = newLanguage; // Guardamos el idioma temporalmente
                            });
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'es',
                              child: Text('Español'),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _confirmLanguageChange, // Confirmar el cambio de idioma
                        child: Text(translate(context, 'confirm') ?? 'Confirmar'),
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
                0: Text(translate(context, 'businesses') ?? 'Comercios'),
                1: Text(translate(context, 'institutions') ?? 'Instituciones'),
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
                    leading: Image.network(
                      item['avatar_url'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${translate(context, 'address') ?? 'Dirección'}: ${item['address'] ?? ''}'),
                        Text('${translate(context, 'phone') ?? 'Teléfono'}: ${item['phone'] ?? ''}'),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              label: Text(translate(context, 'edit') ?? 'Editar'),
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
                                      builder: (context) => EditInstitutionPage(entity: item),
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
                              label: Text(isActive ? translate(context, 'deactivate') ?? 'Desactivar' : translate(context, 'activate') ?? 'Activar'),
                              onPressed: () async {
                                final token = await authService.getToken();
                                final commerceService = CommerceService();
                                final commerceId = item['id'] as int;

                                if (item['accepted'] == false) {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                        title: Text(translate(context, 'notAccepted') ?? 'No aceptado'),
                                        content: Text('${translate(context, 'theBusiness')} ${item['name']} ${translate(context, 'isNotAccepted')}'),
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
                                    success = await commerceService.deactivateCommerce(token!, commerceId);
                                  } else {
                                    success = await commerceService.activateCommerce(token!, commerceId);
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
                                          content: Text('${translate(context, 'problem')} ${isActive ? translate(context, 'deactivating') : translate(context, 'activating')} ${translate(context, 'theBusiness')}'),
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
                              label: Text(translate(context, 'delete') ?? 'Eliminar'),
                              onPressed: () {
                                print('${translate(context, 'deleting')} ${item['name']}');
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
                    ? translate(context, 'createNewBusiness') ?? 'Crear nuevo comercio'
                    : translate(context, 'createNewInstitution') ?? 'Crear nueva institución',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
