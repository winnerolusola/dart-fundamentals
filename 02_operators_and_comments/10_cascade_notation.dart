// ═══════════════════════════════════════════════════════════════════════════
// 10 – CASCADE NOTATION: .. and ?..
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// A cascade performs a sequence of operations on the SAME object and then yields
// that object, not the result of the last operation. It solves the "configure
// then keep" problem: you build an object, set several properties or call
// several methods on it, and want the configured object back without inventing a
// temporary variable and repeating its name on every line. In Flutter you meet
// it constantly (`Paint()..color = ...`); in any builder-style API it turns five
// statements into one fluent expression. The receiver expression is evaluated
// ONCE, and every `..` operates on that single result.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   target
//     ..member = value     cascaded assignment
//     ..method(args)       cascaded method call
//     ..[index] = value    cascaded index assignment
//
//   target            null-aware cascade: if target is null, the WHOLE cascade
//     ?..first        is skipped. The FIRST operation must use ?.. ; subsequent
//     ..second        operations use plain .. once non-null is established.
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// The docs are explicit that `..` is not technically an operator; it is grammar.
// The analyzer rewrites `target..a()..b()` into "evaluate target once into a
// hidden temporary `t`; run `t.a()`; run `t.b()`; the whole expression has the
// value `t`". Because the value is the receiver, the RETURN values of the
// cascaded calls are discarded. The analyzer therefore rejects a cascade whose
// receiver expression has type `void`, since there is no object to return or to
// operate on. `?..` requires a nullable receiver and types the whole cascade as
// nullable.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// The receiver is computed once. Each cascaded operation runs in order on that
// object, its result thrown away. The expression evaluates to the receiver. For
// `?..`, the runtime tests the receiver for null first; if null, no cascaded
// operation runs and the expression is null.
//
// DOCUMENTED EDGE CASES
// ---------------------------------------------------------------------------
//  - A cascade returns the object it operates on, ignoring the values the
//    cascaded calls return (the `Paint()..color = ...` example).
//  - `?..` on the first operation guarantees none of the cascade runs on a null
//    receiver.
//  - Cascades can NEST: a cascaded call's argument can itself be a cascade
//    (the AddressBookBuilder / PhoneNumberBuilder example).
//  - You cannot build a cascade on a `void` result: `sb.write('foo')..write
//    ('bar')` fails because `write` returns void.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - The receiver is evaluated once, so `buildExpensiveThing()..configure()`
//    calls the builder a single time even across many cascaded lines. This is a
//    correctness and performance property, not just sugar.
//  - A cascade is an EXPRESSION, so it can be returned or assigned:
//    `return Cart()..add(item);` returns the configured cart.
//  - Mixing a cascade with the result of a cascaded call needs care:
//    `(builder..configure()).build()` builds from the configured builder, while
//    `builder..configure()..build()` discards the `build()` result and yields
//    the builder. The parentheses change the meaning entirely.
//  - After the first `?..`, do NOT keep writing `?..` on every line; once the
//    receiver is established non-null, plain `..` is correct and idiomatic. The
//    short already covers the whole cascade.
//  - A cascade assignment can target an index: `cache..['key'] = value`.
//  - `..` has very low precedence, which is why `a + b..method()` is a common
//    mistake; it parses against the whole `a + b` only if parenthesised, and
//    without parentheses the binding is rarely what you expect. Parenthesise.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// None beyond the single evaluation of the receiver, which can SAVE work versus
// a non-cascade form that recomputes the receiver. The hidden temporary is a
// local reference, not an allocation. Cascades neither speed up nor slow down
// the cascaded calls themselves.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Cascades exist so that mutable, builder-style configuration reads as one
// fluent unit without forcing every API to return `this` (the fluent-interface
// pattern other languages rely on). Because Dart provides `..` at the language
// level, ordinary setters and void methods become chainable for free; a library
// author does not have to design for it. Making the cascade yield the receiver
// rather than the last call's result is the choice that makes "configure then
// keep" work; `?..` extends the same idea to nullable receivers using the null
// shorting introduced for `?.` (09).
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// Cascade is built on member access (`.`, `[]`) and the call operator from 09,
// and `?..` reuses the null shorting of `?.`. It is unrelated to the spread
// operator (11) despite both using dots. Precedence (12) places cascade very
// low, just above assignment, which is the source of the parenthesisation
// caveats above.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
//  - Compile error: cascade on a void receiver.
//    "The method 'write' isn't defined for the type 'void'." (per the docs'
//    StringBuffer example)
//  - Compile error: plain `..` on a nullable receiver without `?..` first.
//    "The method '...' can't be unconditionally accessed because the receiver
//    can be 'null'."
//  - Logical error: expecting the cascade to return the last call's result
//    (it returns the receiver), or omitting parentheses so precedence misbinds.
// ═══════════════════════════════════════════════════════════════════════════

/// A mutable builder for an outbound email, configured via cascades.
class EmailDraft {
  String to = '';
  String subject = '';
  String body = '';
  final List<String> attachments = [];

  void attach(String filename) => attachments.add(filename);

  @override
  String toString() =>
      'To: $to | Subj: $subject | Body: $body | Files: $attachments';
}

/// A builder whose argument is itself built with a nested cascade.
class ShipmentBuilder {
  String reference = '';
  AddressBuilder destination = AddressBuilder();
  ShipmentBuilder build() => this;
}

class AddressBuilder {
  String city = '';
  String country = '';
  AddressBuilder build() => this;
}

void main() {
  // ── Basic cascade: configure then keep the object ───────────────────────
  final draft = EmailDraft()
    ..to = 'ops@egand.dev'
    ..subject = 'Sensor batch shipped'
    ..body = 'Tracking attached.'
    ..attach('manifest.pdf')
    ..attach('tracking.png');
  print(draft);
  // To: ops@egand.dev | Subj: Sensor batch shipped | Body: Tracking attached. | Files: [manifest.pdf, tracking.png]

  // The cascade evaluates to the receiver, so it can be returned or assigned
  // directly. Here it is the EmailDraft, not the void result of attach().
  print(draft.attachments.length); // 2

  // ── Equivalent longhand (what the cascade desugars to) ──────────────────
  final draft2 = EmailDraft();
  draft2.to = 'ops@egand.dev';
  draft2.subject = 'Sensor batch shipped';
  print(draft2.to); // ops@egand.dev

  // ── Null-aware cascade: ?.. on the FIRST operation only ─────────────────
  EmailDraft? maybeDraft; // null
  maybeDraft
    ?..to = 'noone@egand.dev' // first op uses ?.. ; whole cascade shorts
    ..subject = 'Never set';
  print(maybeDraft); // null   (receiver was null, nothing ran)

  maybeDraft = EmailDraft();
  maybeDraft
    ?..to = 'lin@egand.dev' // receiver non-null, cascade runs
    ..subject = 'Welcome';
  print(maybeDraft.to); // lin@egand.dev

  // ── Index assignment in a cascade ───────────────────────────────────────
  final headerCache = <String, String>{}
    ..['Content-Type'] = 'application/json'
    ..['X-Trace-Id'] = 'trace-001';
  print(headerCache); // {Content-Type: application/json, X-Trace-Id: trace-001}

  // ── Nested cascades ─────────────────────────────────────────────────────
  final shipment = (ShipmentBuilder()
        ..reference = 'SHP-42'
        ..destination = (AddressBuilder()
              ..city = 'Lagos'
              ..country = 'NG')
            .build())
      .build();
  print('${shipment.reference} -> ${shipment.destination.city}'); // SHP-42 -> Lagos

  // ── Parentheses change meaning ──────────────────────────────────────────
  // (builder..configure()).build()  -> builds from the configured builder
  // builder..configure()..build()   -> discards build()'s result, yields builder
  final builtFrom = (ShipmentBuilder()..reference = 'SHP-99').build();
  print(builtFrom.reference); // SHP-99

  // ── INCORRECT USAGE: compile error (cascade on void) ────────────────────
  // StringBuffer.write returns void, so you cannot start a cascade on it.
  //
  //     final sb = StringBuffer();
  //     sb.write('foo')..write('bar');
  //
  //     Error: "The method 'write' isn't defined for the type 'void'."
  //     (Use a cascade on sb itself: sb..write('foo')..write('bar').)

  // ── INCORRECT USAGE: compile error (.. on nullable without ?..) ─────────
  //     EmailDraft? d;
  //     d..to = 'x@egand.dev';
  //
  //     Error: "The method '' can't be unconditionally accessed because the
  //     receiver can be 'null'." (Use ?.. on the first operation.)

  // ── INCORRECT USAGE: logical error (expecting the last call's result) ───
  // A cascade yields the RECEIVER, never the last cascaded call's return value:
  //
  //   final n = (<int>[]..add(1)..add(2)); // n is the List, not 2 (add's result)
  //
  // To capture a call's result, do not cascade that call: use a plain chain.
}
