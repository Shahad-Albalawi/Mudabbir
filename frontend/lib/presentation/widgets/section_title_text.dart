import 'package:flutter/material.dart';

/// Section or page title — aligns to layout start (physical right in RTL).
class SectionTitleText extends StatelessWidget {
  const SectionTitleText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.fullWidth = true,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  /// When true, the title spans the full row width so [TextAlign.start] applies.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: fullWidth ? 1 : null,
      child: Text(
        data,
        textAlign: TextAlign.start,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
