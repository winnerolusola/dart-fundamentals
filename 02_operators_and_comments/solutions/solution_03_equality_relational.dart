// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 03 – EQUALITY AND RELATIONAL OPERATORS
// ═══════════════════════════════════════════════════════════════════════════

class WarehouseBin {
  final String aisle;
  final int shelf;
  const WarehouseBin(this.aisle, this.shelf);

  @override
  bool operator ==(Object other) =>
      other is WarehouseBin && other.aisle == aisle && other.shelf == shelf;

  @override
  int get hashCode => Object.hash(aisle, shelf);
}

void main() {
  // Problem 1
  final first = WarehouseBin('A', 3);
  final second = WarehouseBin('A', 3);

  final bool sameValue = first == second;
  final bool sameObject = identical(first, second);

  print(sameValue); // true
  print(sameObject); // false

  final unique = {first, second};
  print(unique.length); // 1

  // Problem 3 – NaN cannot be detected with ==; use isNaN.
  const readings = [22.5, 35.1, double.nan, 30.0];
  final statuses = [
    for (final reading in readings)
      reading.isNaN
          ? 'invalid'
          : reading > 30.0
              ? 'high'
              : 'normal'
  ];
  print(statuses); // [normal, high, invalid, normal]
}
