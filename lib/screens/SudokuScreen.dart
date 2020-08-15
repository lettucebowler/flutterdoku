import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuState.dart';
import 'package:lettuce_sudoku/framework/problem/Problem.dart';
import 'package:lettuce_sudoku/framework/problem/SolvingAssistant.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/helpers.dart';
import 'package:lettuce_sudoku/util/widgets.dart';
import 'package:lettuce_sudoku/util/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class SudokuScreen extends StatefulWidget {
  SudokuScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  var menuHeight = 70;
  SolvingAssistant _assistant;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (globals.problem == null) {
      _newGameAndSave();
    }
    _assistant = SolvingAssistant(globals.problem);
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LettuceSudoku',
          textAlign: TextAlign.center,
          style: CustomStyles.titleText,
        ),
      ),
      drawer: _getDrawer(),
      body: Builder(
        builder: (context) => RawKeyboardListener(
          autofocus: true,
          focusNode: focusNode,
          onKey: (event) {
            if (event.runtimeType == RawKeyDownEvent) {
              var row = globals.selectedRow;
              var col = globals.selectedCol;
              var actionMap = {
                // Move Down
                LogicalKeyboardKey.arrowDown: () => _shiftDown(),
                LogicalKeyboardKey.keyS: () => _shiftDown(),

                // Move Left
                LogicalKeyboardKey.arrowLeft: () => _shiftLeft(),
                LogicalKeyboardKey.keyA: () => _shiftLeft(),

                // Move Right
                LogicalKeyboardKey.arrowRight: () => _shiftRight(),
                LogicalKeyboardKey.keyD: () => _shiftRight(),

                // Move Up
                LogicalKeyboardKey.arrowUp: () => _shiftUp(),
                LogicalKeyboardKey.keyW: () => _shiftUp(),

                // Place 0 / Delete number from cell
                LogicalKeyboardKey.digit0:
                    _getMove(_cellSelected(), 0, row, col),
                LogicalKeyboardKey.numpad0:
                    _getMove(_cellSelected(), 0, row, col),
                LogicalKeyboardKey.keyX: _getMove(_cellSelected(), 0, row, col),
                LogicalKeyboardKey.delete:
                    _getMove(_cellSelected(), 0, row, col),

                // Place 1
                LogicalKeyboardKey.digit1:
                    _getMove(_cellSelected(), 1, row, col),
                LogicalKeyboardKey.numpad1:
                    _getMove(_cellSelected(), 1, row, col),

                // Place 2
                LogicalKeyboardKey.digit2:
                    _getMove(_cellSelected(), 2, row, col),
                LogicalKeyboardKey.numpad2:
                    _getMove(_cellSelected(), 2, row, col),

                // Place 3
                LogicalKeyboardKey.digit3:
                    _getMove(_cellSelected(), 3, row, col),
                LogicalKeyboardKey.numpad3:
                    _getMove(_cellSelected(), 3, row, col),

                // Place 4
                LogicalKeyboardKey.digit4:
                    _getMove(_cellSelected(), 4, row, col),
                LogicalKeyboardKey.numpad4:
                    _getMove(_cellSelected(), 4, row, col),

                // Place 5
                LogicalKeyboardKey.digit5:
                    _getMove(_cellSelected(), 5, row, col),
                LogicalKeyboardKey.numpad5:
                    _getMove(_cellSelected(), 5, row, col),

                // Place 6
                LogicalKeyboardKey.digit6:
                    _getMove(_cellSelected(), 6, row, col),
                LogicalKeyboardKey.numpad6:
                    _getMove(_cellSelected(), 6, row, col),

                // Place 7
                LogicalKeyboardKey.digit7:
                    _getMove(_cellSelected(), 7, row, col),
                LogicalKeyboardKey.numpad7:
                    _getMove(_cellSelected(), 7, row, col),

                // Place 8
                LogicalKeyboardKey.digit8:
                    _getMove(_cellSelected(), 8, row, col),
                LogicalKeyboardKey.numpad8:
                    _getMove(_cellSelected(), 8, row, col),

                // Place 9
                LogicalKeyboardKey.digit9:
                    _getMove(_cellSelected(), 9, row, col),
                LogicalKeyboardKey.numpad9:
                    _getMove(_cellSelected(), 9, row, col),

                // Get Hint
                LogicalKeyboardKey.keyH: () => _giveHint(row, col),

                //Open Drawer
                LogicalKeyboardKey.keyG: () => _toggleDrawer(context)
              };

              Function action = actionMap[event.data.logicalKey];
              if (action != null) {
                action();
                setState(() {});
              }
            }
          },
          child: _getBody(),
        ),
      ),
    );
  }

  void _shiftLeft() {
    globals.selectedCol =
        ((globals.selectedCol - 1) % globals.problem.board_size);
  }

  void _shiftRight() {
    globals.selectedCol =
        ((globals.selectedCol + 1) % globals.problem.board_size);
  }

  void _shiftUp() {
    globals.selectedRow =
        ((globals.selectedRow - 1) % globals.problem.board_size);
  }

  void _shiftDown() {
    globals.selectedRow =
        ((globals.selectedRow + 1) % globals.problem.board_size);
  }

  void _toggleDrawer(BuildContext context) {
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.pop(context);
    } else {
      Scaffold.of(context).openDrawer();
    }
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    final legalityRadio = globals.legalityRadio.value;
    final doPeerCells = globals.doPeerCells.value;
    final doPeerDigits = globals.doPeerDigits.value;
    final doMistakes = globals.doMistakes.value;
    final hints = globals.initialHints.value;
    prefs.setBool('doPeerCells', doPeerCells);
    prefs.setBool('doPeerDigits', doPeerDigits);
    prefs.setBool('doMistakes', doMistakes);
    prefs.setInt('legalityRadio', legalityRadio);
    prefs.setInt('initialHints', hints);
  }

  Widget _getDrawer() {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: [
          DrawerHeader(
            child: Center(
              child: Text(
                'Settings',
                style: CustomStyles.titleText,
              ),
            ),
            decoration: BoxDecoration(
              color: CustomStyles.polarNight[3],
            ),
          ),
          _getToggle('Highlight Peer Cells', globals.doPeerCells),
          _getToggle('Highlight Peer Digits', globals.doPeerDigits),
          _getToggle('Show Mistakes', globals.doMistakes),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                SizeTransition(
              child: child,
              sizeFactor: animation,
            ),
            child: _getMistakeRadioGroup(),
          ),
          _getSliderNoDivisions('Initial Hints', globals.initialHints, 17, 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Spacer(flex: 2),
              Expanded(
                flex: 16,
                child: getFlatButton(
                    'Solve Game',
                    CustomStyles.snowStorm[2],
                    17,
                    TextAlign.center,
                    CustomStyles.polarNight[3],
                    CustomStyles.polarNight[0],
                    () => _solveGame(globals.problem)),
              ),
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 16,
                child: getFlatButton(
                    'Reset Game',
                    CustomStyles.snowStorm[2],
                    17,
                    TextAlign.center,
                    CustomStyles.polarNight[3],
                    CustomStyles.polarNight[0],
                    () => _resetBoard(globals.problem)),
              ),
              Spacer(flex: 2),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(
                flex: 2,
              ),
              Expanded(
                  flex: 33,
                  child: getFlatButton(
                      'New Game',
                      CustomStyles.snowStorm[2],
                      17,
                      TextAlign.center,
                      CustomStyles.polarNight[3],
                      CustomStyles.polarNight[0],
                      () => _newGameAndSave())),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _newGame() {
    setState(() {
      globals.problem =
          SudokuProblem.withMoreHints(globals.initialHints.value - 17);
      _assistant = SolvingAssistant(globals.problem);
      _resetGlobals();
    });
  }

  void _newGameAndSave() {
    _newGame();
    saveGame();
  }

  void _resetGlobals() {
    globals.selectedRow = -1;
    globals.selectedCol = -1;
    globals.hintsGiven.clear();
  }

  void _resetBoard(Problem problem) {
    setState(() {
      problem.setCurrentState(problem.getInitialState());
      _resetGlobals();
    });
  }

  EdgeInsets _getBoardPadding(int index) {
    var row = index ~/ globals.problem.board_size;
    var col = index % globals.problem.board_size;
    var thickness = 2;
    var defaultThickness = 0.5;
    var isTop = row == 0;
    var isLeft = col == 0;
    var isBottom =
        row % globals.problem.cell_size == globals.problem.cell_size - 1;
    var isRight =
        col % globals.problem.cell_size == globals.problem.cell_size - 1;
    var top = isTop ? thickness : defaultThickness;
    var left = isLeft ? thickness : defaultThickness;
    var bottom = isBottom ? thickness : defaultThickness;
    var right = isRight ? thickness : defaultThickness;

    return EdgeInsets.fromLTRB(
        left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
  }

  bool _givenAsHint(int row, int col) {
    bool hint = false;
    for (List pair in globals.hintsGiven) {
      if (pair[0] == row && pair[1] == col) {
        hint = true;
        break;
      }
    }
    return hint;
  }

  void _giveHint(int row, int col) {
    var validRow = row > -1 && row < 10;
    var validCol = col > -1 && col < 10;
    var validCell = validRow && validCol;
    if (!globals.problem.success() && validCell) {
      SudokuState finalState = globals.problem.getFinalState();
      List finalBoard = finalState.getTiles();
      var num = finalBoard[row][col];
      if (!globals.problem.isCorrect(row, col)) {
        _doMove(num, row, col);
        setState(() {
          globals.hintsGiven.add([row, col]);
        });
      }
    }
  }

  void _doMove(int num, int row, int col) {
    // _assistant = SolvingAssistant(globals.problem);
    SudokuState initialState = globals.problem.getInitialState();
    var initialBoard = initialState.getTiles();
    var notInitialHint = initialBoard[row][col] == 0;
    if (!globals.problem.success() && notInitialHint) {
      var move = 'Place ' +
          num.toString() +
          ' at ' +
          row.toString() +
          ' ' +
          col.toString();
      _assistant.tryMove(move);
      saveGame();
    }
  }

  void _solveGame(SudokuProblem problem) {
    int boardSize = problem.board_size;
    for (var i = 0; i < boardSize; i++) {
      for (var j = 0; j < boardSize; j++) {
        _giveHint(i, j);
      }
    }
    setState(() {});
  }

  bool _cellSelected() {
    return globals.selectedRow != -1 && globals.selectedCol != -1;
  }

  Color _getCellColor(int row, int col) {
    Color peerCell = CustomStyles.frost[1];
    Color background = CustomStyles.snowStorm[2];
    Color peerDigit = CustomStyles.frost[2];
    Color success = CustomStyles.aurora[3];
    Color color = background;

    bool rowSelected = row == globals.selectedRow;
    bool colSelected = col == globals.selectedCol;
    bool floorSelected = row ~/ globals.problem.cell_size ==
        globals.selectedRow ~/ globals.problem.cell_size;
    bool towerSelected = col ~/ globals.problem.cell_size ==
        globals.selectedCol ~/ globals.problem.cell_size;
    bool cells = globals.doPeerCells.value;
    bool digits = globals.doPeerDigits.value;
    SudokuState currentState = globals.problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    bool sameDigit = _cellSelected() &&
        currentBoard[row][col] ==
            currentBoard[globals.selectedRow][globals.selectedCol];
    bool nonZero = _cellSelected() && currentBoard[row][col] != 0;

    color = rowSelected && colSelected ? peerDigit : color;
    color = cells &&
            _cellSelected() &&
            (rowSelected || colSelected || (floorSelected && towerSelected))
        ? peerCell
        : color;
    color = digits &&
            _cellSelected() &&
            ((sameDigit && nonZero) ||
                (sameDigit && rowSelected && colSelected))
        ? peerDigit
        : color;
    color = cells && rowSelected && colSelected ? background : color;
    color = globals.problem.success() ? success : color;

    return color;
  }

  Widget _makeBoardButton(int index) {
    var row = index ~/ globals.problem.board_size;
    var col = index % globals.problem.board_size;
    SudokuState currentState = globals.problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    var cellNum = currentBoard[row][col];
    String toPlace = cellNum == 0 ? '' : cellNum.toString();

    Color cellColor = _getCellColor(row, col);
    return Container(
      padding: _getBoardPadding(index),
      child: Material(
        color: cellColor,
        child: InkWell(
          hoverColor: CustomStyles.aurora[2],
          splashColor: CustomStyles.aurora[1],
          onTap: () => setState(() {
            globals.selectedRow = row;
            globals.selectedCol = col;
          }),
          child: Center(
            child: AutoSizeText(
              toPlace,
              textAlign: TextAlign.center,
              maxLines: 1,
              stepGranularity: 1,
              minFontSize: 1,
              maxFontSize: 40,
              style: TextStyle(
                color: _getTextColor(row, col),
                fontSize: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getMistakeRadioGroup() {
    return globals.doMistakes.value
        ? Column(
            children: [
              _getRadio('Correctness', 0, globals.legalityRadio,
                  globals.legalityRadio),
              _getRadio(
                  'Legality', 1, globals.legalityRadio, globals.legalityRadio),
            ],
          )
        : Container();
  }

  Widget _getRadio(String label, int value, var groupValue, var setting) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label),
        Radio(
          activeColor: CustomStyles.polarNight[3],
          value: value,
          groupValue: groupValue.value,
          onChanged: (val) {
            _save();
            setState(() {
              groupValue.value = value;
            });
          },
        ),
      ],
    );
  }

  Widget _getToggle(String label, globals.BoolWrapper setting) {
    return Row(
      children: [
        Spacer(
          flex: 2,
        ),
        Expanded(
          flex: 35,
          child: Row(
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
                  onChanged: (bool val) {
                    _save();
                    setState(() {
                      setting.value = val;
                    });
                  },
                  activeColor: CustomStyles.polarNight[3],
                  inactiveThumbColor: CustomStyles.polarNight[3],
                  activeTrackColor: CustomStyles.aurora[3],
                  inactiveTrackColor: CustomStyles.aurora[0],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getSliderNoDivisions(
      String label, globals.IntWrapper setting, double min, double max) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Spacer(flex: 2),
            Expanded(
              flex: 35,
              child: Text(
                label,
                style: TextStyle(
                  color: CustomStyles.polarNight[3],
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: setting.value.toDouble(),
                onChanged: (val) {
                  _save();
                  setState(() {
                    setting.value = val.toInt();
                  });
                },
                min: min,
                max: max,
              ),
            ),
            IconButton(
                icon: Icon(Icons.remove, color: CustomStyles.polarNight[3]),
                onPressed: () {
                  if (setting.value > min) {
                    setting.value--;
                    _save();
                    setState(() {});
                  }
                }),
            Text(setting.value.toString()),
            IconButton(
                icon: Icon(Icons.add, color: CustomStyles.polarNight[3]),
                onPressed: () {
                  if (setting.value < max) {
                    setting.value++;
                    _save();
                    setState(() {});
                  }
                }),
          ],
        ),
      ],
    );
  }

  Widget _getBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: CustomStyles.polarNight[3],
        child: GridView.count(
            crossAxisCount: globals.problem.board_size,
            childAspectRatio: 1,
            children: List.generate(
                globals.problem.board_size * globals.problem.board_size,
                (index) {
              return _makeBoardButton(index);
            })),
      ),
    );
  }

  Widget _getMoveButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            children: List.generate(2, (rowIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (colIndex) {
                  int offset = rowIndex * 5;
                  int num = (colIndex + 1 + offset) %
                      (globals.problem.board_size + 1);
                  String toPlace = num == 0 ? 'X' : (num).toString();
                  return Flexible(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: _getMovePadding(rowIndex, colIndex),
                        child: getFlatButton(
                          toPlace,
                          CustomStyles.snowStorm[2],
                          36,
                          TextAlign.center,
                          CustomStyles.polarNight[3],
                          CustomStyles.polarNight[0],
                          _getMove(_cellSelected(), num, globals.selectedRow,
                              globals.selectedCol),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  EdgeInsets _getMovePadding(int row, int col) {
    double left = 0;
    double top = 4;
    double right = 0;
    double bottom = 0;

    left = col % 5 != 0 ? 4 : 0;
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  Function _getMove(bool selected, int num, int row, int col) {
    return selected
        ? () => setState(() {
              _doMove(num, globals.selectedRow, globals.selectedCol);
            })
        : () => setState(() {});
  }

  Color _getTextColor(int row, int col) {
    SudokuState initialState = globals.problem.getInitialState();
    var initialBoard = initialState.getTiles();
    var initialHint = initialBoard[row][col] != 0;
    var legal = globals.problem.isLegal(row, col);
    var correct = globals.problem.isCorrect(row, col);
    var doLegality = globals.legalityRadio.value == 1;
    Color color = CustomStyles.frost[3];

    color = globals.doMistakes.value && doLegality && !legal
        ? CustomStyles.aurora[0]
        : color;
    color = globals.doMistakes.value && !doLegality && !correct
        ? CustomStyles.aurora[0]
        : color;
    color = initialHint ? CustomStyles.polarNight[3] : color;
    color = _givenAsHint(row, col) ? CustomStyles.aurora[4] : color;
    return color;
  }

  Widget _getGameButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              // color: Colors.blue,
              padding: EdgeInsets.fromLTRB(0, 4, 2, 0),
              child: getFlatButton(
                'New Game',
                CustomStyles.snowStorm[2],
                24,
                TextAlign.center,
                CustomStyles.polarNight[3],
                CustomStyles.polarNight[0],
                () => _newGameAndSave(),
              ),
            ),
          ),
        ),
        // Container(width: 4),
        Flexible(
          fit: FlexFit.tight,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              // color: Colors.green,
              padding: EdgeInsets.fromLTRB(2, 4, 0, 0),
              child: getFlatButton(
                'Get Hint',
                CustomStyles.snowStorm[2],
                24,
                TextAlign.center,
                CustomStyles.polarNight[3],
                CustomStyles.polarNight[0],
                () => _giveHint(globals.selectedRow, globals.selectedCol),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getBody() {
    return Container(
      padding: EdgeInsets.all(globals.bodySpacing),
      child: _makeBodyRow(),
    );
  }

  Widget _makeGameCol(bool doVertical) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(flex: 15, child: Container(child: _getBoard())),
        Flexible(
          flex: 6,
          child: AspectRatio(
              aspectRatio: 5 / 2, child: Container(child: _getMoveButtons())),
        ),
        Flexible(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 15 / 2,
            child: Container(
              child: _getGameButtons(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _makeBodyRow() {
    return Row(
      // direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Container()),
        Container(
          width: getBodyWidth(context),
          child: _makeGameCol(true),
          // width: _getBodyWidth(),
        ),
        Flexible(child: Container()),
      ],
    );
  }
}
