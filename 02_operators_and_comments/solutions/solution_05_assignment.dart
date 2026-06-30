// ═══════════════════════════════════════════════════════════════════════════
// SOLUTION 05 – ASSIGNMENT OPERATORS
// ═══════════════════════════════════════════════════════════════════════════

int sideEffectCalls = 0;

int targetIndex() {
  sideEffectCalls++;
  return 1;
}

void main() {
  // Problem 1
  String? cachedRegion;
  cachedRegion ??= 'eu-west-1'; // null, so assigned
  cachedRegion ??= 'us-east-1'; // already set, ignored
  print(cachedRegion); // eu-west-1

  // Problem 2
  var runningMinor = 1000;
  runningMinor += 999; // 1999
  runningMinor -= 250; // 1749
  runningMinor *= 2; // 3498
  runningMinor ~/= 3; // 1166
  runningMinor %= 1000; // 166
  print(runningMinor); // 166

  // Problem 3 – op= evaluates the target index once.
  final stock = [10, 20, 30];
  sideEffectCalls = 0;
  stock[targetIndex()] += 5; // targetIndex() runs once
  print(stock[1]); // 25
  print(sideEffectCalls); // 1
}
