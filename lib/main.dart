//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'CustomStyles.dart';
import 'domains/sudoku/SudokuProblem.dart';
import 'domains/sudoku/SudokuState.dart';
import 'framework/problem/Problem.dart';
import 'globals.dart' as globals;
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'framework/problem/SolvingAssistant.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _read();
  runApp(MyApp());
}

_read() async {
  final prefs = await SharedPreferences.getInstance();
  final legality = prefs.getBool('doLegality');
  final peerCells = prefs.getBool('doPeerCells');
  final peerDigits = prefs.getBool('doPeerDigits');
  final mistakes = prefs.getBool('doMistakes');
  final hints = prefs.getInt('initialHints');
  globals.doLegality.value = legality != null ? legality : false;
  globals.doPeerCells.value = peerCells != null ? peerCells : true;
  globals.doPeerDigits.value = peerDigits != null ? peerDigits : true;
  globals.doMistakes.value = mistakes != null ? mistakes : true;
  globals.initialHints.value = hints != null ? hints : 30;
  globals.legalityRadio.value = legality != null && legality == false ? 0 : 1;
  print('Peer Cells: ' + peerCells.toString());
  print('globals.peerCells: ' + globals.doPeerCells.value.toString());
}

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
  SudokuProblem _problem =
      SudokuProblem.withMoreHints(globals.initialHints.value - 17);
  var menuHeight = 70;
  SolvingAssistant _assistant;
  FocusNode focusNode = FocusNode();
  double _bodySpacing = 4;

  @override
  Widget build(BuildContext context) {
    if (_problem == null) {
      _problem = SudokuProblem.withMoreHints(globals.initialHints.value - 17);
    }

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
    globals.selectedCol = ((globals.selectedCol - 1) % _problem.board_size);
  }

  void _shiftRight() {
    globals.selectedCol = ((globals.selectedCol + 1) % _problem.board_size);
  }

  void _shiftUp() {
    globals.selectedRow = ((globals.selectedRow - 1) % _problem.board_size);
  }

  void _shiftDown() {
    globals.selectedRow = ((globals.selectedRow + 1) % _problem.board_size);
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    final doLegality = globals.doLegality.value;
    final doPeerCells = globals.doPeerCells.value;
    final doPeerDigits = globals.doPeerDigits.value;
    final doMistakes = globals.doMistakes.value;
    final hints = globals.initialHints.value;
    prefs.setBool('doLegality', doLegality);
    prefs.setBool('doPeerCells', doPeerCells);
    prefs.setBool('doPeerDigits', doPeerDigits);
    prefs.setBool('doMistakes', doMistakes);
    prefs.setInt('initialHints', hints);
  }

  Drawer _getDrawer() {
    return Drawer(
      child: Container(
        child: Flex(
          direction: Axis.vertical,
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
            Container(
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        _getToggle('Highlight Peer Cells', globals.doPeerCells),
                        _getToggle(
                            'Highlight Peer Digits', globals.doPeerDigits),
                        _getToggle('Show Mistakes', globals.doMistakes),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) =>
                                  SizeTransition(
                            child: child,
                            sizeFactor: animation,
                          ),
                          child: _getMistakeRadioGroup(),
                        ),
                        _getSliderNoDivisions(
                            'Initial Hints: ' +
                                globals.initialHints.value.toString(),
                            globals.initialHints,
                            17,
                            50),
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              child: _getRaisedButton(
                                  'Solve Game',
                                  CustomStyles.snowStorm[2],
                                  17,
                                  TextAlign.center,
                                  CustomStyles.polarNight[3],
                                  CustomStyles.polarNight[0],
                                  () => _solveGame(_problem)),
                            ),
                            Container(width: 6),
                            Flexible(
                              flex: 1,
                              child: _getRaisedButton(
                                  'Reset Game',
                                  CustomStyles.snowStorm[2],
                                  17,
                                  TextAlign.center,
                                  CustomStyles.polarNight[3],
                                  CustomStyles.polarNight[0],
                                  () => _resetBoard(_problem)),
                            ),
                          ],
                        ),
                        _getRaisedButton(
                            'New Game',
                            CustomStyles.snowStorm[2],
                            17,
                            TextAlign.center,
                            CustomStyles.polarNight[3],
                            CustomStyles.polarNight[0],
                            () => _newGame()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  RaisedButton _getRaisedButton(
      String label,
      Color textColor,
      double textSize,
      TextAlign textAlign,
      Color buttonColor,
      Color splashColor,
      Function function) {
    return RaisedButton(
      elevation: 0,
      hoverElevation: 10,
      focusElevation: 0,
      color: buttonColor,
      splashColor: splashColor,
      onPressed: function,
      child: AutoSizeText(
        label,
        textAlign: textAlign,
        style: TextStyle(
          color: textColor,
          fontSize: textSize,
        ),
      ),
    );
  }

  void _newGame() {
    setState(() {
      _problem = SudokuProblem.withMoreHints(globals.initialHints.value - 17);
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
    int row = index ~/ _problem.board_size;
    int col = index % _problem.board_size;

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
    if (row % _problem.cell_size == _problem.cell_size - 1) {
      bottom = thickness;
    }
    if (col % _problem.cell_size == _problem.cell_size - 1) {
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
    if (!_problem.success() && validCell) {
      // SudokuState currentState = _problem.getCurrentState();
      // List currentBoard = currentState.getTiles();
      SudokuState finalState = _problem.getFinalState();
      List finalBoard = finalState.getTiles();
      var num = finalBoard[row][col];
      if (!_problem.isCorrect(row, col)) {
        _doMove(num, row, col);
        setState(() {
          globals.hintsGiven.add([row, col]);
        });
      }
    }
  }

  void _doMove(int num, int row, int col) {
    _assistant = SolvingAssistant(_problem);
    SudokuState initialState = _problem.getInitialState();
    var initialBoard = initialState.getTiles();
    var notInitialHint = initialBoard[row][col] == 0;
    if (!_problem.success() && notInitialHint) {
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
    bool floorSelected =
        row ~/ _problem.cell_size == globals.selectedRow ~/ _problem.cell_size;
    bool towerSelected =
        col ~/ _problem.cell_size == globals.selectedCol ~/ _problem.cell_size;
    bool cells = globals.doPeerCells.value;
    bool digits = globals.doPeerDigits.value;
    SudokuState currentState = _problem.getCurrentState();
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
    color = _problem.success() ? success : color;

    return color;
  }

  Widget _makeBoardButton(int index) {
    var row = index ~/ _problem.board_size;
    var col = index % _problem.board_size;
    SudokuState currentState = _problem.getCurrentState();
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
                  globals.doLegality, false),
              _getRadio('Legality', 1, globals.legalityRadio,
                  globals.doLegality, true),
            ],
          )
        : Container();
  }

  Widget _getToggle(String label, globals.BoolWrapper setting) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: Text(
            label,
            style: TextStyle(
              color: CustomStyles.polarNight[3],
              fontSize: 17,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
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
    );
  }

  Widget _getRadio(
      String label, int value, var groupValue, var setting, var setTo) {
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
              setting.value = setTo;
            });
          },
        ),
      ],
    );
  }

  Widget _getSliderNoDivisions(
      String label, globals.IntWrapper setting, double min, double max) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: CustomStyles.polarNight[3],
            fontSize: 17,
          ),
          textAlign: TextAlign.center,
        ),
        Row(
          children: [
            Text('17'),
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
            Text('50'),
          ],
        ),
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
            crossAxisCount: _problem.board_size,
            childAspectRatio: 1,
            children: List.generate(_problem.board_size * _problem.board_size,
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
                    int num =
                        (index ~/ 2 + 1 + offset) % (_problem.board_size + 1);
                    String toPlace = num == 0 ? 'X' : (num).toString();
                    return index % 2 == 0
                        ? Flexible(
                            fit: FlexFit.tight,
                            flex: 8,
                            child: _getRaisedButton(
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
    SudokuState initialState = _problem.getInitialState();
    var initialBoard = initialState.getTiles();
    var initialHint = initialBoard[row][col] != 0;
    var legal = _problem.isLegal(row, col);
    var correct = _problem.isCorrect(row, col);
    Color color = CustomStyles.frost[3];

    color = globals.doMistakes.value && globals.doLegality.value && !legal
        ? CustomStyles.aurora[0]
        : color;
    color = globals.doMistakes.value && !globals.doLegality.value && !correct
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
          child: _getRaisedButton(
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
          child: _getRaisedButton(
            'hint: ' + globals.hintsGiven.length.toString(),
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
