import 'package:flutter/material.dart';

import 'craft_outline.dart';
import 'craft_stitch.dart';
import 'material_textures.dart';

/// Visual roles, independent of application content and layout.
enum CraftRole {
  /// A primary sheet behind native content.
  sheet,

  /// A smaller grouped surface.
  card,

  /// A label-shaped surface.
  tag,

  /// A narrow decorative strip.
  ribbon,

  /// A surface grouping other pieces.
  tray,

  /// A native action's background.
  button,

  /// An unselected native choice's background.
  choice,

  /// A selected native choice's background.
  selectedChoice,
}

/// Bounded contour-following thread for material components.
///
/// Components use pitch 8..48 and depth 1..8. Lower-level painters retain their
/// wider independent budgets. The inset is the seam center's distance, 0..64.
@immutable
final class CraftSeam {
  /// Creates an explicit host-colored seam.
  CraftSeam({
    required this.color,
    this.kind = CraftStitchKind.running,
    this.inset = 10,
    this.pitch = 12,
    this.depth = 4,
    this.side = 1,
    this.width = 1.5,
    this.compression = .6,
  }) {
    if (![inset, pitch, depth, width, compression].every((v) => v.isFinite) ||
        inset < 0 ||
        inset > 64 ||
        pitch < 8 ||
        pitch > 48 ||
        depth < 1 ||
        depth > 8 ||
        (side != 1 && side != -1) ||
        width < .5 ||
        width > 4 ||
        compression < 0 ||
        compression > 1) {
      throw ArgumentError('Invalid bounded component seam');
    }
  }

  /// Host-supplied thread color.
  final Color color;

  /// Existing thread family.
  final CraftStitchKind kind;

  /// Nominal seam-center distance from the cut.
  final double inset;

  /// Nominal spacing, 8..48.
  final double pitch;

  /// Transverse reach, 1..8.
  final double depth;

  /// Explicit transverse orientation, 1 or -1.
  final int side;

  /// Thread width, .5..4.
  final double width;

  /// Puncture shading, 0..1.
  final double compression;

  @override
  bool operator ==(Object other) =>
      other is CraftSeam &&
      other.color == color &&
      other.kind == kind &&
      other.inset == inset &&
      other.pitch == pitch &&
      other.depth == depth &&
      other.side == side &&
      other.width == width &&
      other.compression == compression;
  @override
  int get hashCode =>
      Object.hash(color, kind, inset, pitch, depth, side, width, compression);
}

/// Material, cut, thread and padding; fonts and content remain native.
@immutable
final class CraftPanelStyle {
  /// Creates a host-owned material recipe with no bundled palette.
  CraftPanelStyle({
    required this.material,
    required this.color,
    this.shape = const CraftOutline.roundedRectangle(radius: 12),
    this.seed = 7,
    this.scale = 1,
    this.strength = 1,
    this.padding = const EdgeInsets.all(20),
    this.seam,
  }) {
    if (!scale.isFinite ||
        scale < .5 ||
        scale > 4 ||
        !strength.isFinite ||
        strength < 0 ||
        strength > 1 ||
        !padding.isNonNegative) {
      throw ArgumentError('Invalid material scale, grain or padding');
    }
    for (final direction in TextDirection.values) {
      final edges = padding.resolve(direction);
      if (![
        edges.left,
        edges.top,
        edges.right,
        edges.bottom,
      ].every((v) => v.isFinite && v >= 0)) {
        throw ArgumentError('Expected finite nonnegative content padding');
      }
    }
    // Validate the value recipe independently of actual content size/budgets.
    shape.pathFor(Size.zero);
  }

  /// Existing substrate algorithm.
  final CraftMaterial material;

  /// Host-supplied base fill.
  final Color color;

  /// Value-based decorative cut; it does not clip native content or input.
  final CraftOutline shape;

  /// Explicit texture and grain seed.
  final int seed;

  /// Texture scale, .5..4.
  final double scale;

  /// Grain strength, 0..1.
  final double strength;

  /// Content spacing, resolved in the host direction.
  final EdgeInsetsGeometry padding;

  /// Optional thread following an inset of the same cut.
  final CraftSeam? seam;

  @override
  bool operator ==(Object other) =>
      other is CraftPanelStyle &&
      other.material == material &&
      other.color == color &&
      other.shape == shape &&
      other.seed == seed &&
      other.scale == scale &&
      other.strength == strength &&
      other.padding == padding &&
      other.seam == seam;
  @override
  int get hashCode =>
      Object.hash(material, color, shape, seed, scale, strength, padding, seam);
}

/// Host-owned material vocabulary installed in [ThemeData.extensions].
///
/// Unspecified roles use [surface]. This extension owns no application colors,
/// fonts, state or clock. Material/cut/seed/thread recipes switch discretely at
/// the midpoint of a theme transition; fill and padding interpolate natively.
@immutable
final class CraftTheme extends ThemeExtension<CraftTheme> {
  /// Copies [roles] so callers cannot mutate an installed theme.
  CraftTheme({
    required this.surface,
    Map<CraftRole, CraftPanelStyle> roles = const {},
  }) : roles = Map.unmodifiable(roles);

  /// Fallback style for every unspecified role.
  final CraftPanelStyle surface;

  /// Immutable overrides for semantic visual roles.
  final Map<CraftRole, CraftPanelStyle> roles;

  /// Resolves a role without introducing an application palette.
  CraftPanelStyle styleFor(CraftRole role) => roles[role] ?? surface;

  /// Finds an installed theme, or reports how to supply one.
  static CraftTheme of(BuildContext context) =>
      Theme.of(context).extension<CraftTheme>() ??
      (throw FlutterError(
        'Install CraftTheme in ThemeData.extensions or supply an explicit component style.',
      ));

  @override
  CraftTheme copyWith({
    CraftPanelStyle? surface,
    Map<CraftRole, CraftPanelStyle>? roles,
  }) =>
      CraftTheme(surface: surface ?? this.surface, roles: roles ?? this.roles);

  @override
  CraftTheme lerp(covariant CraftTheme? other, double t) {
    if (other == null || t <= 0) return this;
    if (t >= 1) return other;
    CraftPanelStyle mix(CraftPanelStyle a, CraftPanelStyle b) {
      final recipe = t < .5 ? a : b;
      return CraftPanelStyle(
        material: recipe.material,
        color: Color.lerp(a.color, b.color, t)!,
        shape: recipe.shape,
        seed: recipe.seed,
        scale: recipe.scale,
        strength: recipe.strength,
        seam: recipe.seam,
        padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t)!,
      );
    }

    return CraftTheme(
      surface: mix(surface, other.surface),
      roles: {
        for (final role in {...roles.keys, ...other.roles.keys})
          role: mix(styleFor(role), other.styleFor(role)),
      },
    );
  }
}
