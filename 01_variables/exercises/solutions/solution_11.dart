// =============================================================================
// EXERCISE 11 — WILDCARD VARIABLES (_)   [requires language version 3.7+]
// Run: dart run solutions/solution_11.dart
// =============================================================================

List<int> frameSizes() => [120, 256, 256, 64];

void main() {
  // ---------------------------------------------------------------------------
  // 11.1 ISOLATED CONCEPT CHECK
  {
    var frameCount = 0;
    for (var _ in frameSizes()) {
      frameCount++;
    }
    print(frameCount); // 4
  }

  // ---------------------------------------------------------------------------
  // 11.2 APPLIED USAGE
  {
    try {
      throw const FormatException('bad frame');
    } catch (_) {
      print('frame rejected'); // frame rejected
    }
    int _ = 1;
    int _ = 2; // no collision: `_` binds nothing
    print('two wildcard locals, no collision');
  }

  // ---------------------------------------------------------------------------
  // 11.3 COMBINED WITH 03 (scope/no-collision rule)
  {
    final kept = frameSizes().where((_) => true).toList();
    print(kept.length); // 4
    // Normally two declarations of one name in a scope are "already defined"
    // (file 03). `_` is exempt because it binds nothing, so several `_`
    // coexist without collision.
  }
}
