import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/helpers.dart';
import 'package:lettuce_sudoku/util/globals.dart';
import 'SudokuScreen.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _asyncInitState();
  }

  Future<bool> _asyncInitState() async {
    readFromPrefs().then((value) async {
      problem = await getNextGame();
      applyGameState();
    });

    SudokuScreen game = SudokuScreen();
    Timer(Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => game));
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: CustomStyles.nord3,
          ),
          Center(
            child: Container(
              width: getBodyWidth(context),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Spacer(),
                          Expanded(
                            flex: 4,
                            child: Image.asset('assets/icon/splashIcon.png'),
                          ),
                          Spacer(),
                        ]),
                        // Padding(padding: EdgeInsets.only(top: 30)),
                        Text('Lettuce Sudoku',
                            style: TextStyle(
                                fontSize: 30, color: CustomStyles.nord6)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              CustomStyles.nord13),
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        Text(
                          'Sudoku at its worst',
                          style: TextStyle(
                            color: CustomStyles.nord6,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
