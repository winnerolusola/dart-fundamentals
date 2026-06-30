// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 03 – EQUALITY AND RELATIONAL OPERATORS
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_03_equality_relational.dart.
// ═══════════════════════════════════════════════════════════════════════════

// ── Problem 2 (applied): value equality ──────────────────────────────────────
// TODO 2: Override == and hashCode so two warehouse bins are equal when their
//         aisle and shelf match. Keep the contract (equal objects, equal hash).
class WarehouseBin {
  final String aisle;
  final int shelf;
  const WarehouseBin(this.aisle, this.shelf);

  // TODO 2a: implement operator ==
  // TODO 2b: implement hashCode
}

void main() {
  // ── Problem 1 (isolated): == vs identical ─────────────────────────────────
  final first = WarehouseBin('A', 3);
  final second = WarehouseBin('A', 3);

  // TODO 1a: set to whether the two bins are VALUE-equal (uses your ==).
  final bool sameValue = false; // replace
  // TODO 1b: set to whether they are the SAME object.
  final bool sameObject = false; // replace

  print(sameValue); // expected: true   (after Problem 2 is done)
  print(sameObject); // expected: false

  // De-duplication relies on == AND hashCode agreeing.
  final unique = {first, second};
  print(unique.length); // expected: 1   (after Problem 2 is done)

  // ── Problem 3 (cross-concept): NaN guard + relational decision ────────────
  // A sensor sometimes reports NaN for a failed read. Compute a status string:
  //   'invalid'  if the reading is NaN,
  //   'high'     if reading > 30.0,
  //   'normal'   otherwise.
  const readings = [22.5, 35.1, double.nan, 30.0];

  // TODO 3: build the list of status strings. Remember == cannot detect NaN.
  final List<String> statuses = []; // fill this

  print(statuses); // expected: [normal, high, invalid, normal]
}
