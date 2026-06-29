// =============================================================================
// 09 — late final (THE COMBINATION)
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// `late final` combines deferred initialisation (from `late`, file 06) with
// single assignment (from `final`, file 07). It means: this non-nullable value
// will be assigned exactly once, at some point after its declaration, and never
// again. It is the standard pattern for an instance field that cannot be set in
// the initialiser list because it needs `this`, the constructor body, or an async
// setup step, yet should still be immutable once set. In a sensor dashboard,
// `late final SensorBus bus;` is assigned once during `connect()` and then read
// safely everywhere else, with the analyser and runtime both enforcing that it is
// written only once and read only after it is written.
//
// SYNTAX — EVERY VALID FORM
//   late final String deviceName;                 // Deferred, single assignment.
//   late final calibration = readCalibration();    // Lazy AND single assignment.
//   late final String region;                       // As a class field (below).
//
// WHAT THE COMPILER DOES
// `late` removes the definite-assignment requirement, and `final` caps the number
// of assignments at one. Together the analyser allows the declaration with no
// initialiser, permits exactly one later assignment, and rejects a second. With
// an initialiser, the value is computed lazily on first read and is then frozen.
// Importantly, a `late final` field WITHOUT an initialiser implicitly defines a
// SETTER, unlike an ordinary `final` field. If that field is public, the setter
// is public, which is usually not intended.
//
// WHAT THE RUNTIME DOES
// The variable carries the "initialised yet?" flag from `late`. The first
// assignment sets the value and marks it initialised; any second assignment
// throws a LateInitializationError ("already initialized"). Reading before the
// first assignment throws a LateInitializationError ("not been initialized"). For
// the lazy-initialiser form, the initialiser runs once on first read.
//
// EDGE CASES THE DOCS STATE (Effective Dart: Design)
// - A `late final` field is the recommended shape for a field that does not change
//   after construction but cannot be initialised until after the instance exists.
// - AVOID public `late final` fields without initialisers, because they expose a
//   public setter. Prefer: don't use `late`; use a factory constructor; initialise
//   at the declaration; or make the field private with a public getter.
//
// EDGE CASES THE DOCS DO NOT DRAW OUT
// - The "already initialized" runtime error is distinct from the "not been
//   initialized" one. Trigger: assigning a `late final` twice. Result:
//   "LateInitializationError: Field 'x' has already been initialized."
// - A `late final` WITH an initialiser does NOT define a public setter, because
//   the value source is fixed; only the initialiser-less form does.
// - `late final` is not `const`: the value is computed at runtime, so it cannot be
//   used where a compile-time constant is required.
//
// PERFORMANCE
// Same profile as `late`: a one-time flag check per read, and (for the lazy form)
// an initialiser that runs at most once and only if read. The single-assignment
// guarantee adds a write-time check that the field is not already set.
//
// LANGUAGE DESIGN DECISION
// The combination is intentional and common enough that Effective Dart calls it
// out by name. It resolves the tension between "I want immutability" (`final`) and
// "I cannot compute the value at construction" (`late`). The implicit public
// setter on an initialiser-less public `late final` is a deliberate consequence
// of `late` needing SOME way to be assigned later; the guidance is to keep such
// fields private, not to change the language rule.
//
// INTERACTION WITH OTHER CONSTRUCTS
// `late final` sits on top of `late` (file 06) and `final` (file 07) and is the
// usual answer to the field cases that flow analysis (file 05) cannot discharge.
// It is the immutable cousin of a plain `late` field. It is incompatible with
// `const` (file 08).
//
// WHAT FAILURE LOOKS LIKE
// - Runtime: reading before assignment.
//   "LateInitializationError: Field 'bus' has not been initialized."
// - Runtime: a second assignment.
//   "LateInitializationError: Field 'bus' has already been initialized."
// - Design: a public initialiser-less `late final` field silently exposing a
//   public setter, allowing outside code to set it. No error; an unintended API.
// =============================================================================

// A class field that needs `this`-dependent setup, set once in connect().
class SensorBus {
  final String busId;
  // Private late final: assigned once internally, exposed via a getter only.
  late final String _firmwareTag;

  SensorBus(this.busId);

  void connect() {
    // Initialised here, after the instance exists, using its own state.
    _firmwareTag = 'fw-${busId.toUpperCase()}';
  }

  String get firmwareTag => _firmwareTag; // Public read, no public setter.
}

// A lazy late final top-level value: computed once, on first read.
int _calibrationCalls = 0;
late final int calibrationBaseline = _computeBaseline();
int _computeBaseline() {
  _calibrationCalls++;
  return 256;
}

void main() {
  // --- The Flutter-style field pattern: set once in setup, read thereafter. ---
  final bus = SensorBus('north-rack');
  bus.connect(); // Assigns _firmwareTag exactly once.
  print(bus.firmwareTag); // fw-NORTH-RACK
  print(bus.busId); // north-rack

  // --- Deferred, single-assignment local. ---
  late final String reportPath;
  reportPath = '/var/reports/north-rack.json';
  print(reportPath); // /var/reports/north-rack.json

  // --- Lazy late final: initialiser runs once, on first read, then frozen. ---
  print(_calibrationCalls); // 0  (not yet read)
  print(calibrationBaseline); // 256  (first read triggers _computeBaseline)
  print(_calibrationCalls); // 1
  print(calibrationBaseline); // 256  (cached; no recomputation)
  print(_calibrationCalls); // 1

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — RUNTIME ERROR (read before assignment)
  // ---------------------------------------------------------------------------
  // late final String gatewayId;
  // print(gatewayId); // No assignment yet.
  // Runtime error:
  // "LateInitializationError: Local 'gatewayId' has not been initialized."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — RUNTIME ERROR (second assignment)
  // ---------------------------------------------------------------------------
  // late final int sampleRateHz;
  // sampleRateHz = 100;
  // sampleRateHz = 200; // The second write violates single assignment.
  // Runtime error:
  // "LateInitializationError: Local 'sampleRateHz' has already been initialized."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — DESIGN ERROR (public late final without initialiser)
  // ---------------------------------------------------------------------------
  // class Gateway {
  //   late final String token; // PUBLIC and initialiser-less: defines a public
  //                            // setter, so external code can do gateway.token = ...
  // }
  // No compile error, but the field is now writable from outside. Prefer a private
  // field with a public getter, as SensorBus does above.
}
