import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'create_commerce_screen.dart';
import 'create_nro_screen.dart';
import 'login_screen.dart';
import '../helpers/translations_helper.dart';
import '../providers/language_provider.dart';
import '../widgets/entity_actions_popup.dart';

class BusinessInstitutionScreen extends StatefulWidget {
  @override
  _BusinessInstitutionScreenState createState() => _BusinessInstitutionScreenState();
}

class _BusinessInstitutionScreenState extends State<BusinessInstitutionScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedSegment = 0;
  String? _tempSelectedLanguage;

  @override
  bool get wantKeepAlive => true;

  void _confirmLanguageChange() {
    if (_tempSelectedLanguage != null) {
      Provider.of<LanguageProvider>(context, listen: false)
          .updateLanguage(_tempSelectedLanguage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authService = Provider.of<AuthService>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    List<Map<String, dynamic>> _currentList =
    _selectedSegment == 0 ? authService.commerces : authService.institutions;

    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'entity.myEntities') ?? 'My Entities'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                translate(context, 'entity.menu') ?? 'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text(translate(context, 'entity.businessAndInstitutions') ??
                  'Businesses and Institutions'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(translate(context, 'auth.logout') ?? 'Logout'),
              onTap: () async {
                await authService.logout();
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                setState(() => _selectedSegment = value);
              },
              groupValue: _selectedSegment,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _currentList.length,
              itemBuilder: (context, index) {
                final item = _currentList[index];
                final isActive = item['active'] ?? true;

                return Card(
                  color: isActive ? Colors.white : Colors.grey[300],
                  child: ListTile(
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
                        Text(
                          '${translate(context, 'entity_fields.address') ?? 'Address'}: ${item['address'] ?? ''}',
                        ),
                        Text(
                          '${translate(context, 'entity_fields.phone') ?? 'Phone'}: ${item['phone'] ?? ''}',
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      showEntityActionsPopup(
                        context: context,
                        item: item,
                        isBusiness: _selectedSegment == 0,
                        refresh: () => setState(() {}),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: CupertinoButton.filled(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => _selectedSegment == 0
                        ? CreateCommerceScreen()
                        : CreateInstitutionScreen(),
                  ),
                );
              },
              child: Text(
                _selectedSegment == 0
                    ? translate(context, 'business.createNewBusiness') ?? 'Create new business'
                    : translate(context, 'institution.createNewInstitution') ?? 'Create new institution',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
