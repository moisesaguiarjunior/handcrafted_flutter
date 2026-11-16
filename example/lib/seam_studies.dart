import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';
import 'showcase_theme.dart';
import 'prepared_outline.dart';

/// Example-local one-size geometry cache shared by the runnable seam studies.
class PreparedSeamGeometry {
  /// Retains one outline and offset until effective size changes.
  PreparedSeamGeometry(this.makeOutline, this.inset)
    : _source = PreparedOutlineGeometry(makeOutline);

  /// Stable caller-supplied silhouette builder.
  final Path Function(Size) makeOutline;

  /// Requested seam-center offset.
  final double inset;
  Size? _size;
  final PreparedOutlineGeometry _source;
  Path _seam = Path();

  /// Returns the cached silhouette; consumers must not mutate it.
  Path outlineFor(Size size) => _source.pathFor(size);

  /// Returns the offset derived from that same silhouette and effective size.
  Path seamFor(Size size) {
    if (_size != size) {
      final outline = _source.pathFor(size);
      final seam = insetCraftPath(outline, distance: inset);
      _seam = seam;
      _size = size;
    }
    return _seam;
  }
}

/// Example composition sharing one prepared silhouette between fill and seam.
class SeamedSurface extends StatefulWidget {
  /// Keeps text/actions native; the host reserves content padding.
  const SeamedSurface({
    super.key,
    required this.shape,
    required this.material,
    required this.color,
    required this.child,
    this.inset = 12,
    this.seed = 7,
    this.showSeam = true,
  });

  /// Value recipe for the material and seam.
  final CraftOutline shape;

  /// Substrate algorithm.
  final CraftMaterial material;

  /// Substrate color.
  final Color color;

  /// Real layout and controls, not painted text.
  final Widget child;

  /// Seam-center clearance in logical pixels.
  final double inset;

  /// Texture seed; does not change the supplied shape recipe.
  final int seed;

  /// Lets enlarged native content keep the surface while omitting decoration.
  final bool showSeam;
  @override
  State<SeamedSurface> createState() => _SeamedSurfaceState();
}

class _SeamedSurfaceState extends State<SeamedSurface> {
  late PreparedSeamGeometry _geometry = PreparedSeamGeometry(
    widget.shape.pathFor,
    widget.inset,
  );
  @override
  void didUpdateWidget(SeamedSurface old) {
    super.didUpdateWidget(old);
    if (widget.shape != old.shape || widget.inset != old.inset) {
      _geometry = PreparedSeamGeometry(widget.shape.pathFor, widget.inset);
    }
  }

  @override
  Widget build(BuildContext context) => CraftSurface(
    material: widget.material,
    color: widget.color,
    seed: widget.seed,
    outline: _geometry.outlineFor,
    child: CustomPaint(
      foregroundPainter: widget.showSeam ? _SeamPainter(_geometry) : null,
      child: widget.child,
    ),
  );
}

class _SeamPainter extends CustomPainter {
  const _SeamPainter(this.geometry);
  final PreparedSeamGeometry geometry;
  @override
  void paint(Canvas canvas, Size size) {
    final outline = geometry.outlineFor(size), seam = geometry.seamFor(size);
    canvas.save();
    try {
      canvas.clipPath(outline);
      paintRunningStitch(
        canvas,
        seam,
        thread: DemoPalette.thread,
        dash: 5,
        gap: 4,
        width: 1.2,
        compression: .4,
      );
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SeamPainter old) => geometry != old.geometry;
}

enum _Cut { organic, window, bridge }

Path Function(Size) _cutOutline(_Cut cut, int seed) => (size) {
  final b = (Offset.zero & size).deflate(10);
  switch (cut) {
    case _Cut.organic:
      return pigmentOutline(b, seed: seed, broad: true);
    case _Cut.window:
      return Path()
        ..fillType = PathFillType.evenOdd
        ..addRRect(RRect.fromRectAndRadius(b, const Radius.circular(25)))
        ..addOval(
          Rect.fromCenter(
            center: b.center,
            width: b.width * .35,
            height: b.height * .4,
          ),
        );
    case _Cut.bridge:
      final x1 = b.left + b.width * .37, x2 = b.left + b.width * .63;
      return Path()
        ..moveTo(b.left, b.top)
        ..lineTo(x1, b.top)
        ..lineTo(x1, b.center.dy - 4)
        ..lineTo(x2, b.center.dy - 4)
        ..lineTo(x2, b.top)
        ..lineTo(b.right, b.top)
        ..lineTo(b.right, b.bottom)
        ..lineTo(x2, b.bottom)
        ..lineTo(x2, b.center.dy + 4)
        ..lineTo(x1, b.center.dy + 4)
        ..lineTo(x1, b.bottom)
        ..lineTo(b.left, b.bottom)
        ..close();
  }
};

/// Organic, cutout and collapsing-neck specimens using the real inset API.
class SeamStudiesSheet extends StatelessWidget {
  /// Creates deterministic plates at a chosen seam-center distance.
  const SeamStudiesSheet({super.key, this.inset = 10, this.seed = 23});

  /// Centerline inset; thread/puncture clearance is already reserved by the UI.
  final double inset;

  /// Organic cut and texture seed.
  final int seed;
  @override
  Widget build(BuildContext context) => SpecimenRow(
    children: [
      for (final cut in _Cut.values)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: AspectRatio(
                  aspectRatio: 1.45,
                  child: _SeamPlate(cut: cut, inset: inset, seed: seed),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              switch (cut) {
                _Cut.organic => 'Follow the cut',
                _Cut.window => 'Respect the opening',
                _Cut.bridge => 'Let the neck disappear',
              },
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(switch (cut) {
              _Cut.organic => 'One silhouette for paper and thread.',
              _Cut.window => 'The hole grows while the outer seam recedes.',
              _Cut.bridge => 'Two closed seams, without an artificial bridge.',
            }, style: const TextStyle(fontFamily: 'Inter')),
          ],
        ),
    ],
  );
}

class _SeamPlate extends StatefulWidget {
  const _SeamPlate({
    required this.cut,
    required this.inset,
    required this.seed,
  });
  final _Cut cut;
  final double inset;
  final int seed;
  @override
  State<_SeamPlate> createState() => _SeamPlateState();
}

class _SeamPlateState extends State<_SeamPlate> {
  late MaterialTextures _textures = MaterialTextures(seed: widget.seed);
  late PreparedSeamGeometry _geometry = PreparedSeamGeometry(
    _cutOutline(widget.cut, widget.seed),
    widget.inset,
  );
  @override
  void didUpdateWidget(_SeamPlate old) {
    super.didUpdateWidget(old);
    if (widget.cut != old.cut ||
        widget.seed != old.seed ||
        widget.inset != old.inset) {
      _geometry = PreparedSeamGeometry(
        _cutOutline(widget.cut, widget.seed),
        widget.inset,
      );
    }
    if (widget.seed != old.seed) {
      _textures.dispose();
      _textures = MaterialTextures(seed: widget.seed);
    }
  }

  @override
  void dispose() {
    _textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PlatePainter(_geometry, _textures, widget.cut));
}

class _PlatePainter extends CustomPainter {
  const _PlatePainter(this.geometry, this.textures, this.cut);
  final PreparedSeamGeometry geometry;
  final MaterialTextures textures;
  final _Cut cut;
  @override
  void paint(Canvas canvas, Size size) {
    final outline = geometry.outlineFor(size);
    canvas.drawShadow(outline, const Color(0x33000000), 3, false);
    textures.paint(
      canvas,
      outline,
      material: cut == _Cut.organic ? CraftMaterial.paper : CraftMaterial.felt,
      color: cut == _Cut.window
          ? DemoPalette.sage
          : cut == _Cut.bridge
          ? DemoPalette.rose
          : DemoPalette.paper,
    );
    _SeamPainter(geometry).paint(canvas, size);
  }

  @override
  bool shouldRepaint(_PlatePainter old) =>
      geometry != old.geometry || textures != old.textures || cut != old.cut;
}

/// Native controls for inspecting seam distance and seeded silhouettes.
class SeamPlayground extends StatefulWidget {
  /// Creates the quiet interactive specimen sheet.
  const SeamPlayground({super.key});
  @override
  State<SeamPlayground> createState() => _SeamPlaygroundState();
}

class _SeamPlaygroundState extends State<SeamPlayground> {
  double _inset = 10;
  int _seed = 23;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Seams that follow the cut',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 44),
      ),
      const Text(
        'Concavities, holes and narrow regions. One closed silhouette, receding thread.',
      ),
      Text('Seam inset ${_inset.toStringAsFixed(1)} logical pixels'),
      Slider(
        key: const ValueKey('seam-inset'),
        value: _inset,
        min: 6,
        max: 20,
        onChanged: (v) => setState(() => _inset = v),
      ),
      TextButton(
        onPressed: () => setState(() => _seed++),
        child: const Text('Change cut seed'),
      ),
      SeamStudiesSheet(inset: _inset, seed: _seed),
      const SizedBox(height: 20),
      const Text(
        'Curves use bounded polygonal approximation. Thread and puncture clearance '
        'are reserved, and final ink clips to the original substrate. No clock is created.',
      ),
    ],
  );
}
