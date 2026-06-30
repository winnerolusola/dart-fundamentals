// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 01 – COMMENTS
// ═══════════════════════════════════════════════════════════════════════════

// Egand Lab – coupon model. Internal. (file header is a // comment, not a doc)

// Price after discount, stored in minor units (kobo), not naira.
final discountedPriceMinor = 3499;

// Tax rate in basis points (1/100 of a percent); 750 means 7.50%.
final taxRateBasisPoints = 750;

/// Total payable in minor units: [discountedPriceMinor] plus the tax derived
/// from [taxRateBasisPoints]. Basis points are divided by 10000 to apply.
int netPayableMinor() {
  final tax = discountedPriceMinor * taxRateBasisPoints ~/ 10000;
  return discountedPriceMinor + tax;
}

/// A percentage-off coupon identified by [code].
class Coupon {
  final String code;
  final int percentOff;
  const Coupon(this.code, this.percentOff);
}

void main() {
  print(discountedPriceMinor); // 3499
  print(netPayableMinor()); // 3761
  print(Coupon('SAVE10', 10).code); // SAVE10
}
