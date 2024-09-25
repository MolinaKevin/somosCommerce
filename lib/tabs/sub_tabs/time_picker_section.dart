import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePickerSection extends StatelessWidget {
  final TimeOfDay? openingTime;
  final TimeOfDay? closingTime;
  final Function(TimeOfDay) onSelectOpeningTime;
  final Function(TimeOfDay) onSelectClosingTime;

  TimePickerSection({
    required this.openingTime,
    required this.closingTime,
    required this.onSelectOpeningTime,
    required this.onSelectClosingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              openingTime != null
                  ? 'Apertura: ${openingTime!.format(context)}'
                  : 'Selecciona hora de apertura',
            ),
            CupertinoButton(
              child: Text('Elegir'),
              onPressed: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: openingTime ?? TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  onSelectOpeningTime(pickedTime);
                }
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              closingTime != null
                  ? 'Cierre: ${closingTime!.format(context)}'
                  : 'Selecciona hora de cierre',
            ),
            CupertinoButton(
              child: Text('Elegir'),
              onPressed: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: closingTime ?? TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  onSelectClosingTime(pickedTime);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
