// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 02 – ARITHMETIC OPERATORS
// ───────────────────────────────────────────────────────────────────────────
// Complete each TODO so the printed values match the expected comments.
// No solutions here; see solutions/solution_02_arithmetic.dart.
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ── Problem 1 (isolated): / vs ~/ vs % ────────────────────────────────────
  // A basket holds 4 items totalling 13_700 minor units (137.00).
  const basketTotalMinor = 13700;
  const itemCount = 4;

  // TODO 1a: average price per item as a DOUBLE (use the right division op).
  final double averageMinor = 0; // replace 0
  // TODO 1b: whole naira part of the total (an int) using truncating division.
  final int wholeNaira = 0; // replace 0
  // TODO 1c: leftover kobo using modulo.
  final int leftoverKobo = 0; // replace 0

  print(averageMinor); // expected: 3425.0
  print(wholeNaira); // expected: 137
  print(leftoverKobo); // expected: 0

  // ── Problem 2 (applied): prefix vs postfix ────────────────────────────────
  // A login flow tracks attempts. Set each variable using ONE increment
  // expression so the captured value matches the expected output.
  var attempts = 0;

  // TODO 2a: capture the value AFTER incrementing (prefix).
  final int firstCapture = 0; // replace using ++attempts
  // TODO 2b: reset attempts to 0, then capture the value BEFORE incrementing.
  attempts = 0;
  final int secondCapture = 0; // replace using attempts++

  print(firstCapture); // expected: 1
  print(secondCapture); // expected: 0
  print(attempts); // expected: 1

  // ── Problem 3 (cross-concept): Euclidean modulo for ring assignment ───────
  // Tasks are assigned to workers in a ring of size 3 by index % workerCount.
  // Some task indices arrive negative (re-queued tasks use negative ids).
  const workerCount = 3;
  const taskIndices = [7, -7, 0, -1];

  // TODO 3: build a list of worker numbers, one per task index, using % so the
  //         result is ALWAYS a valid worker in 0..2 even for negative indices.
  final List<int> workerAssignments = []; // fill this

  print(workerAssignments); // expected: [1, 2, 0, 2]
}
