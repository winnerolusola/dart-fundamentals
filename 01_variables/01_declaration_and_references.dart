// =============================================================================
// 01 — VARIABLE DECLARATION AND REFERENCE SEMANTICS
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// A variable is a named handle on a value. Without names, a program could only
// compute throwaway expressions; nothing could be stored, passed, or reused.
// Declaring a variable reserves a name in the current scope and (usually) binds
// it to an initial value. In an e-commerce checkout, `cartTotal` lets one part
// of the code compute a figure and a later part read it back without recomputing.
//
// The single most important fact on this page: a Dart variable does not contain
// an object. It contains a REFERENCE to an object. `var name = 'Bob'` does not
// place the characters of "Bob" into the variable. It creates a String object
// somewhere in memory and stores, in `name`, a reference that points at it.
// Every Dart value is an object, including numbers, booleans and null, so this
// is true uniformly. Two variables can hold references to the same object.
//
// SYNTAX — EVERY VALID FORM
//   var orderId = 4501;          // Inferred type. Compiler reads the initialiser.
//   int orderId = 4501;          // Explicit type annotation, same result.
//   Object payload = 4501;       // Widened static type; any object accepted.
//   dynamic payload = 4501;      // Static checking disabled for this name.
//   int orderId;                 // Declared, not initialised (local only).
//   int width = 1, height = 2, depth = 3; // Multiple declarations, one type.
//
// WHAT THE COMPILER DOES
// With `var`, the analyser performs type inference: it computes the static type
// of the initialiser expression and pins the variable to that type permanently.
// `var orderId = 4501` makes `orderId` an `int` for the rest of its life;
// assigning a String to it later is a compile-time error. Inference happens once,
// from the initialiser, and is not re-run on later assignments. `var` is not a
// "dynamic" or "any" keyword (a misconception carried from JavaScript). It is a
// request to infer a single, fixed, static type.
//
// WHAT THE RUNTIME DOES
// At runtime the object is allocated (small integers and some constants are
// canonicalised and may be shared, but conceptually an object exists) and the
// variable slot holds a machine reference to it. Assigning one variable to
// another copies the reference, not the object. Mutating the shared object
// through one name is visible through the other. Reassigning one name to a new
// object does not affect the other, because reassignment overwrites only that
// one slot's reference.
//
// EDGE CASES THE DOCS STATE
// - The style guide recommends `var` over explicit annotations for local
//   variables whose type is obvious from the initialiser.
// - You may specify the type that inference would have chosen anyway (`String
//   name = 'Bob'`); this is permitted but redundant for initialised locals.
//
// EDGE CASES THE DOCS DO NOT STATE
// - `var x;` with no initialiser does NOT infer; the variable's static type
//   becomes `dynamic`, silently disabling type checking. Trigger: omitting the
//   initialiser on a `var` declaration. Result: every later member access on `x`
//   compiles, and failures move to runtime. Annotate the type instead.
// - Inference can pick a type that is too precise. `var ids = [4501]` infers
//   `List<int>`; you cannot later add a `String`. If a wider element type is
//   intended, annotate: `var ids = <Object>[4501]`.
// - `int width = 1, height;` mixes an initialised and an uninitialised name under one
//   type. `b` is a valid non-nullable local that must be assigned before use.
//
// PERFORMANCE
// Type inference is a compile-time activity with zero runtime cost. A statically
// typed variable lets the AOT compiler avoid dynamic dispatch and generate
// direct calls. A `dynamic` variable forces dynamic dispatch on every member
// access, which is measurably slower and removes compile-time checking. Prefer
// inferred or annotated types; reach for `dynamic` only deliberately.
//
// LANGUAGE DESIGN DECISION
// Dart is a "pure" object-oriented language: there are no primitive non-objects,
// so reference semantics apply to everything and the model stays uniform. The
// team chose local inference (not whole-program inference, as in some ML-family
// languages) to keep error messages local and predictable: a type is decided
// from the initialiser in front of you, not from distant usages. The rejected
// alternative, treating `var` as an untyped escape hatch, was avoided precisely
// because it would surrender the static safety the rest of the language depends on.
//
// INTERACTION WITH OTHER CONSTRUCTS
// The type chosen here is the foundation for null safety (file 04): nullability
// is a modifier on this type. `final` and `const` (files 07 and 08) constrain
// reassignment of this binding. Scope (file 03) decides where this name is
// visible. `var` interacts with collection literals through inference, which is
// why annotating element types sometimes matters.
//
// WHAT FAILURE LOOKS LIKE
// - Compile: assigning an incompatible type to an inferred variable.
//   "A value of type 'String' can't be assigned to a variable of type 'int'."
// - Compile: using an uninitialised non-nullable local before assignment.
//   "The non-nullable local variable 'x' must be assigned before it can be used."
// - Logical: aliasing surprise, where mutation through one reference is seen
//   through another because both point at the same object. No error is produced;
//   the output is simply not what an unwary value-semantics intuition expects.
// =============================================================================

void main() {
  // --- Inferred declaration: the compiler reads the initialiser. ---
  var productName = 'Wireless Keyboard'; // Static type inferred as String.
  print(productName); // Wireless Keyboard

  // --- Explicit annotation: identical result, type written by hand. ---
  String categoryName = 'Peripherals';
  print(categoryName); // Peripherals

  // --- Numeric inference. 4501 is an int literal, so unitPriceKobo is int. ---
  var unitPriceKobo = 4501;
  print(unitPriceKobo); // 4501

  // --- Multiple names under one type annotation. ---
  int cartQuantity = 3, discountPercent = 10;
  print('$cartQuantity items, $discountPercent% off'); // 3 items, 10% off

  // --- Declared without initialiser, then definitely assigned before use. ---
  int shippingFeeKobo;
  if (unitPriceKobo > 4000) {
    shippingFeeKobo = 0; // Free shipping above the threshold.
  } else {
    shippingFeeKobo = 1500;
  }
  print(shippingFeeKobo); // 0

  // --- REFERENCE SEMANTICS: two names, one object. ---
  // A List is a mutable object. Both names hold a reference to the SAME list.
  var primaryWishlist = ['Mouse', 'Monitor'];
  var sharedWishlist = primaryWishlist; // Copies the reference, not the list.
  sharedWishlist.add('Webcam'); // Mutates the one shared object.
  print(primaryWishlist); // [Mouse, Monitor, Webcam]
  print(sharedWishlist); // [Mouse, Monitor, Webcam]
  print(identical(primaryWishlist, sharedWishlist)); // true

  // --- Reassignment overwrites one slot only; the other still points at the
  //     original object. ---
  sharedWishlist = ['Headset']; // sharedWishlist now references a NEW list.
  print(primaryWishlist); // [Mouse, Monitor, Webcam]
  print(sharedWishlist); // [Headset]
  print(identical(primaryWishlist, sharedWishlist)); // false

  // --- Inference is fixed from the initialiser; reassigning a compatible value
  //     of the same type is fine. ---
  var sessionToken = 'abc123';
  sessionToken = 'def456'; // Still a String. Allowed.
  print(sessionToken); // def456

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (type mismatch on an inferred variable)
  // ---------------------------------------------------------------------------
  // var orderReference = 4501; // inferred int
  // orderReference = 'INV-4501';
  // Compile-time error:
  // "A value of type 'String' can't be assigned to a variable of type 'int'."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (uninitialised non-nullable local used)
  // ---------------------------------------------------------------------------
  // int loyaltyPoints;
  // print(loyaltyPoints);
  // Compile-time error:
  // "The non-nullable local variable 'loyaltyPoints' must be assigned before it
  //  can be used."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (var with no initialiser becomes dynamic,
  // then a genuinely wrong call slips past static checking and fails at runtime)
  // ---------------------------------------------------------------------------
  // var unverifiedInput;        // Static type is dynamic, NOT inferred.
  // unverifiedInput = 4501;
  // unverifiedInput.submit();   // Compiles, because dynamic permits any call.
  // Runtime error:
  // "NoSuchMethodError: Class 'int' has no instance method 'submit'."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — LOGICAL ERROR (aliasing mistaken for copying)
  // ---------------------------------------------------------------------------
  // var defaultPermissions = ['read'];
  // var adminPermissions = defaultPermissions; // Same object, not a copy.
  // adminPermissions.add('write');
  // print(defaultPermissions); // [read, write]  <- 'read'-only intent broken.
  // No error is raised. To copy, build a new object: [...defaultPermissions].
}
