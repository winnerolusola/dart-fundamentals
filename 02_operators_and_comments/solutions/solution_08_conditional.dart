// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 08 – CONDITIONAL EXPRESSIONS (?: and ??)
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // Problem 1
  const stockOnHand = 0;
  final String availability = stockOnHand > 0 ? 'In stock' : 'Sold out';
  print(availability); // Sold out

  // Problem 2 – first non-null wins.
  const int? requestOverride = null;
  const int? savedPreference = 50;
  const int defaultPageSize = 20;
  final int pageSize = requestOverride ?? savedPreference ?? defaultPageSize;
  print(pageSize); // 50

  // Problem 3 – access then default.
  const List<String>? recentSearches = null;
  final String firstSearch = recentSearches?.first ?? 'none';
  print(firstSearch); // none
}
