// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 04 – TYPE TEST OPERATORS (as, is, is!)
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

  // Problem 1
  final bool isEmail = event is EmailNotification;
  final bool notSms = event is! SmsNotification;
  print(isEmail); // true
  print(notSms); // true

  // Problem 2 – narrow with is + promotion, no as.
  String deliveryTarget;
  if (event is EmailNotification) {
    deliveryTarget = event.address; // promoted
  } else if (event is SmsNotification) {
    deliveryTarget = event.phone;
  } else {
    deliveryTarget = '';
  }
  print(deliveryTarget); // ada@egand.dev

  // Problem 3 – is with && promotes the right operand to String.
  final List<Object?> payloads = ['NGN', 42, '', null, 'sensor-01'];
  final nonEmptyStringLengths = [
    for (final payload in payloads)
      if (payload is String && payload.isNotEmpty) payload.length
  ];
  print(nonEmptyStringLengths); // [3, 9]
}
