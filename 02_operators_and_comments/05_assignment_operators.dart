// ═══════════════════════════════════════════════════════════════════════════
// 05 – ASSIGNMENT OPERATORS
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// Assignment writes a value into a storage location: a variable, a field, or an
// indexed slot. Plain `=` is the foundation; `??=` writes only when the target
// is currently null; and the compound forms (`+=`, `~/=`, `&=`, and the rest)
// fold an operation and a write into one expression. The problem the compound
// and null-aware forms solve is twofold: they remove the repetition of naming
// the target twice (`count = count + 1`), and `??=` removes the
// read-test-then-write dance for lazy defaulting. The subtlety they introduce
// is that the target is evaluated differently from how it first appears, which
// matters the moment the target is a list index or a property with side effects.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   a = value      assign value to a
//   a ??= value    assign value to a ONLY if a is currently null
//
//   Compound assignment, one per binary operator:
//   a += b    a -= b    a *= b    a /= b    a ~/= b   a %= b
//   a <<= b   a >>= b   a >>>= b  a &= b    a ^= b    a |= b
//
//   Each `a op= b` means "a = a op b", with a evaluated only once (see below).
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// An assignment is an expression, not just a statement: it evaluates to the
// assigned value. `final logged = (status = 'active');` binds `logged` to
// `'active'`. The analyzer requires the target to be assignable: a non-final
// variable, a settable field, or an indexable with an `[]=` operator. Writing
// to a `final`, a `const`, or a getter-only property is a compile error.
//
// For `a op= b`, the static type rule is that `a op b` must be assignable back
// to `a`. This is why `int counter; counter += 1.5;` is a compile error: `int +
// double` is `double`, which cannot be stored back into an `int`. The compound
// form does not relax the type of the target.
//
// `??=` requires the target to be of a nullable type (or the analyzer warns the
// assignment is dead, via `dead_null_aware_expression`, because a non-nullable
// target can never be null).
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// `a op= b` evaluates the reference to `a` ONCE, reads its current value,
// computes `value op b`, and writes the result back to that same reference.
// "Once" is the load-bearing word: in `basket[nextIndex()] += 1`, the function
// `nextIndex()` is called a single time, not once for the read and again for
// the write. A naive `basket[nextIndex()] = basket[nextIndex()] + 1` calls it
// twice and writes to the wrong slot. `??=` evaluates the right side LAZILY:
// `cache ??= expensiveDefault()` calls `expensiveDefault()` only when `cache`
// is null.
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - `b ??= value` assigns only if `b` is null; otherwise `b` is unchanged and
//    `value` is not evaluated.
//  - `a += b` is equivalent to `a = a + b` for the value computed, with the
//    target evaluated once.
//  - Assignment is right-associative, so `a = b = c` assigns `c` to `b`, then
//    the result to `a`.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - Single evaluation of the target is the practical difference between `op=`
//    and the longhand. It matters for indexed targets and any target whose
//    evaluation has side effects.
//  - `??=` short-circuits the right operand. This makes it the correct tool for
//    memoising an expensive computation into a nullable field.
//  - `x += 1` where `x` is `int` is fine; `x += 1.5` where `x` is `int` is a
//    compile error. The compound operator inherits the result-type rules of its
//    binary operator (see 02).
//  - For a nullable num, `total += amount` fails to compile if `total` is
//    `int?`, because `int? + int` is not defined. You must establish non-null
//    first (`total ??= 0; total += amount;` with promotion, or use `!`).
//  - On a custom class that overrides `+`, `a += b` calls that override, and
//    the result must be assignable to `a`'s declared type.
//  - `??=` on a non-nullable target is flagged dead by the analyzer; it is not
//    an error but signals a logic mistake.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// Compound assignment is not faster than the longhand for simple variables; the
// compiler generates the same code. Its performance relevance is the single
// evaluation of a target: for an expensive target expression, `op=` avoids
// computing it twice. `??=` avoids computing its right operand at all when the
// target is non-null, which is the entire point of using it for lazy defaults.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Compound operators are inherited from the C family for familiarity and for
// the single-evaluation guarantee, which C also provides. `??=` is Dart's own
// addition, introduced with null safety so that "default this if absent" has a
// dedicated, short-circuiting form rather than an `if (x == null) x = ...`
// statement. Making assignment an expression (returning the assigned value)
// enables chained assignment and assignment inside larger expressions, at the
// cost of the occasional `if (x = y)` typo that other languages reject; Dart
// catches that specific typo because the condition must be `bool`.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// Every compound operator is the assignment partner of a binary operator from
// 02 (arithmetic), 06 (logical, via `&&`/`||` there is no compound form), and
// 07 (bitwise and shift). `??=` is the assignment partner of the if-null
// operator `??` from 08. Precedence (12) places assignment near the bottom,
// just above the cascade and spread, and it is right-associative.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: assigning to a final.
//    "The final variable 'x' can't be used as a setter." / "'x' can't be used
//    as a setter because it's final."
//  - Compile error: compound assignment that changes the target type.
//    "A value of type 'double' can't be assigned to a variable of type 'int'."
//  - Compile error: `+=` on a nullable num.
//    "The operator '+' isn't defined for the type 'int?'."
//  - Logical error: double-evaluating a side-effecting target by using the
//    longhand instead of `op=`.
// ═══════════════════════════════════════════════════════════════════════════

int _indexCallCount = 0;

/// Returns 0 and records that it was called, to demonstrate single evaluation.
int firstSlotIndex() {
  _indexCallCount++;
  return 0;
}

void main() {
  // ── Plain assignment is an expression ───────────────────────────────────
  String orderStatus;
  final captured = (orderStatus = 'pending'); // assign, and capture the value
  print(orderStatus); // pending
  print(captured); // pending

  // Right-associative chaining.
  int retriesLeft;
  int attemptsUsed;
  retriesLeft = attemptsUsed = 3; // both become 3
  print(retriesLeft); // 3
  print(attemptsUsed); // 3

  // ── ??= assigns only when the target is null, and is lazy ───────────────
  String? cachedToken; // null
  cachedToken ??= 'tok_live_001'; // null, so assign
  print(cachedToken); // tok_live_001
  cachedToken ??= 'tok_live_002'; // already non-null, so right side ignored
  print(cachedToken); // tok_live_001

  // ── Compound assignment ─────────────────────────────────────────────────
  var basketTotalMinor = 1500;
  basketTotalMinor += 999; // basketTotalMinor = basketTotalMinor + 999
  print(basketTotalMinor); // 2499
  basketTotalMinor -= 500;
  print(basketTotalMinor); // 1999
  basketTotalMinor *= 2;
  print(basketTotalMinor); // 3998
  basketTotalMinor ~/= 3; // truncating division-assign, stays int
  print(basketTotalMinor); // 1332
  basketTotalMinor %= 1000;
  print(basketTotalMinor); // 332

  // Bitwise compound forms (see 07 for the operators themselves).
  var permissionFlags = 0x01;
  permissionFlags |= 0x04; // set the third bit
  print(permissionFlags); // 5
  permissionFlags &= 0x06; // keep only bits in the mask
  print(permissionFlags); // 4
  permissionFlags ^= 0x04; // toggle the third bit off
  print(permissionFlags); // 0
  permissionFlags = 1;
  permissionFlags <<= 3; // shift-assign left by 3
  print(permissionFlags); // 8

  // ── Single evaluation of a side-effecting target ────────────────────────
  final inventory = [10, 20, 30];
  _indexCallCount = 0;
  inventory[firstSlotIndex()] += 5; // firstSlotIndex() runs exactly once
  print(inventory[0]); // 15
  print(_indexCallCount); // 1

  // The naive longhand would call the index function twice.
  _indexCallCount = 0;
  inventory[firstSlotIndex()] = inventory[firstSlotIndex()] + 5;
  print(inventory[0]); // 20
  print(_indexCallCount); // 2   (called twice; the bug the op= form avoids)

  // ── INCORRECT USAGE: compile errors ─────────────────────────────────────
  // (a) Assigning to a final.
  //
  //     final maxRetries = 3;
  //     maxRetries += 1;
  //
  //     Error: "The final variable 'maxRetries' can't be used as a setter."

  // (b) Compound assignment that would change the target's type.
  //
  //     int wholeUnits = 5;
  //     wholeUnits += 1.5; // int + double is double, cannot store in int
  //
  //     Error: "A value of type 'double' can't be assigned to a variable of
  //     type 'int'."

  // (c) += on a nullable num.
  //
  //     int? runningTotal;
  //     runningTotal += 10;
  //
  //     Error: "The operator '+' isn't defined for the type 'int?'."
  //     (Fix: runningTotal ??= 0; then runningTotal += 10; with promotion.)

  // ── INCORRECT USAGE: logical error (dead ??=) ───────────────────────────
  // A non-nullable target can never be null, so the assignment is unreachable.
  //
  //     int liveCount = 0;
  //     liveCount ??= 5; // analyzer: dead_null_aware_expression
  //
  // It compiles, but `liveCount` is never 5; the line is a logic mistake.
}
