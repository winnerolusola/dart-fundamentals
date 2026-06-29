// =============================================================================
// EXERCISE 10 — TOP-LEVEL AND STATIC VARIABLE LAZY INITIALISATION
// Run: dart run solutions/solution_10.dart
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
  {
  // ---------------------------------------------------------------------------
  // 10.1 ISOLATED CONCEPT CHECK
  print(_poolOpenCount);          // 0
  print(connectionPool.length);   // 2
  print(_poolOpenCount);          // 1

  }

  {
  // ---------------------------------------------------------------------------
  // 10.2 APPLIED USAGE
  print(connectionPool.first); // conn-1
  print(_poolOpenCount);       // 1
  print(connectionPool.first); // conn-1
  print(_poolOpenCount);       // 1

  }

  {
  // ---------------------------------------------------------------------------
  // 10.3 COMBINED WITH 08 (const vs lazy)
  const buildId = 'build-2024-06';
  print(MetricsRegistry.counters['requests']); // 0
  print(buildId);                               // build-2024-06
  // counters initialises lazily on this first read (runtime); buildId is a
  // compile-time constant (file 08) and has no runtime initialiser at all.

  }

}
