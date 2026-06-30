// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 05 – ASSIGNMENT OPERATORS
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_05_assignment.dart.
// ═══════════════════════════════════════════════════════════════════════════

int sideEffectCalls = 0;

/// Returns 1 and records that it was called, to test single evaluation.
int targetIndex() {
  sideEffectCalls++;
  return 1;
}

void main() {
  // ── Problem 1 (isolated): ??= lazy default ────────────────────────────────
  String? cachedRegion; // null

  // TODO 1: assign 'eu-west-1' to cachedRegion ONLY if it is null, using ??=.
  //         Then attempt to assign 'us-east-1' the same way and observe it is
  //         ignored.

  print(cachedRegion); // expected: eu-west-1

  // ── Problem 2 (applied): compound assignment running total ────────────────
  // Apply these mutations to runningMinor IN ORDER using compound operators:
  //   add 999, subtract 250, multiply by 2, truncating-divide by 3, mod 1000.
  var runningMinor = 1000;

  // TODO 2: five compound-assignment statements.

  print(runningMinor); // expected: 166

  // ── Problem 3 (cross-concept): single evaluation of a side-effecting target
  final stock = [10, 20, 30];
  sideEffectCalls = 0;

  // TODO 3: increase the element at targetIndex() by 5 using a SINGLE
  //         compound-assignment statement so targetIndex() runs exactly once.

  print(stock[1]); // expected: 25
  print(sideEffectCalls); // expected: 1
}
