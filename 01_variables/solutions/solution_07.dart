// =============================================================================
// EXERCISE 07 — final
// Run: dart run solutions/solution_07.dart
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // 7.1 ISOLATED CONCEPT CHECK
  {
    final orderId = 'INV-4501';
    final String customerName = 'Ada';
    print(orderId);      // INV-4501
    print(customerName); // Ada
  }

  // ---------------------------------------------------------------------------
  // 7.2 APPLIED USAGE
  {
    final List<String> orderTags = ['new'];
    orderTags.add('priority');
    print(orderTags); // [new, priority]
    // Compile error would be: orderTags = ['x'];  ("can only be set once").
    // .add is allowed because final fixes the binding, not the object's contents.
  }

  // ---------------------------------------------------------------------------
  // 7.3 COMBINED WITH 05 (definite assignment of a final local)
  {
    final orderId = 'INV-4501';
    final int shippingFeeKobo;
    if (orderId.startsWith('INV')) {
      shippingFeeKobo = 0;
    } else {
      shippingFeeKobo = 1500;
    }
    print(shippingFeeKobo); // 0
  }
}
