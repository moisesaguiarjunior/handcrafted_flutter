import 'package:flutter/material.dart';

import 'cover_studies.dart';
import 'showcase_theme.dart';

void main() => runApp(
  MaterialApp(
    theme: showcaseTheme(),
    home: const Scaffold(body: SafeArea(child: CoverGallery())),
  ),
);
