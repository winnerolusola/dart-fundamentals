// =============================================================================
// EXERCISE 04 — NULLABLE AND NON-NULLABLE TYPES (SOUND NULL SAFETY)
// Run: dart run exercise_04.dart
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // 4.1 ISOLATED CONCEPT CHECK
  // Declare a non-nullable article title and a nullable article subtitle (left
  // unset). Print the title's length and print the subtitle (which is null).
  // MARKER CRITERIA: title is String (non-nullable) and used directly; subtitle
  // is String? with no initialiser; subtitle prints as null with no error.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 4.2 APPLIED USAGE
  // Given a nullable String? slug that you then assign 'edge-caching', print its
  // length ONLY after proving it is non-null with an explicit check (promotion).
  // Do not use any null-aware operator (those belong to the Operators topic).
  // MARKER CRITERIA: an `!= null` check that promotes slug to String; length
  // accessed only inside the check; output 12.
  // Your solution:


  // ---------------------------------------------------------------------------
  // 4.3 COMBINED WITH 02 (Object?)
  // Declare lastError as Object? set to null, then assign it a String message.
  // Print the message only after an `is String` check that promotes it, and also
  // print its runtimeType inside that block.
  // MARKER CRITERIA: type is Object? (file 02); both null and a String are
  // assignable; `is String` promotes; outputs the message and String.
  // Your solution:


}
