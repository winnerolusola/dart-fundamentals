// =============================================================================
// EXERCISE 09 — late final
// Run: dart run exercise_09.dart
// =============================================================================

// 9.2 uses this class.
class SensorBus {
  final String busId;
  late final String _firmwareTag; // private, set once in connect()
  SensorBus(this.busId);
  void connect() {
    _firmwareTag = 'fw-${busId.toUpperCase()}';
  }
  String get firmwareTag => _firmwareTag;
}

void main() {
  // ---------------------------------------------------------------------------
  // 9.1 ISOLATED CONCEPT CHECK
  // Declare a `late final String reportPath` local, assign it once, and print it.
  // State in a comment what happens on a second assignment.
  // MARKER CRITERIA: late final local; single assignment; printed; comment
  // correctly states a second assignment throws
  // "LateInitializationError: ... has already been initialized."
  // Your solution:


  // ---------------------------------------------------------------------------
  // 9.2 APPLIED USAGE
  // Use the SensorBus class above. Construct it with 'north-rack', call connect(),
  // then print firmwareTag and busId. Explain in a comment why _firmwareTag is a
  // late final field rather than a constructor-initialised final.
  // MARKER CRITERIA: connect() called before reading firmwareTag; outputs
  // fw-NORTH-RACK and north-rack; comment notes the field depends on `this`/derived
  // state set after construction, which a plain final initialiser list cannot do.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 9.3 COMBINED WITH 06 (lazy initialisation) AND 07 (single assignment)
  // Declare a `late final int calibrationBaseline = _seed();` where _seed()
  // increments a counter and returns 256. Prove it runs at most once by reading
  // it twice and printing the counter before and after.
  // MARKER CRITERIA: lazy late final with an initialiser; counter is 0 before any
  // read, 1 after the first read, and still 1 after the second read.
  // Your solution:


}
