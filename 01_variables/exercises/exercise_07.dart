// =============================================================================
// EXERCISE 07 — final
// Run: dart run exercise_07.dart
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // 7.1 ISOLATED CONCEPT CHECK
  // Declare a final orderId (inferred) set to 'INV-4501' and a final String
  // customerName set to 'Ada'. Print both. (Attempting to reassign either would
  // be a compile error: "The final variable ... can only be set once.")
  // MARKER CRITERIA: one inferred final and one annotated final; both printed; no
  // reassignment.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 7.2 APPLIED USAGE
  // Show the collection trap: declare a final List<String> orderTags = ['new'],
  // add 'priority' through it, and print the list. Then state in a comment which
  // operation WOULD be a compile error.
  // MARKER CRITERIA: `final` on the list; .add succeeds (mutating the object);
  // print shows both elements; comment correctly identifies that rebinding
  // (orderTags = [...]) is the compile error, not .add.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 7.3 COMBINED WITH 05 (definite assignment of a final local)
  // Declare a final int shippingFeeKobo WITHOUT an initialiser. Assign it 0 or
  // 1500 in the two branches of an if/else, then print it. Note that final still
  // obeys definite assignment.
  // MARKER CRITERIA: final local with no initialiser; assigned exactly once on
  // every path; compiles; prints the chosen value.
  // Your solution:


}
