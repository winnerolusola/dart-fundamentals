// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 02 – ARITHMETIC OPERATORS
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // Problem 1
  const basketTotalMinor = 13700;
  const itemCount = 4;

  final double averageMinor = basketTotalMinor / itemCount;
  final int wholeNaira = basketTotalMinor ~/ 100;
  final int leftoverKobo = basketTotalMinor % 100;

  print(averageMinor); // 3425.0
  print(wholeNaira); // 137
  print(leftoverKobo); // 0

  // Problem 2
  var attempts = 0;
  final int firstCapture = ++attempts; // increment, then read -> 1
  print(firstCapture); // 1

  attempts = 0;
  final int secondCapture = attempts++; // read, then increment -> 0
  print(secondCapture); // 0
  print(attempts); // 1

  // Problem 3 – Euclidean modulo keeps the worker index in 0..2 for negatives.
  const workerCount = 3;
  const taskIndices = [7, -7, 0, -1];
  final workerAssignments = [for (final index in taskIndices) index % workerCount];
  print(workerAssignments); // [1, 2, 0, 2]
}
