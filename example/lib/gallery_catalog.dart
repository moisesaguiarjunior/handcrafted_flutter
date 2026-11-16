/// Hosted gallery destinations; only the visible study is mounted.
enum GalleryStudy {
  /// Opening compositions and sculpted motifs.
  cover,

  /// Five existing material algorithms.
  materials,

  /// Paper stocks, edges and finishes.
  paper,

  /// Six shared-contour thread patterns.
  stitches,

  /// Raised cord, ribbon and thread bands.
  trims,

  /// Layered pigment over supplied shapes.
  watercolor,

  /// Independently authored body/detail poses.
  motion,

  /// Bounded gravity/wind with explicit elapsed time.
  physics,

  /// Curves with ink and dry instrument treatments.
  ink,

  /// Crops, hinges, masks and native actions.
  imported,

  /// Native rotary-control recipe.
  rotary,

  /// Bounded pour, droplets and light recipe.
  effects,

  /// A seeded wet front over original botanical artwork.
  spreading,

  /// Ordered stitches, punctures and a travelling thread tip.
  embroidery,

  /// Host-themed panels and native choices.
  vocabulary,

  /// Independently fitted art and accessible native form/viewport.
  experience,
}

/// Human-readable study title.
String galleryLabel(GalleryStudy study) => switch (study) {
  GalleryStudy.vocabulary => 'Material vocabulary',
  GalleryStudy.experience => 'Experience frame',
  GalleryStudy.cover => 'Start exploring',
  GalleryStudy.materials => 'Materials & relief',
  GalleryStudy.paper => 'Paper & edges',
  GalleryStudy.stitches => 'Stitch families',
  GalleryStudy.trims => 'Cord & ribbon',
  GalleryStudy.watercolor => 'Watercolor',
  GalleryStudy.motion => 'Body, tail & tether',
  GalleryStudy.physics => 'Gravity & wind',
  GalleryStudy.ink => 'Curves & ink',
  GalleryStudy.imported => 'Imported artwork',
  GalleryStudy.rotary => 'Rotary control',
  GalleryStudy.effects => 'Pour & light',
  GalleryStudy.spreading => 'Paint spreading',
  GalleryStudy.embroidery => 'Embroidery in motion',
};

/// A short orientation before interacting with a study.
String galleryDescription(GalleryStudy study) => switch (study) {
  GalleryStudy.vocabulary =>
    'Change material themes while keeping native text, focus and selection.',
  GalleryStudy.experience =>
    'Fit artwork independently; keep words, touch targets and footer native.',
  GalleryStudy.cover => 'Explore materials, marks and movement. Choose a study to try its controls.',
  GalleryStudy.spreading => 'Pigment travels from a wet center into the paper.',
  GalleryStudy.embroidery =>
    'Finish missing stitches, pass a loose strand, or reveal embroidery.',
  GalleryStudy.materials =>
    'Look closely at grain, light and raised or pressed shapes.',
  GalleryStudy.paper =>
    'Compare paper stocks, cuts, fibers and printed content.',
  GalleryStudy.stitches =>
    'Compare six thread patterns following the same cut.',
  GalleryStudy.trims =>
    'Lay cord or ribbon over a texture, or follow its edge.',
  GalleryStudy.watercolor => 'Layer pigment, blooms and botanical silhouettes.',
  GalleryStudy.motion => 'Move the sail, the tail or a slow-drifting balloon.',
  GalleryStudy.physics =>
    'Compare gravity and wind with realistic or cartoon response.',
  GalleryStudy.ink => 'Try six instruments on curved, dashed or dotted paths.',
  GalleryStudy.imported =>
    'Move supplied artwork while keeping its touch regions attached.',
  GalleryStudy.rotary => 'Turn a native control with a wooden face.',
  GalleryStudy.effects => 'Inspect a finite pour, drops and light.',
};

/// Editorial order: pigment and movement are discoverable before technical studies.
const galleryOrder = [
  GalleryStudy.cover,
  GalleryStudy.vocabulary,
  GalleryStudy.experience,
  GalleryStudy.spreading,
  GalleryStudy.watercolor,
  GalleryStudy.ink,
  GalleryStudy.paper,
  GalleryStudy.materials,
  GalleryStudy.embroidery,
  GalleryStudy.motion,
  GalleryStudy.physics,
  GalleryStudy.imported,
  GalleryStudy.rotary,
  GalleryStudy.effects,
  GalleryStudy.stitches,
  GalleryStudy.trims,
];
