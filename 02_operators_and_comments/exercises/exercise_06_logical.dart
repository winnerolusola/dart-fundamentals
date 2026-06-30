// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 06 – LOGICAL OPERATORS
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_06_logical.dart.
// ═══════════════════════════════════════════════════════════════════════════

bool auditCalled = false;

/// Records an audit entry as a side effect and returns true.
bool recordAudit() {
  auditCalled = true;
  return true;
}

void main() {
  // ── Problem 1 (isolated): combine conditions ──────────────────────────────
  const isLoggedIn = true;
  const isEmailVerified = true;
  const isSuspended = false;

  // TODO 1: canCheckout is true only when logged in AND email verified AND NOT
  //         suspended.
  final bool canCheckout = false; // replace

  print(canCheckout); // expected: true

  // ── Problem 2 (applied): short-circuit null guard ─────────────────────────
  String? promoCode; // null

  // TODO 2: hasUsablePromo is true only when promoCode is non-null and its
  //         length is at least 4. Rely on short-circuiting so no crash occurs
  //         when promoCode is null.
  final bool hasUsablePromo = false; // replace

  print(hasUsablePromo); // expected: false

  // ── Problem 3 (cross-concept): short-circuit controls a side effect ───────
  // recordAudit() must run ONLY when access is denied. Access is granted when
  // the role is 'admin'. Write the expression so recordAudit() is skipped for
  // an admin.
  const role = 'admin';
  auditCalled = false;

  // TODO 3: set accessHandled using || so recordAudit() is short-circuited for
  //         an admin.
  final bool accessHandled = false; // replace

  print(accessHandled); // expected: true
  print(auditCalled); // expected: false
}
