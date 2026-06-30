// =============================================================================
// EXERCISE 01 — VARIABLE DECLARATION AND REFERENCE SEMANTICS
// Run: dart run solutions/solution_01.dart

// =============================================================================

void main() {
  {
  // ---------------------------------------------------------------------------
  // 1.1 ISOLATED CONCEPT CHECK
  var productName = 'USB-C Cable';
  var unitPriceKobo = 2500;
  print(productName);    // USB-C Cable
  print(unitPriceKobo);  // 2500

  }

  {
  // ---------------------------------------------------------------------------
  // 1.2 APPLIED USAGE
  var defaultPermissions = ['read'];
  var grantedPermissions = defaultPermissions;
  grantedPermissions.add('write');
  print(defaultPermissions);                              // [read, write]
  print(identical(defaultPermissions, grantedPermissions)); // true

  }

  {
  // ---------------------------------------------------------------------------
  // 1.3 EXTENDED APPLIED (no earlier sub-concept exists before this file)
  var defaultPermissions = ['read'];
  var grantedPermissions = [...defaultPermissions]; // independent copy
  grantedPermissions.add('write');
  print(defaultPermissions);                              // [read]
  print(grantedPermissions);                              // [read, write]
  print(identical(defaultPermissions, grantedPermissions)); // false

  }

}
