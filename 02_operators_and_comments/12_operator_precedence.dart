// ═══════════════════════════════════════════════════════════════════════════
// 12 – OPERATOR PRECEDENCE AND ASSOCIATIVITY
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// Precedence decides which operator binds first when several appear without
// parentheses; associativity decides the grouping direction when operators of
// equal precedence sit side by side. Together they answer "what does this
// expression actually compute?" The problem they solve is unavoidable: real
// expressions mix arithmetic, comparison, logic, and null handling, and the
// reader (and the parser) must agree on grouping. This file is placed last on
// purpose: precedence is only meaningful once you know the operators it ranks,
// every one of which the preceding files introduced. The practical payoff is
// knowing exactly when parentheses are decorative and when they are load-bearing.
//
// THE PRECEDENCE TABLE (highest binds first; from the operators page)
// ---------------------------------------------------------------------------
//   unary postfix          expr++  expr--  ()  []  ?[]  .  ?.  !        none
//   unary prefix           -expr  !expr  ~expr  ++expr  --expr  await   none
//   multiplicative         *  /  %  ~/                                  left
//   additive               +  -                                         left
//   shift                  <<  >>  >>>                                  left
//   bitwise AND            &                                            left
//   bitwise XOR            ^                                            left
//   bitwise OR             |                                            left
//   relational/type test   >=  >  <=  <  as  is  is!                    none
//   equality               ==  !=                                       none
//   logical AND            &&                                           left
//   logical OR             ||                                           left
//   if-null                ??                                           left
//   conditional            expr1 ? expr2 : expr3                        right
//   cascade                ..  ?..                                      left
//   assignment             =  *=  /=  +=  -=  &=  ^=  ...               right
//   (spread ... / ...? is collection-literal syntax, not in this table)
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// The parser uses this ranking to build the expression tree before any code is
// generated. Higher-precedence operators become deeper nodes (evaluated first);
// associativity sets the shape of a chain of equal-precedence operators. The
// docs warn TWICE that this table is an APPROXIMATION of the real grammar: the
// authoritative rules live in the language specification, and a handful of
// edge cases (in particular how `is`/`as`, `??`, and cascade interact) are defined by
// the grammar productions rather than by a clean numeric rank. When in doubt,
// the specification, not this table, is correct.
//
// "none" associativity means the operators on that row do NOT chain. `a == b ==
// c` is a COMPILE error, not `(a == b) == c`, because equality is
// non-associating. The same applies to relational and type-test operators.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// Precedence and associativity are entirely resolved at parse time; there is no
// runtime component. What the runtime does observe is a separate rule: for a
// BINARY operator, the LEFTMOST operand determines which operator method runs.
// `aVector + aPoint` calls `Vector`'s `+`, not `Point`'s, because the left
// operand owns the operator. Evaluation order of operands is left to right and
// is unrelated to precedence: precedence groups the tree, then operands are
// evaluated left to right within it.
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - `%` binds tighter than `==`, which binds tighter than `&&`, so
//    `n % i == 0 && d % i == 0` means `((n % i) == 0) && ((d % i) == 0)`.
//  - For binary operators, the left operand selects the method (`Vector` vs
//    `Point` example).
//  - The table is an approximation; the grammar in the spec is authoritative.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - Bitwise `&`, `^`, `|` bind LOWER than `==`/`!=`. So `flags & MASK == MASK`
//    parses as `flags & (MASK == MASK)` (a type error), not the intended
//    `(flags & MASK) == MASK`. This is the most common precedence bug in Dart.
//  - `??` binds LOWER than `||`: `a || b ?? c` parses as `(a || b) ?? c`, and
//    since `a || b` is a non-null bool, the `?? c` is dead. Mixing `??` with
//    boolean logic almost always wants parentheses.
//  - The conditional `?:` is RIGHT-associative, so `a ? b : c ? d : e` is
//    `a ? b : (c ? d : e)`. Chained ternaries read as an if/else-if ladder.
//  - Assignment is RIGHT-associative, enabling `a = b = c`.
//  - Unary postfix (`.`, `?.`, `!`, `[]`, `()`) binds tightest, so `a.b()!`
//    applies `!` to the result of `a.b()`, and `-a.b` is `-(a.b)`, not `(-a).b`.
//  - Cascade binds very LOW, below assignment-free expressions, which is why
//    `a + b..method()` is almost never what you want without parentheses.
//  - `await` sits with the unary prefix operators, so `await a.b()` awaits the
//    result of `a.b()`, and `-await x` negates the awaited value.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// None. Precedence is a parse-time concern with zero runtime representation.
// Parentheses added for clarity have no cost: `(a * b) + c` and `a * b + c`
// compile to identical code. Use parentheses freely for readability.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Dart adopted the C-family precedence ordering, including the historically
// awkward placement of bitwise operators BELOW equality, to keep expressions
// portable in muscle memory for developers coming from C, Java, and JavaScript.
// The cost is the `flags & MASK == MASK` trap, which Dart accepts rather than
// breaking cross-language expectations. Making equality and relational operators
// NON-associating is a Dart-leaning safety choice: `a < b < c` is meaningless as
// a chained comparison in most languages yet silently compiles in C; Dart
// rejects it outright. The repeated "this is an approximation" warning is an
// honest admission that a flat numeric table cannot capture every grammar
// interaction, and it steers serious questions to the specification.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// This file ranks every operator from 02 through 10. The traps it documents are
// exactly the ones flagged locally in those files: the bitwise-vs-equality trap
// (07), the `??`-vs-`?:` and `??`-vs-`||` traps (08), the cascade
// parenthesisation caveats (10). Spread (11) is deliberately absent from the
// table because it is literal syntax, not an operator.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: chaining a non-associating operator.
//    "The operator '==' isn't associative ..." / more commonly a type error
//    from the misgrouped subexpression.
//  - Compile error: the bitwise/equality trap producing `int & bool`.
//    "The operator '&' isn't defined for the type 'bool'." (from `MASK == MASK`)
//  - Logical error: a misread expression that compiles but computes the wrong
//    grouping, for example a dead `?? c` after `a || b`.
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ── Multiplicative over additive ────────────────────────────────────────
  print(2 + 3 * 4); // 14   (* binds first: 2 + (3 * 4))
  print((2 + 3) * 4); // 20   (parentheses override)

  // ── The documented divisibility example ─────────────────────────────────
  final numerator = 12;
  final denominator = 18;
  final divisor = 6;
  // Parses as ((numerator % divisor) == 0) && ((denominator % divisor) == 0).
  final bothDivisible =
      numerator % divisor == 0 && denominator % divisor == 0;
  print(bothDivisible); // true

  // ── Relational over equality over logical AND over logical OR ───────────
  final low = 1, mid = 2, high = 3, ceiling = 4;
  // Parses as ((low < mid) == (high < ceiling)).
  print(low < mid == high < ceiling); // true   (both comparisons true: true == true)

  // ── The bitwise vs equality TRAP ────────────────────────────────────────
  const writeFlag = 0x02;
  final permissions = 0x06; // write + delete bits set
  // Correct: parenthesise the bitwise AND.
  print((permissions & writeFlag) != 0); // true
  // Without parentheses it would parse as permissions & (writeFlag != 0),
  // i.e. int & bool, which does not compile. See the commented error below.

  // ── ?? vs || precedence ─────────────────────────────────────────────────
  final bool loggedIn = false;
  final bool hasGuestPass = true;
  // Parses as (loggedIn || hasGuestPass) ?? somethingElse – the ?? is dead
  // because the left side is a non-null bool. Shown via parentheses for clarity.
  print((loggedIn || hasGuestPass)); // true

  // ── Right-associative conditional (if/else-if ladder) ───────────────────
  final score = 55;
  final band = score >= 70
      ? 'pass'
      : score >= 50
          ? 'borderline'
          : 'fail';
  print(band); // borderline   (a ? b : (c ? d : e))

  // ── Unary postfix binds tightest ────────────────────────────────────────
  final readings = [10, 20, 30];
  print(-readings[1]); // -20   (-(readings[1]), not (-readings)[1])

  // ── Left operand selects the operator method ────────────────────────────
  // For any a + b, a's + method runs. With ordinary ints this is unremarkable,
  // but it is why mixing custom numeric types resolves to the LEFT type's
  // operator (the Vector + Point rule from the docs).
  final total = 5 + 2; // int.+ runs
  print(total); // 7

  // ── Parentheses cost nothing; use them for clarity ──────────────────────
  print(((numerator * divisor) + denominator)); // 90

  // ── INCORRECT USAGE: compile error (non-associating equality) ───────────
  //     final chained = a == b == c;
  //
  //     Error: equality is non-associative; `a == b == c` does not parse as a
  //     chain. The analyzer rejects it (the subexpression types also conflict).

  // ── INCORRECT USAGE: compile error (bitwise/equality trap) ──────────────
  //     if (permissions & writeFlag == writeFlag) { }
  //
  //     Parses as permissions & (writeFlag == writeFlag) = int & bool.
  //     Error: "The operator '&' isn't defined for the type 'bool'."

  // ── INCORRECT USAGE: logical error (dead ?? after ||) ───────────────────
  // `final v = loggedIn || hasGuestPass ?? false;` parses as
  // `(loggedIn || hasGuestPass) ?? false`. The left side is a non-null bool, so
  // `?? false` never runs. It compiles, computes the right answer here by luck,
  // and hides a misunderstanding. Parenthesise to say what you mean.
}
