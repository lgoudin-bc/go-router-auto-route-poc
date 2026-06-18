import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

/// A bottom-to-top modal route for auto_route, mirroring flutter-front's
/// `CupertinoModalRoute` (packages/utilities/extensions/route/lib/src/
/// cupertino_modal_route.dart). Declared at the root of the route tree, it
/// presents on top of everything — including the bottom tabs.
class CupertinoModalRoute extends CustomRoute<void> {
  CupertinoModalRoute({
    required String super.path,
    required super.page,
    bool enableDrag = true,
    bool showDragHandle = false,
    super.children,
    super.initial,
  }) : super(
          fullscreenDialog: true,
          customRouteBuilder: <T>(
            BuildContext context,
            Widget child,
            AutoRoutePage<T> page,
          ) =>
              CupertinoSheetRoute<T>(
            settings: page,
            builder: (_) => child,
            enableDrag: enableDrag,
            showDragHandle: showDragHandle,
          ),
        );
}
