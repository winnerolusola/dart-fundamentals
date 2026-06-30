// ═══════════════════════════════════════════════════════════════════════════
// 11 – SPREAD OPERATORS: ... and ...?
// ═══════════════════════════════════════════════════════════════════════════
//
// FORWARD-DEPENDENCY FLAG
// ---------------------------------------------------------------------------
// The official operators page lists spread but states plainly that it is NOT an
// operator: the `...`/`...?` syntax is part of the COLLECTION LITERAL itself,
// and the page defers the full treatment to the Collections topic. This file
// covers spread because it appears on the operators page and a working
// developer meets it constantly, but it depends on collection literals (lists,
// sets, maps), which the curriculum covers in a later topic. Everything here is
// demonstrated with plain list and map literals so it stands alone; the deeper
// collection mechanics (where a spread is allowed, the element grammar) belong
// to that later topic and are not duplicated here.
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// A spread expands the elements of one collection into another collection
// literal, in place. It solves the "combine without a loop" problem: merging a
// base list with overrides, concatenating page results, inserting a sublist,
// building a widget list from fixed and conditional parts. Before spread you
// wrote `addAll` against a mutable list; spread lets you express the combined
// collection as a single literal, which composes cleanly with the `if` and
// `for` elements that collection literals also support.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   [...iterable]        spread: insert every element of iterable here
//   [...?iterable]       null-aware spread: if iterable is null, insert nothing
//   {...map}             spread into a set or map literal
//   {...?map}            null-aware spread into a set or map literal
//
//   The target of a spread can be any expression yielding an iterable (for
//   lists/sets) or a map (for maps): [...a + b] is valid because the syntax has
//   effectively the lowest "precedence" and accepts any expression.
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// Because spread is literal syntax, not an operator, it has no entry in the
// operator-precedence table and no overridable method behind it. The analyzer
// checks that the spread target's element type is assignable to the surrounding
// collection's element type: spreading a `List<int>` into a `List<String>` is a
// compile error. For a plain `...`, the target must be non-null; spreading a
// nullable iterable with `...` is a compile error, and the analyzer points you
// to `...?`.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// At runtime the surrounding literal is built by iterating each spread target in
// order and inserting its elements. `...?` first tests the target for null and,
// if null, contributes zero elements. A spread iterates its source once; the
// resulting collection is a new collection, and the elements are shared by
// reference (a shallow copy of the structure, not a deep clone of the elements).
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - Spread is not an operator and has no operator precedence; any expression is
//    a valid spread target, including `[...a + b]`.
//  - `...?` is the null-aware form: a null target contributes nothing rather
//    than throwing.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - Plain `...` on a null target THROWS at runtime if the static type let it
//    through (for example via `dynamic`); the safe form for a nullable source is
//    always `...?`.
//  - Spread does a SHALLOW copy. Spreading a list of mutable objects into a new
//    list gives you a new list whose elements are the same objects; mutating an
//    element through either list is visible through both.
//  - Order matters and later entries win in MAP and SET literals. In
//    `{...defaults, ...overrides}`, a key present in both takes the value from
//    `overrides` because it is spread later. This is the idiom for config layering.
//  - Spread composes with collection-`if` and collection-`for`:
//    `[...base, if (isAdmin) ...adminTools, for (final t in extra) t.label]`.
//  - A spread target is iterated eagerly when the literal is built; spreading a
//    lazy `Iterable` (such as a `.map(...)` result) forces it at that point.
//  - Spreading into a `Set` de-duplicates by the elements' `==`/`hashCode`
//    (see 03), so duplicates across spreads silently collapse.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// A spread allocates a new collection and copies element references, so it is
// O(n) in the total number of elements spread. Chained spreads in a hot path
// rebuild the whole collection each time; if you are accumulating across many
// iterations, a single mutable list with `addAll` avoids repeated reallocation.
// For one-off construction, spread's cost is the unavoidable copy and is fine.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Spread was added as collection-literal syntax rather than as an operator so
// that it could sit alongside collection-`if` and collection-`for` as a unified
// way to compute the elements of a literal. This was driven heavily by Flutter,
// where building a `children` list from fixed widgets, conditional widgets, and
// repeated widgets in one expression is extremely common. Keeping it out of the
// operator system means it has no precedence interactions to reason about: a
// spread always takes the entire following expression as its target.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// `...?` uses the same null-aware philosophy as `?.` (09) and `??` (08): a null
// source is tolerated and contributes nothing. De-duplication in set spreads
// depends on `==`/`hashCode` from 03. Unlike every true operator in this topic,
// spread has no row in the precedence table (12) and no compound-assignment or
// overridable-method form.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: element type mismatch.
//    "The element type 'int' can't be assigned to the list type 'String'."
//  - Compile error: plain `...` on a nullable source.
//    "The expression can't be null because of the spread, so use '...?'." /
//    "A nullable expression can't be used in a spread."
//  - Runtime error: `...` on a null `dynamic` source.
//    "type 'Null' is not a subtype of type 'Iterable<dynamic>'" (or NoSuchMethod
//    on the iterator), avoided by using `...?`.
//  - Logical error: relying on a deep copy (spread is shallow), or getting
//    map/set override order backwards.
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ── Basic list spread: concatenation as a literal ───────────────────────
  final featuredSkus = ['SKU-001', 'SKU-002'];
  final newArrivalSkus = ['SKU-040', 'SKU-041'];
  final homepageSkus = [...featuredSkus, ...newArrivalSkus, 'SKU-PROMO'];
  print(homepageSkus);
  // [SKU-001, SKU-002, SKU-040, SKU-041, SKU-PROMO]

  // ── Null-aware spread: a null source contributes nothing ────────────────
  List<String>? clearanceSkus; // null (no clearance section this week)
  final catalogue = [...featuredSkus, ...?clearanceSkus];
  print(catalogue); // [SKU-001, SKU-002]

  clearanceSkus = ['SKU-099'];
  final catalogue2 = [...featuredSkus, ...?clearanceSkus];
  print(catalogue2); // [SKU-001, SKU-002, SKU-099]

  // ── Any expression is a valid spread target ─────────────────────────────
  final pageOne = [1, 2];
  final pageTwo = [3, 4];
  print([...pageOne + pageTwo, 5]); // [1, 2, 3, 4, 5]

  // ── Map spread with later-wins override (config layering) ───────────────
  final defaults = {'theme': 'light', 'currency': 'NGN', 'pageSize': '20'};
  final userOverrides = {'theme': 'dark'};
  final effectiveSettings = {...defaults, ...userOverrides};
  print(effectiveSettings);
  // {theme: dark, currency: NGN, pageSize: 20}   (override spread later wins)

  // ── Set spread de-duplicates via ==/hashCode ────────────────────────────
  final adminTags = {'admin', 'ops'};
  final userTags = {'ops', 'viewer'};
  final allTags = {...adminTags, ...userTags};
  print(allTags); // {admin, ops, viewer}   ('ops' appears once)

  // ── Spread composed with collection-if and collection-for ───────────────
  const isAdmin = true;
  final baseActions = ['view', 'edit'];
  final adminActions = ['delete', 'audit'];
  final extraLabels = ['export', 'share'];
  final menu = [
    ...baseActions,
    if (isAdmin) ...adminActions,
    for (final label in extraLabels) label.toUpperCase(),
  ];
  print(menu); // [view, edit, delete, audit, EXPORT, SHARE]

  // ── Spread is a SHALLOW copy ─────────────────────────────────────────────
  final originalRows = [
    ['a'],
    ['b'],
  ];
  final copiedRows = [...originalRows]; // new outer list, same inner lists
  copiedRows[0].add('mutated'); // mutates the shared inner list
  print(originalRows); // [[a, mutated], [b]]   (visible through the original)

  // ── INCORRECT USAGE: compile error (element type mismatch) ──────────────
  //     final mixed = <String>[...[1, 2, 3]];
  //
  //     Error: "The element type 'int' can't be assigned to the list type
  //     'String'."

  // ── INCORRECT USAGE: compile error (plain ... on a nullable) ────────────
  //     List<String>? maybeList;
  //     final joined = [...maybeList];
  //
  //     Error: "A nullable expression can't be used in a spread." (Use ...?)

  // ── INCORRECT USAGE: logical error (override order backwards) ───────────
  // Spreading defaults LAST overwrites the user's choice:
  //
  //   final wrong = {...userOverrides, ...defaults}; // defaults win, bug
  //
  // The later spread wins, so user overrides must come last.
}
