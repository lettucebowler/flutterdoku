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
//import 'globals.dart';

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
  SudokuProblem _problem = SudokuProblem.withMoreHints(globals.hintOffset.value);
  var menuHeight = 70;
  SolvingAssistant _assistant;

  void _resetBoard() {
    _problem = SudokuProblem.withMoreHints(globals.hintOffset.value);
    globals.selectedRow = -1;
    globals.selectedCol = -1;
    setState(() {});
    globals.hintsGiven.clear();
  }

  double getConstraint() {
    var padding = MediaQuery.of(context).padding;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height -
        padding.top -
        padding.bottom -
        menuHeight;
    var constraint = width <= height ? width : height;
    return constraint;
  }

  EdgeInsets _getBoardPadding(int index) {
    int row = index ~/ _problem.board_size;
    int col = index % _problem.board_size;

    double thickness = 1.5;
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
        globals.selectedRow = pos1;
        globals.selectedCol = pos2;
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
    Color color = background;

    if(row == globals.selectedRow && col == globals.selectedCol) {
      color = peerDigit;
    }

    if(globals.doPeerCells.value) {
      if (_cellSelected()) {
        if (row == globals.selectedRow || col == globals.selectedCol) {
          color = peerCell;
        }
        if (row ~/ _problem.cell_size == globals.selectedRow ~/ _problem.cell_size &&
            col ~/ _problem.cell_size == globals.selectedCol ~/ _problem.cell_size) {
          color = peerCell;
        }
        if (row == globals.selectedRow && col == globals.selectedCol) {
          color = background;
        }
      } else {
        color = background;
      }
    }

    if(globals.doPeerDigits.value) {
      SudokuState currentState = _problem.getCurrentState();
      List currentBoard = currentState.getTiles();
      if(_cellSelected()) {
        if(currentBoard[row][col] != 0 && currentBoard[row][col] == currentBoard[globals.selectedRow][globals.selectedCol]) {
          color = peerDigit;
        }
      }
    }

    if(globals.doPeerCells.value && globals.doPeerDigits.value && row == globals.selectedRow && col == globals.selectedCol) {
      color = background;
    }

    if (_problem.success()) {
      color = peerCell;
    }
    return color;
  }

  Widget _makeBoardButton(int index) {
    var row = index ~/ _problem.board_size;
    var col = index % _problem.board_size;
    SudokuState currentState = _problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    var cellNum = currentBoard[row][col];
    String toPlace = cellNum == 0 ? '' : cellNum.toString();

    Ink button = Ink(
      padding: _getBoardPadding(index),
      child: Material(
        color: _getCellColor(row, col),
        child: InkWell(
          splashColor: CustomStyles.frost[2],
          hoverColor: CustomStyles.frost[3],
          onTap: () {
            globals.selectedRow = row;
            globals.selectedCol = col;
            setState(() {});
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
    );

    return button;
  }

  @override
  Widget build(BuildContext context) {
    if (_problem == null) {
      _problem = SudokuProblem.withMoreHints(globals.hintOffset.value);
    }

    return Scaffold(
//      backgroundColor: CustomStyles.snowStorm[2],
      appBar: AppBar(
        title: Text(
          'LettuceSudoku',
          textAlign: TextAlign.center,
          style: CustomStyles.titleText,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(0),
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
              padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  _getToggle('Highlight Peer Cells', globals.doPeerCells),
                  _getToggle('Highlight Peer Digits', globals.doPeerDigits),
                  _getSlider('Difficulty', globals.hintOffset, 0, 33, 3),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _getBody(),
    );
  }

  _getToggle(String label, globals.BoolWrapper setting) {
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
              fontSize: 16,
            ),
            textAlign: TextAlign.left,
          ),
        ),
//        Transform.scale(
//          scale: 1.3,
//          child:
        Container(
//          color: Colors.red,
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
//        ),
      ],
    );
  }

  _getSlider(String label, globals.IntWrapper setting, double min, double max, int divisions) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: CustomStyles.polarNight[3],
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        Row(
          children: [
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
                divisions: divisions,
              ),
            ),
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
              Ink button = _makeBoardButton(index);
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
        Container button = Container(
          child: Material(
            color: CustomStyles.snowStorm[2],
            child: InkWell(
              hoverColor: Colors.grey,
              splashColor: Colors.grey,
              onTap: () {
                if(_cellSelected()) {
                  _doMove(num, globals.selectedRow, globals.selectedCol);
                  setState(() {});
                }
              },
              child: Center(
                child: AutoSizeText(
                  toPlace,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: CustomStyles.getFiraCode(CustomStyles.polarNight[3], 36),
                ),
              ),
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

    color = globals.doLegality.value && !legal ? CustomStyles.aurora[0] : color;
    color = !globals.doLegality.value && !correct ? CustomStyles.aurora[0] : color;
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
        child: isPortrait ? _makeBoardCol() : _makeBoardRow(),
      ),
    );
    return body;
  }

  Widget _makeBoardCol() {
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
        Container(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.center,
            direction: Axis.horizontal,
            children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
                  child: FlatButton(
                    hoverColor: CustomStyles.snowStorm[0],
                    splashColor: CustomStyles.snowStorm[0],
                    onPressed: () {
                      _resetBoard();
                    },
                    child: Text(
                      'New Game',
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: CustomStyles.getFiraCode(CustomStyles.polarNight[3], 26),
                    ),
                  ),
              ),
              Flexible(
//                flex: 2,
                fit: FlexFit.loose,
                  child: FlatButton(
                    hoverColor: CustomStyles.snowStorm[0],
                    splashColor: CustomStyles.snowStorm[0],
                    onPressed: () {
                      _giveHint();
                    },
                    child: Text(
                      'hint(' + hintsLeft.toString() + ')',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      style: CustomStyles.getFiraCode(CustomStyles.polarNight[3], 26),
                    ),
                  ),
              ),
            ],
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
