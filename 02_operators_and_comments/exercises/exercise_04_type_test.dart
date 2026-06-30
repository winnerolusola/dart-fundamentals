// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 04 – TYPE TEST OPERATORS (as, is, is!)
// ───────────────────────────────────────────────────────────────────────────
// No solutions here; see solutions/solution_04_type_test.dart.
// ═══════════════════════════════════════════════════════════════════════════

sealed class Notification {}

class EmailNotification extends Notification {
  final String address;
  EmailNotification(this.address);
}

class SmsNotification extends Notification {
  final String phone;
  SmsNotification(this.phone);
}

void main() {
  final Notification event = EmailNotification('ada@egand.dev');

  // ── Problem 1 (isolated): is / is! ────────────────────────────────────────
  // TODO 1a: true if event is an EmailNotification.
  final bool isEmail = false; // replace
  // TODO 1b: true if event is NOT an SmsNotification.
  final bool notSms = false; // replace

  print(isEmail); // expected: true
  print(notSms); // expected: true

  // ── Problem 2 (applied): safe narrowing with promotion ────────────────────
  // TODO 2: using `is` and promotion (NOT `as`), produce the delivery target
  //         string: the email address if it is an email, else the phone.
  String deliveryTarget = ''; // replace via if (event is ...) { ... }

  print(deliveryTarget); // expected: ada@egand.dev

  // ── Problem 3 (cross-concept): is + logical && for guarded access ─────────
  // payloads is a heterogeneous list. Build a list of the LENGTHS of only the
  // non-empty String payloads, using `is` with && so the right operand sees
  // the promoted String.
  final List<Object?> payloads = ['NGN', 42, '', null, 'sensor-01'];

  final List<int> nonEmptyStringLengths = []; // fill this

  print(nonEmptyStringLengths); // expected: [3, 9]
}
