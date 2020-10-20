import 'dart:core';
import 'Mover.dart';
import 'Problem.dart';
import 'State.dart';

/*
 * This class provides support as the user attempts to solve a problem.
 * It tries moves indicated by the user, updates the current state as
 * necessary, keeps track of the move count, and checks whether the problem
 * has been solved.
 * @author tcolburn
 */
class SolvingAssistant {
  /*
  * Creates a new solving assistant.
  * @param problem the problem being solved
  */
  SolvingAssistant(Problem problem) {
    this.problem = problem;
    mover = problem.getMover();
    problemSolved = false;
    moveCount = 0;
  }

  /*
     * Tries a move on the current state of the problem, updating the
     * current state if required.
     * @param move the move to try, as a string
     */
  void tryMove(String move) {
    moveLegal = true;
    var next = mover.doMove(move, problem.getCurrentState());
    if (next != null) {
      update(next);
    } else {
      moveLegal = false;
    }
  }

  /*
     * Getter for the problem this solving assistant is working on.
     * @return the problem
     */
  Problem getProblem() {
    return problem;
  }

  /*
     * Getter for the move count so far.
     * @return the move count
     */
  int getMoveCount() {
    return moveCount;
  }

  /*
     * Getter for the legality of the most recently tried move.
     * @return true if the most recently tried move is legal, false otherwise
     */
  bool isMoveLegal() {
    return moveLegal;
  }

  /*
     * Resets the problem to its initial state.
     * Also resets the move count and problem solved status.
     */
  void reset() {
    moveCount = 0;
    problem.setCurrentState(problem.getInitialState());
    problemSolved = false;
  }

  /*
     * Updates the current state of the problem to the given state.
     * Also increments the move count and checks the problem solved status.
     * @param s
     */
  void update(State s) {
    moveCount++;
    problem.setCurrentState(s);
    if (problem.success()) {
      problemSolved = true;
    }
  }

  /*
     * A JavaFX property indicating whether the problem has been solved.
     */
  bool problemSolved;

//     boolProperty problemSolvedProperty() {
//        return problemSolved;
//    }

  bool isProblemSolved() {
    return problemSolved;
  }

  void setProblemSolved(bool value) {
    problemSolved = (value);
  }

  int moveCount;

  Problem problem;
  Mover mover;
  bool moveLegal;
}
