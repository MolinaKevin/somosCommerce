import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/commerce_service.dart';
import 'create_commerce_screen.dart';
import 'create_nro_screen.dart';
import 'login_screen.dart';
import '../edit_page.dart';

class BusinessInstitutionScreen extends StatefulWidget {
  @override
  _BusinessInstitutionScreenState createState() => _BusinessInstitutionScreenState();
}

class _BusinessInstitutionScreenState extends State<BusinessInstitutionScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    List<Map<String, dynamic>> _currentList = _selectedSegment == 0
        ? authService.commerces
        : authService.institutions;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Entidades'),
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
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text('Comercios e Instituciones'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await authService.logout();
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
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
                0: Text('Comercios'),
                1: Text('Instituciones'),
              },
              onValueChanged: (int value) {
                setState(() {
                  _selectedSegment = value;
                });
              },
              groupValue: _selectedSegment,
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: PageStorageKey<String>('listView$_selectedSegment'),
              itemCount: _currentList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _currentList[index];
                final bool isActive = item['active'] ?? true; // Default to true if 'active' doesn't exist

                return Card(
                  color: isActive ? Colors.white : Colors.grey[300], // Grey out inactive items
                  child: ExpansionTile(
                    leading: Image.network(
                      item['avatar'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dirección: ${item['address'] ?? ''}'),
                        Text('Teléfono: ${item['phone'] ?? ''}'),
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
                              label: Text('Editar'),
                              onPressed: () {
                                Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => EditPage(entity: item),
                                    ),
                                  );
                              },
                            ),
                            ElevatedButton.icon(
                              icon: Icon(
                                isActive ? Icons.cancel : Icons.check_circle,
                                color: Colors.orange,
                              ),
                              label: Text(isActive ? 'Desactivar' : 'Activar'),
                              onPressed: () async {
                                final token = await authService.getToken();
                                final commerceService = CommerceService();
                                final commerceId = item['id'] as int;

                                if (item['accepted'] == false) {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                        title: Text('No aceptado'),
                                        content: Text('El comercio ${item['name']} aún no está aceptado, por favor espere.'),
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
                                          content: Text('Hubo un problema al ${isActive ? 'desactivar' : 'activar'} el comercio.'),
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
                              label: Text('Eliminar'),
                              onPressed: () {
                                // Aquí puedes manejar la lógica de eliminación
                                print('Eliminar ${item['name']}');
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
                  // Navegar a la pantalla de creación de comercio
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => CreateCommerceScreen(),
                    ),
                  );
                } else {
                  // Navegar a la pantalla de creación de institución
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => CreateInstitutionScreen(),
                    ),
                  );
                }
              },
              child: Text(
                _selectedSegment == 0 ? 'Crear nuevo comercio' : 'Crear nueva institución',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
