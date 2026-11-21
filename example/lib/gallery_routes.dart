import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'gallery_catalog.dart';

/// Native Router integration retains browser history and shareable study URLs.
class GalleryRouteParser extends RouteInformationParser<GalleryStudy> {
  /// Keeps existing query links working at startup.
  const GalleryRouteParser(this.initialStudy);

  /// Startup fallback when the platform route has no study query.
  final GalleryStudy initialStudy;
  @override
  Future<GalleryStudy> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final requested = routeInformation.uri.queryParameters['study'];
    return SynchronousFuture(
      requested == null
          ? initialStudy
          : GalleryStudy.values.firstWhere(
              (s) => s.name == requested,
              orElse: () => GalleryStudy.cover,
            ),
    );
  }

  @override
  RouteInformation restoreRouteInformation(GalleryStudy configuration) =>
      RouteInformation(
        uri: Uri(path: '/', queryParameters: {'study': configuration.name}),
      );
}

/// One mounted study; native Navigator still owns menus and transient routes.
class GalleryRouter extends RouterDelegate<GalleryStudy> with ChangeNotifier {
  /// Creates a native route owner.
  GalleryRouter(this.selected, this.pageBuilder);

  /// Currently mounted study.
  GalleryStudy selected;

  /// Builds the shell for a resolved route.
  final Widget Function(BuildContext, GalleryStudy, ValueChanged<GalleryStudy>)
  pageBuilder;

  /// Navigator for menus and transient routes.
  final navigatorKey = GlobalKey<NavigatorState>();

  /// Visits a study and notifies the native Router.
  void select(GalleryStudy study) {
    if (study == selected) return;
    selected = study;
    notifyListeners();
  }

  @override
  GalleryStudy get currentConfiguration => selected;
  @override
  Future<void> setNewRoutePath(GalleryStudy configuration) async {
    select(configuration);
  }

  @override
  Future<bool> popRoute() async =>
      navigatorKey.currentState?.maybePop() ?? false;
  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    pages: [
      MaterialPage<void>(
        key: const ValueKey('gallery'),
        child: pageBuilder(context, selected, select),
      ),
    ],
    onDidRemovePage: (_) {},
  );
}

/// Shares browser origin/path on the web, the published gallery on native hosts.
Uri galleryShareLink(
  GalleryStudy study, {
  required bool isWeb,
  required Uri base,
}) {
  final origin = isWeb && (base.scheme == 'https' || base.scheme == 'http')
      ? base
      : Uri.parse('https://moisesaguiarjunior.github.io/handcrafted_flutter/');
  return origin
      .replace(queryParameters: {'study': study.name})
      .removeFragment();
}
