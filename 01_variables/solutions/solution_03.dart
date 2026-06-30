// =============================================================================
// EXERCISE 03 — SCOPE AND SHADOWING
// Run: dart run solutions/solution_03.dart
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // 3.1 ISOLATED CONCEPT CHECK
  {
    var activeUserId = 'user-100';
    if (activeUserId.isNotEmpty) {
      var activeUserId = 'user-200'; // shadows the outer one
      print(activeUserId);           // user-200
    }
    print(activeUserId);             // user-100
  }

  // ---------------------------------------------------------------------------
  // 3.2 APPLIED USAGE
  {
    var handlers = <String Function()>[];
    for (final endpoint in ['/login', '/logout']) {
      handlers.add(() => endpoint);
    }
    print(handlers[0]()); // /login
    print(handlers[1]()); // /logout
  }

  // ---------------------------------------------------------------------------
  // 3.3 COMBINED WITH 01 (reference semantics)
  {
    var sharedHandlers = <int Function()>[];
    for (var attempt = 0; attempt < 3; attempt++) {
      sharedHandlers.add(() => attempt); // all capture the SAME variable
    }
    print(sharedHandlers[0]()); // 3
    print(sharedHandlers[1]()); // 3
    print(sharedHandlers[2]()); // 3
    // Cause: one `attempt` exists for the whole loop; closures hold a reference
    // to that single variable (file 01), so all read its final value, 3.
  }
}
