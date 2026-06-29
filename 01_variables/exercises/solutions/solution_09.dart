// =============================================================================
// EXERCISE 09 — late final
// Run: dart run solutions/solution_09.dart
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
  {
  // ---------------------------------------------------------------------------
  // 9.1 ISOLATED CONCEPT CHECK
  late final String reportPath;
  reportPath = '/var/reports/north-rack.json';
  print(reportPath); // /var/reports/north-rack.json
  // A second assignment (reportPath = '...';) would throw at runtime:
  // "LateInitializationError: Local 'reportPath' has already been initialized."

  }

  {
  // ---------------------------------------------------------------------------
  // 9.2 APPLIED USAGE
  final bus = SensorBus('north-rack');
  bus.connect();
  print(bus.firmwareTag); // fw-NORTH-RACK
  print(bus.busId);       // north-rack
  // _firmwareTag is `late final` because its value is derived from busId during
  // a setup step (connect), after the instance exists; it must stay immutable
  // once set, hence final, but cannot be set in the initialiser list, hence late.

  }

  {
  // ---------------------------------------------------------------------------
  // 9.3 COMBINED WITH 06 (lazy initialisation) AND 07 (single assignment)
  // Place _seedCount and _seed at top level for a real program; shown inline:
  // var _seedCount = 0; int _seed() { _seedCount++; return 256; }
  // late final int calibrationBaseline = _seed();
  // print(_seedCount);          // 0
  // print(calibrationBaseline); // 256
  // print(_seedCount);          // 1
  // print(calibrationBaseline); // 256
  // print(_seedCount);          // 1

  }

}
