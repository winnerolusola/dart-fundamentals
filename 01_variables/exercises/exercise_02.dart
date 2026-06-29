// =============================================================================
// EXERCISE 02 — TYPE ANNOTATIONS, INFERENCE, AND Object / Object? / dynamic
// Run: dart run exercise_02.dart
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // 2.1 ISOLATED CONCEPT CHECK
  // Declare a temperature reading as a double using an explicit annotation, and
  // a humidity reading using inference. Print the runtimeType of each.
  // MARKER CRITERIA: one explicitly annotated double, one inferred double; both
  // runtimeTypes print as double.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 2.2 APPLIED USAGE
  // A payload may be any value but you must NOT lose static checking. Declare it
  // as Object holding the int 42, then safely recover and print its value
  // doubled, using an `is` check to promote it before arithmetic.
  // MARKER CRITERIA: variable typed Object (not dynamic); an `is int` check that
  // promotes the value; arithmetic only inside the promoted block.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 2.3 COMBINED WITH 01 (declaration/reference)
  // Build a window of readings as List<int> [12, 15, 14] (a complete generic
  // type, not a raw one). Create a second name aliasing the same list, add 20
  // through the alias, and print the sum of the original via reduce.
  // MARKER CRITERIA: List<int> with explicit type argument; alias shares the
  // object (file 01); reduce sums all four elements to 61.
  // Your solution:


}
