import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/commerce_service.dart';
import '../edit_page.dart';
import '../edit_institution_page.dart';
import '../helpers/translations_helper.dart';
import '../screens/entity_preview_screen.dart';

void showEntityActionsPopup({
  required BuildContext context,
  required Map<String, dynamic> item,
  required bool isBusiness,
  required VoidCallback refresh,
}) {
  final authService = Provider.of<AuthService>(context, listen: false);
  final commerceService = CommerceService();
  final isActive = item['active'] ?? true;

  showCupertinoModalPopup(
    context: context,
    builder: (_) => CupertinoActionSheet(
      title: Text(item['name'] ?? ''),
      actions: [
        CupertinoActionSheetAction(
          child: Text('Vorschau'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => EntityPreviewScreen(entity: item),
              ),
            );
          },
        ),
        CupertinoActionSheetAction(
          child: Text(translate(context, 'forms.edit') ?? 'Edit'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => isBusiness
                    ? EditPage(entity: item)
                    : EditInstitutionPage(entity: item),
              ),
            );
          },
        ),
        CupertinoActionSheetAction(
          child: Text(isActive
              ? translate(context, 'forms.deactivate') ?? 'Deactivate'
              : translate(context, 'forms.activate') ?? 'Activate'),
          onPressed: () async {
            Navigator.pop(context);
            final token = await authService.getToken();
            final commerceId = item['id'] as int;

            if (!(item['accepted'] ?? true)) {
              showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: Text(translate(context, 'entity.notAccepted') ?? 'Not accepted'),
                  content: Text(
                    '${translate(context, 'entity.theBusiness') ?? 'The business'} ${item['name']} ${translate(context, 'entity.isNotAccepted') ?? 'is not yet accepted, please wait.'}',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
              return;
            }

            bool success = isActive
                ? await commerceService.deactivateCommerce(token!, commerceId)
                : await commerceService.activateCommerce(token!, commerceId);

            if (success) {
              item['active'] = !isActive;
              refresh();
            } else {
              showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: Text('Error'),
                  content: Text(
                    '${translate(context, 'errors.problem') ?? 'There was a problem'} ${isActive ? translate(context, 'forms.deactivating') : translate(context, 'forms.activating')} ${translate(context, 'entity.theBusiness')}',
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
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
