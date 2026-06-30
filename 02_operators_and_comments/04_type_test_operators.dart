// ═══════════════════════════════════════════════════════════════════════════
// 04 – TYPE TEST OPERATORS: as, is, is!
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// `is`, `is!`, and `as` inspect or assert an object's runtime type. The problem
// they solve appears the moment data crosses a boundary the type system cannot
// see through: a JSON payload decoded as `Map<String, dynamic>`, an event from
// a stream typed as `Object`, a value pulled from a heterogeneous list. Inside
// the program the static type is too wide to call the methods you need, and you
// must narrow it. `is` narrows safely with a check; `as` narrows by assertion
// and pays for a wrong guess with a runtime exception.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   obj is T     true if obj's runtime type is T or a subtype of T
//   obj is! T    true if obj's runtime type is NOT T or a subtype (negation)
//   obj as T     cast: yields obj typed as T, or throws if obj is not a T
//   obj as T?    cast to a nullable type; null passes this cast
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// `is` and `is!` are pure static-analysis hooks at compile time and boolean
// tests at runtime. Their real power at compile time is TYPE PROMOTION: inside
// the `true` branch of `if (account is PremiumAccount)`, the analyzer treats
// `account` as `PremiumAccount` and lets you call its members without a cast.
// Promotion requires the variable to be effectively final within the scope; a
// variable reassigned between the check and the use is not promoted.
//
// `as` is a checked cast. The analyzer accepts `obj as T` whenever `T` is a
// type the expression could plausibly be (it rejects casts that can never
// succeed, such as `'text' as int`, with a compile error). At runtime the cast
// either passes through the value unchanged or throws a `TypeError`.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// `is`/`is!` evaluate the object's actual runtime type against `T` and return a
// bool. They never throw. `as` performs the same check and, on failure, throws
// `_TypeError` (a `TypeError`) with a message naming both types. A successful
// `as` is essentially free: it is a type check followed by passing the same
// reference along, with no copying or boxing.
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - `obj is Object?` is always true (every value, including null, is an
//    `Object?`).
//  - `as` is also the keyword for library import prefixes
//    (`import 'dart:math' as math;`); that usage is unrelated to casting.
//  - The docs note that `(employee as Person).firstName = 'Bob'` and
//    `if (employee is Person) { employee.firstName = 'Bob'; }` are NOT
//    equivalent: if `employee` is null or not a `Person`, the cast throws
//    while the `is` check simply skips the block.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - `null is T` is false for every non-nullable `T`, and `null is T?` is true.
//    So `null is String` is false but `null is String?` is true.
//  - Promotion is DEFEATED by non-final variables. If `account` is a mutable
//    field of a class (not a local), the analyzer refuses to promote it even
//    after `is`, because another method could change it between check and use.
//    The fix is to copy the field into a local first.
//  - `as` on `null` to a non-nullable type throws; `null as String` throws,
//    but `null as String?` succeeds and yields null.
//  - `is` checks the FULL generic type at runtime: `<int>[] is List<String>`
//    is false, but `<int>[] is List` is true. Reified generics make this work,
//    unlike Java's erased generics.
//  - Casting up the hierarchy always succeeds (`premium as Account`); casting
//    down only succeeds if the runtime type actually is the subtype.
//  - Using `as` to silence the analyzer when you are merely guessing is the
//    single most common source of production `TypeError` crashes. Prefer `is`
//    plus promotion unless you can prove the type.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// A type check is a cheap class-pointer comparison for non-generic types. For
// deep generic types (`Map<String, List<int>>`) the runtime may walk type
// arguments, which is more expensive but still rarely a bottleneck. `as` adds
// no cost over `is` on success; its only extra cost is the thrown exception on
// failure, which is expensive but should be the exceptional path by definition.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Dart separates the safe narrowing (`is` + promotion) from the asserting
// narrowing (`as`) so the cost of being wrong is explicit at the call site.
// `is` cannot crash, so it is the default; `as` crashes loudly rather than
// returning a corrupted value, which is preferable to C-style silent
// reinterpretation. Type promotion was added so that the safe path is also the
// concise path: you check once and use the narrowed type repeatedly without
// repeating the cast, removing the temptation to reach for `as`.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// `is` pairs with logical AND (06) for guarded access: `x is List && x.isEmpty`
// promotes `x` for the right operand. The not-null assertion `!` (09) is the
// nullability analogue of `as`: both assert and both throw. Precedence (12)
// places `is`, `is!`, and `as` with the relational operators, below the
// arithmetic and shift operators.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: a cast that can never succeed.
//    "A value of type 'String' can't be assigned ... " or an unnecessary-cast
//    hint for casts the analyzer proves always succeed.
//  - Runtime error: a failed `as`.
//    "type 'String' is not a subtype of type 'int' in type cast"
//  - Logical error: relying on `as` where the type assumption is wrong, or
//    expecting promotion on a mutable field (it silently does not happen, and
//    the member access then fails to compile).
// ═══════════════════════════════════════════════════════════════════════════

/// An account in a subscription product. [PremiumAccount] adds a renewal date.
class Account {
  final String email;
  const Account(this.email);
}

class PremiumAccount extends Account {
  final DateTime renewsOn;
  const PremiumAccount(super.email, this.renewsOn);
}

void main() {
  // ── is and type promotion ───────────────────────────────────────────────
  final Account currentUser =
      PremiumAccount('ada@egand.dev', DateTime(2026, 12, 1));

  if (currentUser is PremiumAccount) {
    // Inside this branch currentUser is promoted to PremiumAccount, so
    // renewsOn is reachable with no cast.
    print(currentUser.renewsOn); // 2026-12-01 00:00:00.000
  }

  // ── is! as the negation ─────────────────────────────────────────────────
  final Account guestUser = Account('guest@egand.dev');
  if (guestUser is! PremiumAccount) {
    print('Upgrade prompt shown'); // Upgrade prompt shown
  }

  // ── as for a cast you are certain about ─────────────────────────────────
  final Object decodedField = 'NGN';
  final currencyCode = decodedField as String;
  print(currencyCode.toLowerCase()); // ngn

  // ── Reified generics: is checks type arguments at runtime ───────────────
  final List<int> quantities = [2, 1, 5];
  print(quantities is List<int>); // true
  print(quantities is List<String>); // false
  print(quantities is List); // true   (raw List matches)

  // ── null and type tests ─────────────────────────────────────────────────
  String? optionalNote;
  print(optionalNote is String); // false  (null is not a non-nullable String)
  print(optionalNote is String?); // true   (null is a String?)
  print(optionalNote is Object?); // true   (everything is Object?)

  // null as a nullable type succeeds and yields null.
  final coerced = optionalNote as String?;
  print(coerced); // null

  // ── Upcast always succeeds ──────────────────────────────────────────────
  final PremiumAccount premium =
      PremiumAccount('lin@egand.dev', DateTime(2027, 1, 1));
  final Account asBase = premium as Account; // widening, always valid
  print(asBase.email); // lin@egand.dev

  // ── INCORRECT USAGE: runtime error (failed downcast) ────────────────────
  // currentUser here is actually an Account, not a PremiumAccount.
  //
  //     final Object value = 'NGN';
  //     final asInt = value as int;
  //
  //     Unhandled exception:
  //     type 'String' is not a subtype of type 'int' in type cast

  // ── INCORRECT USAGE: runtime error (null as non-nullable) ───────────────
  //     String? maybeName;
  //     final name = maybeName as String;
  //
  //     Unhandled exception:
  //     type 'Null' is not a subtype of type 'String' in type cast

  // ── INCORRECT USAGE: logical error (promotion on a mutable field) ───────
  // Promotion only applies to locals (and effectively-final variables). A
  // mutable instance field is not promoted by `is`, so the following pattern
  // FAILS TO COMPILE rather than silently working:
  //
  //   class Session { Account? account; void f() {
  //     if (account is PremiumAccount) {
  //       print(account.renewsOn); // Error: 'renewsOn' isn't defined for 'Account?'
  //     }
  //   }}
  //
  // The analyzer message points at non-promotion; the fix is:
  //   final local = account; if (local is PremiumAccount) { local.renewsOn; }
}
