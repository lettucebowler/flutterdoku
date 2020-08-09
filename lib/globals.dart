import 'package:flutter/material.dart';

BoolWrapper doLegality = BoolWrapper(false);
BoolWrapper doPeerCells = BoolWrapper(true);
BoolWrapper doPeerDigits = BoolWrapper(true);
BoolWrapper doMistakes = BoolWrapper(true);
IntWrapper maxHints = IntWrapper(5);
IntWrapper initialHints = IntWrapper(30);
IntWrapper legalityRadio = IntWrapper(0);
int selectedRow = -1;
int selectedCol = -1;
bool keySelected = false;
List hintsGiven = [];

class BoolWrapper {
  bool value;
  BoolWrapper(bool value) {
    this.value = value;
  }
}

class IntWrapper {
  int value;
  IntWrapper(int value) {
    this.value = value;
  }
}

Widget mistakesWidget;
