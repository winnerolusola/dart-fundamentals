// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 12 – OPERATOR PRECEDENCE AND ASSOCIATIVITY
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // Problem 1
  final int r1 = 2 + 3 * 4; // 14  (* before +)
  final int r2 = (2 + 3) * 4; // 20
  final bool r3 = 12 % 5 == 2 && 9 % 5 == 4; // true
  print(r1); // 14
  print(r2); // 20
  print(r3); // true

  // Problem 2 – parenthesise the bitwise AND; & is lower than ==.
  const writeFlag = 0x02;
  const permissions = 0x06;
  final bool hasWrite = (permissions & writeFlag) == writeFlag;
  print(hasWrite); // true

  // Problem 3 – right-associative ternary ladder.
  const score = 55;
  final String band = score >= 70
      ? 'pass'
      : score >= 50
          ? 'borderline'
          : 'fail';
  print(band); // borderline
}
