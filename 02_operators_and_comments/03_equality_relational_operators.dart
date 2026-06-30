// ═══════════════════════════════════════════════════════════════════════════
// 03 – EQUALITY AND RELATIONAL OPERATORS
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// Equality (`==`, `!=`) answers "do these two values represent the same thing?"
// Relational operators (`>`, `<`, `>=`, `<=`) answer "which is larger?" Both
// underpin every conditional, sort, filter, and de-duplication an application
// performs. The problem they solve is harder than it looks: "the same thing"
// for an `int` means equal value, but for a `CartItem` it means whatever your
// class decides, and Dart lets you decide by overriding `==`. Getting that
// override wrong, or confusing value-equality with identity, produces the most
// persistent class of bug in collection-heavy code: items that vanish from a
// `Set`, map lookups that miss, lists that will not de-duplicate.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   a == b     equal (value equality, defined by a's == method)
//   a != b     not equal (the negation of a == b)
//   a > b      greater than
//   a < b      less than
//   a >= b     greater than or equal to
//   a <= b     less than or equal to
//   identical(a, b)   not an operator: a dart:core function for OBJECT identity
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// `a == b` is a method call on `a`: `a.==(b)`, declared on `Object` as
// `bool operator ==(Object other)`. Because it lives on `Object`, every value
// supports `==`; the analyzer never rejects an equality test on type grounds.
// `a != b` is compiled as `!(a == b)`; you cannot override `!=` separately.
//
// Relational operators are different. `>`, `<`, `>=`, `<=` are declared on
// `num` and on any type that defines them; they are NOT on `Object`. So
// `'a' < 'b'` is a COMPILE error, because `String` does not define `<`. The
// analyzer checks that the left operand's type has the operator before allowing
// the expression. This is why you can always test two arbitrary objects for
// `==` but cannot always order them.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// For `==`, the runtime applies a null short-circuit defined by the language
// before dispatching to the method: if either operand is `null`, the result is
// `true` only when both are `null`, and `false` otherwise. The user-defined
// `==` method is never invoked with a `null` receiver. Only when both operands
// are non-null does the runtime call `a.==(b)`.
//
// `identical(a, b)` does no method dispatch. It compares object references (and
// for canonicalised values such as small ints, `const` objects, and interned
// strings, two structurally equal values may also be identical). Use it when
// you specifically need "the exact same object", not "an equal value".
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - The null rule above: `null == null` is `true`; `null == anything` and
//    `anything == null` are `false`, without calling any user `==`.
//  - `==` is a method on the first operand. `a == b` may behave differently
//    from `b == a` if the two have different, asymmetric `==` overrides.
//  - For exact object identity in the rare case you need it, use `identical()`,
//    not `==`.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - `double.nan == double.nan` is `false`. NaN is not equal to anything,
//    including itself. To test for NaN, use `value.isNaN`.
//  - `int` and `double` compare equal across types: `1 == 1.0` is `true`, and
//    `1` and `1.0` even share a hash code, so a `Set` treats them as one entry.
//  - The `==` / `hashCode` contract: if you override `==`, you MUST override
//    `hashCode` so that equal objects have equal hash codes. Break this and
//    `Set` and `Map` misbehave silently; the program compiles and runs.
//  - Overriding `==` without `@override` still works but the analyzer's
//    `hash_and_equals` lint will warn if `hashCode` is missing.
//  - `0.0 == -0.0` is `true`, but `identical(0.0, -0.0)` is `false`, and they
//    hash differently in some implementations; relevant for numeric keys.
//  - Relational operators on mixed numeric types work (`3 < 3.5`), but on
//    non-`num` types they require the type to define the operator. `DateTime`
//    does NOT define `<`; you must call `a.isBefore(b)`.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// The default `Object.==` is identity comparison and is as cheap as a pointer
// compare. A custom `==` is as expensive as the fields it inspects; a value
// class with many fields compared inside a tight `Set` or `Map` operation can
// dominate a hot path. `hashCode` is computed on every `Set`/`Map` insertion
// and lookup, so an expensive `hashCode` is paid repeatedly. Cache it for
// immutable objects if profiling shows it matters.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Putting `==` on `Object` and the relational operators on `num` (and other
// `Comparable` types) reflects a real semantic distinction: every value can be
// asked "are you the same as this other value?", but not every value has a
// natural order. Dart refuses to invent an order for types that lack one,
// which is why `<` on `String` is a compile error rather than a silent
// lexicographic guess. The language also defines the null rule centrally so
// that no `==` override ever has to null-check its argument's receiver, which
// removes an entire category of null-related boilerplate and crashes.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// Equality feeds the logical operators (06): `a == b && c == d`. The if-null
// operator (08) is the idiomatic replacement for `x == null ? y : x`. Type test
// `is` (04) often precedes `==` when comparing across types. Precedence (12)
// places relational above equality above logical AND, so
// `a < b == c < d` parses as `(a < b) == (c < d)`.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: ordering a type with no `<`.
//    "The operator '<' isn't defined for the type 'String'."
//  - Logical error: overriding `==` but not `hashCode`, so a `Set` keeps
//    duplicates. No exception; the program silently does the wrong thing.
//  - Logical error: testing `x == double.nan` (always false) instead of
//    `x.isNaN`.
// ═══════════════════════════════════════════════════════════════════════════

/// A line item in a shopping cart, compared by SKU and quantity.
///
/// Two [CartLineItem]s are equal when they have the same [sku] and the same
/// [quantity]. Overriding [==] requires overriding [hashCode] to keep the
/// equality/hash contract; without it, a [Set] of line items would keep
/// duplicates.
class CartLineItem {
  final String sku;
  final int quantity;

  const CartLineItem(this.sku, this.quantity);

  @override
  bool operator ==(Object other) =>
      other is CartLineItem && other.sku == sku && other.quantity == quantity;

  @override
  int get hashCode => Object.hash(sku, quantity);

  @override
  String toString() => 'CartLineItem($sku x$quantity)';
}

void main() {
  // ── Equality and the null rule ──────────────────────────────────────────
  print(2 == 2); // true
  print(2 != 3); // true

  String? activeCoupon; // null
  String? appliedCoupon; // null
  print(activeCoupon == appliedCoupon); // true   (null == null)
  appliedCoupon = 'WELCOME10';
  print(activeCoupon == appliedCoupon); // false  (one side null)

  // ── Relational operators ────────────────────────────────────────────────
  final stockOnHand = 12;
  final reorderLevel = 5;
  print(stockOnHand > reorderLevel); // true
  print(stockOnHand < reorderLevel); // false
  print(stockOnHand >= 12); // true
  print(reorderLevel <= 5); // true

  // Mixed int/double comparison is allowed because both are num.
  print(3 < 3.5); // true
  print(3 == 3.0); // true

  // ── Value equality via a custom == ──────────────────────────────────────
  final firstScan = CartLineItem('NGN-TSHIRT-01', 2);
  final secondScan = CartLineItem('NGN-TSHIRT-01', 2);
  print(firstScan == secondScan); // true   (same sku and quantity)
  print(identical(firstScan, secondScan)); // false  (different objects)

  // Because == and hashCode agree, a Set de-duplicates correctly.
  final uniqueItems = {firstScan, secondScan};
  print(uniqueItems.length); // 1

  // ── NaN is not equal to itself ──────────────────────────────────────────
  final invalidReading = double.nan;
  print(invalidReading == invalidReading); // false
  print(invalidReading.isNaN); // true   (the correct test)

  // ── int and double cross-equality and shared hashing ────────────────────
  print(1 == 1.0); // true
  final numericKeys = {1, 1.0};
  print(numericKeys.length); // 1   (1 and 1.0 collapse to one entry)

  // ── Signed zero: equal by ==, not identical ─────────────────────────────
  print(0.0 == -0.0); // true
  print(identical(0.0, -0.0)); // false

  // ── INCORRECT USAGE: compile error (ordering an unordered type) ─────────
  // String defines == but not <, so this does not compile.
  //
  //     final precedes = 'apple' < 'banana';
  //
  //     Error: "The operator '<' isn't defined for the type 'String'."
  //     (Use 'apple'.compareTo('banana') < 0 instead.)

  // ── INCORRECT USAGE: compile error (ordering DateTime) ──────────────────
  //     final earlier = DateTime(2026) < DateTime(2027);
  //
  //     Error: "The operator '<' isn't defined for the type 'DateTime'."
  //     (Use DateTime(2026).isBefore(DateTime(2027)) instead.)

  // ── INCORRECT USAGE: logical error (== without hashCode) ────────────────
  // If CartLineItem had overridden == but NOT hashCode, the two equal scans
  // above would land in different hash buckets, uniqueItems.length would be 2,
  // and the duplicate would never be removed. No error is raised; the bug is
  // entirely silent. The hash_and_equals lint is the only warning you get.

  // ── INCORRECT USAGE: logical error (comparing with NaN) ─────────────────
  // A guard written as `if (reading == double.nan)` can NEVER be true and so
  // never rejects a bad reading. The correct guard is `if (reading.isNaN)`.
}
