# 01 — Variables

A self-contained reference lab for Dart variables, derived from the official
documentation at <https://dart.dev/language/variables> and the type guidance in
<https://dart.dev/effective-dart/design#types>. Every `.dart` file is standalone
and runs on its own with no dependency on any other file in this folder.

## Minimum Dart SDK

`3.7.0`. The only feature in this folder gated on a specific language version is
the wildcard variable (`_`), which requires language version 3.7. Every other
construct here predates that. The reference content reflects Dart `3.12.2`, the
documentation's stated version at the time of writing.

## How to run

Run any reference file or exercise directly:

```
dart run 01_declaration_and_references.dart
dart run exercises/exercise_01.dart
```

Each file's `main()` produces observable output, and every `print()` in the
reference files carries a comment showing its exact output, so the behaviour can
be verified by reading alone.

## Reference files

| File | Sub-concept |
| --- | --- |
| `01_declaration_and_references.dart` | Variable declaration, type inference, and reference (not value) semantics |
| `02_type_annotations_and_inference.dart` | Explicit annotations vs `var`, and the `Object` / `Object?` / `dynamic` distinction |
| `03_scope_and_shadowing.dart` | Lexical scope, block scope, shadowing, and closure capture |
| `04_nullable_and_non_nullable.dart` | Sound null safety: nullable (`?`) vs non-nullable types and the null-dereference rule |
| `05_default_values_and_flow_analysis.dart` | Null defaults for nullable variables and definite-assignment flow analysis for non-nullable ones |
| `06_late_variables.dart` | The `late` modifier: deferred initialisation and lazy initialisation |
| `07_final.dart` | `final` single-assignment bindings and the collection-mutation trap |
| `08_const.dart` | Compile-time constants, `static const`, const values, const constructors, canonicalisation, and deep immutability |
| `09_late_final.dart` | The `late final` combination and the public-setter caveat |
| `10_toplevel_static_lazy_init.dart` | Lazy initialisation of top-level and static variables |
| `11_wildcard_variables.dart` | Non-binding `_` placeholders (language version 3.7+) |

## Exercises

The `exercises/` folder holds one file per reference file plus a combined file.
Each exercise file contains three problems in ascending difficulty: an isolated
concept check, an applied-usage problem, and a problem that combines the file's
concept with an earlier one. Problem statements and marking criteria are written
as comments; a worked solution is commented out beneath each problem.

| File | Covers |
| --- | --- |
| `exercises/exercise_01.dart` | Declaration and references |
| `exercises/exercise_02.dart` | Type annotations and inference |
| `exercises/exercise_03.dart` | Scope and shadowing |
| `exercises/exercise_04.dart` | Nullable and non-nullable types |
| `exercises/exercise_05.dart` | Default values and flow analysis |
| `exercises/exercise_06.dart` | `late` variables |
| `exercises/exercise_07.dart` | `final` |
| `exercises/exercise_08.dart` | `const` |
| `exercises/exercise_09.dart` | `late final` |
| `exercises/exercise_10.dart` | Top-level and static lazy initialisation |
| `exercises/exercise_11.dart` | Wildcard variables |
| `exercises/exercise_12_combined.dart` | All sub-concepts, three problems of increasing complexity |

## Reading order

The files are numbered in dependency order. Read them in sequence: each builds on
the constructs established before it. Null-aware operators (`?.`, `??`, `??=`,
`!`) are referenced where null safety requires them but are defined in the
Operators topic, not here.
