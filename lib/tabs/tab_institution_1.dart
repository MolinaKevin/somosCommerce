import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabInstitution1 extends StatelessWidget {
  final Map<String, dynamic> entity;

  TabInstitution1({required this.entity});

  void _showNfcPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Transacción Institution NFC'),
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Esperando dispositivo...')),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
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
          title: Text('Transacción aass por QR'),
          content: Text('Actualmente no está disponible.'),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Tab 1'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Puntos actuales: ${entity['points'] ?? 0}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40), // Espacio entre el texto y los botones
            CupertinoButton.filled(
              child: Text('Transacción Insti NFC'),
              onPressed: () => _showNfcPopup(context),
            ),
            SizedBox(height: 20),
            CupertinoButton.filled(
              child: Text('Transacción Insti por QR'),
              onPressed: () => _showQrUnavailablePopup(context),
            ),
          ],
        ),
      ),
    );
  }
}
