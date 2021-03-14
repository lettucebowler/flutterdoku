import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';

class LettuceRadio extends StatelessWidget {
  const LettuceRadio({
    required this.label,
    required this.padding,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final int groupValue;
  final int value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          if (value != groupValue) onChanged(value);
        },
        child: Row(
          children: <Widget>[
            Radio<int>(
              groupValue: groupValue,
              value: value,
              onChanged: (int? newValue) => onChanged(newValue),
            ),
            Padding(padding: padding),
            Text(
              label,
              style: TextStyle(
                color: CustomStyles.nord3,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
