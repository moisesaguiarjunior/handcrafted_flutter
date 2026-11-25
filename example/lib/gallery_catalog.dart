/// Hosted gallery destinations; only the visible study is mounted.
enum GalleryStudy {
  /// Opening compositions and sculpted motifs.
  cover,

  /// Three substrates under a draggable world-space lamp.
  light,

  /// Contact transfer and articulated textile recipes.
  contact,

  /// Two-sided cloth, soft articulation, one gust and two paper hinges.
  gestures,

  /// Every material texture family.
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

  /// Cut EVA with independent grain, finish and raised edges.
  foam,

  /// Original stuffed silhouettes with independent fabric and filling.
  pillows,

  /// Soft pockets, recessed thread, chalk and satin folded paper.
  softCraft,

  /// Independent long fibers over any substrate or padded cut.
  fluffy,

  /// Controlled local-light and thin/rounded surface proofs.
  volume,
}

/// Human-readable study title.
String galleryLabel(GalleryStudy study) => switch (study) {
  GalleryStudy.contact => 'Contact & cloth',
  GalleryStudy.gestures => 'Material gestures',
  GalleryStudy.vocabulary => 'Material vocabulary',
  GalleryStudy.experience => 'Experience frame',
  GalleryStudy.cover => 'Start exploring',
  GalleryStudy.foam => 'EVA foam & layers',
  GalleryStudy.softCraft => 'Cloth, chalk & folds',
  GalleryStudy.pillows => 'Stuffed shapes',
  GalleryStudy.fluffy => 'Fluffy finishes',
  GalleryStudy.volume => 'Local light & volume',
  GalleryStudy.light => 'Light studio',
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
  GalleryStudy.gestures =>
    'Follow lining, contact, wind and folds through one finite gesture.',
  GalleryStudy.contact =>
    'Pass a sheet between hands, then release an articulated textile.',
  GalleryStudy.vocabulary =>
    'Change material themes while keeping native text, focus and selection.',
  GalleryStudy.experience =>
    'Fit artwork independently; keep words, touch targets and footer native.',
  GalleryStudy.cover =>
    'Explore materials, marks and movement. Choose a study to try its controls.',
  GalleryStudy.light =>
    'Move one lamp over clay, EVA and paper; turn a piece under the same light.',
  GalleryStudy.volume =>
    'Compare local volume before sharing light across a scene.',
  GalleryStudy.fluffy =>
    'Try longer, curled fibers and a soft fringe on any material.',
  GalleryStudy.pillows =>
    'Compare cotton, felt and short matte pile, then vary visual filling.',
  GalleryStudy.softCraft =>
    'Try soft cloth, irregular sewing, chalk and folded paper.',
  GalleryStudy.foam =>
    'Compare fine-pore foam, surface impressions and raised cuts.',
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
  GalleryStudy.light,
  GalleryStudy.contact,
  GalleryStudy.gestures,
  GalleryStudy.vocabulary,
  GalleryStudy.experience,
  GalleryStudy.spreading,
  GalleryStudy.watercolor,
  GalleryStudy.ink,
  GalleryStudy.paper,
  GalleryStudy.foam,
  GalleryStudy.pillows,
  GalleryStudy.fluffy,
  GalleryStudy.softCraft,
  GalleryStudy.volume,
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
