// =============================================================================
// 04 — NULLABLE AND NON-NULLABLE TYPES (SOUND NULL SAFETY)
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// Null safety partitions every type into two: a non-nullable form that can never
// hold null, and a nullable form (written with a trailing `?`) that can. The
// problem it eliminates is the null dereference: calling a method or reading a
// property on something that turns out to be null. In a content feed, an
// `Article` that is non-nullable is guaranteed to exist, so `article.title`
// cannot blow up; an `Article?` forces the code to handle the "no article" case
// before touching it. Dart's null safety is SOUND: the compiler proves the
// absence of null dereferences at edit time rather than hoping at runtime.
//
// SYNTAX — EVERY VALID FORM
//   String title;     // Non-nullable. Cannot be null. Must be initialised.
//   String? subtitle; // Nullable. May be null; defaults to null (file 05).
//   int? viewCount;   // Any type has a nullable counterpart via `?`.
// The `?` attaches to the TYPE, not the variable name. There is no `var?`; you
// cannot make an inferred declaration nullable by punctuation, because `var`
// already infers a concrete type from the initialiser.
//
// WHAT THE COMPILER DOES
// The analyser tracks, for every expression, whether its static type admits null.
// On a value whose type is nullable, it forbids unconditional member access
// (except members that null itself supports: toString, hashCode, runtimeType, ==,
// and the null-aware forms covered in the Operators topic). It converts what
// other languages leave as runtime NullPointerExceptions into edit-time analysis
// errors. It also flags a non-nullable variable that is either never initialised
// with a non-null value or is assigned null.
//
// WHAT THE RUNTIME DOES
// Nullability is largely a static property. At runtime, a nullable variable that
// holds null simply holds the null object; a non-nullable variable, by
// construction, never does. There is no per-access null check inserted for code
// the compiler already proved safe, which is part of why sound null safety also
// improves performance: the proof is done once, at compile time.
//
// EDGE CASES THE DOCS STATE
// - null supports a small set of members (toString(), hashCode), so those are the
//   exception to the "no access on nullable" rule.
// - Sound null safety turns potential runtime errors into edit-time errors,
//   flagging a non-null variable that was not initialised or was set to null.
//
// EDGE CASES THE DOCS DO NOT FULLY DRAW OUT
// - `String?` is NOT the same as "String or empty"; null and "" are distinct.
//   Trigger: treating an empty string as the absence of a value. Result: code
//   that checks `isEmpty` misses the null case, and vice versa.
// - A nullable type with no initialiser is already initialised (to null), so the
//   "must assign before use" rule does not apply to it. This is why `late` is
//   pointless on a nullable variable (see file 06).
// - Reassigning a nullable variable does not re-widen a non-nullable one; the two
//   forms are different static types and are not interchangeable by assignment in
//   the unsafe direction.
//
// PERFORMANCE
// Sound null safety lets the compiler omit defensive null checks it has proven
// unnecessary, and lets the AOT compiler lay out non-nullable fields without a
// null sentinel path. The cost is paid by you at edit time (handling the null
// case), not by the program at runtime.
//
// LANGUAGE DESIGN DECISION
// "Sound" is the load-bearing word. A merely optional null-checking scheme (as in
// some gradually-typed languages) catches some mistakes but cannot promise the
// absence of null dereferences, because unchecked code can reintroduce null.
// Dart made non-nullable the DEFAULT and nullability opt-in, so the common case
// is the safe case and the dangerous case is visibly marked with `?`. The
// rejected alternative, nullable-by-default with optional non-null annotations,
// would have inverted that and left most code unprotected.
//
// INTERACTION WITH OTHER CONSTRUCTS
// Nullability is a modifier on the type chosen in file 02; `Object?` is the widest
// nullable type. Definite assignment (file 05) is the mechanism that lets a
// non-nullable local be declared without an initialiser yet used safely. `late`
// (file 06) is the escape hatch for non-nullable values the analyser cannot prove
// are assigned. The null-aware operators that consume nullable values (`?.`, `??`,
// `??=`, `!`) belong to the Operators topic and are deliberately not redefined
// here; this file establishes only the restriction they exist to relax.
//
// WHAT FAILURE LOOKS LIKE
// - Compile: unconditional access on a nullable receiver.
//   "The property 'length' can't be unconditionally accessed because the receiver
//    can be 'null'."
// - Compile: assigning null to a non-nullable variable.
//   "A value of type 'Null' can't be assigned to a variable of type 'String'."
// - Compile: a nullable value where a non-nullable one is required.
//   "A value of type 'String?' can't be assigned to a variable of type 'String'."
// =============================================================================

void main() {
  // --- Non-nullable: guaranteed to hold a real String. ---
  String articleTitle = 'Edge Caching Explained';
  print(articleTitle.length); // 24  (safe, receiver is never null)

  // --- Nullable: may hold a String or null. ---
  String? articleSubtitle; // Defaults to null (see file 05).
  print(articleSubtitle); // null

  articleSubtitle = 'A practical guide';
  // Even now, the STATIC type is still String?, so the compiler requires proof
  // of non-null before member access. An explicit check promotes it:
  if (articleSubtitle != null) {
    print(articleSubtitle.length); // 17  (promoted to String inside the if)
  }

  // --- null and empty string are different absences of "content". ---
  String? draftBody = '';
  print(draftBody == null); // false
  print(draftBody.isEmpty); // true  (safe: draftBody is provably non-null here)

  // --- Members that null itself supports are allowed on a nullable receiver. ---
  int? pendingViews; // null
  print(pendingViews.toString()); // null  (toString is defined on Null)
  print(pendingViews.hashCode == null.hashCode); // true

  // --- A nullable variable assigned from a non-nullable source is fine; the
  //     unsafe direction (nullable into non-nullable) is the one that is blocked.
  String authorName = 'Ada';
  String? maybeAuthor = authorName; // Widening: always safe.
  print(maybeAuthor); // Ada

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (member access on a nullable receiver)
  // ---------------------------------------------------------------------------
  // String? summary;
  // print(summary.length);
  // Compile-time error:
  // "The property 'length' can't be unconditionally accessed because the receiver
  //  can be 'null'."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (null assigned to a non-nullable variable)
  // ---------------------------------------------------------------------------
  // String headline = null;
  // Compile-time error:
  // "A value of type 'Null' can't be assigned to a variable of type 'String'."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (nullable value into a non-nullable slot)
  // ---------------------------------------------------------------------------
  // String? maybeSlug = 'edge-caching';
  // String slug = maybeSlug; // maybeSlug is String?, slug demands String.
  // Compile-time error:
  // "A value of type 'String?' can't be assigned to a variable of type 'String'."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — LOGICAL ERROR (treating "" as null)
  // ---------------------------------------------------------------------------
  // String? category;
  // if (category != null) { /* runs only when set, even to '' */ }
  // category = '';
  // if (category != null) print('treated as present'); // prints; '' is not null
  // No error is raised; the empty string is a present, non-null value.
}
