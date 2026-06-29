// =============================================================================
// 05 — DEFAULT VALUES AND DEFINITE-ASSIGNMENT FLOW ANALYSIS
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// Two rules govern whether a variable is usable. First, a nullable variable with
// no initialiser gets a default value of null, so it is always usable (it just
// might be null). Second, a non-nullable local with no initialiser has NO default;
// it is usable only once the compiler can prove a value has reached it on every
// path that leads to the use. That proof is definite-assignment flow analysis.
// The problem solved is reading uninitialised memory: in many languages an
// unassigned local holds garbage; in Dart the analyser refuses to let you read
// one until it is certainly set. In an authentication flow, `sessionToken` can be
// declared up top and assigned in either branch of an `if`, and the analyser
// confirms every branch assigns it before it is read.
//
// SYNTAX — THE RELEVANT FORMS
//   int? retries;            // Nullable, defaults to null. Immediately usable.
//   int retries;             // Non-nullable, no default. Usable after assignment.
//   int retries = 0;         // Initialised at declaration. Always usable.
//   late int retries;        // Defers the requirement to runtime (file 06).
//
// WHAT THE COMPILER DOES
// The analyser models control flow as paths and tracks each local's assignment
// state along them. At a use site it asks: is this variable definitely assigned
// on every path that can reach here? If yes, the read is allowed and the
// variable may even be promoted to non-nullable. If any path can reach the use
// without an assignment, it is a compile error. The analysis also understands
// that some statements never fall through (`return`, `throw`, a loop that cannot
// exit), and uses that to discharge branches.
//
// WHAT THE RUNTIME DOES
// For nullable locals, the runtime initialises the slot to null. For non-nullable
// locals proven assigned, the runtime simply stores the value the proven
// assignment computed; no extra default-writing or null sentinel is involved.
// Top-level and static variables are different: their initialisers run lazily,
// the first time the variable is read, not at program start (see file 10).
//
// EDGE CASES THE DOCS STATE
// - Uninitialised nullable variables (including numeric ones) start as null,
//   because numbers are objects like everything else.
// - A local need not be initialised at its declaration, only assigned before use.
// - Top-level and class variables are lazily initialised on first use.
//
// EDGE CASES THE DOCS DO NOT DRAW OUT
// - Assignment in only SOME branches is not enough. Trigger: assigning inside an
//   `if` with no `else`, then reading after. Result: "must be assigned" error,
//   because the else-path reaches the read unassigned.
// - A `throw` or `return` in the missing branch DOES discharge it, because that
//   path cannot reach the read. Trigger: `else { throw ... }`. Result: the read
//   compiles.
// - Assignment inside a loop body is not assumed to run, since the loop may
//   execute zero times. Trigger: assigning only inside `for`/`while`. Result:
//   the variable is not considered definitely assigned afterwards.
// - Fields and top-level variables are NOT subject to local definite-assignment
//   analysis; that is precisely why `late` exists for them (file 06).
//
// PERFORMANCE
// Definite-assignment analysis is entirely compile time. By proving assignment,
// it allows the same omission of null checks discussed in file 04. Lazy
// initialisation of top-level and static variables means their (possibly
// expensive) initialisers are skipped entirely if the variable is never read.
//
// LANGUAGE DESIGN DECISION
// Dart chose flow-based definite assignment over the cruder rule "every local
// must be initialised at its declaration" because real code computes values
// conditionally. Forcing a placeholder initialiser would invite a meaningless
// default that hides genuine "forgot to set it" bugs. The analyser instead proves
// the property the programmer actually cares about: a real value arrives before
// the first read. It deliberately does NOT extend this proof to fields, because
// fields can be assigned from many methods and constructors across a class, which
// would make whole-class flow analysis fragile; `late` is the explicit opt-in for
// those cases.
//
// INTERACTION WITH OTHER CONSTRUCTS
// This is the bridge between null safety (file 04) and `late` (file 06): `late`
// exists for exactly the cases this analysis cannot discharge. Promotion of a
// nullable local to non-nullable after an assignment or null check is the same
// flow machinery. Scope (file 03) bounds the paths the analysis considers.
//
// WHAT FAILURE LOOKS LIKE
// - Compile: reading a non-nullable local not assigned on all paths.
//   "The non-nullable local variable 'sessionToken' must be assigned before it
//    can be used."
// - Logical: relying on a loop body to assign a variable that may run zero times,
//   which surfaces as the same "must be assigned" error.
// =============================================================================

int countActiveSessions() => 7; // Stand-in for a real lookup.

void main() {
  // --- Nullable locals default to null and are immediately usable. ---
  int? cachedSessionCount; // No initialiser, yet already initialised to null.
  print(cachedSessionCount == null); // true

  double? lastLatencyMs; // Numeric type is no exception: still null.
  print(lastLatencyMs); // null

  // --- Non-nullable local: declared without an initialiser, assigned on EVERY
  //     path before the read. The analyser proves this and allows the read. ---
  int sessionToken;
  if (countActiveSessions() > 0) {
    sessionToken = 100;
  } else {
    sessionToken = 0;
  }
  print(sessionToken); // 100

  // --- A throwing branch discharges the requirement on that path. ---
  int retryCeiling;
  var configuredCeiling = 5;
  if (configuredCeiling >= 0) {
    retryCeiling = configuredCeiling;
  } else {
    throw StateError('retry ceiling cannot be negative');
  }
  print(retryCeiling); // 5

  // --- Promotion: a null check narrows a nullable local to non-nullable. ---
  String? authHeader = 'Bearer xyz';
  if (authHeader != null) {
    // Inside this block authHeader is promoted to String.
    print(authHeader.startsWith('Bearer')); // true
  }

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (assigned in only one branch)
  // ---------------------------------------------------------------------------
  // int deviceCount;
  // if (countActiveSessions() > 0) {
  //   deviceCount = 3;
  // } // No else: the else-path reaches the read unassigned.
  // print(deviceCount);
  // Compile-time error:
  // "The non-nullable local variable 'deviceCount' must be assigned before it
  //  can be used."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (loop body assignment is not guaranteed)
  // ---------------------------------------------------------------------------
  // int firstReading;
  // for (var i = 0; i < countActiveSessions(); i++) {
  //   firstReading = i; // The loop might run zero times.
  // }
  // print(firstReading);
  // Compile-time error:
  // "The non-nullable local variable 'firstReading' must be assigned before it
  //  can be used."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — LOGICAL ERROR (a nullable default silently propagates)
  // ---------------------------------------------------------------------------
  // int? totalBytes; // null by default, no warning.
  // var headerSize = 20;
  // // Forgot to assign totalBytes from the parsed frame...
  // print((totalBytes ?? 0) + headerSize); // 20, silently using the fallback.
  // No error: the nullable default masked the missing assignment.
}
