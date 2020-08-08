//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'CustomStyles.dart';
import 'domains/sudoku/SudokuProblem.dart';
import 'domains/sudoku/SudokuState.dart';
import 'globals.dart' as globals;
import 'dart:ui';
import 'dart:math';
import 'framework/problem/SolvingAssistant.dart';

void main() {
  runApp(MyApp());
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
        fontFamily: 'FiraCode',
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
  SudokuProblem _problem = SudokuProblem.withMoreHints(globals.initialHints.value - 17);
  var menuHeight = 70;
  SolvingAssistant _assistant;

  @override
  Widget build(BuildContext context) {
    if (_problem == null) {
      _problem = SudokuProblem.withMoreHints(globals.initialHints.value - 17);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LettuceSudoku',
          textAlign: TextAlign.center,
          style: CustomStyles.titleText,
        ),
      ),
      drawer: _getDrawer(),
      body: _getBody(),
    );
  }

  Drawer _getDrawer() {
    return Drawer(
      child: Column(
//          padding: EdgeInsets.all(0),
        children: [
          DrawerHeader(
            child: Center(
              child: Text('Settings',
                style: CustomStyles.titleText,
              ),
            ),
            decoration: BoxDecoration(
              color: CustomStyles.polarNight[3],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
            child: Flex(
              direction: Axis.vertical,
              children: [
                _getToggle('Highlight Peer Cells', globals.doPeerCells),
                _getToggle('Highlight Peer Digits', globals.doPeerDigits),
                _getToggle('Show Mistakes', globals.doMistakes),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) =>
                      SizeTransition(
                        child: child, sizeFactor: animation,
                      ),
                  child: _getMistakeRadioGroup(),
                ),
                _getSliderNoDivisions('Initial Hints: ' + globals.initialHints.value.toString(), globals.initialHints, 17, 50),
              ],
            ),
          ),
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                color: CustomStyles.polarNight[3],
                splashColor: CustomStyles.polarNight[0],
                child: Text('Solve Game', style: CustomStyles.getFiraCode(CustomStyles.snowStorm[2], 17)),
                onPressed: () => _solveGame(_problem),
              ),
              Container(width: 6),
              FlatButton(
                color: CustomStyles.polarNight[3],
                splashColor: CustomStyles.polarNight[0],
                child: Text('Reset Game', style: CustomStyles.getFiraCode(CustomStyles.snowStorm[2], 17)),
                onPressed: () => _resetBoard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _newGame() {
    setState(() {
      _problem = SudokuProblem.withMoreHints(globals.initialHints.value - 17);
      globals.selectedRow = -1;
      globals.selectedCol = -1;
      globals.hintsGiven.clear();
    });

  }

  void _resetBoard() {
    setState(() {
      _problem.setCurrentState(_problem.getInitialState());
      globals.selectedRow = -1;
      globals.selectedCol = -1;
      globals.hintsGiven.clear();
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

  int _getRandom(int max) {
    var random = Random();
    return random.nextInt(max);
  }

  bool _givenAsHint(int row, int col) {
    bool hint = false;
    for(List pair in globals.hintsGiven) {
      if(pair[0] == row && pair[1] == col) {
        hint = true;
      }
    }
    return hint;
  }

  void _giveHint() {
    if (!_problem.success() && _getHintsLeft() > 0) {
      SudokuState currentState = _problem.getCurrentState();
      List currentBoard = currentState.getTiles();
      SudokuState finalState = _problem.getFinalState();
      List finalBoard = finalState.getTiles();
      var pos1;
      var pos2;
      do {
        pos1 = _getRandom(_problem.board_size);
        pos2 = _getRandom(_problem.board_size);
      } while(currentBoard[pos1][pos2] != 0);
      var num = finalBoard[pos1][pos2];
      _doMove(num, pos1, pos2);
      setState(() {
        globals.hintsGiven.add([pos1, pos2]);
      });
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
//    int cell_size = problem.cell_size;
    int board_size = problem.board_size;
    for (var i = 0; i < board_size; i++) {
      for (var j = 0; j < board_size; j++) {
        for (var k = 1; k <= board_size; k++) {
          if (!problem.isCorrect(i, j)) {
            _doMove(k, i, j);
            if (problem.isCorrect(i, j)) {
              break;
            }
          }
        }
      }
    }
    setState(() {});
  }

  bool _cellSelected() {
    return globals.selectedRow != -1 && globals.selectedCol != -1;
  }

  int _getHintsLeft() {
    var hintsLeft = globals.maxHints.value - globals.hintsGiven.length;
    return hintsLeft;
  }

  Color _getCellColor(int row, int col) {
    Color peerCell = CustomStyles.frost[1];
    Color background = CustomStyles.snowStorm[2];
    Color peerDigit = CustomStyles.frost[2];
    Color success = CustomStyles.aurora[3];
    Color color = background;

    bool rowSelected = row == globals.selectedRow;
    bool colSelected = col == globals.selectedCol;
    bool floorSelected = row ~/ _problem.cell_size == globals.selectedRow ~/ _problem.cell_size;
    bool towerSelected = col ~/ _problem.cell_size == globals.selectedCol ~/ _problem.cell_size;
    bool cells = globals.doPeerCells.value;
    bool digits = globals.doPeerDigits.value;
    SudokuState currentState = _problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    bool sameDigit = _cellSelected() && currentBoard[row][col] == currentBoard[globals.selectedRow][globals.selectedCol];
    bool nonZero = _cellSelected() && currentBoard[row][col] != 0;

    color = rowSelected && colSelected ? peerDigit : color;
    color = cells && _cellSelected() && (rowSelected || colSelected || (floorSelected && towerSelected)) ? peerCell : color;
    color = digits && _cellSelected() && ((sameDigit && nonZero) || (sameDigit && rowSelected && colSelected)) ? peerDigit : color;
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

    FlatButton button = FlatButton(
      padding: _getBoardPadding(index),
      color: cellColor,
      child: Container(
        child: Material(
          color: _getCellColor(row, col),
          child: InkWell(
            splashColor: CustomStyles.frost[2],
            hoverColor: CustomStyles.frost[3],
            onTap: () {
              setState(() {
                globals.selectedRow = row;
                globals.selectedCol = col;
              });
            },
            child: Center(
              child: AutoSizeText(
                toPlace,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: CustomStyles.getFiraCode(_getTextColor(row, col), 30),
              ),
            ),
          ),
        ),
      ),

    );

    return button;
  }

  Widget _getMistakeRadioGroup() {
    return globals.doMistakes.value ? Column(
      children: [
        _getRadio('Correctness', 0, globals.legalityRadio, globals.doLegality, false),
        _getRadio('Legality', 1, globals.legalityRadio, globals.doLegality, true),
      ],
    ) : Container(
    );
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


  Widget _getRadio(String label, int value, var groupValue, var setting, var setTo) {
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
            setState(() {
              groupValue.value = value;
              setting.value = setTo;
            });
          },
        ),
      ],
    );
  }

  Widget _getSliderNoDivisions(String label, globals.IntWrapper setting, double min, double max) {
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
            padding: EdgeInsets.all(1),
            crossAxisCount: _problem.board_size,
            childAspectRatio: 1,
            children:
                List.generate(_problem.board_size * _problem.board_size, (index) {
              FlatButton button = _makeBoardButton(index);
              return button;
            })),
      ),
    );
    return board;
  }

  Widget _getMoveButtons() {
    var buttons = GridView.count(
      padding: EdgeInsets.all(1),
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: List.generate(10, (index) {
        int num = (index + 1) % (_problem.board_size + 1);
        String toPlace = num == 0 ? 'X' : (index + 1).toString();
        RaisedButton button = RaisedButton(
          elevation: 10,
          color: CustomStyles.polarNight[3],
          splashColor: CustomStyles.polarNight[1],
          onPressed: () {
            setState(() {
              if(_cellSelected()) {
                _doMove(num, globals.selectedRow, globals.selectedCol);
              }
            });
          },
          child: Center(
            child: AutoSizeText(
              toPlace,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: CustomStyles.getFiraCode(CustomStyles.snowStorm[2], 36),
            ),
          ),
        );
        return button;
      }),
    );
    return buttons;
  }

  Color _getTextColor(int row, int col) {
    SudokuState initialState = _problem.getInitialState();
    var initialBoard = initialState.getTiles();
    var initialHint = initialBoard[row][col] != 0;
    var legal = _problem.isLegal(row, col);
    var correct = _problem.isCorrect(row, col);
    Color color = CustomStyles.frost[3];

    color = globals.doMistakes.value && globals.doLegality.value && !legal ? CustomStyles.aurora[0] : color;
    color = globals.doMistakes.value && !globals.doLegality.value && !correct ? CustomStyles.aurora[0] : color;
    color = initialHint ? CustomStyles.polarNight[3] : color;
    color = _givenAsHint(row, col) ? CustomStyles.aurora[4] : color;
    return color;
  }

  Widget _getBody() {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var body = Center(
      child: Container(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(4),
        child: isPortrait ? _makeBodyCol() : _makeBoardRow(),
      ),
    );
    return body;
  }

  Widget _makeBodyCol() {
    var hintsLeft = _getHintsLeft();
    Column col = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          flex: 4,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(4),
              child: Container(
                child: _getBoard(),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: Container(
            padding: EdgeInsets.all(4),
            child: Center(
              child: Container(
                child: _getMoveButtons(),
              ),
            ),
          ),
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Flex(
              mainAxisAlignment: MainAxisAlignment.center,
              direction: Axis.horizontal,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  child: RaisedButton(
                    elevation: 10,
                    color: CustomStyles.polarNight[3],
//                    hoverColor: CustomStyles.polarNight[0],
                    splashColor: CustomStyles.polarNight[0],
                    onPressed: () {
                      _newGame();
                    },
                    child: Text(
                      'New Game',
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: CustomStyles.getFiraCode(CustomStyles.snowStorm[2], 26),
                    ),
                  ),
                ),
                Container(
                  width: 8,
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: RaisedButton(
                    elevation: 10,
                    color: CustomStyles.polarNight[3],
//                    hoverColor: CustomStyles.polarNight[0],
                    splashColor: CustomStyles.polarNight[0],
                    onPressed: () {
                      _giveHint();
                    },
                    child: Text(
                      'hint(' + hintsLeft.toString() + ')',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      style: CustomStyles.getFiraCode(CustomStyles.snowStorm[2], 26),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    return col;
  }

  Widget _makeBoardRow() {
    Row row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          // board
          flex: 4,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(4),
              child: Container(
                color: CustomStyles.polarNight[3],
                child: _getBoard(),
              ),
            ),
          ),
        ),
        Flexible(
          // move buttons
          flex: 4,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(4),
              child: Container(
                child: _getMoveButtons(),
              ),
            ),
          ),
        ),
      ],
    );
    return row;
  }
}
