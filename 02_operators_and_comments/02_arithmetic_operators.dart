// ═══════════════════════════════════════════════════════════════════════════
// 02 – ARITHMETIC OPERATORS
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// Arithmetic operators compute numeric results: sums, differences, products,
// quotients, remainders, and sign changes. In application code they appear
// everywhere money, quantities, time, or sensor values are processed. The
// problem they solve is obvious in the abstract and treacherous in detail:
// the abstract operation "divide" splits into two distinct Dart operators with
// different return types, and "remainder" splits into two operations that
// disagree on negative numbers. A working developer who treats `/`, `~/`, and
// `%` as the school-arithmetic operators they resemble will ship subtle bugs.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   a + b      addition
//   a - b      subtraction
//   -a         unary minus (negation)
//   a * b      multiplication
//   a / b      division, ALWAYS yields a double
//   a ~/ b     truncating division, yields an int when both operands are int
//   a % b      Euclidean modulo, result is never negative
//
//   ++a        prefix increment: increment, then yield the NEW value
//   a++        postfix increment: yield the OLD value, then increment
//   --a        prefix decrement: decrement, then yield the NEW value
//   a--        postfix decrement: yield the OLD value, then decrement
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// Each operator is a method on `num` (or `int`/`double`). `a + b` is sugar for
// `a.+(b)`. The static type of the result is inferred from the operand types
// and the method signature: `int + int` is `int`, `int + double` is `double`,
// and, importantly, `int / int` is `double` because `num.operator /` is declared to
// return `double`. The analyzer enforces this. Assigning `5 / 2` to an `int`
// variable is a compile error, not a runtime surprise.
//
// `++` and `--` desugar to a read, an add or subtract of the literal 1, and a
// write back to the same storage location. The compiler rejects them on a
// non-assignable target (a literal, a `final` variable, the result of an
// expression) because there is nowhere to write the new value.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// On the Dart VM, `int` is a 64-bit signed integer; arithmetic that overflows
// 64 bits wraps around in two's complement. On the web (compiled to JavaScript)
// `int` is backed by a 64-bit float, so the safe integer range is roughly
// +/- 2^53 and large-integer arithmetic loses precision instead of wrapping.
// `double` is an IEEE 754 64-bit float on every platform, which is why `0.1 +
// 0.2` is not exactly `0.3`. Division by zero on doubles yields the IEEE
// sentinels Infinity or NaN rather than throwing.
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - `/` always returns a double, even for `4 / 2`, which is `2.0`.
//  - `~/` returns an int (when both operands are int) by truncating the
//    mathematical quotient.
//  - Prefix forms yield the value AFTER the change; postfix forms yield the
//    value BEFORE the change. This is the source of the classic `b = a++`
//    versus `b = ++a` difference shown in the code below.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - `~/` truncates TOWARD ZERO, not toward negative infinity. `-7 ~/ 2` is
//    `-3`, not `-4`. Developers from Python (where `//` floors) get this wrong.
//  - `%` is EUCLIDEAN. Its result is always in the range `0 <= r < b.abs()`,
//    so `-7 % 3` is `2`, never `-1`. This differs from C, Java, and JavaScript,
//    where `-7 % 3` is `-1`. If you need the C-style sign-of-dividend remainder,
//    call `(-7).remainder(3)`, which is `-1`.
//  - `~/` and `%` do NOT use the same division. `~/` pairs with `remainder()`:
//    `a == (a ~/ b) * b + a.remainder(b)`. The Euclidean quotient implied by
//    `%` can differ from `a ~/ b` for negative operands.
//  - Integer `~/ 0` and `% 0` THROW at runtime. Double division by zero does
//    not throw; `5.0 / 0` is `Infinity`, `0.0 / 0` is `NaN`.
//  - Floating-point sums are not associative. `(a + b) + c` may differ from
//    `a + (b + c)` in the last bits. Never compare money or accumulated
//    sensor sums with `==` after double arithmetic.
//  - `++` on a `double` works: `temperature++` adds `1.0`. The operators are
//    not int-only.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// Integer add, subtract, and multiply compile to single machine instructions
// on the VM and are effectively free. Division (`/`, `~/`, `%`) is markedly
// slower than multiplication on every CPU; in a hot loop, replacing `x ~/ 2`
// with `x >> 1` or `x % 2` with `x & 1` (covered in 07) is a real micro
// optimisation. Double arithmetic carries the usual IEEE 754 cost and, on the
// web, integers above 2^53 silently lose precision, which is a correctness
// cost rather than a speed cost.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Two decisions stand out. First, `/` returns `double` unconditionally so that
// the type of an expression never depends on runtime values: the analyzer can
// always type `a / b` as `double` without knowing whether the division comes
// out even. The cost is that `~/` exists as a separate operator for the common
// "I want an int" case. Second, `%` is Euclidean rather than truncated so that
// `x % n` is always a valid array-like index in `[0, n)` for positive `n`. This
// makes modulo arithmetic (clock faces, ring buffers, hash bucketing) correct
// without a manual `if (r < 0) r += n` correction that C-style remainder forces.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// Every arithmetic operator has a compound-assignment partner in 05
// (`+=`, `~/=`, `%=`, and so on). `/` interacts with equality (03): never use
// `==` on the double it returns. Precedence (12) places `*`, `/`, `~/`, `%`
// above `+` and `-`, so `2 + 3 * 4` is `14`. Bitwise shifts (07) are the
// integer-only fast path for powers-of-two multiply and divide.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: assigning a `/` result to an int.
//    "A value of type 'double' can't be assigned to a variable of type 'int'."
//  - Compile error: `++` on a non-assignable target.
//    "The operator '++' can't be used with a value of type '...'" / for a
//    literal: "Illegal assignment to non-assignable expression."
//  - Runtime error: integer division by zero.
//    "Unsupported operation: Result of truncating division is Infinity: 10 ~/ 0"
//  - Logical error: assuming `-7 % 3 == -1` (it is `2`), or comparing the
//    double from `/` with `==`.
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ── The six binary arithmetic operators ─────────────────────────────────
  final itemPriceMinor = 4599; // 45.99 stored in minor units
  final quantity = 3;

  print(itemPriceMinor + 100); // 4699
  print(itemPriceMinor - 599); // 4000
  print(itemPriceMinor * quantity); // 13797

  // `/` ALWAYS yields a double, even when the result is whole.
  final averagePerItem = itemPriceMinor / quantity;
  print(averagePerItem); // 1533.0
  print(averagePerItem.runtimeType); // double

  // `~/` yields an int by truncating toward zero.
  final wholeNairaPart = itemPriceMinor ~/ 100;
  print(wholeNairaPart); // 45
  print(wholeNairaPart.runtimeType); // int

  // `%` yields the Euclidean remainder, always non-negative for positive b.
  final koboRemainder = itemPriceMinor % 100;
  print(koboRemainder); // 99

  // ── Unary minus ─────────────────────────────────────────────────────────
  final refundMinor = -itemPriceMinor; // negation
  print(refundMinor); // -4599

  // ── Truncation direction of ~/ (toward zero, not toward -infinity) ──────
  print(7 ~/ 2); // 3
  print(-7 ~/ 2); // -3   (toward zero; Python's // would give -4)
  print(7 ~/ -2); // -3
  print(-7 ~/ -2); // 3

  // ── Euclidean sign behaviour of % (result never negative for positive b) ─
  print(7 % 3); // 1
  print(-7 % 3); // 2    (NOT -1; this is the Dart divergence)
  print(7 % -3); // 1    (0 <= r < |b|, sign of r is always positive)
  print(-7 % -3); // 2

  // remainder() gives the C/Java/JavaScript sign-of-dividend result.
  print((-7).remainder(3)); // -1
  print(7.remainder(-3)); // 1

  // The identity that actually holds is with remainder(), not %:
  // a == (a ~/ b) * b + a.remainder(b)
  print((-7 ~/ 3) * 3 + (-7).remainder(3)); // -7

  // ── Prefix vs postfix increment and decrement ───────────────────────────
  // Prefix: change first, then yield the new value.
  var loginAttempts = 0;
  final afterPreIncrement = ++loginAttempts; // increment a, then read
  print(loginAttempts); // 1
  print(afterPreIncrement); // 1

  // Postfix: yield the old value, then change.
  loginAttempts = 0;
  final afterPostIncrement = loginAttempts++; // read a, then increment
  print(loginAttempts); // 1
  print(afterPostIncrement); // 0

  // Decrement mirrors increment.
  var remainingRetries = 3;
  print(--remainingRetries); // 2  (prefix: new value)
  print(remainingRetries--); // 2  (postfix: old value)
  print(remainingRetries); // 1

  // Increment also works on doubles; it adds 1.0.
  var sensorTempCelsius = 22.5;
  sensorTempCelsius++;
  print(sensorTempCelsius); // 23.5

  // ── Floating-point is not exact; never compare double results with == ───
  final accumulated = 0.1 + 0.2;
  print(accumulated); // 0.30000000000000004
  print(accumulated == 0.3); // false

  // ── Double division by zero does NOT throw; it yields IEEE sentinels ────
  print(5.0 / 0); // Infinity
  print(-5.0 / 0); // -Infinity
  print(0.0 / 0); // NaN

  // ── INCORRECT USAGE: compile errors ─────────────────────────────────────
  // (a) Assigning a double result to an int.
  //
  //     int unitPrice = itemPriceMinor / quantity;
  //
  //     Error: "A value of type 'double' can't be assigned to a variable of
  //     type 'int'."

  // (b) Incrementing a final variable (no assignable storage).
  //
  //     final attempts = 0;
  //     attempts++;
  //
  //     Error: "The final variable 'attempts' can't be used as a setter."

  // (c) Incrementing a literal (not assignable).
  //
  //     5++;
  //
  //     Error: "Illegal assignment to non-assignable expression."

  // ── INCORRECT USAGE: runtime error ──────────────────────────────────────
  // Integer truncating division by zero throws.
  //
  //     final perGroup = 10 ~/ 0;
  //
  //     Unhandled exception:
  //     Unsupported operation: Result of truncating division is Infinity: 10 ~/ 0

  // ── INCORRECT USAGE: logical error ──────────────────────────────────────
  // Assuming C-style remainder. A scheduler that places task index i into
  // worker (i % workerCount) is correct only because Dart's % is non-negative.
  // The same code with a manual C-style remainder on a negative i would index
  // out of range. The compiler cannot catch the wrong mental model; only
  // knowing that Dart's % is Euclidean prevents the bug.
}
