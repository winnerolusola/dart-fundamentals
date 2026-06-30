// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 13 – COMBINED (whole topic)
// ───────────────────────────────────────────────────────────────────────────
// Build a small checkout summariser for an Egand Lab storefront. This exercise
// draws on every sub-concept: comments, arithmetic, equality/relational, type
// test, assignment, logical, conditional, member access/null-aware, cascade,
// spread, and precedence. Complete each TODO so the final printed receipt
// matches the expected output at the bottom.
//
// No solutions here; see solutions/solution_13_combined.dart.
// ═══════════════════════════════════════════════════════════════════════════

/// A single line in the order. Two lines are equal when sku and quantity match.
class OrderLine {
  final String sku;
  final int unitPriceMinor; // minor units (kobo)
  final int quantity;
  const OrderLine(this.sku, this.unitPriceMinor, this.quantity);

  // TODO A: implement == and hashCode so equal sku+quantity collapse in a Set.

  int get lineTotalMinor => unitPriceMinor * quantity;

  @override
  String toString() => '$sku x$quantity = $lineTotalMinor';
}

/// A mutable receipt assembled via cascade.
class Receipt {
  String customer = '';
  final List<String> lines = [];
  int subtotalMinor = 0;
  int discountMinor = 0;
  int get totalMinor => subtotalMinor - discountMinor;

  void addLine(String text) => lines.add(text);

  @override
  String toString() => [
        'Customer: $customer',
        ...lines,
        'Subtotal: $subtotalMinor',
        'Discount: $discountMinor',
        'Total: $totalMinor',
      ].join('\n');
}

void main() {
  // Base order plus a re-ordered duplicate (same sku and quantity).
  final baseLines = [
    const OrderLine('TSHIRT-01', 4599, 2),
    const OrderLine('STICKER-09', 500, 3),
  ];
  final reorderedLine = const OrderLine('TSHIRT-01', 4599, 2);

  // ── Part 1: de-duplicate with == (uses Part A) and spread ─────────────────
  // TODO 1: build a Set of all base lines plus the reordered line. After Part A
  //         the duplicate collapses, so the set has 2 entries.
  final Set<OrderLine> uniqueLines = {}; // replace using spreads into a set

  // ── Part 2: subtotal with compound assignment + arithmetic ────────────────
  var subtotalMinor = 0;
  // TODO 2: sum lineTotalMinor across uniqueLines using += in a loop.

  // ── Part 3: discount via conditional + config layering with ?? ────────────
  // A coupon may override the default discount rate (in basis points). Missing
  // layers are null. Priority: request coupon ?? saved coupon ?? default 0.
  const int? requestCouponBps = null;
  const int? savedCouponBps = 1000; // 10.00%
  // TODO 3a: resolve the effective basis points with a ?? chain.
  final int effectiveBps = 0; // replace
  // TODO 3b: discount is subtotal * effectiveBps ~/ 10000, but ONLY when the
  //          subtotal exceeds 5000; otherwise 0. Use a ternary.
  final int discountMinor = 0; // replace

  // ── Part 4: type test + null-aware access for the customer label ──────────
  // rawCustomer arrives as Object? from an untyped source.
  final Object? rawCustomer = 'Ada Obi';
  // TODO 4: if rawCustomer is a non-empty String, use it; else 'Guest'.
  //         Use `is` with && (short-circuit) and a ternary or ?? fallback.
  final String customerLabel = ''; // replace

  // ── Part 5: assemble the receipt with a cascade ───────────────────────────
  // TODO 5: build the receipt in a SINGLE cascade: set customer to
  //         customerLabel, add one line string per uniqueLine (its toString),
  //         set subtotalMinor and discountMinor.
  final Receipt receipt = Receipt(); // replace with a cascade

  print(receipt);
  // expected:
  // Customer: Ada Obi
  // TSHIRT-01 x2 = 9198
  // STICKER-09 x3 = 1500
  // Subtotal: 10698
  // Discount: 1069
  // Total: 9629
}
