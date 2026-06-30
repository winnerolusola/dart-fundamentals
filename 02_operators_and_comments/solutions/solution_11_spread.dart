// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 11 – SPREAD OPERATORS (... and ...?)
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // Problem 1
  const featured = ['SKU-001', 'SKU-002'];
  const newArrivals = ['SKU-040', 'SKU-041'];
  final homepage = [...featured, ...newArrivals, 'SKU-PROMO'];
  print(homepage); // [SKU-001, SKU-002, SKU-040, SKU-041, SKU-PROMO]

  // Problem 2
  const List<String>? clearance = null;
  const defaults = {'theme': 'light', 'currency': 'NGN'};
  const overrides = {'theme': 'dark'};
  final catalogue = [...featured, ...?clearance];
  final settings = {...defaults, ...overrides}; // later spread wins
  print(catalogue); // [SKU-001, SKU-002]
  print(settings); // {theme: dark, currency: NGN}

  // Problem 3
  const isAdmin = true;
  const base = ['view', 'edit'];
  const adminOnly = ['delete'];
  const extras = ['export', 'share'];
  final menu = [
    ...base,
    if (isAdmin) ...adminOnly,
    for (final extra in extras) extra.toUpperCase(),
  ];
  print(menu); // [view, edit, delete, EXPORT, SHARE]
}
