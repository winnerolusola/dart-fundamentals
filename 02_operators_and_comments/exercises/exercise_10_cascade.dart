// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 10 – CASCADE NOTATION (.. and ?..)
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_10_cascade.dart.
// ═══════════════════════════════════════════════════════════════════════════

class QueryBuilder {
  String table = '';
  final List<String> wheres = [];
  int? limitValue;

  void where(String clause) => wheres.add(clause);
  void limit(int n) => limitValue = n;

  @override
  String toString() =>
      'SELECT * FROM $table WHERE ${wheres.join(' AND ')} LIMIT $limitValue';
}

void main() {
  // ── Problem 1 (isolated): build with a cascade ────────────────────────────
  // TODO 1: using a SINGLE cascade expression, configure a QueryBuilder with
  //         table 'orders', two where clauses 'status = paid' and 'total > 0',
  //         and a limit of 25. Assign the configured builder to `query`.
  final QueryBuilder query = QueryBuilder(); // replace with a cascade

  print(query);
  // expected: SELECT * FROM orders WHERE status = paid AND total > 0 LIMIT 25

  // ── Problem 2 (applied): ?.. null-aware cascade ───────────────────────────
  QueryBuilder? maybeBuilder; // null

  // TODO 2: attempt to configure maybeBuilder with table 'users' and limit 10
  //         using ?.. on the FIRST operation. Because it is null, nothing runs.
  // (write the cascade here)

  print(maybeBuilder); // expected: null

  // ── Problem 3 (cross-concept): parentheses change meaning ─────────────────
  // TODO 3: produce the LIMIT value (an int) by configuring a fresh builder
  //         with table 'audit' and limit 5, then reading limitValue. Use
  //         parentheses around the cascade so you can read the field off the
  //         configured object.
  final int? configuredLimit = null; // replace

  print(configuredLimit); // expected: 5
}
