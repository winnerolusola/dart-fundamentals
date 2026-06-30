// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 13 – COMBINED (whole topic)
// ═══════════════════════════════════════════════════════════════════════════

/// A single line in the order. Two lines are equal when sku and quantity match.
class OrderLine {
  final String sku;
  final int unitPriceMinor;
  final int quantity;
  const OrderLine(this.sku, this.unitPriceMinor, this.quantity);

  @override
  bool operator ==(Object other) =>
      other is OrderLine && other.sku == sku && other.quantity == quantity;

  @override
  int get hashCode => Object.hash(sku, quantity);

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
  final baseLines = [
    const OrderLine('TSHIRT-01', 4599, 2),
    const OrderLine('STICKER-09', 500, 3),
  ];
  final reorderedLine = const OrderLine('TSHIRT-01', 4599, 2);

  // Part 1 – spread into a set; the duplicate collapses via == and hashCode.
  final uniqueLines = {...baseLines, reorderedLine};

  // Part 2 – subtotal via compound assignment.
  var subtotalMinor = 0;
  for (final line in uniqueLines) {
    subtotalMinor += line.lineTotalMinor;
  }

  // Part 3 – config layering with ?? and a guarded discount via ternary.
  const int? requestCouponBps = null;
  const int? savedCouponBps = 1000;
  final int effectiveBps = requestCouponBps ?? savedCouponBps ?? 0;
  final int discountMinor =
      subtotalMinor > 5000 ? subtotalMinor * effectiveBps ~/ 10000 : 0;

  // Part 4 – type test + short-circuit for the customer label.
  final Object? rawCustomer = 'Ada Obi';
  final String customerLabel =
      (rawCustomer is String && rawCustomer.isNotEmpty) ? rawCustomer : 'Guest';

  // Part 5 – assemble via a single cascade.
  final receipt = Receipt()
    ..customer = customerLabel
    ..lines.addAll([for (final line in uniqueLines) line.toString()])
    ..subtotalMinor = subtotalMinor
    ..discountMinor = discountMinor;

  print(receipt);
  // Customer: Ada Obi
  // TSHIRT-01 x2 = 9198
  // STICKER-09 x3 = 1500
  // Subtotal: 10698
  // Discount: 1069
  // Total: 9629
}
