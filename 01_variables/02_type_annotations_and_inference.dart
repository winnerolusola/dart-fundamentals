// =============================================================================
// 02 — TYPE ANNOTATIONS, INFERENCE, AND Object / Object? / dynamic
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// A type annotation constrains which values may flow through a name. It is both
// a contract and documentation: it tells the compiler what to reject and tells
// the next reader what to expect. The problem it solves is silent corruption. In
// a sensor pipeline, a reading declared `double temperatureCelsius` cannot
// accidentally be assigned a String parsed from a malformed packet; the error is
// caught at edit time, not three layers downstream.
//
// Three types accept "anything", and choosing between them is a recurring real
// decision. `dynamic`, `Object` and `Object?` all admit a wide range of values
// but they differ in what they let you DO with the value afterwards.
//
// SYNTAX — EVERY VALID FORM
//   var reading = 21.4;          // Inferred: static type double.
//   double reading = 21.4;       // Explicit, identical static type.
//   num reading = 21.4;          // Wider numeric supertype (int or double).
//   Object payload = 21.4;       // Any non-null object; members of Object only.
//   Object? payload = null;      // Any object OR null.
//   dynamic payload = 21.4;      // Any object; all member access permitted.
//
// WHAT THE COMPILER DOES
// For `var` with an initialiser, the analyser infers the initialiser's static
// type and fixes it. For an explicit annotation, the analyser checks every
// assignment against it. The three "wide" types diverge sharply at compile time:
// - On an `Object` value, only members declared on Object are allowed
//   (toString, hashCode, runtimeType, ==). `payload.abs()` is a compile error.
// - On an `Object?` value, you cannot even call those without first proving
//   non-null, because the value might be null.
// - On a `dynamic` value, EVERY member access compiles. The analyser performs no
//   checking at all; `dynamic` is an opt-out of static typing for that name.
//
// WHAT THE RUNTIME DOES
// The runtime type of the stored object is unchanged by the annotation; the
// annotation is a static (edit-time) constraint, not a runtime box. A value
// annotated `Object` is still really a `double` at runtime, recoverable with an
// `is` check. With `dynamic`, member lookups that the compiler waved through are
// resolved at runtime by dynamic dispatch, and a missing member throws
// NoSuchMethodError then rather than being caught earlier.
//
// EDGE CASES THE DOCS STATE (Effective Dart: Design)
// - Annotate variables WITHOUT initialisers; inference has nothing to work from.
// - Annotate fields and top-level variables unless the initialiser type is
//   obvious (literals, constructor calls, references to typed constants).
// - Do NOT redundantly annotate initialised LOCAL variables; prefer `var`.
// - Annotate with `dynamic` explicitly rather than letting inference fail
//   silently into it, so intent is visible.
// - Prefer `Object?`/`Object` plus `is` checks over `dynamic` for "accept any".
//
// EDGE CASES THE DOCS DO NOT FORCE TO THE SURFACE
// - "Raw" generic types fill missing arguments with `dynamic`, not by context.
//   `List numbers = [1, 2, 3]` makes element access dynamic. Write `List<int>`.
//   Trigger: writing a generic type name with no type arguments. Result: a
//   silent loss of element-level checking.
// - Inferred-too-precise: `var widget = Text('hi')` infers `Text`, so you cannot
//   reassign a `Padding`. Annotate the supertype (`Widget widget = ...`) when you
//   intend to reassign across subtypes.
// - `dynamic` is contagious through inference: `var first = dynamicList.first`
//   makes `first` dynamic too, propagating the opt-out further than intended.
//
// PERFORMANCE
// Statically typed code lets the compiler devirtualise and inline. `dynamic`
// forces runtime member resolution on each access, which is slower and defeats
// AOT optimisation. `Object`/`Object?` keep full static typing; the only cost is
// the `is` check you write to narrow them, which is cheap.
//
// LANGUAGE DESIGN DECISION
// Dart deliberately separates "accepts any value" (`Object?`) from "accepts any
// value and disables checking" (`dynamic`). Many languages conflate these into a
// single top type, which means using the catch-all type also surrenders safety.
// By splitting them, Dart lets you say "I will accept anything but I still want
// the analyser to stop me calling nonsense" via `Object?`. `dynamic` remains
// available for genuine dynamic dispatch (interop, JSON, reflection-like code).
// The rejected alternative, a single `any` type, was passed over because it made
// the loss of safety invisible at the use site.
//
// INTERACTION WITH OTHER CONSTRUCTS
// The `?` that turns `Object` into `Object?` is the same nullability modifier as
// in file 04; here it appears on the widest type. Inference decisions here feed
// `final`/`const` (the constant's type is inferred the same way) and collections.
//
// WHAT FAILURE LOOKS LIKE
// - Compile: a non-Object member on an Object value.
//   "The method 'abs' isn't defined for the type 'Object'."
// - Compile: any member on an Object? without a null check.
//   "The method 'abs' can't be unconditionally invoked because the receiver can
//    be 'null'."
// - Runtime: a missing member on a dynamic value.
//   "NoSuchMethodError: Class 'String' has no instance method 'abs'."
// =============================================================================

void main() {
  // --- Inference picks the initialiser's type. ---
  var temperatureCelsius = 21.4; // Inferred double.
  print(temperatureCelsius.abs()); // 21.4  (double members available)

  // --- Explicit annotation, same static type as inference would give. ---
  double humidityPercent = 58.2;
  print(humidityPercent.roundToDouble()); // 58.0

  // --- Wider numeric supertype: accepts int and double. ---
  num pressureReading = 1013; // int now...
  pressureReading = 1013.25; // ...double later. Both are num.
  print(pressureReading); // 1013.25

  // --- Object: accepts any non-null value, exposes only Object's members. ---
  Object sensorPayload = 21.4;
  print(sensorPayload.toString()); // 21.4
  // Recover the real type with an is check, which promotes it to double:
  if (sensorPayload is double) {
    print(sensorPayload.abs()); // 21.4  (now double members are available)
  }

  // --- Object?: accepts any value OR null. Must be proven non-null to use. ---
  Object? lastError = null;
  lastError = 'Checksum mismatch';
  if (lastError != null) {
    print(lastError); // Checksum mismatch
  }

  // --- dynamic: accepts anything, permits any call at compile time. ---
  dynamic decodedFrame = 21.4;
  print(decodedFrame.abs()); // 21.4  (compiles because checking is disabled)
  decodedFrame = 'now a string';
  print(decodedFrame.toUpperCase()); // NOW A STRING

  // --- Complete generic type vs raw generic type. ---
  List<int> sampleWindow = [12, 15, 14]; // Element type fixed to int.
  print(sampleWindow.reduce((running, next) => running + next)); // 41

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (non-Object member on an Object value)
  // ---------------------------------------------------------------------------
  // Object rawReading = 21.4;
  // print(rawReading.abs());
  // Compile-time error:
  // "The method 'abs' isn't defined for the type 'Object'."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (member on Object? without a null check)
  // ---------------------------------------------------------------------------
  // Object? maybeReading = 21.4;
  // print(maybeReading.abs());
  // Compile-time error:
  // "The method 'abs' can't be unconditionally invoked because the receiver can
  //  be 'null'."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — RUNTIME ERROR (missing member on a dynamic value)
  // ---------------------------------------------------------------------------
  // dynamic frame = 'not a number';
  // print(frame.abs()); // Compiles. dynamic disables the check.
  // Runtime error:
  // "NoSuchMethodError: Class 'String' has no instance method 'abs'."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — LOGICAL ERROR (raw generic silently goes dynamic)
  // ---------------------------------------------------------------------------
  // List rawWindow = [12, 15, 14]; // Element type is dynamic, not int.
  // var sum = rawWindow.first + 'oops'; // Compiles: dynamic + anything.
  // Runtime error at the addition:
  // "NoSuchMethodError" / type error, depending on operands. Write List<int>.
}
