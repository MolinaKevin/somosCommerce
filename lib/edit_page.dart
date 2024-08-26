import 'package:flutter/cupertino.dart';
import 'tabs/tab_1.dart';
import 'tabs/tab_2.dart';
import 'tabs/tab_3.dart';

class EditPage extends StatefulWidget {
  final Map<String, dynamic> entity;

  EditPage({required this.entity});  // Constructor que acepta un entity

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int _currentIndex = 0;

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    // Inicializa las tabs con la entidad a editar
    _tabs = [
      Tab1(entity: widget.entity),
      Tab2(entity: widget.entity),
      Tab3(entity: widget.entity),
    ];
  }

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
        return CupertinoTabView(
          builder: (BuildContext context) {
            return _tabs[index];
          },
        );
      },
    );
  }
}
