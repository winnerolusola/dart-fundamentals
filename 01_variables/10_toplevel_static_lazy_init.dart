// =============================================================================
// 10 — TOP-LEVEL AND STATIC VARIABLE LAZY INITIALISATION
// =============================================================================
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// Every top-level variable and every static class variable in Dart is lazily
// initialised: its initialiser runs the first time the variable is READ, not when
// the program starts and not when the class is loaded. The docs state this in one
// sentence; the consequences are large enough to deserve their own treatment. The
// problem it solves is startup cost and ordering: a program with many expensive
// global configurations does not pay for any of them until they are first used,
// and there is no fragile "global initialisation order" to get wrong, because each
// global initialises itself on demand. In a service, `final database = openPool();`
// at the top level will not open a connection pool unless and until some code
// actually reads `database`.
//
// SYNTAX — THE RELEVANT DECLARATIONS
//   final region = computeRegion();        // Top-level, lazy on first read.
//   const buildId = 'b-2024';              // const: evaluated at COMPILE time.
//   class Cache { static final box = open(); } // Static, lazy on first read.
//   late final pool = openPool();           // Explicit lazy + single assignment.
//
// WHAT THE COMPILER DOES
// The compiler arranges for each top-level and static variable's initialiser to be
// invoked on first access, guarding it so the initialiser runs at most once. This
// applies to `var`, `final`, and `late` top-level/static variables. `const` is the
// exception: a const value is computed at compile time and embedded, so there is no
// runtime initialiser to defer. The analyser does not run local definite-assignment
// analysis on these variables, which is why a non-nullable top-level variable needs
// either an initialiser or `late` (file 06).
//
// WHAT THE RUNTIME DOES
// On the first read, the runtime executes the initialiser, stores the result, marks
// the variable initialised, and returns the value. Later reads return the stored
// value directly. If the initialiser reads the SAME variable before it has finished
// (a cyclic initialisation), the runtime throws, because the value is not yet
// available. Any side effects in the initialiser therefore occur at first-read time,
// not at program start.
//
// EDGE CASES THE DOCS STATE
// - Top-level and class variables are lazily initialised; the initialisation code
//   runs the first time the variable is used.
//
// EDGE CASES THE DOCS DO NOT DRAW OUT
// - Observation order: side effects in a top-level initialiser happen on first
//   read, which may be well after main() begins. Trigger: a print or a counter
//   bump in a top-level initialiser. Result: it fires when the variable is first
//   touched, not at startup.
// - Cyclic initialisation: a top-level variable whose initialiser reads itself
//   (directly or through another global) throws at the first read. Trigger: two
//   top-level finals that reference each other in their initialisers. Result: a
//   reentrancy/Stack or LateInitialization-style error at first access.
// - Static vs instance: `static` variables share the lazy-global behaviour;
//   non-static instance fields do NOT, since they are initialised per instance at
//   construction time.
// - Tree-shaking interaction: a top-level variable that is never read may have its
//   initialiser eliminated entirely by the compiler, so an initialiser relied upon
//   purely for its side effect can vanish if nothing reads the variable.
//
// PERFORMANCE
// Lazy initialisation defers, and sometimes eliminates, the cost of expensive
// globals. A global never read costs nothing at runtime. The trade is a one-time
// guard check on each access and the unpredictability of WHEN the side effect runs,
// which matters if the initialiser does I/O or logging.
//
// LANGUAGE DESIGN DECISION
// Dart made all top-level and static variables lazy to remove the classic global
// initialisation-order problem found in languages with eager static initialisers,
// where the order of file or translation-unit initialisation is hard to predict and
// reorder-sensitive. With lazy semantics, each global is responsible for itself and
// the first reader triggers exactly the initialisation it needs, in dependency order
// by construction. The rejected alternative, eager initialisation at program start,
// was avoided because it pays for everything up front and reintroduces ordering
// hazards.
//
// INTERACTION WITH OTHER CONSTRUCTS
// This is the runtime mechanism behind `final` top-level variables (file 07) and the
// `late` lazy form (file 06). It contrasts with `const` (file 08), whose values are
// compile-time and never have a runtime initialiser. It explains why definite
// assignment (file 05) does not apply to globals and why `late` is their tool.
//
// WHAT FAILURE LOOKS LIKE
// - Runtime: cyclic initialisation of a top-level variable.
//   A reentrant initialisation error is thrown at first read (commonly surfaced as
//   a "Reading static variable during its initialization" style error or a
//   LateInitializationError, depending on the form used).
// - Logical: assuming a top-level initialiser's side effect ran at startup, when it
//   ran on first read, or did not run at all because the variable was never read.
// =============================================================================

// Side-effecting top-level initialiser: the print proves WHEN it runs.
int _poolOpenCount = 0;
final connectionPool = _openPool();
List<String> _openPool() {
  _poolOpenCount++;
  print('opening pool'); // Fires on first read of connectionPool, not at startup.
  return ['conn-1', 'conn-2'];
}

// const is the exception: evaluated at compile time, no runtime initialiser.
const buildIdentifier = 'build-2024-06';

class MetricsRegistry {
  // Static field: lazy like a top-level variable.
  static final Map<String, int> counters = _seedCounters();
  static Map<String, int> _seedCounters() {
    print('seeding counters'); // Fires on first read of counters.
    return {'requests': 0};
  }
}

void main() {
  print('main started'); // main started

  // connectionPool has not been read yet, so _openPool has NOT run.
  print(_poolOpenCount); // 0

  // First read triggers the initialiser (and its print) exactly once.
  print(connectionPool.length); // opening pool   then   2
  print(_poolOpenCount); // 1

  // Subsequent reads use the stored value; no re-initialisation.
  print(connectionPool.first); // conn-1
  print(_poolOpenCount); // 1

  // const needs no runtime initialisation; available immediately.
  print(buildIdentifier); // build-2024-06

  // Static field initialises on first read, with its side effect then.
  print(MetricsRegistry.counters['requests']); // seeding counters   then   0

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — RUNTIME ERROR (cyclic top-level initialisation)
  // ---------------------------------------------------------------------------
  // Place these at top level:
  //   final alpha = beta + 1;
  //   final beta = alpha + 1; // Each initialiser reads the other.
  // Reading either one first triggers a reentrant initialisation that cannot
  // complete. Runtime error at first access, for example:
  // "Reading static variable 'beta' during its initialization" (or an equivalent
  //  reentrant-initialisation error depending on the exact form).

  // ---------------------------------------------------------------------------
  // INCORRECT USAGE — LOGICAL ERROR (side effect assumed to run at startup)
  // ---------------------------------------------------------------------------
  // final auditLog = _writeStartupBanner(); // Side effect intended at startup.
  // // If nothing ever reads auditLog, _writeStartupBanner never runs, and the
  // // compiler may remove it entirely. The banner silently never appears.
  // No error is raised; the side effect simply never happens.
}
