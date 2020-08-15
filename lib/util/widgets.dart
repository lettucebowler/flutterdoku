import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
