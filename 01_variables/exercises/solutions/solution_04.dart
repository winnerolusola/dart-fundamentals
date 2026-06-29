// =============================================================================
// EXERCISE 04 — NULLABLE AND NON-NULLABLE TYPES (SOUND NULL SAFETY)
// Run: dart run solutions/solution_04.dart
// =============================================================================

void main() {
  {
  // ---------------------------------------------------------------------------
  // 4.1 ISOLATED CONCEPT CHECK
  String articleTitle = 'Edge Caching';
  String? articleSubtitle;
  print(articleTitle.length); // 12
  print(articleSubtitle);     // null

  }

  {
  // ---------------------------------------------------------------------------
  // 4.2 APPLIED USAGE
  String? slug;
  slug = 'edge-caching';
  if (slug != null) {
    print(slug.length); // 12
  }

  }

  // ---------------------------------------------------------------------------
  // 4.3 COMBINED WITH 02 (Object?)
  Object? lastError;
  lastError = 'Checksum mismatch';
  if (lastError is String) {
    print(lastError);             // Checksum mismatch
    print(lastError.runtimeType); // String
  }

}
