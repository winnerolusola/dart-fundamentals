// =============================================================================
// 06 — LATE VARIABLES
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// `late` is a modifier with two distinct jobs. First, it lets you declare a
// non-nullable variable that is assigned AFTER its declaration in a place the
// flow analyser (file 05) cannot inspect, typically a top-level or instance
// variable. You promise the compiler the value will be there before it is read,
// and you accept a runtime check instead of an edit-time proof. Second, when you
// DO give a `late` variable an initialiser, that initialiser runs lazily, on
// first read rather than at declaration, which avoids paying for an expensive
// computation that may never be needed. In a sensor dashboard, `late final
// SensorBus bus;` can be assigned in a setup method the analyser cannot trace,
// and `late final calibration = readCalibrationFromEeprom();` defers a slow read
// until the first time calibration is actually consulted.
//
// SYNTAX — EVERY VALID FORM
//   late String deviceName;                 // Non-nullable, assigned later.
//   late final String deviceName;           // As above, single assignment.
//   late String label = computeLabel();      // Lazily initialised on first use.
//   late final config = loadConfig();         // Lazy AND single-assignment.
//
// WHAT THE COMPILER DOES
// `late` suspends definite-assignment analysis for that variable: the analyser no
// longer demands proof that it is set before use, and stops treating a missing
// initialiser as an error. In exchange it inserts a runtime guard. For a `late`
// variable WITH an initialiser, the analyser arranges for the initialiser to run
// on first access rather than eagerly. `late` is only meaningful on non-nullable
// variables or on any variable you want lazily initialised; the analyser will
// warn that `late` on a nullable variable with no initialiser is pointless,
// because such a variable already has a default (null).
//
// WHAT THE RUNTIME DOES
// A `late` variable carries a hidden "initialised yet?" state. Reading it before
// assignment throws a LateInitializationError. For the lazy-initialiser form, the
// first read runs the initialiser, stores the result, and returns it; subsequent
// reads return the stored value without re-running the initialiser. The
// initialiser therefore runs at most once and only if the variable is read.
//
// EDGE CASES THE DOCS STATE
// - Failing to initialise a `late` variable before use is a RUNTIME error.
// - The lazy form helps when the value may not be needed and is costly, or when
//   an instance initialiser needs access to `this`.
//
// EDGE CASES THE DOCS DO NOT DRAW OUT
// - The lazy initialiser runs in the reader's context, so any exception it throws
//   surfaces at the first READ, not at the declaration. Trigger: a `late value =
//   risky()` where `risky()` throws. Result: the throw appears wherever `value` is
//   first read, which can be far from the declaration and confusing to trace.
// - Re-reading after a failed lazy initialisation re-runs the initialiser
//   (the variable is not marked initialised if the initialiser threw).
// - `late` on a non-`final` variable still permits reassignment; it does not by
//   itself make the variable single-assignment. Combine with `final` for that
//   (file 09).
// - A `late` local is legal but rarely needed; `late` earns its keep mostly on
//   fields and top-level variables where flow analysis does not apply.
//
// PERFORMANCE
// The lazy form saves the cost of an initialiser that is never needed, at the
// price of a one-time flag check on each read (cheap). The deferred-assignment
// form trades an edit-time proof for a per-read initialisation check; in hot
// paths that is a negligible but non-zero cost compared with an eagerly
// initialised non-nullable field.
//
// LANGUAGE DESIGN DECISION
// `late` exists because sound null safety would otherwise force either a nullable
// type (and null checks everywhere) or an eager initialiser (sometimes impossible,
// for example when the value needs `this`). `late` lets you keep the non-nullable
// type and its ergonomics while moving the "is it set" guarantee from compile time
// to runtime, exactly where flow analysis cannot reach. The lazy-initialisation
// behaviour was folded into the same keyword because both use cases share one
// implementation: a guarded, write-once-then-read slot. The rejected alternative,
// a separate `lazy` keyword, was avoided to keep the surface small.
//
// INTERACTION WITH OTHER CONSTRUCTS
// `late` is the direct answer to the limits of flow analysis (file 05) and the
// non-nullable default rule (file 04). Combined with `final` it forms the standard
// Flutter field pattern (file 09). It is distinct from `const` (file 08), which is
// compile-time and cannot be `late`.
//
// WHAT FAILURE LOOKS LIKE
// - Runtime: reading a `late` variable that was never assigned.
//   "LateInitializationError: Field 'deviceName' has not been initialized."
//   (for a local the message reads "Local 'deviceName' has not been initialized.")
// - Runtime: an exception thrown by a lazy initialiser, surfacing at first read.
// - Logical: assuming the lazy initialiser ran at declaration time, when it ran
//   only on first read, so a side effect happened later than expected.
// =============================================================================

// A top-level variable: flow analysis does not apply, so `late` is the tool that
// lets it stay non-nullable while being assigned in main().
late String activeFirmwareVersion;

// Lazy top-level initialiser: readCalibration() runs only on first read.
int _calibrationReadCount = 0;
int readCalibration() {
  _calibrationReadCount++;
  return 512; // Pretend this is a slow EEPROM read.
}

late int calibrationOffset = readCalibration();

void main() {
  // --- Deferred assignment of a non-nullable top-level variable. ---
  activeFirmwareVersion = '2.4.1';
  print(activeFirmwareVersion); // 2.4.1

  // --- Lazy initialisation: the initialiser has not run yet. ---
  print(_calibrationReadCount); // 0  (readCalibration not called)
  print(calibrationOffset); // 512  (first read triggers readCalibration)
  print(_calibrationReadCount); // 1  (it ran exactly once)
  print(calibrationOffset); // 512  (cached; readCalibration NOT called again)
  print(_calibrationReadCount); // 1  (still 1)

  // --- A late LOCAL, deferred assignment, then used. ---
  late String connectionState;
  connectionState = 'connected';
  print(connectionState); // connected

  // --- late without final still allows reassignment. ---
  late int batteryPercent;
  batteryPercent = 80;
  batteryPercent = 60; // Permitted: late did not make it single-assignment.
  print(batteryPercent); // 60

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — RUNTIME ERROR (read before assignment)
  // ---------------------------------------------------------------------------
  // late String gatewayAddress;
  // print(gatewayAddress); // Compiles; no value has been assigned.
  // Runtime error:
  // "LateInitializationError: Local 'gatewayAddress' has not been initialized."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE WARNING (late on a nullable variable is pointless)
  // ---------------------------------------------------------------------------
  // late int? optionalReading; // Already defaults to null; late adds nothing.
  // Analyser hint (lint):
  // "Unnecessary 'late' modifier." (the variable is nullable and so has a default)

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — LOGICAL ERROR (lazy initialiser side effect runs late)
  // ---------------------------------------------------------------------------
  // late int firstThreshold = readCalibration(); // Side effect deferred.
  // print('about to read');                       // Prints first.
  // print(firstThreshold);                         // NOW readCalibration runs.
  // If you expected the read to happen at declaration, the ordering surprises you.
  // No error is raised; the side effect simply occurs at first use.
}
