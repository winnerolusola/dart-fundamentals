// ═══════════════════════════════════════════════════════════════════════════
// 09 – MEMBER ACCESS AND NULL-AWARE OPERATORS: . ?. ?[] [] ! ()
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// These are the operators that reach INTO a value: `.` reads a member, `[]`
// reads an indexed element, `()` calls a function, and the null-aware variants
// `?.` and `?[]` do the same while tolerating a null receiver. `!` asserts that
// a nullable value is actually non-null. They are grouped together because they
// are the bread and butter of every line that touches an object, and because
// null safety makes the choice between `.` and `?.`, and the decision to use
// `!`, a constant judgement call. The problem they solve is reaching into possibly
// absent data: a user who may not be loaded, a list that may be empty, a config
// key that may be missing, without a cascade of `if (x != null)` guards.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   target.member       member access (property or method)
//   target?.member      null-aware member access; whole expression is null if
//                       target is null, and member is not evaluated
//   list[index]         subscript via operator []
//   list?[index]        null-aware subscript; null if list is null
//   function(args)      function application (a call)
//   value!              not-null assertion; value typed non-null, throws if null
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// `.` requires the receiver's static type to declare the member; on a nullable
// receiver, `.` is a compile error and the analyzer directs you to `?.` or `!`.
// `?.` is permitted on a nullable receiver and types the whole expression as
// nullable (because it may produce null). `[]` and `?[]` require the type to
// define `operator []`. `!` takes a value of type `T?` and yields `T`; the
// analyzer also reports `unnecessary_non_null_assertion` when applied to a value
// it already knows is non-null. `()` requires a callable target.
//
// A key compile-time behaviour is NULL SHORTING: in `a?.b.c.d`, the `?.` shorts
// the ENTIRE remaining chain. If `a` is null, none of `.b`, `.c`, `.d` runs and
// the result is null. You do not need `a?.b?.c?.d` unless `b` or `c` are
// themselves independently nullable.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// `.`, `[]`, and `()` dispatch normally. `?.` and `?[]` first test the receiver
// for null; if null, they yield null immediately and skip the access. `!`
// performs a runtime null check: if the value is non-null it passes through
// unchanged (no object is created), and if it is null it throws a `TypeError`
// with the message "Null check operator used on a null value".
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - `?.` yields null when the leftmost operand is null; `foo?.bar` is null if
//    `foo` is null.
//  - `?[]` yields null when the leftmost operand is null; `list?[1]` is null if
//    `list` is null.
//  - `!` casts to the underlying non-nullable type and throws at runtime if the
//    value is null; `foo!.bar` asserts `foo` is non-null then reads `bar`.
//  - `[]` represents a call to the overridable `operator []`.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - Null shorting covers the whole chain, not one link. `user?.profile.bio` is
//    safe even though `.profile.bio` has no `?`, because the short propagates.
//  - `?.` in an assignment also shorts: `user?.lastSeen = now` does nothing if
//    `user` is null, and the right-hand side is still evaluated only if needed.
//  - `!` is an ASSERTION, not a conversion: `(value as T)` and `value!` both
//    throw on mismatch, but `!` only removes nullability and cannot change the
//    base type, while `as` can. Using `!` to silence the analyzer when the value
//    can be null is the nullable analogue of a wrong `as`: a latent crash.
//  - `[]` on a `List` throws `RangeError` for an out-of-bounds index; `?[]` does
//    NOT guard the index, only the receiver. `list?[99]` still throws if `list`
//    is non-null and 99 is out of range.
//  - `[]` on a `Map` returns null for a missing key (no throw), because
//    `Map.operator []` is declared to return a nullable value. This is a
//    frequent source of confusion versus `List`.
//  - The not-null assertion participates in flow: after `final p = user!;`, the
//    local `p` is non-null, but the original `user` is not promoted unless it is
//    effectively final.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// `.` and `()` are ordinary dispatch and indistinguishable in cost from any
// method call. `?.`/`?[]` add one null comparison, which is negligible. `!`
// adds one null check on the success path, also negligible; its only cost is
// the thrown exception on failure, which should be the exceptional path. None of
// these allocate.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Null shorting was designed so that a single `?.` early in a chain protects the
// rest, which keeps null-safe access concise instead of peppering every link
// with `?.`. `!` exists as an explicit, searchable escape hatch: when you know
// more than the analyzer, you say so in one character, and you accept a loud
// crash if you are wrong, rather than a silent null propagating. The separation
// of `?.` (tolerate null) from `!` (assert non-null) makes the author's intent
// explicit at every access, which is the core bargain of sound null safety.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// `?.` composes with `??` (08) for the canonical "access then default":
// `user?.name ?? 'Guest'`. `!` is the nullability sibling of `as` (04). The
// cascade `..`/`?..` (10) is built directly on member access and reuses null
// shorting via `?..`. Precedence (12) places these unary postfix operators at
// the very top of the table, so they bind tighter than every binary operator.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: `.` on a nullable receiver.
//    "The property 'name' can't be unconditionally accessed because the
//    receiver can be 'null'."
//  - Runtime error: `!` on a null value.
//    "Null check operator used on a null value"
//  - Runtime error: `[]` out of range (not guarded by `?[]`).
//    "RangeError (index): Invalid value: Not in inclusive range 0..n: 99"
//  - Logical error: using `!` to suppress a warning where the value really can
//    be null, deferring the crash to runtime.
// ═══════════════════════════════════════════════════════════════════════════

/// A user profile that may or may not have been loaded into a session.
class UserProfile {
  String displayName;
  String? bio; // may be absent even when the profile is loaded
  DateTime? lastSeen;

  UserProfile(this.displayName, {this.bio, this.lastSeen});
}

void main() {
  // ── Plain member access and calls ───────────────────────────────────────
  final profile = UserProfile('Ada Obi', bio: 'Builds IoT things at Egand');
  print(profile.displayName); // Ada Obi
  print(profile.displayName.toUpperCase()); // ADA OBI

  // ── Null-aware member access and null shorting ──────────────────────────
  UserProfile? maybeProfile; // null (session not loaded)
  print(maybeProfile?.displayName); // null   (?. shorts, no crash)

  // The short covers the WHOLE chain: .bio?.length need only short once at the
  // top for the receiver, though bio itself is independently nullable here.
  print(maybeProfile?.displayName.toUpperCase()); // null

  maybeProfile = profile;
  print(maybeProfile?.displayName.toUpperCase()); // ADA OBI

  // ── Null-aware assignment also shorts ───────────────────────────────────
  UserProfile? unloaded;
  unloaded?.lastSeen = DateTime(2026, 6, 29); // does nothing; unloaded is null
  print(unloaded); // null

  // ── Subscript: List throws on bad index, Map returns null ───────────────
  final recentOrders = ['ORD-1', 'ORD-2', 'ORD-3'];
  print(recentOrders[0]); // ORD-1

  final settings = {'theme': 'dark', 'currency': 'NGN'};
  print(settings['currency']); // NGN
  print(settings['missing']); // null   (Map [] returns null for absent keys)

  // Null-aware subscript guards the RECEIVER, not the index.
  List<String>? maybeOrders;
  print(maybeOrders?[0]); // null   (receiver null, shorted)
  maybeOrders = recentOrders;
  print(maybeOrders?[1]); // ORD-2

  // ── Not-null assertion ! ────────────────────────────────────────────────
  String? validatedEmail = 'ada@egand.dev'; // proven non-null by validation
  final email = validatedEmail!; // assert non-null, yields String
  print(email.contains('@')); // true

  // ── ?. composed with ?? for access-then-default ───────────────────────
  UserProfile? guestSession;
  final nameForUi = guestSession?.displayName ?? 'Guest';
  print(nameForUi); // Guest

  // ── INCORRECT USAGE: compile error (. on nullable) ──────────────────────
  //     UserProfile? p;
  //     print(p.displayName);
  //
  //     Error: "The property 'displayName' can't be unconditionally accessed
  //     because the receiver can be 'null'."
  //     (Use p?.displayName, or p!.displayName if you can prove non-null.)

  // ── INCORRECT USAGE: runtime error (! on null) ──────────────────────────
  //     UserProfile? notLoaded;
  //     final name = notLoaded!.displayName;
  //
  //     Unhandled exception:
  //     Null check operator used on a null value

  // ── INCORRECT USAGE: runtime error (index out of range) ─────────────────
  // ?[] does NOT guard the index; only the receiver.
  //
  //     final first = recentOrders[99];
  //
  //     Unhandled exception:
  //     RangeError (index): Invalid value: Not in inclusive range 0..2: 99

  // ── INCORRECT USAGE: logical error (! used to silence a real null) ──────
  // If a value genuinely can be null and you write value! to quiet the
  // analyzer, you have only moved the failure from compile time to runtime.
  // Prefer ?. with a default, or an explicit null check that promotes.
}
