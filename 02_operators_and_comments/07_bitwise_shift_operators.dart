// ═══════════════════════════════════════════════════════════════════════════
// 07 – BITWISE AND SHIFT OPERATORS
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// Bitwise and shift operators manipulate the individual bits of an integer.
// They are the right tool whenever a value is really a packed set of flags, a
// hardware register, a colour channel, a permission mask, or a protocol field.
// On an IoT board an ESP32 status register might pack eight independent flags
// into one byte; in an auth system a permission set is a bitmask. The problem
// these operators solve is reading and writing those packed bits directly,
// without expanding into a list of booleans. The catch is platform behaviour:
// Dart integers are 64-bit on native targets and 32-bit-ish (backed by a JS
// number) on the web, and the high-bit operators diverge between them.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   a & b     bitwise AND      1 only where both bits are 1
//   a | b     bitwise OR       1 where either bit is 1
//   a ^ b     bitwise XOR      1 where the bits differ
//   ~a        bitwise NOT      flips every bit (unary)
//   a << n    shift left       move bits left by n, filling with 0
//   a >> n    shift right      arithmetic: fills with the sign bit
//   a >>> n   unsigned shift   logical: fills with 0 (since language version 2.14)
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// All seven are `int` methods; the analyzer requires `int` operands and
// produces an `int`. There is no implicit conversion from `double`, so
// `3.0 & 1` is a compile error. `&`, `|`, and `^` are ALSO defined on `bool`
// (true is 1, false is 0), where they behave as non-short-circuiting logical
// operators; the analyzer accepts `boolA & boolB`. `>>>` requires the file's
// language version to be at least 2.14; below that the analyzer reports the
// operator as undefined. This project's floor is 3.7.0, so `>>>` is available.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// On the Dart VM (and AOT), `int` is a 64-bit two's-complement integer, so bit
// operations act on 64 bits and `~0` is `-1`. On the web, `int` is a 64-bit
// IEEE double; the runtime masks operands to fit JavaScript's 32-bit bitwise
// semantics, which means operations involving the high bits or negative numbers
// can yield DIFFERENT results from native. `>>` is arithmetic (the sign bit is
// copied into the vacated high bits), so shifting a negative number right keeps
// it negative. `>>>` is logical (zeros fill the high bits), so shifting a
// negative number right turns it positive.
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - The docs note bitwise behaviour with large or negative operands MAY differ
//    between platforms, and point to the number-representation page.
//  - `~bitmask` combined with `&` clears the masked bits (`value & ~bitmask`).
//  - `-value >> 4` differs on the web because the operand is masked to 32 bits.
//  - `>>>` (triple-shift / unsigned shift) requires language version 2.14+.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - `~0` is `-1` on native (all 64 bits set). On the web the bit pattern is
//    the same but the surrounding arithmetic on very large magnitudes can drift
//    past 2^53. Mask deliberately (`x & 0xFFFFFFFF`) when you need 32-bit
//    semantics on both platforms.
//  - Shifting by a negative amount throws; shifting by a count larger than the
//    width does NOT wrap the count on native (it shifts the value out to 0 for
//    `<<`/`>>>`, or to the sign for `>>`).
//  - `x << 1` equals `x * 2` and `x >> 1` equals `x ~/ 2` for non-negative `x`;
//    for negative `x`, `>>` matches floor division, not `~/` (which truncates
//    toward zero). So `-7 >> 1` is `-4`, while `-7 ~/ 2` is `-3`.
//  - `x & 1` tests oddness faster than `x % 2`, and `x & (n - 1)` computes
//    `x % n` when `n` is a power of two. These are the standard fast paths.
//  - Precedence is a notorious trap: `&`, `^`, `|` bind LOWER than `==`. So
//    `flags & MASK == MASK` parses as `flags & (MASK == MASK)`, a type error,
//    not the intended `(flags & MASK) == MASK`. Always parenthesise.
//  - `&`/`|` on bools evaluate BOTH operands (no short-circuit), unlike
//    `&&`/`||`. Occasionally intended, usually a mistake.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// Bitwise operations and shifts are single-cycle on every CPU and are the
// fastest arithmetic available. Replacing `* 2` with `<< 1`, `~/ 2` with `>> 1`
// (when sign semantics permit), or `% powerOfTwo` with `& (powerOfTwo - 1)` is a
// genuine micro-optimisation in hot loops. Packing flags into one int instead of
// a `List<bool>` also saves allocation and improves cache locality. On the web,
// the masking the runtime inserts to emulate 32-bit semantics adds a small but
// non-zero cost to each bitwise op.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Dart kept the C-family bitwise set, including the surprising-but-conventional
// low precedence of `&`/`^`/`|` relative to `==`, for cross-language
// familiarity, accepting the parenthesisation trap as the price. `>>>` was
// added in 2.14 specifically because the web's number model made a logical
// (zero-filling) right shift necessary and it had been missing; `>>` alone could
// not express an unsigned shift. Defining `&`/`|`/`^` on `bool` lets you write
// branchless boolean combinations when you deliberately want both sides
// evaluated.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// Each bitwise and shift operator has a compound-assignment form in 05
// (`&=`, `|=`, `^=`, `<<=`, `>>=`, `>>>=`). The bool overloads of `&`/`|`/`^`
// contrast with the short-circuiting logical operators in 06. Precedence (12)
// spreads these across several rows: shifts above `&` above `^` above `|`, all
// above the relational and equality operators, which is the source of the
// parenthesisation trap above.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: bitwise op on a double.
//    "The operator '&' isn't defined for the type 'double'."
//  - Runtime error: negative shift amount.
//    "Unsupported operation: shift amount must be non-negative" (RangeError /
//    ArgumentError depending on platform).
//  - Logical error: the `flags & MASK == MASK` precedence trap, or assuming
//    native and web give identical results for high-bit or negative operands.
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  // ── AND, OR, XOR, NOT with a sensor status register ─────────────────────
  // Treat one byte as packed flags from a device register.
  final statusRegister = 0x22; // 0b0010_0010
  final activeMask = 0x0f; // 0b0000_1111

  print((statusRegister & activeMask).toRadixString(16)); // 2    (AND)
  print((statusRegister & ~activeMask).toRadixString(16)); // 20   (AND NOT)
  print((statusRegister | activeMask).toRadixString(16)); // 2f   (OR)
  print((statusRegister ^ activeMask).toRadixString(16)); // 2d   (XOR)

  // ── Shifts ──────────────────────────────────────────────────────────────
  print((statusRegister << 4).toRadixString(16)); // 220  (shift left)
  print((statusRegister >> 4).toRadixString(16)); // 2    (shift right)

  // Arithmetic right shift preserves sign; the web masks the operand to 32 bits
  // and so can differ here.
  print(-statusRegister >> 4); // -3   (arithmetic: sign bit fills)

  // Unsigned right shift fills with zeros, so a negative becomes large positive.
  print((statusRegister >>> 4).toRadixString(16)); // 2
  print(-statusRegister >>> 4 > 0); // true (logical shift: no sign extension)

  // ── Building and testing a permission bitmask (auth flow) ───────────────
  const canRead = 1 << 0; // 0b001
  const canWrite = 1 << 1; // 0b010
  const canDelete = 1 << 2; // 0b100

  var editorPermissions = canRead | canWrite; // grant read and write
  print(editorPermissions); // 3

  // Test a single permission. Parentheses are REQUIRED: & is lower than ==.
  print((editorPermissions & canWrite) != 0); // true
  print((editorPermissions & canDelete) != 0); // false

  // Grant delete, then revoke write.
  editorPermissions |= canDelete; // set delete bit
  print(editorPermissions); // 7
  editorPermissions &= ~canWrite; // clear write bit
  print(editorPermissions); // 5
  editorPermissions ^= canRead; // toggle read off
  print(editorPermissions); // 4

  // ── Power-of-two fast paths ─────────────────────────────────────────────
  final byteCount = 37;
  print(byteCount << 1); // 74   (== byteCount * 2)
  print(byteCount >> 1); // 18   (== byteCount ~/ 2 for non-negative)
  print(byteCount & 1); // 1    (oddness test, faster than % 2)
  print(byteCount & (8 - 1)); // 5    (== byteCount % 8, power-of-two modulo)

  // ── Sign behaviour: >> floors, ~/ truncates ─────────────────────────────
  print(-7 >> 1); // -4   (arithmetic shift floors toward -infinity)
  print(-7 ~/ 2); // -3   (truncating division rounds toward zero)

  // ── INCORRECT USAGE: compile error (double operand) ─────────────────────
  //     final masked = 3.0 & 1;
  //
  //     Error: "The operator '&' isn't defined for the type 'double'."

  // ── INCORRECT USAGE: runtime error (negative shift) ─────────────────────
  //     final shifted = 1 << -2;
  //
  //     Unhandled exception:
  //     Unsupported operation: shift amount must be non-negative

  // ── INCORRECT USAGE: logical error (precedence trap) ────────────────────
  // Without parentheses, & binds LOWER than ==, so this does not mean what it
  // looks like and does not even type-check:
  //
  //     if (editorPermissions & canWrite == canWrite) { }
  //
  //     This parses as editorPermissions & (canWrite == canWrite), i.e.
  //     int & bool, which is a type error. Always write
  //     (editorPermissions & canWrite) == canWrite.
}
