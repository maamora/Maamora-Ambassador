import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../design/app_motion.dart';

/// Counts up from 0 to [value]. Screen readers hear only the final number.
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
  });

  final num value;
  final TextStyle? style;
  final String suffix;

  static final NumberFormat _format = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final target = value.toDouble();
    final reduced = AppMotion.reduced(context);
    final finalText = '${_format.format(target.round())}$suffix';
    return Semantics(
      label: finalText,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: reduced ? target : 0, end: target),
        duration: reduced ? Duration.zero : AppMotion.slow,
        curve: AppMotion.emphasized,
        builder: (context, current, _) => Text(
          '${_format.format(current.round())}$suffix',
          style: style,
        ),
      ),
    );
  }
}
