// =============================================================================
// EXERCISE 06 — LATE VARIABLES
// Run: dart run exercise_06.dart
// =============================================================================

int _readCount = 0;
int _readThermometer() {
  _readCount++;
  return 21;
}

// 6.2 uses this lazily initialised top-level variable.
late int currentTemperature = _readThermometer();

void main() {
  // ---------------------------------------------------------------------------
  // 6.1 ISOLATED CONCEPT CHECK
  // Declare a non-nullable late String connectionState (no initialiser), assign
  // it 'connected' inside main, then print it.
  // MARKER CRITERIA: `late` non-nullable local with no initialiser; assigned
  // before the read; prints connected. (Reading before assignment would throw a
  // LateInitializationError.)
  // Your solution:


  // ---------------------------------------------------------------------------
  // 6.2 APPLIED USAGE
  // Using the top-level `late int currentTemperature = _readThermometer();`,
  // prove lazy initialisation: print _readCount before any read (expect 0), then
  // read currentTemperature twice, printing _readCount after each read to show
  // the initialiser ran exactly once.
  // MARKER CRITERIA: _readCount is 0 before the first read; reading once runs the
  // initialiser (_readCount becomes 1); the second read does NOT re-run it.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 6.3 COMBINED WITH 05 (why late exists)
  // Write a `late int firstSample;` and assign it inside a for-loop that runs at
  // least once, then print it. In a comment, explain why a PLAIN (non-late) int
  // here would NOT compile, referencing definite-assignment analysis.
  // MARKER CRITERIA: `late` suppresses the definite-assignment requirement;
  // prints the assigned value; comment correctly notes that a loop body is not
  // guaranteed to run, so a non-late int would be "must be assigned before used".
  // Your solution:


}
