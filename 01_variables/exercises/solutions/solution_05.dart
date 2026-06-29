// =============================================================================
// EXERCISE 05 — DEFAULT VALUES AND DEFINITE-ASSIGNMENT FLOW ANALYSIS
// Run: dart run solutions/solution_05.dart
// =============================================================================

int countActiveSessions() => 7;

void main() {
  // ---------------------------------------------------------------------------
  // 5.1 ISOLATED CONCEPT CHECK
  {
    int sessionToken;
    if (countActiveSessions() > 0) {
      sessionToken = 100;
    } else {
      sessionToken = 0;
    }
    print(sessionToken); // 100
  }

  // ---------------------------------------------------------------------------
  // 5.2 APPLIED USAGE
  {
    int retryCeiling;
    var configuredCeiling = 5;
    if (configuredCeiling >= 0) {
      retryCeiling = configuredCeiling;
    } else {
      throw StateError('retry ceiling cannot be negative');
    }
    print(retryCeiling); // 5
    // Compiles because the else path throws and so never reaches the read; the
    // only path that reaches print() assigned retryCeiling.
  }

  // ---------------------------------------------------------------------------
  // 5.3 COMBINED WITH 04 (nullable promotion)
  {
    String? authHeader = 'Bearer xyz';
    if (authHeader != null) {
      print(authHeader.startsWith('Bearer')); // true
    }
  }
}
