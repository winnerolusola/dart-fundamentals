// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 11 – SPREAD OPERATORS (... and ...?)
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_11_spread.dart.
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ── Problem 1 (isolated): list spread concatenation ───────────────────────
  const featured = ['SKU-001', 'SKU-002'];
  const newArrivals = ['SKU-040', 'SKU-041'];

  // TODO 1: build a single list: all featured, then all new arrivals, then the
  //         literal 'SKU-PROMO' at the end. Use spreads.
  final List<String> homepage = []; // replace

  print(homepage);
  // expected: [SKU-001, SKU-002, SKU-040, SKU-041, SKU-PROMO]

  // ── Problem 2 (applied): ...? and map override order ──────────────────────
  const List<String>? clearance = null; // no clearance this week
  const defaults = {'theme': 'light', 'currency': 'NGN'};
  const overrides = {'theme': 'dark'};

  // TODO 2a: build a catalogue of featured plus clearance, where a null
  //          clearance contributes nothing (use ...?).
  final List<String> catalogue = []; // replace
  // TODO 2b: merge defaults and overrides so the user's override WINS.
  final Map<String, String> settings = {}; // replace

  print(catalogue); // expected: [SKU-001, SKU-002]
  print(settings); // expected: {theme: dark, currency: NGN}

  // ── Problem 3 (cross-concept): spread with if/for ─────────────────────────
  const isAdmin = true;
  const base = ['view', 'edit'];
  const adminOnly = ['delete'];
  const extras = ['export', 'share'];

  // TODO 3: build a menu of: all base actions, the admin actions only when
  //         isAdmin, then each extra UPPERCASED. Use spread + collection-if +
  //         collection-for in one literal.
  final List<String> menu = []; // replace

  print(menu); // expected: [view, edit, delete, EXPORT, SHARE]
}
