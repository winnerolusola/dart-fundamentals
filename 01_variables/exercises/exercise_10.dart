// =============================================================================
// EXERCISE 10 — TOP-LEVEL AND STATIC VARIABLE LAZY INITIALISATION
// Run: dart run exercise_10.dart
// =============================================================================

// 10.1 / 10.2 use these top-level declarations.
int _poolOpenCount = 0;
List<String> connectionPool = _openPool();
List<String> _openPool() {
  _poolOpenCount++;
  return ['conn-1', 'conn-2'];
}

class MetricsRegistry {
  static final Map<String, int> counters = _seed();
  static Map<String, int> _seed() => {'requests': 0};
}

void main() {
  // ---------------------------------------------------------------------------
  // 10.1 ISOLATED CONCEPT CHECK
  // Without reading connectionPool first, print _poolOpenCount (expect 0). Then
  // read connectionPool.length and print _poolOpenCount again (expect 1). This
  // proves the top-level initialiser runs on first read, not at startup.
  // MARKER CRITERIA: _poolOpenCount is 0 before any read of connectionPool; it
  // becomes 1 only after the first read.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 10.2 APPLIED USAGE
  // Read connectionPool.first, then read it again, printing _poolOpenCount after
  // each. Show the initialiser does not re-run.
  // MARKER CRITERIA: after the first read _poolOpenCount is 1; after the second
  // read it is still 1 (cached, not re-initialised).
  // Your solution:


  // ---------------------------------------------------------------------------
  // 10.3 COMBINED WITH 08 (const vs lazy)
  // Print MetricsRegistry.counters['requests'] (a lazy static, initialised on
  // first read) and a const buildId you declare locally. In a comment, contrast
  // when each becomes available: the static on first read, the const at compile
  // time.
  // MARKER CRITERIA: static field read works and prints 0; const declared and
  // printed; comment correctly contrasts runtime-first-read vs compile-time.
  // Your solution:


}
