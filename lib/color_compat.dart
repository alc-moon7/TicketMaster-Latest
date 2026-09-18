import 'dart:ui' show Color;

extension ColorAlphaCompat on Color {
  // Backwards-compatible shim for older Flutter SDKs that do not expose
  // Color.withValues(alpha: ...).
  Color withValues({double? alpha}) {
    if (alpha == null) {
      return this;
    }
    return withValues(alpha: alpha);
  }
}
