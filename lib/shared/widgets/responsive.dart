import 'package:flutter/material.dart';

import '../design/app_tokens.dart';

enum ScreenSize { compact, medium, expanded }

extension ResponsiveX on BuildContext {
  /// compact < 600, medium < 900, expanded >= 900 (logical pixels).
  ScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width < 600) return ScreenSize.compact;
    if (width < 900) return ScreenSize.medium;
    return ScreenSize.expanded;
  }
}

/// Centers content, caps its width on tablets/desktop and applies a gutter
/// that grows with the screen. Put it inside a scroll view.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.maxWidth = 1040});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gutter = width < 600
            ? AppSpacing.lg
            : (width < 900 ? AppSpacing.xl : AppSpacing.xxl);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
