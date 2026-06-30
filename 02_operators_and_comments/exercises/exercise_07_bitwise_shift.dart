// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 07 – BITWISE AND SHIFT OPERATORS
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_07_bitwise_shift.dart.
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // Permission bits for an auth system.
  const canRead = 1 << 0; // 1
  const canWrite = 1 << 1; // 2
  const canDelete = 1 << 2; // 4

  // ── Problem 1 (isolated): set / clear / toggle ────────────────────────────
  var permissions = canRead; // start with read only

  // TODO 1a: grant write (set the write bit).
  // TODO 1b: grant delete (set the delete bit).
  // TODO 1c: revoke read (clear the read bit) using & with ~.

  print(permissions); // expected: 6

  // ── Problem 2 (applied): test a bit (mind the precedence) ─────────────────
  // TODO 2: set canDeleteNow to whether the delete bit is set in permissions.
  //         Remember & binds LOWER than ==; parenthesise correctly.
  final bool canDeleteNow = false; // replace

  print(canDeleteNow); // expected: true

  // ── Problem 3 (cross-concept): power-of-two fast paths and shift sign ─────
  const value = 37;

  // TODO 3a: double `value` using a shift.
  final int doubled = 0; // replace
  // TODO 3b: halve `value` (non-negative) using a shift.
  final int halved = 0; // replace
  // TODO 3c: value mod 8 using a bitmask (& with 8-1).
  final int modEight = 0; // replace
  // TODO 3d: arithmetic right shift of -37 by 1 (observe it floors).
  final int negShifted = 0; // replace

  print(doubled); // expected: 74
  print(halved); // expected: 18
  print(modEight); // expected: 5
  print(negShifted); // expected: -19
}
