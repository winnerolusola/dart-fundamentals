// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 10 – CASCADE NOTATION (.. and ?..)
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
  // Problem 1 – one cascade yields the configured builder.
  final query = QueryBuilder()
    ..table = 'orders'
    ..where('status = paid')
    ..where('total > 0')
    ..limit(25);
  print(query);
  // SELECT * FROM orders WHERE status = paid AND total > 0 LIMIT 25

  // Problem 2 – ?.. on the first op; null receiver runs nothing.
  QueryBuilder? maybeBuilder;
  maybeBuilder
    ?..table = 'users'
    ..limit(10);
  print(maybeBuilder); // null

  // Problem 3 – parentheses let you read a field off the configured object.
  final int? configuredLimit = (QueryBuilder()
        ..table = 'audit'
        ..limit(5))
      .limitValue;
  print(configuredLimit); // 5
}
