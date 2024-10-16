import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helpers/translations_helper.dart'; // Importar el helper de traducciones

class Tab1 extends StatelessWidget {
  final Map<String, dynamic> entity;

  Tab1({required this.entity});

  void _showNfcPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate(context, 'nfcTransaction') ?? 'Transacción NFC'),  // Modificado
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text(translate(context, 'waitingForDevice') ?? 'Esperando dispositivo...')),  // Modificado
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translate(context, 'cancel') ?? 'Cancelar'),  // Modificado
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
          title: Text(translate(context, 'qrTransaction') ?? 'Transacción por QR'),  // Modificado
          content: Text(translate(context, 'notAvailable') ?? 'Actualmente no está disponible.'),  // Modificado
          actions: <Widget>[
            TextButton(
              child: Text(translate(context, 'ok') ?? 'OK'),  // Modificado
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
        middle: Text(translate(context, 'tab1') ?? 'Tab 1'),  // Modificado
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${translate(context, 'currentPoints') ?? 'Puntos actuales'}: ${entity['points'] ?? 0}',  // Modificado
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40), // Espacio entre el texto y los botones
            CupertinoButton.filled(
              child: Text(translate(context, 'nfcTransaction') ?? 'Transacción NFC'),  // Modificado
              onPressed: () => _showNfcPopup(context),
            ),
            SizedBox(height: 20),
            CupertinoButton.filled(
              child: Text(translate(context, 'qrTransaction') ?? 'Transacción por QR'),  // Modificado
              onPressed: () => _showQrUnavailablePopup(context),
            ),
          ],
        ),
      ),
    );
  }
}
