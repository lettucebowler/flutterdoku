import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuState.dart';
import 'package:lettuce_sudoku/framework/problem/Problem.dart';
import 'package:lettuce_sudoku/framework/problem/SolvingAssistant.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/globals.dart';
import 'package:lettuce_sudoku/util/helpers.dart';
import 'package:lettuce_sudoku/util/widgets.dart';
import 'package:lettuce_sudoku/util/globals.dart' as globals;

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
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'LettuceSudoku',
          textAlign: TextAlign.center,
          style: CustomStyles.titleText,
        ),
      ),
      drawer: _getDrawer(_scaffoldKey),
      body: Builder(
        builder: (_scaffoldKey) => RawKeyboardListener(
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
          child: _getBody(_scaffoldKey),
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
    if (_scaffoldKey.currentState.isDrawerOpen) {
      Navigator.pop(context);
    } else {
      _scaffoldKey.currentState.openDrawer();
    }
  }

  Widget _getDrawer(context) {
    var radioList = [
      getStyledRadio('Correctness', 0, globals.legalityRadio,
          (var val) => _setIntWrapper(0, globals.legalityRadio)),
      getStyledRadio('Legality', 1, globals.legalityRadio,
          (var val) => _setIntWrapper(1, globals.legalityRadio)),
    ];
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
          Row(
            children: [
              Spacer(flex: 2),
              Expanded(
                flex: 35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getStyledToggleRow(
                        'Highlight Peer Cells',
                        globals.doPeerCells,
                        (bool value) =>
                            _toggleBoolWrapper(globals.doPeerCells)),
                    getStyledToggleRow(
                        'Highlight Peer Digits',
                        globals.doPeerDigits,
                        (bool value) =>
                            _toggleBoolWrapper(globals.doPeerDigits)),
                    getStyledToggleRow('Show Mistakes', globals.doMistakes,
                        (bool value) => _toggleBoolWrapper(globals.doMistakes)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) =>
                              SizeTransition(
                        child: child,
                        sizeFactor: animation,
                      ),
                      child: globals.doMistakes.value
                          ? getWidgetGroup(radioList)
                          : Container(),
                    ),
                    Text(
                      'Initial Hints',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: CustomStyles.polarNight[3],
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          getStyledSliderRow(
              globals.initialHints,
              17,
              50,
              (double val) => _setIntWrapper(val.toInt(), globals.initialHints),
              () => _setIntWrapper(
                  globals.initialHints.value - 1, globals.initialHints),
              () => _setIntWrapper(
                  globals.initialHints.value + 1, globals.initialHints)),
          Row(
            children: [
              Spacer(flex: 2),
              Expanded(
                flex: 33,
                child: AspectRatio(
                  aspectRatio: 3,
                  child: Container(
                    height: 120,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 0, 2, 2),
                                    child: getFlatButton(
                                        'Solve Game',
                                        CustomStyles.snowStorm[2],
                                        17,
                                        TextAlign.center,
                                        CustomStyles.polarNight[3],
                                        CustomStyles.polarNight[0],
                                        () => _solveGame(globals.problem)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(2, 0, 0, 2),
                                    child: getFlatButton(
                                        'Reset Game',
                                        CustomStyles.snowStorm[2],
                                        17,
                                        TextAlign.center,
                                        CustomStyles.polarNight[3],
                                        CustomStyles.polarNight[0],
                                        () => _resetBoard(globals.problem)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                      padding: EdgeInsets.only(top: 2),
                                      child: getFlatButton(
                                          'New Game',
                                          CustomStyles.snowStorm[2],
                                          17,
                                          TextAlign.center,
                                          CustomStyles.polarNight[3],
                                          CustomStyles.polarNight[0],
                                          () => _newGameAndSave())),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(flex: 2),
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

  void _toggleBoolWrapper(VariableWrapper setting) {
    setState(() {
      setting.value = !setting.value;
      saveToPrefs();
    });
  }

  void _setIntWrapper(int value, VariableWrapper setting) {
    setState(() {
      setting.value = value;
      saveToPrefs();
    });
  }

  Widget _getBoard() {
    return Container(
      padding: EdgeInsets.all(2),
      child: AspectRatio(
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
            }),
          ),
        ),
      ),
    );
  }

  Widget _getMoveButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            children: List.generate(2, (rowIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (colIndex) {
                  int offset = rowIndex * 5;
                  int num = (colIndex + 1 + offset) %
                      (globals.problem.board_size + 1);
                  String toPlace = num == 0 ? 'X' : (num).toString();
                  return Expanded(
                    child: Container(
                      // padding: _getMovePadding(rowIndex, colIndex),
                      padding: EdgeInsets.all(2),
                      child: AspectRatio(
                        aspectRatio: 1,
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
              padding: EdgeInsets.all(2),
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
        Flexible(
          fit: FlexFit.tight,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(2),
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

  Widget _getBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(globals.bodySpacing),
      child: _makeBodyRow(context),
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

  Widget _makeBodyRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Container()),
        Container(
          width: getBodyWidth(context),
          child: _makeGameCol(true),
        ),
        Flexible(child: Container()),
      ],
    );
  }
}
