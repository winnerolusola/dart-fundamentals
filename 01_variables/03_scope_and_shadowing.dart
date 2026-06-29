// =============================================================================
// 03 — SCOPE AND SHADOWING
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// Scope is the region of code in which a name is visible and resolvable. It
// answers a question every later file silently assumes you can answer: when I
// write `userId`, which declaration does that refer to? Dart uses lexical
// (static) scope, meaning the answer is determined by where the name appears in
// the source text, not by the runtime call path. The problem scope solves is
// name collision and lifetime control: a loop counter in one function must not
// leak into another, and a helper's locals must not pollute the caller.
//
// Shadowing is the consequence when an inner scope declares a name that already
// exists in an outer scope. The inner declaration hides the outer one for the
// duration of the inner scope. This is legal and sometimes useful, but it is a
// frequent source of "why didn't my change take effect" bugs.
//
// SYNTAX — THE SCOPE-CREATING CONSTRUCTS
//   { ... }                       // Any block introduces a new scope.
//   if (c) { ... } else { ... }   // Each branch body is its own scope.
//   for (var i ...) { ... }       // Loop header and body share a scope.
//   while (c) { ... }             // Body is a scope.
//   void f() { ... }              // Function body is a scope; params included.
//   (x) => x + 1                  // Closures capture enclosing scope by reference.
// Top-level declarations live in library scope; class members live in class
// scope; everything inside a function lives in nested block scopes.
//
// WHAT THE COMPILER DOES
// Name resolution walks outward from the innermost enclosing scope to the
// library scope, stopping at the first match. Two declarations of the same name
// in the SAME scope are a compile error. A declaration in an inner scope with
// the same name as an outer one is allowed and shadows it. The analyser also
// reports a variable used before its declaration within the same scope, because
// Dart scopes a local to the whole block but does not allow use before the
// declaration point.
//
// WHAT THE RUNTIME DOES
// A local variable's storage exists while its scope is active on the call stack.
// When a closure captures a variable, the runtime keeps that variable alive for
// as long as the closure is reachable, even after the enclosing function
// returns. Capture is by reference to the variable, not by snapshot of its value
// at capture time, which is why a closure sees later mutations.
//
// EDGE CASES THE DOCS DO NOT COVER (scope is not on the variables page)
// - Loop-variable capture: a `for (var i = 0; ...)` declares ONE `i` shared by
//   every iteration, so closures created in the loop all capture the same `i`
//   and observe its final value. A `for (final item in list)` declares a FRESH
//   binding per iteration, so closures capture distinct values. Trigger: storing
//   closures from inside a C-style for loop. Result: every stored closure prints
//   the loop's terminal value.
// - Shadowing in a smaller block: assigning to a shadowing inner variable does
//   not change the outer one. Trigger: redeclaring a name with `var` inside an
//   `if`. Result: the outer value is unchanged after the block ends.
// - Use-before-declaration in the same block is an error even though the name is
//   in scope for the whole block.
//
// PERFORMANCE
// Scope itself is a compile-time concept with no direct runtime cost. Closures
// that capture variables allocate a context object to hold the captured slots;
// capturing many variables, or capturing inside hot loops, has a small allocation
// cost worth knowing about in tight code.
//
// LANGUAGE DESIGN DECISION
// Lexical scope was chosen because it makes a name's meaning decidable by reading
// the surrounding source, independent of how the code is reached at runtime. The
// per-iteration fresh binding for `for-in` (and the shared binding for C-style
// `for`) follows the same rule each language in this family settled on after the
// classic "closures in a loop" bug; Dart's `for-in` gives the safer default while
// the C-style form preserves the single mutable counter its syntax implies.
//
// INTERACTION WITH OTHER CONSTRUCTS
// Wildcard variables (file 11) exploit scope: multiple `_` in one scope do not
// collide because `_` is non-binding. `final` (file 07) interacts with shadowing,
// since a `final` outer variable can still be shadowed by an inner declaration.
// Flow analysis (file 05) reasons within scopes about definite assignment.
//
// WHAT FAILURE LOOKS LIKE
// - Compile: two declarations of one name in a scope.
//   "The name 'userId' is already defined."
// - Compile: use before declaration in the same scope.
//   "Local variable 'userId' can't be referenced before it is declared."
// - Logical: shadowing, where an inner assignment leaves the outer value intact
//   and the programmer expected the outer value to change. No error is produced.
// =============================================================================

String currentRegion = 'eu-west-1'; // Library (top-level) scope.

void main() {
  // --- Block scope: a name declared inside { } is invisible outside it. ---
  var requestCount = 0;
  {
    var temporaryBuffer = 'staging';
    requestCount = 1; // Outer requestCount is in scope here and is updated.
    print(temporaryBuffer); // staging
  }
  // print(temporaryBuffer); // Would not compile: out of scope here.
  print(requestCount); // 1

  // --- Resolution walks outward: the top-level currentRegion is visible. ---
  print(currentRegion); // eu-west-1

  // --- Shadowing: an inner name hides the outer one inside its block only. ---
  var activeUserId = 'user-100';
  if (activeUserId.isNotEmpty) {
    var activeUserId = 'user-200'; // A NEW, separate variable, shadows outer.
    print(activeUserId); // user-200
  }
  print(activeUserId); // user-100  (outer value untouched)

  // --- for-in gives a fresh binding per iteration: closures capture distinct
  //     values. ---
  var freshHandlers = <String Function()>[];
  for (final endpoint in ['/login', '/logout']) {
    freshHandlers.add(() => endpoint); // Each closure captures its own endpoint.
  }
  print(freshHandlers[0]()); // /login
  print(freshHandlers[1]()); // /logout

  // --- C-style for shares ONE counter: every closure sees its final value. ---
  var sharedHandlers = <int Function()>[];
  for (var attempt = 0; attempt < 3; attempt++) {
    sharedHandlers.add(() => attempt); // All capture the same `attempt`.
  }
  print(sharedHandlers[0]()); // 3
  print(sharedHandlers[1]()); // 3
  print(sharedHandlers[2]()); // 3  (loop ended with attempt == 3)

  // --- Closures capture by reference, so later mutation is visible. ---
  var retryBudget = 5;
  int readBudget() => retryBudget; // Captures the variable, not the value 5.
  retryBudget = 2;
  print(readBudget()); // 2

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (duplicate name in one scope)
  // ---------------------------------------------------------------------------
  // var apiVersion = 'v1';
  // var apiVersion = 'v2';
  // Compile-time error:
  // "The name 'apiVersion' is already defined."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — COMPILE ERROR (use before declaration in same scope)
  // ---------------------------------------------------------------------------
  // print(maxConnections);
  // var maxConnections = 32;
  // Compile-time error:
  // "Local variable 'maxConnections' can't be referenced before it is declared."

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — LOGICAL ERROR (shadowing defeats an intended update)
  // ---------------------------------------------------------------------------
  // var cacheHits = 0;
  // void recordHit() {
  //   var cacheHits = 1; // Shadows the field-like outer; outer stays 0.
  //   cacheHits += 1;
  // }
  // recordHit();
  // print(cacheHits); // 0  <- the outer counter never moved. No error raised.
}
