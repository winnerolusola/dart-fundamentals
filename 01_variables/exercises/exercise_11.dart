// =============================================================================
// EXERCISE 11 — WILDCARD VARIABLES (_)   [requires language version 3.7+]
// Run: dart run exercise_11.dart
// =============================================================================

List<int> frameSizes() => [120, 256, 256, 64];

void main() {
  // ---------------------------------------------------------------------------
  // 11.1 ISOLATED CONCEPT CHECK
  // Iterate frameSizes() with a for-in loop that IGNORES each element using `_`,
  // counting how many frames there are, and print the count.
  // MARKER CRITERIA: the loop variable is `_` (non-binding); a separate counter
  // is incremented; output is 4. (Reading `_` would be "Undefined name '_'.")
  // Your solution:


  // ---------------------------------------------------------------------------
  // 11.2 APPLIED USAGE
  // Catch a thrown FormatException with a wildcard catch clause that ignores the
  // exception object, printing a fixed message. Then declare two `_` locals in
  // the same scope to show they do not collide.
  // MARKER CRITERIA: `catch (_)` drops the exception; two `_` locals compile with
  // no "already defined" error; the catch message prints.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 11.3 COMBINED WITH 03 (scope/no-collision rule)
  // Use a wildcard function parameter in a .where callback to keep every element,
  // and explain in a comment how this relates to the scope rule that normally
  // forbids two identical names in one scope.
  // MARKER CRITERIA: `(_) => true` used as the predicate; result length is 4;
  // comment correctly states that `_` relaxes the "already defined in this scope"
  // rule (file 03) precisely because it is non-binding.
  // Your solution:


}
