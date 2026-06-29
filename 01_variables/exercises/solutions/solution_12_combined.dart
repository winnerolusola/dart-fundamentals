// =============================================================================
// SOLUTION 12 — COMBINED (draws on all sub-concepts 01–11)
// Run: dart run solutions/solution_12_combined.dart
// Top-level declarations required by 12.2 are outside main().
// =============================================================================

// 12.2: top-level lazy declarations
int _calibrationReads = 0;
int _readCalibration() {
  _calibrationReads++;
  return 512;
}

late final int calibrationOffset = _readCalibration();
const sampleRateHz = 100;

// 12.3: const-constructible class
class AlertThreshold {
  final int min;
  final int max;
  const AlertThreshold(this.min, this.max);
}

void main() {
  // ---------------------------------------------------------------------------
  // 12.1 — DEVICE REGISTRY ENTRY
  {
    final deviceId = 'dev-north-01';
    var rawBattery = 73;
    int batteryPercent;
    if (rawBattery < 0) {
      batteryPercent = 0;
    } else {
      batteryPercent = rawBattery;
    }
    String? lastError;
    print(deviceId);       // dev-north-01
    print(batteryPercent); // 73
    print(lastError);      // null
  }

  // ---------------------------------------------------------------------------
  // 12.2 — CALIBRATION CACHE
  {
    print(_calibrationReads); // 0
    var _ = sampleRateHz * 2; // throwaway wildcard
    print(calibrationOffset); // 512
    print(_calibrationReads); // 1
    print(calibrationOffset); // 512
    print(_calibrationReads); // 1
    print(sampleRateHz);      // 100
  }

  // ---------------------------------------------------------------------------
  // 12.3 — IMMUTABLE THRESHOLD SET WITH CANONICALISATION
  {
    const lowerBand = AlertThreshold(10, 90);
    const upperBand = AlertThreshold(10, 90);
    var liveBand = AlertThreshold(10, 90);
    print(identical(lowerBand, upperBand)); // true
    print(identical(lowerBand, liveBand));  // false

    for (final Object? reading in [95, 50]) {
      if (reading is int &&
          (reading < lowerBand.min || reading > lowerBand.max)) {
        print('ALERT'); // for 95
      } else {
        print('ok');    // for 50
      }
    }
  }
}
