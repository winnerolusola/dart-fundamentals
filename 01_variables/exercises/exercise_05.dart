// =============================================================================
// EXERCISE 05 — DEFAULT VALUES AND DEFINITE-ASSIGNMENT FLOW ANALYSIS
// Run: dart run exercise_05.dart
// =============================================================================

int countActiveSessions() => 7;

void main() {
  // ---------------------------------------------------------------------------
  // 5.1 ISOLATED CONCEPT CHECK
  // Declare a non-nullable int sessionToken WITHOUT an initialiser. Assign it in
  // both branches of an if/else based on countActiveSessions() > 0, then print
  // it. The program must compile and print a value.
  // MARKER CRITERIA: sessionToken declared with no initialiser; assigned on BOTH
  // branches; compiles (definite assignment satisfied); prints the assigned value.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 5.2 APPLIED USAGE
  // Declare a non-nullable int retryCeiling with no initialiser. Assign it from a
  // configuredCeiling of 5 when that value is >= 0; otherwise throw a StateError.
  // Print retryCeiling. Explain in a comment why this compiles despite the else
  // branch not assigning.
  // MARKER CRITERIA: the else branch throws (discharging that path); compiles;
  // prints 5; comment correctly states that a throwing path cannot reach the read.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 5.3 COMBINED WITH 04 (nullable promotion)
  // Declare String? authHeader = 'Bearer xyz'. Using definite-assignment/promotion
  // (NOT a null-aware operator), print whether it starts with 'Bearer' only after
  // proving it is non-null.
  // MARKER CRITERIA: nullable declaration (file 04); `!= null` promotes it; method
  // call only inside the promoted block; output true.
  // Your solution:


}
