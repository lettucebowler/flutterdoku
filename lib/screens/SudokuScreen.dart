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
import 'package:lettuce_sudoku/util/globals.dart' as globals;
import 'package:lettuce_sudoku/widgets/widgets.dart';

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
  var _actionMap;
  var _correctnessRadio;
  var _legalityRadio;
  Drawer _drawer;
  Container board;
  List<Widget> sudokuGrid = [];

  @override
  void initState() {
    super.initState();
    if (globals.problem == null) {
      _newGameAndSave();
    }
    _assistant = SolvingAssistant(globals.problem);
    board = _makeBoard();
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

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
    _actionMap = {
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
      LogicalKeyboardKey.digit0: _getMove(
          _cellSelected(), 0, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad0: _getMove(
          _cellSelected(), 0, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.keyX: _getMove(
          _cellSelected(), 0, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.delete: _getMove(
          _cellSelected(), 0, globals.selectedRow, globals.selectedCol),

      // Place 1
      LogicalKeyboardKey.digit1: _getMove(
          _cellSelected(), 1, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad1: _getMove(
          _cellSelected(), 1, globals.selectedRow, globals.selectedCol),

      // Place 2
      LogicalKeyboardKey.digit2: _getMove(
          _cellSelected(), 2, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad2: _getMove(
          _cellSelected(), 2, globals.selectedRow, globals.selectedCol),

      // Place 3
      LogicalKeyboardKey.digit3: _getMove(
          _cellSelected(), 3, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad3: _getMove(
          _cellSelected(), 3, globals.selectedRow, globals.selectedCol),

      // Place 4
      LogicalKeyboardKey.digit4: _getMove(
          _cellSelected(), 4, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad4: _getMove(
          _cellSelected(), 4, globals.selectedRow, globals.selectedCol),

      // Place 5
      LogicalKeyboardKey.digit5: _getMove(
          _cellSelected(), 5, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad5: _getMove(
          _cellSelected(), 5, globals.selectedRow, globals.selectedCol),

      // Place 6
      LogicalKeyboardKey.digit6: _getMove(
          _cellSelected(), 6, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad6: _getMove(
          _cellSelected(), 6, globals.selectedRow, globals.selectedCol),

      // Place 7
      LogicalKeyboardKey.digit7: _getMove(
          _cellSelected(), 7, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad7: _getMove(
          _cellSelected(), 7, globals.selectedRow, globals.selectedCol),

      // Place 8
      LogicalKeyboardKey.digit8: _getMove(
          _cellSelected(), 8, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad8: _getMove(
          _cellSelected(), 8, globals.selectedRow, globals.selectedCol),

      // Place 9
      LogicalKeyboardKey.digit9: _getMove(
          _cellSelected(), 9, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad9: _getMove(
          _cellSelected(), 9, globals.selectedRow, globals.selectedCol),

      // Get Hint
      LogicalKeyboardKey.keyH: () =>
          _giveHint(globals.selectedRow, globals.selectedCol),
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
            Function action = _actionMap[event.data.logicalKey];
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

  Widget _getDrawer() {
    return _drawer == null
        ? Drawer(
            child: ListView(
              padding: const EdgeInsets.all(0.0),
              children: [
                const DrawerHeader(
                  child: Center(
                    child: Text(
                      'Settings',
                      style: CustomStyles.titleText,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: CustomStyles.nord3,
                  ),
                ),
                Row(
                  children: [
                    const Spacer(flex: 2),
                    Expanded(
                      flex: 35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Highlight Peer Cells',
                                style: TextStyle(
                                  color: CustomStyles.nord3,
                                  fontSize: 17,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Switch(
                                value: globals.doPeerCells.value,
                                onChanged: (bool value) =>
                                    _toggleBoolWrapper(globals.doPeerCells),
                                activeColor: CustomStyles.nord3,
                                inactiveThumbColor: CustomStyles.nord3,
                                activeTrackColor: CustomStyles.nord14,
                                inactiveTrackColor: CustomStyles.nord15,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Highlight Peer Digits',
                                style: TextStyle(
                                  color: CustomStyles.nord3,
                                  fontSize: 17,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Switch(
                                value: globals.doPeerDigits.value,
                                onChanged: (bool value) =>
                                    _toggleBoolWrapper(globals.doPeerDigits),
                                activeColor: CustomStyles.nord3,
                                inactiveThumbColor: CustomStyles.nord3,
                                activeTrackColor: CustomStyles.nord14,
                                inactiveTrackColor: CustomStyles.nord15,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Show Mistakes',
                                style: TextStyle(
                                  color: CustomStyles.nord3,
                                  fontSize: 17,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Switch(
                                value: globals.doMistakes.value,
                                onChanged: (bool value) =>
                                    _toggleBoolWrapper(globals.doMistakes),
                                activeColor: CustomStyles.nord3,
                                inactiveThumbColor: CustomStyles.nord3,
                                activeTrackColor: CustomStyles.nord14,
                                inactiveTrackColor: CustomStyles.nord15,
                              ),
                            ],
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) =>
                                    SizeTransition(
                              child: child,
                              sizeFactor: animation,
                            ),
                            child: globals.doMistakes.value
                                ? Column(
                                    children: [
                                      getStyledRadio(
                                          _correctnessRadio,
                                          'Correctness',
                                          0,
                                          globals.legalityRadio,
                                          (var val) => _setIntWrapper(
                                              0, globals.legalityRadio)),
                                      getStyledRadio(
                                          _legalityRadio,
                                          'Legality',
                                          1,
                                          globals.legalityRadio,
                                          (var val) => _setIntWrapper(
                                              1, globals.legalityRadio)),
                                    ],
                                  )
                                : Container(),
                          ),
                          const Text(
                            'Initial Hints',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: CustomStyles.nord3,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: globals.initialHints.value.toDouble(),
                        onChanged: (double val) =>
                            _setIntWrapper(val.toInt(), globals.initialHints),
                        min: 17,
                        max: 50,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove, color: CustomStyles.nord3),
                      onPressed: () => _setIntWrapper(
                          globals.initialHints.value - 1, globals.initialHints),
                    ),
                    Text(globals.initialHints.value.toString()),
                    IconButton(
                        icon: Icon(Icons.add, color: CustomStyles.nord3),
                        onPressed: () => _setIntWrapper(
                            globals.initialHints.value + 1,
                            globals.initialHints))
                  ],
                ),
                Row(
                  children: [
                    const Spacer(flex: 2),
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
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 2, 2),
                                          child: FlatButton(
                                            color: CustomStyles.nord3,
                                            splashColor: CustomStyles.nord0,
                                            onPressed: () =>
                                                _solveGame(problem),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0.0)),
                                            child: AutoSizeText(
                                              'Solve game',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: CustomStyles.nord6,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(2, 0, 0, 2),
                                          child: FlatButton(
                                            color: CustomStyles.nord3,
                                            splashColor: CustomStyles.nord0,
                                            onPressed: () =>
                                                _resetBoard(problem),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0.0)),
                                            child: AutoSizeText(
                                              'Reset Game',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: CustomStyles.nord6,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
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
                                          child: FlatButton(
                                            color: CustomStyles.nord3,
                                            splashColor: CustomStyles.nord0,
                                            onPressed: () => _newGameAndSave(),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0.0)),
                                            child: AutoSizeText(
                                              'New Game',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: CustomStyles.nord6,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        ),
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
                    const Spacer(flex: 2),
                  ],
                ),
              ],
            ),
          )
        : _drawer;
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
    // print("doMove");
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
      var changeIndex =
          row * globals.problem.board_size + col % globals.problem.board_size;
      sudokuGrid[changeIndex] = _makeBoardButton(changeIndex);
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
    Color peerCell = CustomStyles.nord8;
    Color background = CustomStyles.nord6;
    Color peerDigit = CustomStyles.nord9;
    Color success = CustomStyles.nord14;
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
    Container button = Container(
      padding: _getBoardPadding(index),
      child: Material(
        color: cellColor,
        child: InkWell(
          hoverColor: CustomStyles.nord13,
          splashColor: CustomStyles.nord12,
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
    sudokuGrid.add(button);
    return button;
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

  Widget _makeBoard() {
    sudokuGrid = List.generate(
        globals.problem.board_size * globals.problem.board_size, (index) {
      return _makeBoardButton(index);
    });
    Container board = Container(
      padding: EdgeInsets.all(2),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: CustomStyles.nord3,
          child: GridView.count(
            crossAxisCount: globals.problem.board_size,
            childAspectRatio: 1,
            children: sudokuGrid,
          ),
        ),
      ),
    );
    return board;
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
                          CustomStyles.nord6,
                          36,
                          TextAlign.center,
                          CustomStyles.nord3,
                          CustomStyles.nord0,
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
    Function func = () => {};
    if (selected) {
      func = () => _applyMove(num, row, col);
    }
    return func;
  }

  void _applyMove(int num, int row, int col) {
    _doMove(num, row, col);
    setState(() {});
  }

  Color _getTextColor(int row, int col) {
    SudokuState initialState = globals.problem.getInitialState();
    var initialBoard = initialState.getTiles();
    var initialHint = initialBoard[row][col] != 0;
    var legal = globals.problem.isLegal(row, col);
    var correct = globals.problem.isCorrect(row, col);
    var doLegality = globals.legalityRadio.value == 1;
    Color color = CustomStyles.nord10;

    color = globals.doMistakes.value && doLegality && !legal
        ? CustomStyles.nord11
        : color;
    color = globals.doMistakes.value && !doLegality && !correct
        ? CustomStyles.nord11
        : color;
    color = initialHint ? CustomStyles.nord3 : color;
    color = _givenAsHint(row, col) ? CustomStyles.nord15 : color;
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
                CustomStyles.nord6,
                24,
                TextAlign.center,
                CustomStyles.nord3,
                CustomStyles.nord0,
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
                CustomStyles.nord6,
                24,
                TextAlign.center,
                CustomStyles.nord3,
                CustomStyles.nord0,
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
      child: _makeBodyRow(context),
    );
  }

  Widget _makeGameCol(bool doVertical) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          flex: 15,
//          child: Container(
          child: board,
//          color: Colors.red,
        ),
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
