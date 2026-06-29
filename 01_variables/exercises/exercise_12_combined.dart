// =============================================================================
// EXERCISE 12 — COMBINED (draws on all sub-concepts 01–11)
// Run: dart run exercise_12_combined.dart
// Three problems of increasing complexity. Write your solution in the space below each problem statement.
// =============================================================================

void main() {
  // ===========================================================================
  // 12.1 — DEVICE REGISTRY ENTRY (declaration, inference, null safety, final,
  //        flow analysis)
  // Model one entry in a device registry. Requirements:
  //  - A final, inferred deviceId string.
  //  - A non-nullable int batteryPercent assigned via if/else from a raw reading
  //    (clamp a negative raw value to 0, otherwise use it), declared without an
  //    initialiser.
  //  - A nullable String? lastError left unset.
  //  Print deviceId, batteryPercent, and lastError.
  // MARKER CRITERIA: final inferred id; non-nullable battery satisfied by
  // definite assignment on both branches; nullable error prints as null; no
  // null-aware operators required.
  // Your solution:


  // ===========================================================================
  // 12.2 — CALIBRATION CACHE (late final lazy init, top-level lazy semantics,
  //        const, scope)
  // Below main, declare:
  //  - a top-level counter _calibrationReads (int, 0),
  //  - a function _readCalibration() that increments it and returns 512,
  //  - a `late final int calibrationOffset = _readCalibration();`,
  //  - a `const sampleRateHz = 100;`.
  // In main: print _calibrationReads before any read (0), read calibrationOffset
  // twice (printing _calibrationReads after each to show it runs once), and print
  // sampleRateHz. Use a wildcard `_` to consume one throwaway computation.
  // MARKER CRITERIA: lazy late final runs exactly once (counter 0 -> 1 -> 1);
  // const printed; at least one `_` used as a non-binding placeholder; the
  // top-level declarations are in library scope while the reads happen in main.
  // Your solution:


  // 12.3 — IMMUTABLE THRESHOLD SET WITH CANONICALISATION (const constructor,
  //        deep immutability, reference vs const identity, Object?/promotion)
  // Define (below) a const-constructible class AlertThreshold(min, max) with final
  // int fields. In main:
  //  - Build two const AlertThreshold(10, 90) and show they are identical (canon).
  //  - Build one non-const AlertThreshold(10, 90) and show it is NOT identical.
  //  - Accept an Object? incoming reading, and only when it `is int` and lies
  //    outside [min, max], print 'ALERT', otherwise 'ok'. Test with 95 and 50.
  // MARKER CRITERIA: const constructor; canonicalisation true for the const pair,
  // false against the non-const instance; Object? narrowed with `is int` before
  // comparison (file 04/02); correct ALERT/ok decisions.
  // Your solution:


}
