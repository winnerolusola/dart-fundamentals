// =============================================================================
// 07 — final
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// `final` makes a binding single-assignment: the variable can be set exactly once
// and never reassigned. It constrains the NAME, not the object the name points
// at. This is the cheapest way to communicate and enforce "this does not change
// after it is set", which is the property that makes code easiest to reason about.
// In an order pipeline, `final orderId = generateOrderId();` guarantees that no
// later line silently rebinds `orderId` to a different value, so every read of
// `orderId` in the function is the same value.
//
// SYNTAX — EVERY VALID FORM
//   final orderId = 'INV-4501';        // Inferred type, single assignment.
//   final String customerName = 'Ada'; // Explicit type, single assignment.
//   final List<String> tags = ['new']; // The binding is fixed...
//                                        // ...but the list object is mutable.
// A `final` local may be declared and assigned later, as long as it is assigned
// exactly once on every path before use (definite assignment still applies).
//
// WHAT THE COMPILER DOES
// The analyser permits exactly one assignment to a `final` variable and rejects
// any second assignment as a compile error. Unlike `const` (file 08), the value
// need NOT be known at compile time; `final` accepts any expression, including a
// function call evaluated at runtime. The analyser still runs definite-assignment
// analysis: a `final` local declared without an initialiser must be assigned once
// before use.
//
// WHAT THE RUNTIME DOES
// A `final` variable is initialised at runtime when its single assignment
// executes (for a top-level or static `final`, lazily on first read, like other
// top-level variables, file 10). After that the slot is never written again. The
// referenced object is ordinary and may be mutated through its own API; `final`
// does nothing to freeze it.
//
// EDGE CASES THE DOCS STATE
// - A `final` variable can be set only once.
// - A `final` object cannot be reassigned, but its FIELDS can still change; only
//   `const` makes the object itself immutable.
// - Effective Dart recommends making fields and top-level variables `final` by
//   default, reserving mutability for when it is genuinely needed.
//
// EDGE CASES THE DOCS DO NOT DRAW OUT
// - `final` on a collection is a classic trap: `final tags = ['new']` forbids
//   `tags = [...]` but permits `tags.add('sale')`. Trigger: expecting `final` to
//   block element mutation. Result: the list changes despite the `final`. Use a
//   `const` list, or an unmodifiable view, to freeze contents.
// - A `final` local in a loop body is re-created each iteration, so it can be
//   "assigned once" per iteration without error. Trigger: declaring `final` inside
//   a loop. Result: legal; each iteration's binding is fresh.
// - `final` is implied by `const`: every `const` variable is also `final`, but
//   not vice versa.
//
// PERFORMANCE
// `final` has no direct runtime cost over a mutable variable; it is a static
// constraint. Its value is in maintainability and in enabling certain analyser
// optimisations and lints. It does not, by itself, enable the
// constant-canonicalisation benefits that `const` provides (file 08).
//
// LANGUAGE DESIGN DECISION
// Dart separates "this binding will not be reassigned" (`final`) from "this value
// is a compile-time constant" (`const`) because they answer different questions.
// Many runtime values you never want to reassign (a generated id, a parsed
// configuration) are not compile-time constants, so a single keyword conflating
// the two would force a false choice. `final` covers the common, runtime case;
// `const` covers the narrower, compile-time case and implies `final` on top. The
// rejected alternative, a single immutability keyword, was avoided because it
// could not express "fixed binding to a runtime-computed value".
//
// INTERACTION WITH OTHER CONSTRUCTS
// `final` builds on declaration (file 01) and inference (file 02); it is subject
// to definite assignment (file 05). Combined with `late` it gives the deferred,
// single-assignment field pattern (file 09). `const` (file 08) is `final` plus a
// compile-time-constant requirement and deep immutability.
//
// WHAT FAILURE LOOKS LIKE
// - Compile: a second assignment to a `final` variable.
//   "The final variable 'orderId' can only be set once."
// - Compile: a `final` field with no initialiser and no constructor assignment.
//   "The final variable 'x' must be initialized."
// - Logical: mutating the object behind a `final` binding and being surprised the
//   contents changed, because `final` never promised immutability of the object.
// =============================================================================

void main() {
  // --- Inferred type, assigned once. ---
  final orderId = 'INV-4501';
  print(orderId); // INV-4501

  // --- Explicit type, assigned once. ---
  final String customerName = 'Ada Obi';
  print(customerName); // Ada Obi

  // --- final accepts a RUNTIME value (not required to be const). ---
  final placedAt = DateTime.now().toUtc().isUtc; // Computed at runtime.
  print(placedAt); // true

  // --- final local assigned after declaration (once, before use). ---
  final int shippingFeeKobo;
  if (orderId.startsWith('INV')) {
    shippingFeeKobo = 0;
  } else {
    shippingFeeKobo = 1500;
  }
  print(shippingFeeKobo); // 0

  // --- THE COLLECTION TRAP: the binding is fixed, the object is not. ---
  final List<String> orderTags = ['new-customer'];
  orderTags.add('priority'); // Allowed: mutating the list, not rebinding.
  print(orderTags); // [new-customer, priority]

  // --- final inside a loop: a fresh binding each iteration, so no error. ---
  for (var lineNumber = 1; lineNumber <= 2; lineNumber++) {
    final lineLabel = 'line-$lineNumber'; // New binding per iteration.
    print(lineLabel); // line-1   then   line-2
  }

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (reassigning a final variable)
  // ---------------------------------------------------------------------------
  // final invoiceNumber = 'INV-4501';
  // invoiceNumber = 'INV-4502';
  // Compile-time error:
  // "The final variable 'invoiceNumber' can only be set once."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (final local read before its assignment)
  // ---------------------------------------------------------------------------
  // final int totalKobo;
  // print(totalKobo); // No assignment has reached this point.
  // Compile-time error:
  // "The final variable 'totalKobo' must be assigned before it can be used."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — LOGICAL ERROR (expecting final to freeze contents)
  // ---------------------------------------------------------------------------
  // final defaultDiscounts = {'loyalty': 5};
  // defaultDiscounts['flash'] = 20; // Allowed: final did not freeze the map.
  // print(defaultDiscounts); // {loyalty: 5, flash: 20}
  // No error. To freeze, use a const map or Map.unmodifiable.
}
