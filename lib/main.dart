import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lettuce_sudoku/screens/LoadingScreen.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/helpers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  await readFromPrefs();
//  await applyGameState();
  runApp(LettuceSudoku());
}

class LettuceSudoku extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LettuceSudoku',
      theme: ThemeData(
        primarySwatch: getMaterialColor(CustomStyles.nord3),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: getMaterialColor(CustomStyles.nord6),
      ),
      home: LoadingScreen(title: 'LettuceSudoku'),
    );
  }
}
