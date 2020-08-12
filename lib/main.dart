//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_sudoku/widgets.dart';
import 'CustomStyles.dart';
import 'domains/sudoku/SudokuProblem.dart';
import 'domains/sudoku/SudokuState.dart';
import 'framework/problem/Problem.dart';
import 'globals.dart' as globals;
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'framework/problem/SolvingAssistant.dart';
import 'widgets.dart' as widgets;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _readFromPrefs();
  // bool problemGood = await _getGame();
  runApp(MyApp());
}

Future<bool> _readFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  // final legality = prefs.getBool('doLegality');
  final peerCells = prefs.getBool('doPeerCells');
  final peerDigits = prefs.getBool('doPeerDigits');
  final mistakes = prefs.getBool('doMistakes');
  final hints = prefs.getInt('initialHints');
  final legality = prefs.getInt('legalityRadio');
  // globals.doLegality.value = legality != null ? legality : false;
  globals.doPeerCells.value = peerCells != null ? peerCells : true;
  globals.doPeerDigits.value = peerDigits != null ? peerDigits : true;
  globals.doMistakes.value = mistakes != null ? mistakes : true;
  globals.initialHints.value = hints != null ? hints : 30;
  globals.legalityRadio.value = legality == 1 || legality == 0 ? legality : 0;
  return true;
}

// _getGame() async {
//   final prefs = await SharedPreferences.getInstance();
//   final initialString = prefs.getString('initialBoard');
//   final currentString = prefs.getString('currentBoard');
//   final finalString = prefs.getString('finalBoard');
//   List initialBoard = List.generate(9, (i) => List(9), growable: false);
//   List currentBoard = List.generate(9, (i) => List(9), growable: false);
//   List finalBoard = List.generate(9, (i) => List(9), growable: false);
//   if (initialString != null && currentString != null && finalString != null) {
//     for (int i = 0; i < initialString.length; i++) {
//       initialBoard[i ~/ 9][i % 9] = int.parse(initialString[i]);
//       currentBoard[i ~/ 9][i % 9] = int.parse(currentString[i]);
//       finalBoard[i ~/ 9][i % 9] = int.parse(finalString[i]);
//     }
//     globals.problem =
//         SudokuProblem.resume(initialBoard, currentBoard, finalBoard);
//   } else {
//     globals.problem =
//         SudokuProblem.withMoreHints(globals.initialHints.value - 17);
//   }
// }

// _saveGame() async {
//   final prefs = await SharedPreferences.getInstance();
//   String initialString = "";
//   String currentString = "";
//   String finalString = "";
//   SudokuState initialState = globals.problem.getInitialState();
//   List initialBoard = initialState.getTiles();
//   SudokuState currentState = globals.problem.getCurrentState();
//   List currentBoard = currentState.getTiles();
//   SudokuState finalState = globals.problem.getFinalState();
//   List finalBoard = finalState.getTiles();
//   for (int i = 0; i < globals.problem.board_size; i++) {
//     for (int j = 0; j < globals.problem.board_size; j++) {
//       initialString += initialBoard[i][j].toString();
//       currentString += currentBoard[i][j].toString();
//       finalString += finalBoard[i][j].toString();
//     }
//   }
//   prefs.setString('initialBoard', initialString);
//   prefs.setString('currentBoard', currentString);
//   prefs.setString('finalBoard', finalString);
// }

// _deleteGame() async {
//   final prefs = await SharedPreferences.getInstance();
//   prefs.remove('initialBoard');
//   prefs.remove('currentBoard');
//   prefs.remove('finalBoard');
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LettuceSudoku',
      theme: ThemeData(
        primarySwatch: CustomStyles.themeColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: CustomStyles.snowStorm[2],
      ),
      home: MyHomePage(title: 'LettuceSudoku'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // SudokuProblem _problem =
  //     SudokuProblem.withMoreHints(globals.initialHints.value - 17);
  var menuHeight = 70;
  SolvingAssistant _assistant;
  FocusNode focusNode = FocusNode();
  double _bodySpacing = 4;

  @override
  Widget build(BuildContext context) {
    if (globals.problem == null) {
      _newGame();
    }

    // final GlobalKey _scaffoldKey = new GlobalKey();

    FocusScope.of(context).requestFocus(focusNode);
    return Scaffold(
      // key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'LettuceSudoku',
          textAlign: TextAlign.center,
          style: CustomStyles.titleText,
        ),
      ),
      drawer: _getDrawer(context),
      body: RawKeyboardListener(
        autofocus: true,
        focusNode: focusNode,
        onKey: (event) {
          if (event.runtimeType == RawKeyDownEvent) {
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

              // Place 0
              LogicalKeyboardKey.digit0: () =>
                  _doMove(0, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad0: () =>
                  _doMove(0, globals.selectedRow, globals.selectedCol),

              // Place 1
              LogicalKeyboardKey.digit1: () =>
                  _doMove(1, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad1: () =>
                  _doMove(1, globals.selectedRow, globals.selectedCol),

              // Place 2
              LogicalKeyboardKey.digit2: () =>
                  _doMove(2, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad2: () =>
                  _doMove(2, globals.selectedRow, globals.selectedCol),

              // Place 3
              LogicalKeyboardKey.digit3: () =>
                  _doMove(3, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad3: () =>
                  _doMove(3, globals.selectedRow, globals.selectedCol),

              // Place 4
              LogicalKeyboardKey.digit4: () =>
                  _doMove(4, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad4: () =>
                  _doMove(4, globals.selectedRow, globals.selectedCol),

              // Place 5
              LogicalKeyboardKey.digit5: () =>
                  _doMove(5, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad5: () =>
                  _doMove(5, globals.selectedRow, globals.selectedCol),

              // Place 6
              LogicalKeyboardKey.digit6: () =>
                  _doMove(6, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad6: () =>
                  _doMove(6, globals.selectedRow, globals.selectedCol),

              // Place 7
              LogicalKeyboardKey.digit7: () =>
                  _doMove(7, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad7: () =>
                  _doMove(7, globals.selectedRow, globals.selectedCol),

              // Place 8
              LogicalKeyboardKey.digit8: () =>
                  _doMove(8, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad8: () =>
                  _doMove(8, globals.selectedRow, globals.selectedCol),

              // Place 9
              LogicalKeyboardKey.digit9: () =>
                  _doMove(9, globals.selectedRow, globals.selectedCol),
              LogicalKeyboardKey.numpad9: () =>
                  _doMove(9, globals.selectedRow, globals.selectedCol),
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

  Widget _getDrawer(BuildContext context) {
    _readFromPrefs();
    return Drawer(
      child: ListView(
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
          _getSliderNoDivisions('Givens', globals.initialHints, 17, 50),
          Row(
            // direction: Axis.horizontal,
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
                      () => _newGame())),
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
      _resetGlobals();
    });
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
    int row = index ~/ globals.problem.board_size;
    int col = index % globals.problem.board_size;

    double thickness = 2;
    double defaultThickness = 0.5;
    double right = defaultThickness;
    double top = defaultThickness;
    double left = defaultThickness;
    double bottom = defaultThickness;

    if (row == 0) {
      top = thickness;
    }
    if (col == 0) {
      left = thickness;
    }
    if (row % globals.problem.cell_size == globals.problem.cell_size - 1) {
      bottom = thickness;
    }
    if (col % globals.problem.cell_size == globals.problem.cell_size - 1) {
      right = thickness;
    }

    return EdgeInsets.fromLTRB(
        left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
  }

  bool _givenAsHint(int row, int col) {
    bool hint = false;
    for (List pair in globals.hintsGiven) {
      if (pair[0] == row && pair[1] == col) {
        hint = true;
      }
    }
    return hint;
  }

  void _giveHint(int row, int col) {
    var validRow = row > -1 && row < 10;
    var validCol = col > -1 && col < 10;
    var validCell = validRow && validCol;
    if (!globals.problem.success() && validCell) {
      // SudokuState currentState = _problem.getCurrentState();
      // List currentBoard = currentState.getTiles();
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
    _assistant = SolvingAssistant(globals.problem);
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
    Container cell = Container(
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
    // Material cell =
    // return button;
    return cell;
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
                // color: Colors.red,
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
                // color: Colors.blue,
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
        // Spacer(
        //   flex: 1,
        // ),
      ],
    );
  }

  Widget _getSliderNoDivisions(
      String label, globals.IntWrapper setting, double min, double max) {
    return Row(
      children: [
        Spacer(flex: 2),
        Expanded(
          flex: 33,
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: CustomStyles.polarNight[3],
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
              // Spacer(),
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
              // Spacer(),
              Text(setting.value.toString()),
            ],
          ),
        ),
        Spacer(flex: 2),
      ],
    );
  }

  Widget _getBoard() {
    AspectRatio board = AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: CustomStyles.polarNight[3],
        child: GridView.count(
//            padding: EdgeInsets.all(1),
            crossAxisCount: globals.problem.board_size,
            childAspectRatio: 1,
            children: List.generate(
                globals.problem.board_size * globals.problem.board_size,
                (index) {
              return _makeBoardButton(index);
            })),
      ),
    );
    return board;
  }

  Widget _getMoveButtons() {
    return Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(3, (index) {
          int offset = index ~/ 2 * 5;
          return index % 2 == 0
              ? Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(9, (index) {
                    int num = (index ~/ 2 + 1 + offset) %
                        (globals.problem.board_size + 1);
                    String toPlace = num == 0 ? 'X' : (num).toString();
                    return index % 2 == 0
                        ? Flexible(
                            fit: FlexFit.tight,
                            flex: 8,
                            child: getFlatButton(
                                toPlace,
                                CustomStyles.snowStorm[2],
                                36,
                                TextAlign.center,
                                CustomStyles.polarNight[3],
                                CustomStyles.polarNight[0],
                                _getMove(_cellSelected(), num,
                                    globals.selectedRow, globals.selectedCol)))
                        : Container(width: 4);
                  }))
              : Container(height: 4);
        }));
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
    return Flex(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      direction: Axis.horizontal,
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: getFlatButton(
            'New Game',
            CustomStyles.snowStorm[2],
            24,
            TextAlign.center,
            CustomStyles.polarNight[3],
            CustomStyles.polarNight[0],
            () => _newGame(),
          ),
        ),
        Container(width: 4),
        Flexible(
          fit: FlexFit.tight,
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
      ],
    );
  }

  double _getBodyWidth() {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double width = MediaQuery.of(context).size.width - padding.horizontal;
    double height = MediaQuery.of(context).size.height - padding.vertical;
    double aspect = 0.575;
    return width / height < aspect ? width : height * aspect;
//    return height * aspect;
  }

  Widget _getBody() {
    return Container(
      padding: EdgeInsets.all(_bodySpacing),
      child: _makeBodyVertical(),
    );
  }

  Widget _makeBodyFlex(bool doVertical) {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _getBoard(),
        Container(height: 4),
        Flexible(
          child: Flex(
            direction: Axis.vertical,
            children: [
              Flexible(
                child: _getMoveButtons(),
              ),
              _getGameButtons(),
            ],
          ),
        )
      ],
    );
  }

  Widget _makeBodyVertical() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Container()),
        Container(
          child: _makeBodyFlex(true),
          width: _getBodyWidth() - _bodySpacing * 2,
          // width: _getBodyWidth(),
        ),
        Flexible(child: Container()),
      ],
    );
  }
}
