import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/helpers.dart';

import 'SudokuScreen.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    readFromPrefs().then((data) {
      applyGameState().then((data2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SudokuScreen()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            // width: MediaQuery.of(context).size.width,
            color: CustomStyles.polarNight[3],
          ),
          Container(
            width: getBodyWidth(context),
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // CircleAvatar(
                        //   child: Icon(
                        //     Icons.games_rounded,
                        //     color: CustomStyles.polarNight[3],
                        //     size: 100,
                        //   ),
                        //   backgroundColor: CustomStyles.snowStorm[0],
                        //   radius: 50,
                        // ),
                        Row(children: [
                          Spacer(),
                          Expanded(
                            flex: 4,
                            child: Image.asset('assets/icon/splashIcon.png'),
                          ),
                          Spacer(),
                        ]),
                        // Padding(padding: EdgeInsets.only(top: 30)),
                        Text('LettuceSudoku',
                            style: TextStyle(
                                fontSize: 30,
                                color: CustomStyles.snowStorm[2])),
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
                              CustomStyles.aurora[2]),
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        Text(
                          'Sudoku at its worst',
                          style: TextStyle(
                            color: CustomStyles.snowStorm[2],
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
