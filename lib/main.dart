import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(MyNewApp());
}

class MyNewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Tabs Demo',
      home: MyNewHomePage(),
    );
  }
}

class MyNewHomePage extends StatefulWidget {
  @override
  _MyNewHomePageState createState() => _MyNewHomePageState();
}

class _MyNewHomePageState extends State<MyNewHomePage> {
  int _currentIndex = 0;

  List<Widget> _tabs = [
    Tab1(),
    Tab2(),
    Tab3(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.circle),
            label: 'Tab 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'Tab 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            label: 'Tab 3',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      tabBuilder: (BuildContext context, int index) {
        return _tabs[_currentIndex];
      },
    );
  }
}


class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  TextEditingController _controller = TextEditingController();
  String? _qrData;
  double? _money;

  void _generateQRCode() {
    double? money = double.tryParse(_controller.text);
    if (money != null) {
      _money = money;
      double points = money * 0.1;
      var data = {
        'dinero': _money,
        'puntos': points,
      };
      String jsonString = jsonEncode(data);
      setState(() {
        _qrData = jsonString;
      });
    } else {
      setState(() {
        _qrData = null;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Tab 1'),
          ),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: CupertinoTextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          placeholder: 'Introduce la cantidad',
                          decoration: BoxDecoration(
                            border: Border.all(style: BorderStyle.none),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('€'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                CupertinoButton.filled(
                  child: Text('Aceptar'),
                  onPressed: _generateQRCode,
                ),
                SizedBox(height: 16),
                if (_qrData != null)
                  Center(
                    child: QrImage(
                      data: _qrData ?? '',
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Tab2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Tab 2'),
          ),
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text('Tarjeta ${index + 1}'),
                  subtitle: Text('Detalle de la tarjeta ${index + 1}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class Tab3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Perfil de prueba'),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nombre: John Doe', style: TextStyle(fontSize: 18)),
                          Text('Usuario: johndoe', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('Biografía', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Vestibulum aliquet sapien ac velit consequat, in egestas libero gravida. '
                        'Curabitur nec ligula ac erat lobortis aliquet id id odio.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
