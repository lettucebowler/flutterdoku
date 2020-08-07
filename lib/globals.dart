BoolWrapper doLegality = BoolWrapper(false);
BoolWrapper doPeerCells = BoolWrapper(true);
BoolWrapper doPeerDigits = BoolWrapper(true);
IntWrapper maxHints = IntWrapper(5);
IntWrapper hintOffset = IntWrapper(13);
int selectedRow = -1;
int selectedCol = -1;
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

