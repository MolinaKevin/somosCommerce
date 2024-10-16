import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'tabs/tab_1.dart';
import 'tabs/tab_2.dart';
import 'tabs/tab_3.dart';
import '../helpers/translations_helper.dart';  // Importar el helper de traducciones

class EditPage extends StatefulWidget {
  final Map<String, dynamic> entity;

  EditPage({required this.entity});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int _currentIndex = 0;

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      Tab1(entity: widget.entity),
      Tab2(entity: widget.entity),
      Tab3(entity: widget.entity),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(
            child: _tabs[_currentIndex],
          ),
          CupertinoTabBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.circle),
                label: translate(context, 'tab1') ?? 'Tab 1',  // Modificado
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.list_bullet),
                label: translate(context, 'tab2') ?? 'Tab 2',  // Modificado
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.profile_circled),
                label: translate(context, 'tab3') ?? 'Tab 3',  // Modificado
              ),
            ],
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
