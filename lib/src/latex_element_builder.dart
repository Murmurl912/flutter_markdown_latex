import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

typedef LatexErrorBuilder = Widget Function(
    Object message, String text, TextStyle? textStyle);

Widget defaultLatexErrorBuilder(
    Object message, String text, TextStyle? textStyle) {
  return Text(
    text,
    style: textStyle,
  );
}

class LatexElementBuilder extends MarkdownElementBuilder {
  LatexElementBuilder(
      {this.textStyle,
      this.textScaleFactor,
      this.selectable = true,
      this.errorBuilder = defaultLatexErrorBuilder});

  /// The style to apply to the text.
  final TextStyle? textStyle;

  /// The text scale factor to apply to the text.
  final double? textScaleFactor;

  final LatexErrorBuilder errorBuilder;

  final bool selectable;

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final String text = element.textContent;
    if (text.isEmpty) {
      return const SizedBox();
    }

    MathStyle mathStyle;
    switch (element.attributes['MathStyle']) {
      case 'text':
        mathStyle = MathStyle.text;
      case 'display':
        mathStyle = MathStyle.display;
      default:
        mathStyle = MathStyle.text;
    }
    final widget = selectable || false
        ? SelectableMath.tex(
            text,
            mathStyle: mathStyle,
            textStyle: textStyle,
            textScaleFactor: textScaleFactor,
            onErrorFallback: (message) {
              return errorBuilder(message, text, textStyle);
            },
          )
        : Math.tex(
            text,
            mathStyle: mathStyle,
            textStyle: textStyle,
            textScaleFactor: textScaleFactor,
            onErrorFallback: (message) {
              return errorBuilder(message, text, textStyle);
            },
          );
    return SingleChildScrollView(
      clipBehavior: Clip.antiAlias,
      scrollDirection: Axis.horizontal,
      child: widget,
    );
  }
}
