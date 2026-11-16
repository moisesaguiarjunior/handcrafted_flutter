import 'package:flutter/material.dart';

import 'pendulum_studies.dart';
import 'showcase_theme.dart';

void main() => runApp(
  MaterialApp(
    theme: showcaseTheme(),
    home: const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: PendulumPlayground(),
        ),
      ),
    ),
  ),
);
