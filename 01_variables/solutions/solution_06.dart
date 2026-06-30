// =============================================================================
// EXERCISE 06 — LATE VARIABLES
// Run: dart run solutions/solution_06.dart
// =============================================================================

int _readCount = 0;
int _readThermometer() {
  _readCount++;
  return 21;
}

late int currentTemperature = _readThermometer();

void main() {
  // ---------------------------------------------------------------------------
  // 6.1 ISOLATED CONCEPT CHECK
  {
    late String connectionState;
    connectionState = 'connected';
    print(connectionState); // connected
  }

  // ---------------------------------------------------------------------------
  // 6.2 APPLIED USAGE
  {
    print(_readCount);          // 0
    print(currentTemperature);  // 21
    print(_readCount);          // 1
    print(currentTemperature);  // 21
    print(_readCount);          // 1
  }

  // ---------------------------------------------------------------------------
  // 6.3 COMBINED WITH 05 (why late exists)
  {
    late int firstSample;
    for (var i = 0; i < 3; i++) {
      firstSample = i;
    }
    print(firstSample); // 2
    // A non-late `int firstSample;` would fail to compile because flow analysis
    // (file 05) cannot prove a loop body runs; `late` moves that guarantee to
    // runtime.
  }
}
