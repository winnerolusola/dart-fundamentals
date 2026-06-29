// =============================================================================
// 11 — WILDCARD VARIABLES (_)
// =============================================================================
//
// VERSION REQUIREMENT
// Wildcard variables require a language version of at least 3.7. Below that
// version, `_` is an ordinary binding identifier and the behaviour described here
// does not apply.
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// A wildcard variable, written `_`, declares a local variable or parameter that is
// NON-BINDING: a deliberate placeholder. The initialiser still runs, but the value
// is not accessible through the name, and crucially, multiple declarations named
// `_` can coexist in the same namespace without a collision error. The problem it
// solves is the noise and accidental-use risk of naming things you do not intend to
// read. In a stream of sensor frames where you only care about the index, `for (var
// _ in frames)` states "I am iterating, I am ignoring each element" without
// inventing a throwaway name that the analyser would then flag as unused or that you
// might accidentally reference.
//
// SYNTAX — EVERY VALID FORM (all are block-local; see the restriction below)
//   var _ = computeSideEffect();          // Local variable declaration.
//   int _ = 2;                            // Typed local; value discarded.
//   for (var _ in frames) { }             // For-loop variable.
//   try { } catch (_) { }                 // Catch-clause parameter.
//   class Box<_> {}                       // Generic type parameter.
//   void scan<_>() {}                     // Generic function type parameter.
//   list.where((_) => true);              // Function parameter.
//   void f(void g(int _, bool _)) {}      // Repeated `_` parameters, no collision.
//   typedef Handler = void Function(String _, String _);
//
// WHAT THE COMPILER DOES
// The analyser treats `_` as non-binding: it introduces no readable name, so any
// attempt to read a value through `_` fails to resolve. Because it binds nothing,
// two or more `_` in the same scope do not conflict, where two real identically
// named declarations would be "already defined". The initialiser, if present, is
// still type-checked and still executed for its side effects.
//
// WHAT THE RUNTIME DOES
// Any initialiser or argument associated with a `_` is still evaluated; only the
// binding is dropped. There is no slot to read later. For a `for (var _ in xs)`,
// each element is still produced by the iterator (and any side effect of iteration
// occurs); the element is simply not bound to a usable name.
//
// EDGE CASES THE DOCS STATE
// - Top-level declarations, and any member where library privacy (`_` prefix
//   meaning "private") might be affected, are NOT valid wildcard uses. Wildcards
//   are for block-local declarations.
// - Valid sites: local variable, for-loop variable, catch-clause parameter, generic
//   type and function type parameters, and function parameters.
// - The lint `unnecessary_underscores` flags places where a single `_` can replace
//   the older convention of `__`, `___` used to dodge name collisions.
//
// EDGE CASES THE DOCS DO NOT DRAW OUT
// - `_` as a private-name prefix is unchanged: a top-level `_helper()` is still a
//   library-private declaration, not a wildcard, because privacy applies there.
//   Trigger: expecting a top-level `_` to be a wildcard. Result: it is treated as a
//   (private) real name, and a second top-level `_` collides.
// - A catch clause may use `catch (_)` to drop the exception object and `catch (_,
//   _)` to drop both the exception and the stack trace, two wildcards side by side.
// - Pre-3.7 code that used a single `_` as a REAL parameter name and then read it
//   will break under 3.7 semantics, because `_` no longer binds. Trigger: upgrading
//   a codebase that read from a `_` parameter. Result: "Undefined name '_'" at the
//   read site.
//
// PERFORMANCE
// None of consequence. Dropping the binding can let the compiler avoid keeping a
// value around, but the practical effect is readability and the elimination of
// "unused variable" lints, not measurable speed.
//
// LANGUAGE DESIGN DECISION
// `_` was made non-binding so that "I am ignoring this" has a first-class spelling
// that also composes: you can ignore several positions at once without the awkward
// `__`, `___` escalation the lint now discourages. It was confined to block-local
// sites because at the top level and in members `_` already carries the meaning
// "library-private", and overloading it there would clash with that established
// rule. The rejected alternative, making `_` non-binding everywhere, was avoided to
// preserve the privacy convention.
//
// INTERACTION WITH OTHER CONSTRUCTS
// Wildcards lean on scope (file 03): the "no collision" property is exactly the
// relaxation of the "already defined in this scope" rule for `_`. They pair with
// pattern matching and destructuring in the Patterns topic, where `_` ignores a
// field. They are independent of `final`/`const`/`late`, since there is no binding
// to constrain.
//
// WHAT FAILURE LOOKS LIKE
// - Compile: reading a value through `_`.
//   "Undefined name '_'." (there is no binding to read)
// - Compile: using `_` as a wildcard at a top-level/member site where privacy
//   applies, then declaring a second `_`, which collides as a real private name.
//   "The name '_' is already defined."
// =============================================================================

// A normal private (library-local) helper. The leading underscore here means
// PRIVATE, and `_scanFrames` is a real, readable name (not a wildcard).
List<int> _frameSizes() => [120, 256, 256, 64];

void main() {
  // --- Local wildcard: the initialiser runs, the value is discarded. ---
  var _ = _frameSizes().length; // length is computed; not stored under a name.
  // print(_); // Would not compile: "Undefined name '_'."

  // --- Typed local wildcard; multiple `_` in one scope do not collide. ---
  int _ = 2;
  int _ = 3; // No "already defined" error, because `_` binds nothing.
  print('two wildcard locals declared, neither readable'); // (proof by no error)

  // --- For-loop wildcard: iterate while ignoring each element. ---
  var frameCount = 0;
  for (var _ in _frameSizes()) {
    frameCount++; // We only care how many frames there are.
  }
  print(frameCount); // 4

  // --- Catch-clause wildcards: drop the exception, or exception AND stack. ---
  try {
    throw const FormatException('bad frame');
  } catch (_) {
    print('frame rejected'); // frame rejected
  }
  try {
    throw StateError('desync');
  } catch (_, _) {
    print('error and stack ignored'); // error and stack ignored
  }

  // --- Function-parameter wildcards: ignore the callback's argument. ---
  final acceptedFrames = _frameSizes().where((_) => true).toList();
  print(acceptedFrames.length); // 4

  // --- Two wildcard parameters in one signature, no collision. ---
  void logPair(void Function(int _, int _) reducer) {} // Declaration only.
  print('pair signature with two wildcards compiled'); // (proof by no error)

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (reading a wildcard)
  // ---------------------------------------------------------------------------
  // var _ = _frameSizes().first;
  // print(_); // There is no binding named `_` to read.
  // Compile-time error:
  // "Undefined name '_'."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (wildcard misused at top level)
  // ---------------------------------------------------------------------------
  // Place at top level:
  //   var _ = 1; // Here `_` is a PRIVATE real name, not a wildcard.
  //   var _ = 2; // A second private `_` now collides.
  // Compile-time error:
  // "The name '_' is already defined."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — MIGRATION ERROR (pre-3.7 code that read a `_` parameter)
  // ---------------------------------------------------------------------------
  // list.map((_) => _ * 2); // Under 3.7+, `_` is non-binding; the read fails.
  // Compile-time error:
  // "Undefined name '_'."  (rename the parameter if you must read it)
}
