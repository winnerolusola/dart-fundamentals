// =============================================================================
// 08 — const (COMPILE-TIME CONSTANTS, CANONICALISATION, DEEP IMMUTABILITY)
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// `const` declares a compile-time constant: a value the compiler can fully
// evaluate before the program runs, freeze forever, and share. It does two things
// `final` does not. It requires the value to be known at compile time, and it
// makes the value DEEPLY immutable, the object and all its fields. As a side
// effect the compiler CANONICALISES const values: two const expressions that
// produce equal values become the SAME object in memory. This is the property
// behind Flutter's widget reuse, where identical const widgets are reused rather
// than rebuilt. In a configuration module, `const maxRetries = 5;` is baked into
// the binary, and `const EdgeInsets.all(8)` used in many places is allocated once.
//
// SYNTAX — EVERY VALID FORM
//   const maxRetries = 5;                 // Top-level / local const variable.
//   static const apiVersion = 'v1';       // Class-level const MUST be static.
//   const double atm = 1.01325 * pressureUnitDynes; // Arithmetic on const operands.
//   const empty = [];                     // Equivalent to const [].
//   var mutableHolder = const [];         // const VALUE held by a non-const var.
//   final fixedHolder = const {};         // const value behind a final binding.
//   const point = Point(0, 0);            // Requires a const constructor.
// const values may use type checks/casts (is, as), collection `if`, and spreads:
//   const tier = i as int;
//   const map = {if (i is int) i: 'int'};
//   const set = {if (list is List<int>) ...list};
//
// WHAT THE COMPILER DOES
// The analyser evaluates the const expression at compile time and rejects
// anything that is not a compile-time constant (a function call returning a
// runtime value, `DateTime.now()`, a non-final variable, and so on). A class-level
// const must be `static`, because a const belongs to the type, not to any
// instance. The compiler canonicalises: structurally equal const values are
// deduplicated to one shared instance, so `identical(const [1], const [1])` is
// true. Within a const context (the initialiser of a const declaration, or after
// the `const` keyword) inner `const` keywords are implied and may be omitted.
//
// WHAT THE RUNTIME DOES
// Const values are created during compilation and embedded; at runtime there is
// no allocation and no initialiser to execute for them. A canonicalised const is
// a single shared, immutable object for the whole program. Because it is deeply
// immutable, no field can be written, so sharing is always safe.
//
// EDGE CASES THE DOCS STATE
// - Instance variables can be `final` but never `const`.
// - A class-level const must be `static const`.
// - You may omit a redundant inner `const` inside a const context (`const empty =
//   []` is `const []`).
// - A non-final, non-const variable can be reassigned even if it held a const
//   value (`liveHolder = [1,2,3]` after `var liveHolder = const []`).
// - A `const` object and its fields cannot be changed; a `final` object's fields
//   can.
//
// EDGE CASES THE DOCS DO NOT DRAW OUT
// - Canonicalisation has observable identity: `identical(const [1], const [1])`
//   is true, while `identical([1], [1])` is false. Trigger: comparing const
//   literals with `identical`. Result: equal const literals are the same object.
// - Mutating a `const` collection is a RUNTIME error, not a compile error, when
//   the call is made through an interface that allows it. Trigger: `const []`
//   then `.add(...)`. Result: "Unsupported operation: Cannot add to an
//   unmodifiable list".
// - A const constructor does not FORCE const construction; `Point(1, 2)` without
//   `const` builds a normal, non-canonicalised instance. The `const` keyword at
//   the call site (or const context) is what triggers canonicalisation.
// - Floating-point const arithmetic uses the same IEEE-754 rules as runtime, so
//   `const sum = 0.1 + 0.2` is the usual 0.30000000000000004, frozen at compile time.
//
// PERFORMANCE
// const eliminates both allocation and initialisation at runtime for the value,
// and canonicalisation reduces memory by sharing one instance across all uses. In
// Flutter, const widgets let the framework skip rebuilding subtrees whose const
// configuration is unchanged, because identity comparison short-circuits the diff.
// The cost is paid once, at compile time.
//
// LANGUAGE DESIGN DECISION
// Dart distinguishes a const VALUE from a const VARIABLE deliberately. The keyword
// is overloaded to mean both "this variable is a compile-time constant" and
// "construct this value as a canonicalised constant", because both rest on the
// same evaluation-at-compile-time machinery. Requiring `static` on class-level
// const reflects that a constant is a property of the type and cannot depend on
// any instance's state. The rejected alternative, allowing instance-level const,
// was avoided because an instance does not exist at compile time.
//
// INTERACTION WITH OTHER CONSTRUCTS
// Every `const` variable is implicitly `final` (file 07), so it inherits
// single-assignment and adds compile-time evaluation and deep immutability. const
// cannot combine with `late` (file 06), since `late` is a runtime concept and
// const is compile-time. const collections are the correct fix for the `final`
// collection trap in file 07.
//
// WHAT FAILURE LOOKS LIKE
// - Compile: const initialised with a non-constant expression.
//   "Const variables must be initialized with a constant value."
// - Compile: a class-level const that is not static.
//   "Only static fields can be declared as const."
// - Compile: reassigning a const variable.
//   "Constant variables can't be assigned a value."
// - Runtime: mutating a const collection.
//   "Unsupported operation: Cannot add to an unmodifiable list".
// =============================================================================

const pressureUnitDynes = 1000000; // Unit of pressure (dynes/cm^2).
const double standardAtmosphere = 1.01325 * pressureUnitDynes; // const arithmetic.

// A class with a const constructor: all fields are final, constructor only
// initialises them, so instances can be compile-time constants.
class GridPoint {
  final int column;
  final int row;
  const GridPoint(this.column, this.row);

  // A class-level constant must be static.
  static const GridPoint origin = GridPoint(0, 0);
}

void main() {
  // --- Plain const variable, baked into the binary. ---
  const maxRetries = 5;
  print(maxRetries); // 5

  // --- const arithmetic on const operands. ---
  print(standardAtmosphere); // 1013250.0

  // --- const value held by different binding kinds. ---
  var mutableHolder = const <int>[]; // const VALUE, mutable BINDING.
  final fixedHolder = const <int>[]; // const value, fixed binding.
  const inlineHolder = <int>[]; // Equivalent to const []; inner const implied.
  print(mutableHolder); // []
  print(fixedHolder); // []
  print(inlineHolder); // []

  // The binding is non-const, so it can be re-pointed at a new (non-const) list.
  mutableHolder = [1, 2, 3];
  print(mutableHolder); // [1, 2, 3]

  // --- CANONICALISATION: equal const literals are the SAME object. ---
  const firstWindow = [10, 20];
  const secondWindow = [10, 20];
  print(identical(firstWindow, secondWindow)); // true
  // Non-const literals are distinct objects even when equal:
  var liveA = [10, 20];
  var liveB = [10, 20];
  print(identical(liveA, liveB)); // false

  // --- const constructor: canonicalised instances. ---
  const cornerA = GridPoint(0, 0);
  const cornerB = GridPoint(0, 0);
  print(identical(cornerA, cornerB)); // true
  print(identical(cornerA, GridPoint.origin)); // true
  // Without const at the call site, a fresh, non-canonical instance is built:
  var liveCorner = GridPoint(0, 0);
  print(identical(cornerA, liveCorner)); // false

  // --- const with is/as, collection if, and spread (from the docs). ---
  const Object tierValue = 3;
  const tierList = [tierValue as int]; // Typecast in a const.
  const tierMap = {if (tierValue is int) tierValue: 'int'}; // is + collection if.
  const tierSet = {if (tierList is List<int>) ...tierList}; // spread in a const.
  print(tierList); // [3]
  print(tierMap); // {3: int}
  print(tierSet); // {3}

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (const from a runtime expression)
  // ---------------------------------------------------------------------------
  // const startedAt = DateTime.now(); // Not knowable at compile time.
  // Compile-time error:
  // "Const variables must be initialized with a constant value."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (reassigning a const variable)
  // ---------------------------------------------------------------------------
  // const sampleCeiling = [42];
  // sampleCeiling = [43];
  // Compile-time error:
  // "Constant variables can't be assigned a value."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — RUNTIME ERROR (mutating a const collection)
  // ---------------------------------------------------------------------------
  // const allowedRoles = <String>['admin'];
  // allowedRoles.add('guest'); // Compiles via the List interface...
  // Runtime error:
  // "Unsupported operation: Cannot add to an unmodifiable list"

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — LOGICAL ERROR (const constructor without const call site)
  // ---------------------------------------------------------------------------
  // var firstCell = GridPoint(1, 1); // No const keyword: a normal instance.
  // var secondCell = GridPoint(1, 1); // Another normal instance.
  // print(identical(firstCell, secondCell)); // false  <- no canonicalisation without const.
  // No error; you simply lost the sharing benefit by omitting const.
}
