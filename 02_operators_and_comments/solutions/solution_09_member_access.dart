// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 09 – MEMBER ACCESS AND NULL-AWARE OPERATORS
// ═══════════════════════════════════════════════════════════════════════════

class Device {
  final String id;
  String? firmwareVersion;
  Device(this.id, {this.firmwareVersion});
}

void main() {
  // Problem 1 – ?. shorts the whole chain.
  Device? device;
  final String? uppercasedId = device?.id.toUpperCase();
  print(uppercasedId); // null

  // Problem 2 – ! asserts non-null after the guarantee.
  device = Device('esp32-001', firmwareVersion: '1.4.2');
  final int majorVersion = int.parse(device.firmwareVersion!.split('.').first);
  print(majorVersion); // 1

  // Problem 3 – Map [] returns null for missing keys; ?[] guards the receiver.
  final telemetry = {'temp': 23, 'humidity': 41};
  final List<int>? recentTemps = null;
  final int? humidity = telemetry['humidity'];
  final int? pressure = telemetry['pressure'];
  final int? latestTemp = recentTemps?[0];
  print(humidity); // 41
  print(pressure); // null
  print(latestTemp); // null
}
