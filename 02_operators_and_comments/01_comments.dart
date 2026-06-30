// ═══════════════════════════════════════════════════════════════════════════
// 01 – COMMENTS
// ═══════════════════════════════════════════════════════════════════════════
//
// WHAT THIS IS AND THE PROBLEM IT SOLVES
// ---------------------------------------------------------------------------
// A comment is text in a source file that the Dart compiler discards before it
// produces any executable code. It exists for human readers, not the machine.
// The problem it solves is that source code records *what* a program does but
// rarely *why* it does it that way. A price-rounding rule, a workaround for a
// hardware quirk on an IoT board, a deliberate choice not to cache a value:
// none of these survive in the bare syntax. Comments carry that intent forward
// to the next reader, who is usually your future self with the context already
// evaporated.
//
// Dart has three comment forms, and they are not interchangeable:
//
//   //   single-line comment      ignored by the compiler
//   /* */ multi-line comment      ignored by the compiler, may nest
//   ///  documentation comment    ignored by the compiler, READ by `dart doc`
//   /** */ documentation comment  same role as ///, but discouraged
//
// The distinction that matters in practice: `//` and `/* */` are private notes
// that vanish entirely once code is compiled and once docs are generated. `///`
// is structured output. The `dart doc` tool harvests every `///` comment that
// sits directly above a declaration and turns it into the public API reference
// you read on api.dart.dev. So the choice of `//` versus `///` is a choice
// about audience: a `//` note speaks to whoever opens this file; a `///` note
// speaks to everyone who ever calls this code without opening the file.
//
// EXACT SYNTAX FOR EVERY VALID FORM
// ---------------------------------------------------------------------------
//   // anything until end of line
//
//   /* anything, including
//      newlines, until the closing */ */
//
//   /* outer /* inner */ still inside outer */   // nesting is legal in Dart
//
//   /// A doc comment line. Consecutive /// lines form one doc comment.
//   /// A second line of the same doc comment.
//
//   /** JavaDoc-style doc comment. Valid, but the linter flags it. */
//
//   /// Refers to [identifier] resolved in the lexical scope of the
//   /// documented declaration.
//
// WHAT THE COMPILER DOES
// ---------------------------------------------------------------------------
// The lexer (the first stage of the front end) strips all three comment forms
// before the parser ever sees a token. Comments produce no bytecode, no kernel
// AST node, and occupy no space in the compiled output. There is no runtime
// cost to a comment because there is no runtime representation of a comment.
//
// `///` and `/** */` comments are a special case for one specific tool. The
// compiler still discards them for the purpose of producing a program, but the
// analyzer retains them so that `dart doc` can read them and so that your IDE
// can show them on hover. The analyzer also parses the bracketed references
// inside a doc comment and resolves each `[name]` against the lexical scope of
// the declaration the comment documents. If a bracketed name does not resolve,
// the `comment_references` lint reports it; the program still compiles.
//
// WHAT THE RUNTIME DOES
// ---------------------------------------------------------------------------
// Nothing. A comment has no object, no allocation, no lifecycle. This is worth
// stating plainly because developers arriving from languages with reflection
// sometimes assume doc comments are queryable at runtime. In Dart they are not.
// A `///` comment is available to `dart doc` and the analyzer at static-analysis
// time only. At runtime the string does not exist anywhere in the program.
//
// EDGE CASES THE DOCUMENTATION MENTIONS
// ---------------------------------------------------------------------------
//  - Multi-line comments nest. `/* a /* b */ c */` is one complete comment.
//    Most C-family languages do NOT allow this; Dart does.
//  - A doc comment may be written either as a run of `///` lines or as a single
//    `/** ... */` block. The two are equivalent in meaning to `dart doc`.
//  - Inside a doc comment, all prose is ignored by the analyzer except text in
//    square brackets, which is treated as a reference to a program element.
//
// EDGE CASES THE DOCUMENTATION OMITS (you WILL hit these)
// ---------------------------------------------------------------------------
//  - A `///` comment only becomes documentation when it sits immediately above
//    a declaration (class, method, field, top-level function, variable, or a
//    library/import directive). A `///` line floating inside a function body is
//    a syntactically valid comment but documents nothing and is dropped.
//  - `dart doc` attaches a stray doc comment to whatever declaration follows it.
//    A file-header `/** copyright */` block placed above the first `import`
//    becomes a doc comment on that import, which is why the analyzer emits
//    `slash_for_doc_comments` there. Add a blank line and use `//` for headers.
//  - Angle brackets inside a doc comment are interpreted as HTML by the doc
//    generator. `/// A List<int>.` renders as an invisible tag and the `<int>`
//    disappears from the output. The `unintended_html_in_doc_comment` lint
//    (Dart 3.5 and later) flags this. Escape it as `` [List<int>] `` in a code
//    span, or write `List&lt;int&gt;`.
//  - `//` inside a string literal is NOT a comment. `'https://egand.dev'` keeps
//    its `//` because the lexer is inside a string, not scanning for comments.
//  - There is no documentation-comment form built on `//`. Three slashes are
//    required; `////` (four or more) is treated as an ordinary `//` comment,
//    not a doc comment.
//
// PERFORMANCE IMPLICATIONS
// ---------------------------------------------------------------------------
// None at runtime, as established above. The only measurable cost is to tooling:
// extremely large doc comments slow `dart doc` generation marginally and inflate
// the analyzer's in-memory model. Neither is a concern at any realistic scale.
//
// THE LANGUAGE DESIGN DECISION
// ---------------------------------------------------------------------------
// Dart inherited `//` and `/* */` from the C family for familiarity. The choice
// that is genuinely Dart's own is `///` as the canonical doc-comment form. Java
// uses `/** */`; Dart supports it for migration but the team standardised on
// `///` because, per Effective Dart, `/**` and `*/` add two content-free lines
// to every block and `///` reads better when a comment contains a Markdown
// bullet list that itself uses `*`. Allowing nested `/* */` is the second
// deliberate choice: it means you can comment out a region of code that already
// contains a block comment without the inner `*/` prematurely closing the outer
// block. C and Java do not allow this and the omission is a frequent source of
// "why is half my file uncommented" confusion that Dart sidesteps.
//
// HOW THIS INTERACTS WITH OTHER CONSTRUCTS IN THIS TOPIC
// ---------------------------------------------------------------------------
// Every other file in this topic relies on comments to annotate operator
// behaviour and to show expected output beside each `print`. The doc-comment
// reference syntax `[name]` will reappear once you document classes that
// override operators such as `==` and `+`; a well-documented operator override
// uses `///` to explain the equivalence relation it implements.
//
// WHAT FAILURE LOOKS LIKE
// ---------------------------------------------------------------------------
// Comments rarely cause compile errors because they are removed early, but two
// failure modes exist:
//
//  1. Unterminated block comment – a `/*` with no matching `*/`. The lexer
//     consumes the rest of the file as comment text and the parser then sees an
//     empty or truncated program.
//     Analyzer message: "Unterminated multi-line comment."
//
//  2. Misplaced doc comment / wrong syntax – using `/** */` where `///` is
//     preferred, or `//` where `///` is needed for an API you intend to
//     document.
//     Analyzer (lint) message: "Prefer using /// for doc comments."
//
// Logical failure is the quiet one: a comment that lies. A comment describing
// behaviour the code no longer has is worse than no comment, because the reader
// trusts it. The compiler cannot catch this. Only discipline can.
// ═══════════════════════════════════════════════════════════════════════════

/// A single charge attempt against a customer's saved payment method.
///
/// A [PaymentAttempt] is immutable once created. To retry a declined charge,
/// build a new attempt from [retryOf] rather than mutating an existing one.
/// The [amountMinor] is stored in the currency's minor unit (kobo for NGN,
/// cents for USD) to avoid floating-point rounding on money. See [settle]
/// for how an attempt transitions to a settled state.
class PaymentAttempt {
  /// The charge amount in the currency's minor unit. Never negative.
  final int amountMinor;

  /// ISO 4217 currency code, for example `'NGN'` or `'USD'`.
  final String currencyCode;

  PaymentAttempt(this.amountMinor, this.currencyCode);

  /// Settles this attempt and returns a human-readable receipt line.
  ///
  /// Throws nothing; a settled attempt is always representable. The returned
  /// string includes the [currencyCode] and the major-unit amount derived from
  /// [amountMinor].
  String settle() {
    final majorUnits = amountMinor / 100;
    return '$currencyCode $majorUnits settled';
  }
}

void main() {
  // ── Single-line comments ────────────────────────────────────────────────
  // A single-line comment runs from // to the end of the line. Use it for
  // notes that sit beside or above one or two statements.
  final cartTotalMinor = 4599; // 45.99 in major units; stored as minor units
  print(cartTotalMinor); // 4599

  // A single-line comment may also occupy a whole line on its own, which is
  // the usual way to explain the line that follows it.
  // Convert minor units to a display string in the major unit.
  final cartTotalDisplay = cartTotalMinor / 100;
  print(cartTotalDisplay); // 45.99

  // The // inside a string is NOT a comment; it is data.
  final apiBaseUrl = 'https://api.egand.dev/v1';
  print(apiBaseUrl); // https://api.egand.dev/v1

  // ── Multi-line comments ─────────────────────────────────────────────────
  /*
    A multi-line comment spans from the opening slash-star to the closing
    star-slash. It is the right tool for a longer explanation or for
    temporarily disabling a block of code during debugging.
  */
  final sensorReadingCelsius = 23.4;
  print(sensorReadingCelsius); // 23.4

  // Multi-line comments NEST in Dart. The inner block does not end the outer
  // one. This is how you comment out code that already contains a block
  // comment without the inner */ closing the region early.
  /*
    final reading = readThermocouple();
    /* legacy calibration, kept for reference */
    applyCalibration(reading);
  */
  // The line above is fully disabled; nothing between the outer /* */ ran.

  // ── Documentation comments ──────────────────────────────────────────────
  // The PaymentAttempt class above is documented with /// comments. Those are
  // invisible at runtime but are read by `dart doc` and shown on IDE hover.
  // Here the class simply behaves like any other; the docs do not change it.
  final attempt = PaymentAttempt(4599, 'NGN');
  print(attempt.settle()); // NGN 45.99 settled

  // A /// line that floats inside a function body documents nothing, because
  // no declaration follows it. It is a legal comment and is silently dropped.
  /// This line documents no declaration and produces no output.
  print('doc-comment-with-no-target had no effect'); // doc-comment-with-no-target had no effect

  // ── INCORRECT USAGE: compile / analyzer errors ──────────────────────────
  // Each block below is intentionally disabled. Uncommenting it reproduces the
  // stated diagnostic.

  // (a) Unterminated block comment. The lexer would read the rest of the file
  //     as comment text.
  //
  //     /* this comment is never closed
  //     print('unreachable');
  //
  //     Analyzer error: "Unterminated multi-line comment."

  // (b) JavaDoc-style doc comment where /// is preferred. This compiles and
  //     runs, but the linter reports it under a default Dart lint set.
  //
  //     /** Charges the customer once. */
  //     void chargeOnce() {}
  //
  //     Analyzer (lint) message: "Prefer using /// for doc comments."

  // ── INCORRECT USAGE: logical error ──────────────────────────────────────
  // The comment below claims the value is a percentage. It is not; it is a
  // minor-unit amount. The compiler cannot detect the lie. A reader who trusts
  // the comment divides by the wrong factor downstream. This is the most
  // dangerous comment failure precisely because nothing flags it.
  //
  //   // discountRate as a percentage from 0 to 100
  //   final discountRate = 1500; // actually minor units, not a percentage
  //
  // The fix is to make the comment true or delete it.
}
