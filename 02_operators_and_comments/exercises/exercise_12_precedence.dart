// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 12 – OPERATOR PRECEDENCE AND ASSOCIATIVITY
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_12_precedence.dart.
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ── Problem 1 (isolated): predict the grouping ────────────────────────────
  // Without adding parentheses, set each result to the value Dart computes.
  // TODO 1a: 2 + 3 * 4
  final int r1 = 0; // replace
  // TODO 1b: (2 + 3) * 4 – here parentheses ARE present
  final int r2 = 0; // replace
  // TODO 1c: 12 % 5 == 2 && 9 % 5 == 4   (predict the bool)
  final bool r3 = false; // replace

  print(r1); // expected: 14
  print(r2); // expected: 20
  print(r3); // expected: true

  // ── Problem 2 (applied): fix the bitwise/equality trap ────────────────────
  const writeFlag = 0x02;
  const permissions = 0x06;

  // The following expression does not compile because & binds lower than ==:
  //   final hasWrite = permissions & writeFlag == writeFlag;
  // TODO 2: write the CORRECT expression with parentheses so hasWrite is true
  //         when the write bit is set.
  final bool hasWrite = false; // replace

  print(hasWrite); // expected: true

  // ── Problem 3 (cross-concept): right-associative ternary ladder ───────────
  // Map a score to a band: >=70 'pass', >=50 'borderline', else 'fail'.
  // Use a single nested ternary (relying on right-associativity).
  const score = 55;

  // TODO 3:
  final String band = ''; // replace

  print(band); // expected: borderline
}
