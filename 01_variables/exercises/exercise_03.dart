// =============================================================================
// EXERCISE 03 — SCOPE AND SHADOWING
// Run: dart run exercise_03.dart
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // 3.1 ISOLATED CONCEPT CHECK
  // Declare activeUserId = 'user-100'. Inside an if-block, declare a shadowing
  // activeUserId = 'user-200' and print it. After the block, print the outer
  // activeUserId. Show that the outer value was not changed.
  // MARKER CRITERIA: a genuinely separate inner declaration (uses var/type, not
  // bare assignment); inner print is user-200; outer print is user-100.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 3.2 APPLIED USAGE
  // Create a list of closures over the endpoints ['/login', '/logout'] using a
  // for-in loop so that each closure returns ITS OWN endpoint. Print the result
  // of calling the first and second closures.
  // MARKER CRITERIA: for-in (not C-style for) to get a fresh binding per
  // iteration; closures capture distinct values; outputs are /login and /logout.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 3.3 COMBINED WITH 01 (reference semantics)
  // Demonstrate the C-style-for capture trap: build closures over a shared
  // counter with `for (var attempt = 0; attempt < 3; attempt++)` and show all
  // three return the loop's final value. Then explain in a comment why this is a
  // scope/reference issue rather than a value-copy.
  // MARKER CRITERIA: C-style for; one shared `attempt` binding; all closures
  // print 3; comment correctly attributes the cause to a single shared variable
  // captured by reference.
  // Your solution:


}
