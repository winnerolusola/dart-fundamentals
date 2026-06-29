// =============================================================================
// EXERCISE 08 — const
// Run: dart run solutions/solution_08.dart
// =============================================================================

// 8.2 / 8.3 use this const-constructible class.
class GridPoint {
  final int column;
  final int row;
  const GridPoint(this.column, this.row);
}

void main() {
  {
  // ---------------------------------------------------------------------------
  // 8.1 ISOLATED CONCEPT CHECK
  const maxRetries = 5;
  const double atm = 1.01325 * 1000000;
  print(maxRetries); // 5
  print(atm);        // 1013250.0
  // DateTime.now() is computed at runtime, so it cannot initialise a const:
  // "Const variables must be initialized with a constant value."

  }

  {
  // ---------------------------------------------------------------------------
  // 8.2 APPLIED USAGE
  const cornerA = GridPoint(0, 0);
  const cornerB = GridPoint(0, 0);
  var liveCorner = GridPoint(0, 0);
  print(identical(cornerA, cornerB));    // true
  print(identical(cornerA, liveCorner)); // false

  }

  {
  // ---------------------------------------------------------------------------
  // 8.3 COMBINED WITH 07 (const is implicitly final) AND THE COLLECTION TRAP
  const allowedRoles = <String>['admin'];
  print(allowedRoles); // [admin]
  // allowedRoles = ['guest'];   // compile error: const is implicitly final.
  // allowedRoles.add('guest');  // runtime error: unmodifiable list.

  }

}
