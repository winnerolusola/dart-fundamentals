// =============================================================================
// EXERCISE 01 — VARIABLE DECLARATION AND REFERENCE SEMANTICS
// Run: dart run exercise_01.dart
// Write your solution in the blank space below each problem statement,
// then run the file to verify your output.
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // 1.1 ISOLATED CONCEPT CHECK
  // Declare a product name using inference (no explicit type) and a unit price
  // in kobo using inference. Print each on its own line.
  // MARKER CRITERIA: one inferred String and one inferred int; no type
  // annotations; two print statements producing the two values.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 1.2 APPLIED USAGE
  // You receive a default permissions list ['read']. Create a second name that
  // refers to the SAME list, add 'write' through the second name, then print the
  // first name. Then print whether the two names refer to the same object.
  // MARKER CRITERIA: the second variable is assigned from the first (alias, not
  // a copy); the mutation through the alias is visible via the first name;
  // identical(...) returns true.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 1.3 EXTENDED APPLIED (no earlier sub-concept exists before this file)
  // Fix the aliasing bug from 1.2: starting again from ['read'], produce a
  // grantedPermissions that is an independent COPY, add 'write' to the copy, and
  // show the original is unchanged.
  // MARKER CRITERIA: grantedPermissions is built as a new list (spread or
  // List.of); mutation does NOT affect the original; identical(...) is false.
  // Your solution:


}
