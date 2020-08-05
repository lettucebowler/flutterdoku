import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'domains/sudoku/SudokuProblem.dart';
import 'domains/sudoku/SudokuState.dart';
import 'dart:ui';

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
  var menuHeight = 70;


  void _resetBoard() {
    problem = SudokuProblem();
    setState(() {});
  }

  void _highLightOnClick() {
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

//          InkWell button = InkWell(
//            onTap: () {}, // needed
//            child: Ink( // use Ink
//              width: 200,
//              height: 200,
//              color: Colors.blue,
//            ),
//          );

          Container button = Container(
            color: Colors.black,
            padding: getBoardPadding(index),
            child: Material(
              child: InkWell(
                splashColor: Colors.deepOrange,
                onTap: () {},
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

//          Container button = Container(
//            padding: getBoardPadding(index),
//            child: FlatButton(
//              color: Colors.white,
//              hoverColor: Colors.teal[400],
//              splashColor: Colors.deepOrange,
//              onPressed: () {
//              },
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
//          );
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
//                  width: getConstraint(),
//                  height: getConstraint(),
                    padding: EdgeInsets.all(4),
                    child: Container(
                      color: Colors.black,
                      child: board,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
//        child: board,
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
