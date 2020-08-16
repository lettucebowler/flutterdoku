import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/globals.dart';

Widget getFlatButton(
    String label,
    Color textColor,
    double textSize,
    TextAlign textAlign,
    Color buttonColor,
    Color splashColor,
    Function function) {
  return FlatButton(
    color: buttonColor,
    splashColor: splashColor,
    onPressed: function,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
    child: AutoSizeText(
      label,
      textAlign: textAlign,
      maxLines: 1,
      style: TextStyle(
        color: textColor,
        fontSize: textSize,
      ),
    ),
  );
}

Widget getStyledToggleRow(
    String label, VariableWrapper setting, Function onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        child: Text(
          label,
          style: TextStyle(
            color: CustomStyles.polarNight[3],
            fontSize: 17,
          ),
          textAlign: TextAlign.left,
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Switch(
          value: setting.value,
          onChanged: onChanged,
          activeColor: CustomStyles.polarNight[3],
          inactiveThumbColor: CustomStyles.polarNight[3],
          activeTrackColor: CustomStyles.aurora[3],
          inactiveTrackColor: CustomStyles.aurora[0],
        ),
      ),
    ],
  );
}

Widget getStyledSliderRow(VariableWrapper setting, double min, double max,
    Function onChange, Function decrease, Function increase) {
  return Row(
    children: [
      Expanded(
        child: Slider(
          value: setting.value.toDouble(),
          onChanged: onChange,
          min: min,
          max: max,
        ),
      ),
      IconButton(
        icon: Icon(Icons.remove, color: CustomStyles.polarNight[3]),
        onPressed: decrease,
      ),
      Text(setting.value.toString()),
      IconButton(
        icon: Icon(Icons.add, color: CustomStyles.polarNight[3]),
        onPressed: increase,
      ),
    ],
  );
}

Widget getStyledRadio(
    String label, int value, var groupValue, Function onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(label),
      Radio(
        activeColor: CustomStyles.polarNight[3],
        value: value,
        groupValue: groupValue.value,
        onChanged: onChanged,
      ),
    ],
  );
}

Widget getWidgetGroup(List radioList) {
  return Align(
    alignment: Alignment.centerRight,
    child: Column(
      children: radioList,
    ),
  );
}
