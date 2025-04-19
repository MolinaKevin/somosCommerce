import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/commerce_service.dart';
import 'login_screen.dart';
import '../edit_page.dart';
import '../edit_institution_page.dart';
import '../helpers/translations_helper.dart';
import '../providers/language_provider.dart';
import 'create_commerce_screen.dart';
import 'create_nro_screen.dart';

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

  void _showActionsPopup(Map<String, dynamic> item, bool isActive) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(item['name'] ?? ''),
        actions: [
          CupertinoActionSheetAction(
            child: Text(translate(context, 'forms.edit') ?? 'Edit'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => _selectedSegment == 0
                    ? EditPage(entity: item)
                    : EditInstitutionPage(entity: item),
              ));
            },
          ),
          CupertinoActionSheetAction(
            child: Text(isActive
                ? (translate(context, 'forms.deactivate') ?? 'Deactivate')
                : (translate(context, 'forms.activate') ?? 'Activate')),
            onPressed: () async {
              Navigator.pop(context);
              final token = await Provider.of<AuthService>(context, listen: false).getToken();
              final commerceService = CommerceService();
              final commerceId = item['id'] as int;

              bool success = isActive
                  ? await commerceService.deactivateCommerce(token!, commerceId)
                  : await commerceService.activateCommerce(token!, commerceId);

              if (success) {
                setState(() => item['active'] = !isActive);
              }
            },
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: Text(translate(context, 'forms.delete') ?? 'Delete'),
            onPressed: () {
              Navigator.pop(context);
              print('${translate(context, 'forms.deleting')} ${item['name']}');
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(translate(context, 'forms.cancel') ?? 'Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
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
                final bool isActive = item['active'] ?? true;

                return ListTile(
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
                      Text('${translate(context, 'entity_fields.address') ?? 'Address'}: ${item['address']}'),
                      Text('${translate(context, 'entity_fields.phone') ?? 'Phone'}: ${item['phone']}'),
                    ],
                  ),
                  trailing: Icon(Icons.more_horiz),
                  onTap: () => _showActionsPopup(item, isActive),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoButton.filled(
              onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => _selectedSegment == 0
                    ? CreateCommerceScreen()
                    : CreateInstitutionScreen(),
              )),
              child: Text(_selectedSegment == 0
                  ? translate(context, 'business.createNewBusiness') ?? 'Create new business'
                  : translate(context, 'institution.createNewInstitution') ?? 'Create new institution'),
            ),
          ),
        ],
      ),
    );
  }
}
