import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helpers/translations_helper.dart';

class Tab1 extends StatelessWidget {
  final Map<String, dynamic> entity;

  Tab1({required this.entity});

  void _showNfcPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate(context, 'transactions.nfcTransaction') ?? 'NFC Transaction'),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text(translate(context, 'transactions.waitingForDevice') ?? 'Waiting for device...')),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translate(context, 'forms.cancel') ?? 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showQrUnavailablePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate(context, 'transactions.qrTransaction') ?? 'QR Transaction'),
          content: Text(translate(context, 'transactions.notAvailable') ?? 'Currently unavailable.'),
          actions: <Widget>[
            TextButton(
              child: Text(translate(context, 'forms.ok') ?? 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(translate(context, 'tabs.tab1') ?? 'Tab 1'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${translate(context, 'points.currentPoints') ?? 'Current Points'}: ${entity['points'] ?? 0}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            CupertinoButton.filled(
              child: Text(translate(context, 'transactions.nfcTransaction') ?? 'NFC Transaction'),
              onPressed: () => _showNfcPopup(context),
            ),
            SizedBox(height: 20),
            CupertinoButton.filled(
              child: Text(translate(context, 'transactions.qrTransaction') ?? 'QR Transaction'),
              onPressed: () => _showQrUnavailablePopup(context),
            ),
          ],
        ),
      ),
    );
  }
}
