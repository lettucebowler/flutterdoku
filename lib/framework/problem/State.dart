abstract class State {
  /*
     * Tests for equality between this state and the argument state.
     * The argument state will need to be cast to a specific class type.
     * @param other the state to test against this state
     * @return true if this state and the other are equal, false otherwise
    */
  bool equals(Object other);

  /*
     *Creates a primitive, non-GUI representation of this State object.
     *@return the string representation of this state
    */

  @override
  String toString();
}
