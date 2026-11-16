import 'package:flutter/painting.dart';

/// Example-local one-size silhouette cache; the callback must remain stable.
class PreparedOutlineGeometry {
  /// Retains the builder; changing its recipe requires a new geometry owner.
  PreparedOutlineGeometry(this.makeOutline);

  /// Deterministic source builder for the current recipe.
  final Path Function(Size) makeOutline;
  Size? _size;
  Path _path = Path();

  /// Returns a shared path for the effective size; callers must not mutate it.
  Path pathFor(Size size) {
    if (_size != size) {
      _path = makeOutline(size);
      _size = size;
    }
    return _path;
  }
}
