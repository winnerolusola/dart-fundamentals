// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 08 – CONDITIONAL EXPRESSIONS (?: and ??)
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_08_conditional.dart.
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ── Problem 1 (isolated): ternary ─────────────────────────────────────────
  const stockOnHand = 0;

  // TODO 1: availability is 'In stock' when stockOnHand > 0, else 'Sold out'.
  final String availability = ''; // replace using ?:

  print(availability); // expected: Sold out

  // ── Problem 2 (applied): ?? chain for layered config ──────────────────────
  // Resolve the page size from, in priority order: a request override, a saved
  // user preference, then a hard default of 20. Missing layers are null.
  const int? requestOverride = null;
  const int? savedPreference = 50;
  const int defaultPageSize = 20;

  // TODO 2: first non-null wins.
  final int pageSize = 0; // replace using a ?? chain

  print(pageSize); // expected: 50

  // ── Problem 3 (cross-concept): ?. then ?? (access-then-default) ─────────
  // recentSearches may be null. Produce the first search if present, else
  // 'none'. Combine ?. with ?? in one expression.
  const List<String>? recentSearches = null;

  // TODO 3:
  final String firstSearch = ''; // replace

  print(firstSearch); // expected: none
}
