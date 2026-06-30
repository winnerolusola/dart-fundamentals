// =============================================================================
// EXERCISE 02 — TYPE ANNOTATIONS, INFERENCE, AND Object / Object? / dynamic
// Run: dart run solutions/solution_02.dart
// =============================================================================

void main() {
  {
  // ---------------------------------------------------------------------------
  // 2.1 ISOLATED CONCEPT CHECK
  double temperatureCelsius = 21.0;
  var humidityPercent = 58.2;
  print(temperatureCelsius.runtimeType); // double
  print(humidityPercent.runtimeType);    // double

  }

  {
  // ---------------------------------------------------------------------------
  // 2.2 APPLIED USAGE
  Object sensorPayload = 42;
  if (sensorPayload is int) {
    print(sensorPayload * 2); // 84
  }

  }

  // ---------------------------------------------------------------------------
  // 2.3 COMBINED WITH 01 (declaration/reference)
  List<int> sampleWindow = [12, 15, 14];
  var liveWindow = sampleWindow;          // alias (file 01)
  liveWindow.add(20);                      // mutates shared list
  print(sampleWindow.reduce((running, next) => running + next)); // 61

}
