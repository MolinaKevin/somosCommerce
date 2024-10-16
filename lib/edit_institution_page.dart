import 'package:flutter/cupertino.dart';
import 'tabs/tab_institution_1.dart';
import 'tabs/tab_institution_2.dart';
import 'tabs/tab_institution_3.dart';
import '../helpers/translations_helper.dart'; // Importar el helper de traducciones

class EditInstitutionPage extends StatefulWidget {
  final Map<String, dynamic> entity;

  EditInstitutionPage({required this.entity});

  @override
  _EditInstitutionPageState createState() => _EditInstitutionPageState();
}

class _EditInstitutionPageState extends State<EditInstitutionPage> {
  int _currentIndex = 0;

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    // Inicializa las tabs con la entidad a editar
    _tabs = [
      TabInstitution1(entity: widget.entity),
      TabInstitution2(entity: widget.entity),
      TabInstitution3(entity: widget.entity),
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
