// ═══════════════════════════════════════════════════════════════════════════
// EXERCISE 01 – COMMENTS
// ───────────────────────────────────────────────────────────────────────────
// Complete each TODO. The file compiles as given; your job is to add and fix
// comments so the documented intent is correct and the doc tooling is happy.
// No solutions here; see solutions/solution_01_comments.dart to check.
// ═══════════════════════════════════════════════════════════════════════════

// ── Problem 1 (isolated): comment forms ─────────────────────────────────────
// TODO 1a: Above `discountedPriceMinor` below, write a SINGLE-LINE comment that
//          explains the value is stored in minor units (kobo), not naira.
// TODO 1b: Replace the WRONG comment style on `taxRateBasisPoints` with the
//          correct single-line form, and make the text true: it is basis
//          points (1/100 of a percent), not a percentage.

final discountedPriceMinor = 3499;

/* taxRateBasisPoints as a percentage */
final taxRateBasisPoints = 750;

// ── Problem 2 (applied): document a public API with /// ──────────────────────
// TODO 2: Write a doc comment for `netPayableMinor` using ///. It must:
//   - start with a one-sentence summary,
//   - refer to [discountedPriceMinor] and [taxRateBasisPoints] in square
//     brackets so the doc tool links them.
int netPayableMinor() {
  final tax = discountedPriceMinor * taxRateBasisPoints ~/ 10000;
  return discountedPriceMinor + tax;
}

// ── Problem 3 (cross-concept): fix a misplaced doc comment ───────────────────
// The doc comment below is intended to document the `Coupon` class, but as
// written it documents nothing useful and would attach to the wrong target if
// an import were added above it.
// TODO 3: Move/convert the comment so it correctly documents the `Coupon`
//          class with ///, and turn the file-header note into a // comment.

/** Egand Lab – coupon model. Internal. */

/// TODO: this line should document Coupon; fix it.
class Coupon {
  final String code;
  final int percentOff;
  const Coupon(this.code, this.percentOff);
}

void main() {
  print(discountedPriceMinor); // expected: 3499
  print(netPayableMinor()); // expected: 3761
  print(Coupon('SAVE10', 10).code); // expected: SAVE10
}
