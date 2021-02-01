import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';

class LettuceIconButton extends StatelessWidget {
  const LettuceIconButton({
    this.icon,
    this.iconColor,
    this.textAlign,
    this.buttonColor,
    this.iconSize,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color buttonColor;
  final double iconSize;
  final TextAlign textAlign;
  final Color splashColor;
  final Color highlightColor;
  final Color hoverColor;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: buttonColor,
      onPressed: onTap,
      splashColor: splashColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}

class LettuceBoardButton extends StatelessWidget {
  const LettuceBoardButton({
    this.label,
    this.textColor,
    this.textAlign,
    this.buttonColor,
    this.textSize,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.onTap,
  });

  final String label;
  final Color textColor;
  final Color buttonColor;
  final double textSize;
  final TextAlign textAlign;
  final Color splashColor;
  final Color highlightColor;
  final Color hoverColor;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: buttonColor,
      onPressed: onTap,
      splashColor: splashColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Center(
        child: AutoSizeText(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          stepGranularity: 1,
          minFontSize: 1,
          maxFontSize: textSize,
          style: TextStyle(
            color: textColor,
            fontSize: textSize,
          ),
        ),
      ),
    );
  }
}

class LettuceButton extends StatelessWidget {
  const LettuceButton({
    this.label,
    this.textColor,
    this.textAlign,
    this.buttonColor,
    this.textSize,
    this.splashColor,
    this.highlightColor,
    this.hoverColor,
    this.onTap,
  });

  final String label;
  final Color textColor;
  final Color buttonColor;
  final double textSize;
  final TextAlign textAlign;
  final Color splashColor;
  final Color highlightColor;
  final Color hoverColor;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: buttonColor,
      onPressed: onTap,
      splashColor: splashColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            color: textColor,
            fontSize: textSize,
          ),
        ),
      ),
    );
  }
}

class LettuceRadio extends StatelessWidget {
  const LettuceRadio({
    this.label,
    this.padding,
    this.groupValue,
    this.value,
    this.onChanged,
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
              onChanged: (int newValue) {
                onChanged(newValue);
              },
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
