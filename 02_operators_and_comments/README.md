# 02 – Operators and Comments

This topic covers every operator in the Dart language together with the three
comment forms, treated as one unit because comments are how you annotate
operator behaviour and because both are prerequisites for everything that
follows. Each concept lives in its own standalone file that you can read and run
on its own. Nothing here depends on a later file, and the order is chosen so
that each file only uses ideas introduced before it.

The reference files are written to serve a complete beginner and a working
engineer from the same text. The header of each file explains what the construct
is and the problem it solves, the exact syntax of every form, what the compiler
does, what the runtime does, the edge cases the official documentation covers,
the edge cases it leaves out that you will still hit in practice, the
performance characteristics, the language design reasoning, how the construct
interacts with the others in this topic, and what failure looks like with the
exact compiler or runtime message. Every `print` is annotated with its expected
output, and every incorrect-usage block carries the precise diagnostic it
produces.

## Reading order

The files are numbered in dependency order. Read them in sequence.

1. `01_comments.dart` – single-line, multi-line, and documentation comments
2. `02_arithmetic_operators.dart` – `+ - * / ~/ %`, unary minus, `++`, `--`
3. `03_equality_relational_operators.dart` – `== != > < >= <=` and `identical`
4. `04_type_test_operators.dart` – `as`, `is`, `is!` and type promotion
5. `05_assignment_operators.dart` – `=`, `??=`, and the compound forms
6. `06_logical_operators.dart` – `! && ||` and short-circuit evaluation
7. `07_bitwise_shift_operators.dart` – `& | ^ ~ << >> >>>`
8. `08_conditional_expressions.dart` – the ternary `?:` and the if-null `??`
9. `09_member_access_operators.dart` – `. ?. ?[] [] ! ()` and null shorting
10. `10_cascade_notation.dart` – `..` and `?..`
11. `11_spread_operators.dart` – `...` and `...?` (collection-literal syntax)
12. `12_operator_precedence.dart` – precedence, associativity, and the traps

## Running the files

Each file is self-contained and runnable. From the topic folder:

```bash
dart run 01_comments.dart
```

The minimum Dart SDK for this topic is 3.7.0, which guarantees the unsigned
shift operator `>>>` and the rest of the syntax used here. The output comments
were written against Dart 3.12.2.

## Exercises and solutions

The `exercises/` folder contains one file per sub-concept plus a combined
exercise that draws on the whole topic. Each exercise file states its tasks in
comments and marks the spots you complete with `// TODO`, and each `print`
carries the expected output so you can check your own work. The exercises hold
no answers.

The `solutions/` folder contains a complete, runnable solution for every
exercise, with the same expected-output annotations. Use them to confirm your
approach after you have attempted the exercise yourself, not before.

```bash
dart run exercises/exercise_02_arithmetic.dart
dart run solutions/solution_02_arithmetic.dart
```

## A note on two Dart-specific surprises

Two behaviours in this topic differ from what you may expect from other
languages, and both are documented in the relevant files. The modulo operator
`%` is Euclidean, so its result is never negative when the divisor is positive:
`-7 % 3` is `2`, not `-1`. The truncating division operator `~/` rounds toward
zero rather than toward negative infinity, and it pairs with `remainder()`, not
with `%`. Read `02_arithmetic_operators.dart` for the full account before
relying on either with negative numbers.
