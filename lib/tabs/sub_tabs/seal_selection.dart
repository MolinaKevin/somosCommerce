import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SealSelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> sealsWithState;
  final Function(List<Map<String, dynamic>> updatedSeals) onSealStateChanged;

  SealSelectionWidget({
    required this.sealsWithState,
    required this.onSealStateChanged,
  });

  @override
  _SealSelectionWidgetState createState() => _SealSelectionWidgetState();
}

class _SealSelectionWidgetState extends State<SealSelectionWidget> {
  late List<Map<String, dynamic>> _seals;

  final List<String> states = ['none', 'partial', 'full'];
  final List<String> stateLabels = ['Nada', 'Algo', 'Todo'];

  @override
  void initState() {
    super.initState();
    _seals = widget.sealsWithState.map((seal) {
      if (seal['state'] == null || !states.contains(seal['state'])) {
        seal['state'] = 'none';
      }
      return seal;
    }).toList();
  }

  void _updateSealState(Map<String, dynamic> seal, int newStateIndex) {
    setState(() {
      seal['state'] = states[newStateIndex];
      widget.onSealStateChanged(_seals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 150),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 136.0),
                      child: Text(stateLabels[0]),
                    ),
                    Text(stateLabels[1]),
                    Padding(
                      padding: const EdgeInsets.only(right: 56.0),
                      child: Text(stateLabels[2]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: _seals.map((seal) {
              int currentIndex = states.indexOf(seal['state']);
              if (currentIndex == -1) currentIndex = 0;

              String? imagePath = seal['image'] as String?;
              if (imagePath == null) {
                imagePath = 'seals/default/::STATE::.svg';
              }

              imagePath = imagePath.replaceAll('::STATE::', seal['state']);
              final imageUrl = 'http://localhost/storage/$imagePath';

              print('URL de la imagen del sello: $imageUrl');

              return Column(
                children: [
                  ListTile(
                    leading: SvgPicture.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      placeholderBuilder: (context) => CircularProgressIndicator(),
                      excludeFromSemantics: true,
                    ),
                    trailing: SizedBox(
                      width: 350,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 10.0,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 16.0),
                        ),
                        child: Slider(
                          value: currentIndex.toDouble(),
                          min: 0,
                          max: (states.length - 1).toDouble(),
                          divisions: states.length - 1,
                          onChanged: (value) {
                            _updateSealState(seal, value.toInt());
                          },
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
