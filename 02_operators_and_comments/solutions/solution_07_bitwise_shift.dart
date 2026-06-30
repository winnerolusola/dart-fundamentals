// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 07 – BITWISE AND SHIFT OPERATORS
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  const canRead = 1 << 0; // 1
  const canWrite = 1 << 1; // 2
  const canDelete = 1 << 2; // 4

  // Problem 1
  var permissions = canRead; // 1
  permissions |= canWrite; // set write -> 3
  permissions |= canDelete; // set delete -> 7
  permissions &= ~canRead; // clear read -> 6
  print(permissions); // 6

  // Problem 2 – parenthesise: & is lower than ==.
  final bool canDeleteNow = (permissions & canDelete) != 0;
  print(canDeleteNow); // true

  // Problem 3
  const value = 37;
  final int doubled = value << 1; // 74
  final int halved = value >> 1; // 18
  final int modEight = value & (8 - 1); // 5
  final int negShifted = -37 >> 1; // -19 (arithmetic shift floors)
  print(doubled); // 74
  print(halved); // 18
  print(modEight); // 5
  print(negShifted); // -19
}
