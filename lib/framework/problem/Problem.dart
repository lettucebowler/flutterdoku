import 'dart:core';
import 'State.dart';

/*
 * This class represents problems in a problem solving domain.
 * Getters and setters are provided for the problem name and
 * introduction, the initial, current, and final States of the
 * problem, and the problem's associated Mover object.
 * This class can be subclassed, especially if the success method
 * needs to be overridden.
 * @author tcolburn
 */
class Problem {
  String getName() {
    return name;
  }

  void setName(String name) {
    this.name = name;
  }

  String getIntroduction() {
    return introduction;
  }

  void setIntroduction(String introduction) {
    this.introduction = introduction;
  }

  State getInitialState() {
    return initialState;
  }

  void setInitialState(State initialState) {
    this.initialState = initialState;
  }

  State getFinalState() {
    return finalState;
  }

  void setFinalState(State finalState) {
    this.finalState = finalState;
  }

  State getCurrentState() {
    return currentState;
  }

  void setCurrentState(State currentState) {
    this.currentState = currentState;
  }

  /*
     * Checks if the current state solves the problem.
     * This method may need to be overridden if the domain does not
     * have a unique final state.
     * @return whether the current state solves the problem
     */
  bool success() {
    return getCurrentState().equals(getFinalState());
  }

  late String name;
  late String introduction;
  late State initialState;
  late State currentState;
  late State finalState;
}
