// ═══════════════════════════════════════════════════════════════════════════
// 06 – LOGICAL OPERATORS
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// Logical operators combine and invert boolean conditions: `&&` (and), `||`
// (or), `!` (not). They express the compound rules every application is built
// from: "logged in AND email verified", "guest OR trial expired", "NOT
// suspended". The problem they solve beyond simple combination is ORDER OF
// EVALUATION. `&&` and `||` are short-circuiting: they stop as soon as the
// result is known. This is not a performance footnote; it is the mechanism that
// lets you write `user != null && user.isActive` without the second test
// crashing when `user` is null. Treating `&&`/`||` as if both sides always run
// produces null-dereference crashes that only appear on the unlucky input.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   !a       logical NOT: true becomes false, false becomes true
//   a && b   logical AND: true only if both a and b are true
//   a || b   logical OR: true if either a or b is true
//
//   All three require bool operands and produce a bool. Dart has no "truthy"
//   coercion: `if (1)` and `!"text"` are compile errors.
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// The analyzer requires both operands of `&&`/`||` and the operand of `!` to be
// of type `bool` (or `bool` after promotion). There is no implicit conversion
// from int, string, or null to bool, so `if (count)` does not compile. `&&` and
// `||` also drive TYPE PROMOTION across their operands: in
// `node is Branch && node.children.isEmpty`, the right operand sees `node`
// promoted to `Branch`, because it only runs when the left operand is true.
// Likewise the code AFTER an `if (x == null || ...) return;` sees `x` promoted
// to non-null.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// `a && b`: evaluate `a`. If `a` is false, the result is false and `b` is NEVER
// evaluated. Only if `a` is true does `b` run, and its value becomes the result.
// `a || b`: evaluate `a`. If `a` is true, the result is true and `b` is NEVER
// evaluated. Only if `a` is false does `b` run. `!a` simply negates. This
// left-to-right, stop-early behaviour is guaranteed by the language, not an
// optimisation that might or might not happen.
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - All operands are boolean expressions; there is no truthiness in Dart.
//  - `!` binds tighter than `&&`, which binds tighter than `||`, so
//    `!a && b || c` parses as `((!a) && b) || c`.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - Short-circuiting is the documented-by-omission behaviour most code relies
//    on without stating it. `user != null && user.isActive` is SAFE precisely
//    because `user.isActive` does not run when `user` is null. Reorder the two
//    and it crashes.
//  - A side effect on the right operand runs CONDITIONALLY. `if (cacheHit() ||
//    recordMiss())`, `recordMiss()` runs only on a cache miss. Putting a
//    needed side effect on the short-circuited side is a real bug source.
//  - `&&` and `||` propagate promotion; a bitwise `&`/`|` (07) on bools does
//    NOT short-circuit and does NOT promote, so `a & b` evaluates both sides.
//    Using `&`/`|` on bools is legal and occasionally intended, but it defeats
//    the null guard that `&&` provides.
//  - `!` applied to a nullable bool is a compile error: `bool? flag; !flag` does
//    not compile because the operand may be null. You must resolve nullability
//    first (`!(flag ?? false)`).
//  - De Morgan's laws hold and matter for refactoring: `!(a && b)` equals
//    `!a || !b`, and `!(a || b)` equals `!a && !b`. Getting these wrong while
//    "simplifying" a condition silently inverts logic.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// Short-circuiting is itself the optimisation: place the cheapest and most
// often decisive test first so the expensive test runs least often. A condition
// like `isCached(id) || fetchFromNetwork(id)` should keep the cheap local check
// on the left so the network call is skipped on a hit. Beyond ordering, the
// operators compile to conditional branches and cost nothing measurable.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Requiring strict `bool` operands and rejecting truthiness is a deliberate
// safety choice: it removes the JavaScript class of bug where `0`, `''`, and
// `null` are falsy and surprise the author. The cost is verbosity (`list.isEmpty`
// instead of `!list`), traded for conditions that mean exactly what they say.
// Guaranteeing short-circuit order, rather than leaving it implementation
// defined, is what makes the null-guard idiom reliable across every Dart
// platform.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// Logical operators consume the booleans produced by equality and relational
// operators (03) and by type tests (04), and they drive the promotion those
// tests enable. The ternary `?:` (08) chooses between values based on a boolean
// these operators build. Bitwise `&`/`|`/`^` (07) look similar but are
// non-short-circuiting and operate bit by bit. Precedence (12) orders
// `!` (unary) above `&&` above `||`.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: non-bool operand.
//    "A value of type 'int' can't be assigned to a variable of type 'bool'." /
//    "Conditions must have a static type of 'bool'."
//  - Compile error: `!` on a nullable bool.
//    "A value of type 'bool?' can't be assigned to a variable of type 'bool'."
//  - Logical error: ordering operands so a needed side effect is short-circuited
//    away, or placing a null-unsafe access before its guard.
// ═══════════════════════════════════════════════════════════════════════════

bool _missRecorded = false;

/// Returns whether the id is in the in-memory cache. Cheap and side-effect free.
bool isCached(String id) => id == 'sku-001';

/// Records a cache miss as a side effect and returns true. Stands in for an
/// expensive operation we only want to run when the cheap check fails.
bool recordMiss(String id) {
  _missRecorded = true;
  return true;
}

void main() {
  // ── The three operators ─────────────────────────────────────────────────
  final isLoggedIn = true;
  final isEmailVerified = false;
  final isSuspended = false;

  print(isLoggedIn && isEmailVerified); // false  (both must be true)
  print(isLoggedIn || isEmailVerified); // true   (either suffices)
  print(!isSuspended); // true   (NOT suspended)

  final canCheckout = isLoggedIn && isEmailVerified && !isSuspended;
  print(canCheckout); // false  (email not verified)

  // ── Short-circuit makes the null guard safe ─────────────────────────────
  String? promoCode; // null
  // The right operand never runs because the left is false.
  final hasValidPromo = promoCode != null && promoCode.length >= 5;
  print(hasValidPromo); // false

  promoCode = 'SAVE20';
  final hasValidPromo2 = promoCode != null && promoCode.length >= 5;
  print(hasValidPromo2); // true   (now both sides evaluated, promoted to String)

  // ── Short-circuit controls a side effect ────────────────────────────────
  _missRecorded = false;
  final servedFromCache = isCached('sku-001') || recordMiss('sku-001');
  print(servedFromCache); // true
  print(_missRecorded); // false  (cache hit: recordMiss never ran)

  _missRecorded = false;
  final servedFromCache2 = isCached('sku-999') || recordMiss('sku-999');
  print(servedFromCache2); // true
  print(_missRecorded); // true   (cache miss: recordMiss ran)

  // ── Precedence: ! over && over || ───────────────────────────────────────
  final isArchived = false;
  final isPinned = true;
  final isShared = true;
  // parses as ((!isArchived) && isPinned) || isShared
  print(!isArchived && isPinned || isShared); // true

  // ── De Morgan equivalence (useful when refactoring conditions) ──────────
  final premium = true;
  final trialActive = false;
  print(!(premium && trialActive)); // true
  print(!premium || !trialActive); // true   (same result, De Morgan)

  // ── INCORRECT USAGE: compile errors ─────────────────────────────────────
  // (a) Non-bool operand (no truthiness in Dart).
  //
  //     final itemCount = 3;
  //     if (itemCount && isLoggedIn) { }
  //
  //     Error: "A value of type 'int' can't be assigned to a variable of type
  //     'bool'."

  // (b) ! on a nullable bool.
  //
  //     bool? featureFlag;
  //     final disabled = !featureFlag;
  //
  //     Error: "A value of type 'bool?' can't be assigned to a variable of
  //     type 'bool'."
  //     (Fix: !(featureFlag ?? false).)

  // ── INCORRECT USAGE: logical error (guard after the access) ─────────────
  // Reversing the operands removes the protection short-circuiting provided:
  //
  //   String? note;
  //   final ok = note.length >= 5 && note != null; // crashes when note is null
  //
  // This still does not compile (note.length on a nullable), but the deeper
  // lesson is order: the null check must come FIRST so the dereference is
  // guarded by short-circuiting.
}
