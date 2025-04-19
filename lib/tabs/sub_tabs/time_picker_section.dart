import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../helpers/translations_helper.dart';

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
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                openingTime != null
                    ? '${translate(context, 'time.openingTime') ?? 'Opening Time'}: ${openingTime!.format(context)}'
                    : translate(context, 'time.selectOpeningTime') ?? 'Select Opening Time',
                style: textStyle,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                translate(context, 'time.choose') ?? 'Choose',
                style: TextStyle(fontSize: 14, color: Colors.indigo),
              ),
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
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                closingTime != null
                    ? '${translate(context, 'time.closingTime') ?? 'Closing Time'}: ${closingTime!.format(context)}'
                    : translate(context, 'time.selectClosingTime') ?? 'Select Closing Time',
                style: textStyle,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                translate(context, 'time.choose') ?? 'Choose',
                style: TextStyle(fontSize: 14, color: Colors.indigo),
              ),
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
