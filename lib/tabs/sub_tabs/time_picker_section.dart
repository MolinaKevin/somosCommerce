import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../helpers/translations_helper.dart'; // Importa el helper de traducción

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
                  ? '${translate(context, 'openingTime') ?? 'Apertura'}: ${openingTime!.format(context)}'
                  : translate(context, 'selectOpeningTime') ?? 'Selecciona hora de apertura',
            ),
            CupertinoButton(
              child: Text(translate(context, 'choose') ?? 'Elegir'),
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
                  ? '${translate(context, 'closingTime') ?? 'Cierre'}: ${closingTime!.format(context)}'
                  : translate(context, 'selectClosingTime') ?? 'Selecciona hora de cierre',
            ),
            CupertinoButton(
              child: Text(translate(context, 'choose') ?? 'Elegir'),
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
