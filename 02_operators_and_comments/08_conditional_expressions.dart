// ═══════════════════════════════════════════════════════════════════════════
// 08 – CONDITIONAL EXPRESSIONS: ?: and ??
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// Two operators let you choose a value inside an expression rather than across
// several statements. The ternary `condition ? a : b` picks `a` when the
// condition holds and `b` otherwise. The if-null `x ?? y` yields `x` when `x`
// is non-null and `y` only when `x` is null. Both solve the same shape of
// problem: producing one value out of two candidates without writing a
// multi-line `if`/`else` that forces you to declare the target first and assign
// it in two places. The if-null operator additionally encodes the single most
// common decision in null-safe code: "use this if present, otherwise fall back".
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   condition ? whenTrue : whenFalse    ternary conditional
//   value ?? fallback                   if-null (null-coalescing)
//   a ?? b ?? c                         chained: first non-null wins
//
//   The condition of `?:` must be `bool`. `??` takes any nullable left operand.
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// `?:` requires a `bool` condition and infers the result type as the least
// upper bound of the two branch types: `flag ? 1 : 2` is `int`, `flag ? 1 :
// 'two'` is `Object`. The analyzer applies type promotion per branch, so in
// `x is int ? x + 1 : 0`, `x` is promoted to `int` in the true branch only.
//
// `x ?? y` is typed so that the result is non-nullable when `y` is non-nullable:
// if `x` is `String?` and `y` is `String`, then `x ?? y` is `String`. This is
// how `??` removes nullability from an expression. The analyzer also flags a
// `??` whose left operand is already non-nullable (`dead_null_aware_expression`)
// because the fallback is then unreachable.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// Both operators short-circuit. `?:` evaluates the condition, then exactly ONE
// branch. `x ?? y` evaluates `x`; only if `x` is null does it evaluate `y`. In a
// chain `a ?? b ?? c`, evaluation stops at the first non-null operand, so a
// costly fallback at the end runs only when every earlier operand is null.
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - `?:` is the concise replacement for an `if`/`else` that assigns a value.
//  - `??` is the concise replacement for `x != null ? x : y`, and the docs show
//    `String playerName(String? name) => name ?? 'Guest';` as the idiom.
//  - `?:` is right-associative, so `a ? b : c ? d : e` parses as
//    `a ? b : (c ? d : e)`.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - `??` tests for NULL only, not for "empty" or "false". `'' ?? 'fallback'`
//    yields `''`, because the empty string is non-null. To fall back on empty,
//    you need an explicit check, not `??`.
//  - `?:` and `??` differ in what they branch on: `?:` branches on a boolean you
//    supply; `??` branches on nullness. `flag ? a : b` and `x ?? y` are not
//    interchangeable.
//  - Precedence: `??` binds LOWER than `?:`'s condition machinery and lower than
//    `||`, but the interaction people get wrong is mixing `??` with `?:` without
//    parentheses. `a ?? b ? c : d` parses as `(a ?? b) ? c : d`, which is rarely
//    what you intend.
//  - In a ternary, both branches are type-checked even though only one runs, so
//    a branch that does not type-check fails to compile regardless of the
//    condition.
//  - `??` chains are the idiom for layered configuration: per-request override
//    ?? user setting ?? workspace default ?? hard-coded default.
//  - The if-null ASSIGNMENT `??=` (05) is the statement form: `x ??= y` writes
//    `y` into `x` only when `x` is null. `x ?? y` does not write anything.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// Both compile to a conditional branch and cost nothing measurable. Their
// performance relevance is the short-circuit: order `??` chains so the cheap,
// usually-present source is first and the expensive fallback (a database read,
// a network default) is last and rarely reached.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// `?:` is the C-family ternary, kept for familiarity and for being an
// expression (an `if` statement is not). `??` is a null-safety-era operator
// whose entire purpose is to make "value or default" a single, type-narrowing
// expression. Importantly, `??` keys on null specifically rather than on a broad
// notion of "falsy", which is consistent with Dart's refusal of truthiness
// (see 06): the only thing `??` reacts to is the absence that the type system
// already tracks.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// `?:` consumes booleans built by equality (03), type tests (04), and logical
// operators (06). `??` is the expression partner of `??=` (05) and composes
// with the null-aware member access `?.` (09): `user?.name ?? 'Guest'` reads a
// possibly-null chain and supplies a default. Precedence (12) places `??` just
// above `?:`, both near the bottom of the table.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: non-bool ternary condition.
//    "A value of type 'String?' can't be assigned to a variable of type 'bool'."
//  - Analyzer warning: dead `??` on a non-nullable left operand.
//    "The left operand can't be null, so the right operand is never executed."
//  - Logical error: expecting `??` to fall back on empty/false values, or
//    mis-parsing `a ?? b ? c : d`.
// ═══════════════════════════════════════════════════════════════════════════

/// Resolves a display name, falling back through layers of configuration.
String resolveDisplayName(String? requestOverride, String? savedNickname) {
  // First non-null wins; the hard-coded default is reached only when both
  // earlier sources are null.
  return requestOverride ?? savedNickname ?? 'Guest';
}

void main() {
  // ── Ternary: choose a value from a boolean ──────────────────────────────
  final isPublicListing = true;
  final visibility = isPublicListing ? 'public' : 'private';
  print(visibility); // public

  final stockOnHand = 0;
  final availability = stockOnHand > 0 ? 'In stock' : 'Sold out';
  print(availability); // Sold out

  // Result type is the least upper bound of the branches.
  final mixed = isPublicListing ? 1 : 'two';
  print(mixed.runtimeType); // int
  print(mixed); // 1

  // ── If-null: fall back only on null ─────────────────────────────────────
  String? incomingCoupon; // null
  final couponToApply = incomingCoupon ?? 'NO-COUPON';
  print(couponToApply); // NO-COUPON

  incomingCoupon = 'SAVE20';
  print(incomingCoupon ?? 'NO-COUPON'); // SAVE20

  // ?? keys on null ONLY; an empty string is non-null and passes through.
  final note = '';
  print(note ?? 'fallback'); // (empty line) – '' is non-null, so no fallback

  // ── Chained if-null: first non-null wins, evaluated left to right ────────
  print(resolveDisplayName('Ada (this request)', 'ada_dev')); // Ada (this request)
  print(resolveDisplayName(null, 'ada_dev')); // ada_dev
  print(resolveDisplayName(null, null)); // Guest

  // ?? removes nullability: the result type here is non-nullable String.
  String? maybeCity;
  final String city = maybeCity ?? 'Lagos'; // String, not String?
  print(city); // Lagos

  // ── Composing ?? with null-aware access (?. from file 09) ───────────────
  final List<String>? recentSearches = null;
  final firstSearch = recentSearches?.first ?? 'none'; // null chain, defaulted
  print(firstSearch); // none

  // ── Right-associativity of nested ternaries ─────────────────────────────
  final score = 72;
  final grade = score >= 80
      ? 'A'
      : score >= 70
          ? 'B'
          : 'C';
  print(grade); // B

  // ── INCORRECT USAGE: compile error (non-bool condition) ─────────────────
  //     String? name;
  //     final label = name ? 'has name' : 'no name';
  //
  //     Error: "A value of type 'String?' can't be assigned to a variable of
  //     type 'bool'."
  //     (?: needs a bool condition; perhaps you meant name != null ? ... : ...)

  // ── INCORRECT USAGE: analyzer warning (dead ??) ─────────────────────────
  //     String alwaysPresent = 'x';
  //     final v = alwaysPresent ?? 'fallback';
  //
  //     Warning: "The left operand can't be null, so the right operand is never
  //     executed." (dead_null_aware_expression)

  // ── INCORRECT USAGE: logical error (?? does not catch empty/false) ──────
  // A username field defaulted with ?? keeps an empty submission:
  //
  //   final username = submitted ?? 'anonymous'; // '' stays '', not 'anonymous'
  //
  // If empty must also fall back, test it explicitly:
  //   final username = (submitted == null || submitted.isEmpty)
  //       ? 'anonymous' : submitted;

  // ── INCORRECT USAGE: logical error (?? vs ?: precedence) ────────────────
  // Mixing the two without parentheses surprises:
  //
  //   final result = a ?? b ? c : d; // parses as (a ?? b) ? c : d
  //
  // Parenthesise to state intent: a ?? (b ? c : d), or (a ?? b) ? c : d.
}
