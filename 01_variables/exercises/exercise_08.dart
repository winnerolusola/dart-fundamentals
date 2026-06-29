// =============================================================================
// EXERCISE 08 — const
// Run: dart run exercise_08.dart
// =============================================================================

// 8.2 / 8.3 use this const-constructible class.
class GridPoint {
  final int column;
  final int row;
  const GridPoint(this.column, this.row);
}

void main() {
  // ---------------------------------------------------------------------------
  // 8.1 ISOLATED CONCEPT CHECK
  // Declare const maxRetries = 5 and a const double computed from const operands
  // (e.g. const double atm = 1.01325 * 1000000). Print both. In a comment, state
  // why DateTime.now() could not be used here.
  // MARKER CRITERIA: two const declarations, one using arithmetic on const
  // operands; both printed; comment correctly says DateTime.now() is a runtime
  // value, not a compile-time constant.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 8.2 APPLIED USAGE
  // Demonstrate canonicalisation: create two const GridPoint(0, 0) values and a
  // non-const GridPoint(0, 0). Print identical(...) for the two const ones (true)
  // and for one const vs the non-const one (false).
  // MARKER CRITERIA: const constructor invoked with the const keyword for the
  // first two; the third built without const; identical is true for the const
  // pair and false against the non-const instance.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 8.3 COMBINED WITH 07 (const is implicitly final) AND THE COLLECTION TRAP
  // Replace a mutable-by-accident list with a const one. Declare const
  // allowedRoles = ['admin']. Show that rebinding fails (compile) and mutation
  // fails (runtime) by stating each in a comment, then print the const list.
  // MARKER CRITERIA: const list declared; comment correctly states rebinding is a
  // compile error ("Constant variables can't be assigned a value") because const
  // implies final (file 07), and mutation is a runtime error ("Cannot add to an
  // unmodifiable list"); the list prints as [admin].
  // Your solution:


}
