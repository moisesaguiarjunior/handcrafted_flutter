import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/main_gallery.dart';
import 'package:handcrafted_example/foam_sewing_studies.dart';

void main() {
  testWidgets(
    'foam adjustments expose purpose and units on the actual slider node',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const HandcraftedGalleryApp(initialStudy: GalleryStudy.foam),
        );
        await tester.pumpAndSettle();
        for (final item in [
          ('foam-depth', 'Raised edge', 'logical pixels'),
          ('foam-strength', 'Finish contrast', 'percent'),
        ]) {
          final finder = find.byKey(ValueKey(item.$1));
          SemanticsData control() {
            final matches = <SemanticsData>[];
            void visit(SemanticsNode node) {
              final data = node.getSemanticsData();
              if (!node.isMergedIntoParent &&
                  data.hasAction(SemanticsAction.increase)) {
                matches.add(data);
              }
              node.visitChildren((child) {
                visit(child);
                return true;
              });
            }

            visit(
              tester.getSemantics(
                find
                    .ancestor(of: finder, matching: find.byType(MergeSemantics))
                    .first,
              ),
            );
            expect(matches, hasLength(1));
            return matches.single;
          }

          await tester.ensureVisible(finder);
          final before = control();
          final beforeArt = tester.widget<FoamSewingStudies>(
            find.byType(FoamSewingStudies),
          );
          await tester.drag(finder, const Offset(40, 0));
          await tester.pumpAndSettle();
          final after = control();
          final afterArt = tester.widget<FoamSewingStudies>(
            find.byType(FoamSewingStudies),
          );
          expect(
            item.$1 == 'foam-depth' ? afterArt.depth : afterArt.strength,
            isNot(
              item.$1 == 'foam-depth' ? beforeArt.depth : beforeArt.strength,
            ),
          );
          expect(after.label, item.$2);
          expect(after.value, contains(item.$3));
          expect(after.value, isNot(before.value));
          expect(tester.takeException(), isNull);
        }
      } finally {
        handle.dispose();
      }
    },
  );
}
