import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lettuce_sudoku/sudoku_dart.dart';
import 'domains/sudoku/SudokuProblem.dart';
import 'domains/sudoku/SudokuState.dart';
import 'dart:ui';

import 'framework/problem/SolvingAssistant.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LettuceSudoku',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'FiraCode',
      ),
      home: MyHomePage(title: 'LettuceSudoku'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SudokuProblem problem;
  GridView board;
  List button_grid;
  bool cell_selected = false;
  var menuHeight = 70;
  int selectedRow = 0;
  int selectedCol = 0;
  SolvingAssistant assistant;


  void _resetBoard() {
    problem = SudokuProblem();
    cell_selected = false;
    setState(() {});
  }

  void _highLightOnClick(int row, int col) {
    for(var i = 0; i < problem.board_size; i++) {
//      button_grid[row * problem.cell_size + col].
    }
  }

  double getConstraint() {
    var padding = MediaQuery.of(context).padding;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height - padding.top - padding.bottom - menuHeight;
    var constraint = width <= height ? width : height;
    return constraint;
  }

  EdgeInsets getBoardPadding(int index) {
    int row = index ~/ problem.board_size;
    int col = index % problem.board_size;

    double thickness = 2;
    double defaultThickness = 0.5;
    double right = defaultThickness;
    double top = defaultThickness;
    double left = defaultThickness;
    double bottom = defaultThickness;

    if(row == 0) {
      top = thickness;
    }
    if(col == 0) {
      left = thickness;
    }
    if(row % problem.cell_size == problem.cell_size - 1) {
      bottom = thickness;
    }
    if(col % problem.cell_size == problem.cell_size - 1) {
      right = thickness;
    }

    return EdgeInsets.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
  }

  void doMove(int num, int row, int col) {
    assistant = SolvingAssistant(problem);
    if (!problem.success()) {
      var move = 'Place ' +
          num.toString() +
          ' at ' +
          row.toString() +
          ' ' +
          col.toString();
      assistant.tryMove(move);
    }
  }

  Color _getColor(int row, int col) {
    Color color;
    if (cell_selected == null) {
      cell_selected = false;
    }
    if(cell_selected) {
      if(row == selectedRow || col == selectedCol) {
        color = Colors.deepOrange;
      }
      if(row ~/ problem.cell_size == selectedRow ~/ problem.cell_size && col ~/ problem.cell_size == selectedCol ~/ problem.cell_size) {
        color = Colors.deepOrange;
      }
      if(row == selectedRow && col == selectedCol) {
        color = Colors.white;
      }
    }
    else {
      color = Colors.white;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    if(problem == null || problem.success()) {
      problem = SudokuProblem();
    }

    if(button_grid == null) {
      button_grid = List();
    }
    SudokuState currentState = problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    board = GridView.count(
        padding: EdgeInsets.all(1),
        crossAxisCount: problem.board_size,
        childAspectRatio: 1,
        children: List.generate(problem.board_size * problem.board_size, (index) {
          var row = index ~/ problem.board_size;
          var col = index % problem.board_size;
          var cellNum = currentBoard[row][col];
          String toPlace = cellNum == 0 ? '' : cellNum.toString();

          Container button = Container(
            padding: getBoardPadding(index),
            child: Material(
              color: _getColor(row, col),
              child: InkWell(
                splashColor: Colors.deepOrange,
                onTap: () {
                  selectedRow = row;
                  selectedCol = col;
                  cell_selected = true;
                  setState(() {
                  });
                },
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
          );

          button_grid.add(button);
          return button;
        })
    );

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
        height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
        width: MediaQuery.of(context).size.width,
        child: Column (
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 40,
              padding: EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'LettuceSudoku',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'FiraCode-Bold',
                        fontSize: 26,
                      ),
                    ),
                  ),
                  InkWell(
                    hoverColor: Colors.teal[400],
                    splashColor: Colors.deepOrange,
                    child: Container(
                      height: 40,
                      width: 40,
                      child: Icon(Icons.menu, color: Colors.black, size: 30),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Flexible(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Container(
                    color: Colors.black,
                    child: board,
                  ),
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 2,
              child: GridView.count(
                padding: EdgeInsets.all(1),
                crossAxisCount: 5,
                childAspectRatio: 1,
                children: List.generate(10, (index) {
                  int num = (index + 1) % (problem.board_size + 1);
                  String toPlace = num == 0 ? 'X' : (index + 1).toString();
                  Container button = Container(
                    padding: getBoardPadding(index),
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        splashColor: Colors.deepOrange,
                        onTap: () {
                          doMove(num, selectedRow, selectedCol);
                          setState(() {});
                        },
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
                  );

                    button_grid.add(button);
                    return button;
                  }
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _resetBoard();
        },
        tooltip: 'Increment',
        child: Icon(Icons.android),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

//class BoardButton extends StatefulWidget {
//
//  int index;
//  int cell;
//  int num;
//
//  BoardButton({Key key}) : super(key: key) {
//    index = 0;
//    cell = 3;
//  }
//
//  BoardButton.withInfo(int index, int cell, num) {
//    this.index = index;
//    this.cell = cell;
//    this.num = num;
//  }
//
//  @override
//  _BoardButtonState createState() => _BoardButtonState.withInfo(index, cell, num);
//}
//
//class _BoardButtonState extends State<BoardButton> {
//  bool selected = false;
//  int index;
//  int cellSize;
//  int boardSize;
//  int num;
//
//  _BoardButtonState.withInfo(int index, int cell, int num) {
//    print('constructor');
//    this.index = index;
//    this.cellSize = cell;
//    this.boardSize = cell * cell;
//    this.num = num;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    print('build');
//    var toPlace = num == 0 ? '' : num.toString();
//    print('num ' + toPlace + ' ' + num.toString());
//    return GestureDetector(
//      onTap: () {
//        setState(() {
//          selected = !selected;
//        });
//      },
//      child: Center(
//        child: Container(
//          padding: EdgeInsets.all(1),
//          color: Colors.black,
//          child: Material(
//            child: InkWell(
//              splashColor: Colors.deepOrange,
//              onTap: () {},
//              child: AutoSizeText(
//                toPlace,
//                textAlign: TextAlign.center,
//                maxLines: 1,
//                style: TextStyle(
//                  fontFamily: 'FiraCode-Bold',
//                  fontSize: 40,
//                ),
//              ),
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//
//  EdgeInsets getBoardPadding(int index) {
//    int row = index ~/ boardSize;
//    int col = index % boardSize;
//
//    double thickness = 2;
//    double defaultThickness = 0.5;
//    double right = defaultThickness;
//    double top = defaultThickness;
//    double left = defaultThickness;
//    double bottom = defaultThickness;
//
//    if(row == 0) {
//      top = thickness;
//    }
//    if(col == 0) {
//      left = thickness;
//    }
//    if(row % cellSize == cellSize - 1) {
//      bottom = thickness;
//    }
//    if(col % cellSize == cellSize - 1) {
//      right = thickness;
//    }
//
//    return EdgeInsets.fromLTRB(left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
//  }
//}
