//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:auto_size_text/auto_size_text.dart';
//import 'package:lettuce_sudoku/sudoku_dart.dart';
import 'CustomColors.dart';
import 'domains/sudoku/SudokuProblem.dart';
import 'domains/sudoku/SudokuState.dart';
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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  SudokuProblem problem = SudokuProblem();
  GridView board;
  bool cell_selected = false;
  var menuHeight = 70;
  int selectedRow = 0;
  int selectedCol = 0;
  SolvingAssistant assistant;
  int hintsLeft = 5;
  List hintsGiven = [];

  void _resetBoard() {
    problem = SudokuProblem();
    cell_selected = false;
    setState(() {});
    hintsLeft = 5;
    hintsGiven.clear();
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

  EdgeInsets getBoardPadding(int index) {
    int row = index ~/ problem.board_size;
    int col = index % problem.board_size;

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
    if (row % problem.cell_size == problem.cell_size - 1) {
      bottom = thickness;
    }
    if (col % problem.cell_size == problem.cell_size - 1) {
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
    for(List pair in hintsGiven) {
      if(pair[0] == row && pair[1] == col) {
        hint = true;
      }
    }
    return hint;
  }

  void _giveHint() {
    if (!problem.success() && hintsLeft > 0) {
      SudokuState currentState = problem.getCurrentState();
      List currentBoard = currentState.getTiles();
      SudokuState finalState = problem.getFinalState();
      List finalBoard = finalState.getTiles();
      var pos1;
      var pos2;
      do {
        pos1 = _getRandom(problem.board_size);
        pos2 = _getRandom(problem.board_size);
      } while(currentBoard[pos1][pos2] != 0);
      var num = finalBoard[pos1][pos2];
      _doMove(num, pos1, pos2);
      setState(() {
        selectedRow = pos1;
        selectedCol = pos2;
        hintsGiven.add([pos1, pos2]);
        hintsLeft--;
      });
    }
  }

  void _doMove(int num, int row, int col) {
    assistant = SolvingAssistant(problem);
    SudokuState initialState = problem.getInitialState();
    var initialBoard = initialState.getTiles();
    var notInitialHint = initialBoard[row][col] == 0;
    if (!problem.success() && notInitialHint) {
      var move = 'Place ' +
          num.toString() +
          ' at ' +
          row.toString() +
          ' ' +
          col.toString();
      assistant.tryMove(move);
    }
  }

  void _solveGame(SudokuProblem problem) {
    int cell_size = problem.cell_size;
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

  Color _getColor(int row, int col) {
    Color color;
    if (cell_selected == null) {
      cell_selected = false;
    }
    if (cell_selected) {
      if (row == selectedRow || col == selectedCol) {
        color = Colors.deepOrange;
      }
      if (row ~/ problem.cell_size == selectedRow ~/ problem.cell_size &&
          col ~/ problem.cell_size == selectedCol ~/ problem.cell_size) {
        color = Colors.deepOrange;
      }
      if (row == selectedRow && col == selectedCol) {
        color = Colors.white;
      }
    } else {
      color = Colors.white;
    }
    if (problem.success()) {
      color = Colors.deepOrange;
    }
    return color;
  }

  Widget _makeBoardButton(int index, SudokuProblem problem) {
    var row = index ~/ problem.board_size;
    var col = index % problem.board_size;
    SudokuState currentState = problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    var cellNum = currentBoard[row][col];
    String toPlace = cellNum == 0 ? '' : cellNum.toString();

    Ink button = Ink(
      padding: getBoardPadding(index),
      child: Material(
        color: _getColor(row, col),
        child: InkWell(
          splashColor: Colors.deepOrange,
          hoverColor: Colors.red,
          onTap: () {
            selectedRow = row;
            selectedCol = col;
            cell_selected = true;
            setState(() {});
          },
          child: Center(
            child: AutoSizeText(
              toPlace,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'FiraCode-Bold',
                fontSize: 40,
                color: _getTextColor(row, col),
//                color: _getTextColor(row, col),
              ),
            ),
          ),
        ),
      ),
    );

    return button;
  }

  @override
  Widget build(BuildContext context) {
    if (problem == null) {
      problem = SudokuProblem();
    }

    return Scaffold(
      appBar: AppBar(
        leading: Container(
//          child: Material(
          child: InkWell(
//              splashColor: Colors.deepOrange,
            child: Container(
              height: 30,
              width: 30,
              child: Icon(Icons.menu, color: Colors.white, size: 30),
            ),
            onTap: () {
              _solveGame(problem);
              setState(() {});
            },
          ),
//          ),
        ),
        title: Text(
          'LettuceSudoku',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'FiraCode-Bold',
            fontSize: 26,
          ),
        ),
      ),
      body: _getBody(),
    );
  }

  Widget _getBoard() {
    AspectRatio board = AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.black,
        child: GridView.count(
            padding: EdgeInsets.all(1),
            crossAxisCount: problem.board_size,
            childAspectRatio: 1,
            children:
                List.generate(problem.board_size * problem.board_size, (index) {
              Ink button = _makeBoardButton(index, problem);
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
        int num = (index + 1) % (problem.board_size + 1);
        String toPlace = num == 0 ? 'X' : (index + 1).toString();
        Container button = Container(
          child: Material(
            child: InkWell(
              hoverColor: Colors.grey,
              splashColor: Colors.grey,
              onTap: () {
                if(cell_selected) {
                  _doMove(num, selectedRow, selectedCol);
                  setState(() {});
                }
              },
              child: Center(
                child: AutoSizeText(
                  toPlace,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'FiraCode-Bold',
                    fontSize: 40,
                  ),
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
    SudokuState initialState = problem.getInitialState();
    var initialBoard = initialState.getTiles();
    var initialHint = initialBoard[row][col] != 0;
    var color = Colors.blue;
    if (initialHint) {
      color = CustomColors.black;
    }
    if(_givenAsHint(row, col)) {
      const int _cyanPrimaryValue = 0xFF00FFFF;
      color = MaterialColor(
        _cyanPrimaryValue,
        <int, Color>{
          50: Color(0xFF00FFFF),
          100: Color(0xFF00FFFF),
          200: Color(0xFF00FFFF),
          300: Color(0xFF00FFFF),
          400: Color(0xFF00FFFF),
          500: Color(0xFF00FFFF),
          600: Color(0xFF00FFFF),
          700: Color(0xFF00FFFF),
          800: Color(0xFF00FFFF),
          900: Color(0xFF00FFFF),
        },
      );
    }
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
//                color: Colors.black,
                child: _getBoard(),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
//          color: Colors.red,
          child: Container(
//            color: Colors.black,
            padding: EdgeInsets.all(4),
            child: Center(
              child: Container(
//                color: Colors.blue,
                child: _getMoveButtons(),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(padding: EdgeInsets.only(right: 16),
              child: Material(
                child: InkWell(
                  hoverColor: Colors.grey,
                  splashColor: Colors.grey,
                  onTap: () {
                    _resetBoard();
                  },
                  child: Text(
                    'New Game',
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'FiraCode-Bold',
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 16),
              child: Material(
                child: InkWell(
                  hoverColor: Colors.grey,
                  splashColor: Colors.grey,
                  onTap: () {
                    _giveHint();
                  },
                  child: Text(
                    'Get hint ($hintsLeft)',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'FiraCode-Bold',
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            )
          ],
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
                color: Colors.black,
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
