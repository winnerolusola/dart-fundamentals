// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 09 – MEMBER ACCESS AND NULL-AWARE OPERATORS
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_09_member_access.dart.
// ═══════════════════════════════════════════════════════════════════════════

class Device {
  final String id;
  String? firmwareVersion; // may be unknown until the device reports in
  Device(this.id, {this.firmwareVersion});
}

void main() {
  // ── Problem 1 (isolated): ?. and null shorting ────────────────────────────
  Device? device; // not yet connected (null)

  // TODO 1: uppercasedId is the device id uppercased, or null if device is
  //         null. Use ?. and let the short cover the whole chain.
  final String? uppercasedId = null; // replace

  print(uppercasedId); // expected: null

  // ── Problem 2 (applied): ! assertion after a guarantee ────────────────────
  // After this point the device is guaranteed connected.
  device = Device('esp32-001', firmwareVersion: '1.4.2');

  // TODO 2: read firmwareVersion as a non-nullable String using !, then split
  //         on '.' and take the major version as an int.
  final int majorVersion = 0; // replace

  print(majorVersion); // expected: 1

  // ── Problem 3 (cross-concept): List [] vs Map [] and ?[] ──────────────────
  final telemetry = {'temp': 23, 'humidity': 41};
  final List<int>? recentTemps = null;

  // TODO 3a: read 'humidity' from the map (note: missing keys return null).
  final int? humidity = null; // replace
  // TODO 3b: read 'pressure' from the map (absent) – should be null, no throw.
  final int? pressure = null; // replace
  // TODO 3c: read index 0 from recentTemps using ?[] (receiver is null).
  final int? latestTemp = null; // replace

  print(humidity); // expected: 41
  print(pressure); // expected: null
  print(latestTemp); // expected: null
}
