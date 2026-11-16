import 'package:flutter/material.dart';

import 'showcase_theme.dart';
import 'trim_studies.dart';

void main() => runApp(
  MaterialApp(
    theme: showcaseTheme(),
    home: const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: TrimPlayground(),
        ),
      ),
    ),
  ),
);
