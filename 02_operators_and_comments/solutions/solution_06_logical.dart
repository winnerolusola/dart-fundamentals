// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 06 – LOGICAL OPERATORS
// ═══════════════════════════════════════════════════════════════════════════

bool auditCalled = false;

bool recordAudit() {
  auditCalled = true;
  return true;
}

void main() {
  // Problem 1
  const isLoggedIn = true;
  const isEmailVerified = true;
  const isSuspended = false;
  final bool canCheckout = isLoggedIn && isEmailVerified && !isSuspended;
  print(canCheckout); // true

  // Problem 2 – short-circuit guards the null dereference.
  String? promoCode;
  final bool hasUsablePromo = promoCode != null && promoCode.length >= 4;
  print(hasUsablePromo); // false

  // Problem 3 – admin short-circuits the OR, so recordAudit never runs.
  const role = 'admin';
  auditCalled = false;
  final bool accessHandled = role == 'admin' || recordAudit();
  print(accessHandled); // true
  print(auditCalled); // false
}
