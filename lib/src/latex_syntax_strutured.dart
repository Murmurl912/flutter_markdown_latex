import 'package:markdown/markdown.dart';

class LatexInlineBracketSyntax extends InlineSyntax {
  // This pattern matches LaTeX expressions within \( e = mc^2 \)
  static const String latexPattern = r'(?<!\\)\\\((.+?)(?<!\\)\\\)';

  LatexInlineBracketSyntax()
      : super(latexPattern, startCharacter: '\\'.codeUnitAt(0));

  @override
  bool onMatch(InlineParser parser, Match match) {
    final equation = match.group(1);
    if (equation != null && equation.isNotEmpty) {
      final element = Element.text('latex', equation);
      element.attributes['MathStyle'] = 'text';
      parser.addNode(element);
      return true;
    }
    return false;
  }
}

class LatexInlineSquareBracketSyntax extends InlineSyntax {
  // This pattern matches LaTeX expressions within \[ e = mc^2 \]
  static const String latexPattern = r'(?<!\\)\\\[(.+?)(?<!\\)\\]';

  LatexInlineSquareBracketSyntax()
      : super(latexPattern, startCharacter: '\\'.codeUnitAt(0));

  @override
  bool onMatch(InlineParser parser, Match match) {
    final equation = match.group(1);
    if (equation != null && equation.isNotEmpty) {
      final element = Element.text('latex', equation);
      element.attributes['MathStyle'] = 'display';
      parser.addNode(element);
      return true;
    }
    return false;
  }
}

class LatexInlineDoubleDollarSyntax extends InlineSyntax {
  // This pattern matches LaTeX expressions within $$ e = mc^2 $$
  static const String latexPattern = r'(?<!\\)\$\$(.+?)(?<!\\)\$\$';

  LatexInlineDoubleDollarSyntax()
      : super(latexPattern, startCharacter: '\$'.codeUnitAt(0));

  @override
  bool onMatch(InlineParser parser, Match match) {
    var equation = match.group(1);
    if (equation != null && equation.isNotEmpty) {
      final element = Element.text('latex', equation);
      element.attributes['MathStyle'] = 'text';
      parser.addNode(element);
      return true;
    }
    return false;
  }
}

class LatexInlineSingleDollarSyntax extends InlineSyntax {
  // This pattern matches LaTeX expressions within $ e = mc^2 $
  static const String latexPattern = r'(?<!\\)\$(.+?)(?<!\\)\$';

  LatexInlineSingleDollarSyntax()
      : super(latexPattern, startCharacter: '\$'.codeUnitAt(0));

  @override
  bool onMatch(InlineParser parser, Match match) {
    var equation = match.group(1);
    if (equation != null) {
      final element = Element.text('latex', equation);
      element.attributes['MathStyle'] = 'text';
      parser.addNode(element);
      return true;
    }
    return false;
  }
}


/// syntax:
/// 1. $$ ... $$ followed by optional character then end of line
/// 2. \[ ... \] followed by optional character then end of line
class LatexBlockSyntaxExtended extends BlockSyntax {
  @override
  RegExp get pattern => RegExp(
    r'^[\s\t]*(?:(?<dollar>\$\$)|(?<bracket>\\\[))[\s\t]*$',
    multiLine: true,
  );

  LatexBlockSyntaxExtended() : super();

  @override
  List<Line> parseChildLines(BlockParser parser) {
    final firstMatch = pattern.firstMatch(parser.current.content);
    if (firstMatch == null) {
      return [];
    }
    final dollarMatch = firstMatch.namedGroup('dollar');
    final bracketMatch = firstMatch.namedGroup('bracket');
    if (dollarMatch != null) {
      return parseChildLineWithEnding(parser, "\$\$");
    } else if (bracketMatch != null) {
      return parseChildLineWithEnding(parser, '\\]');
    } else {
      return [];
    }
  }

  List<Line> parseChildLineWithEnding(BlockParser parser, String ending) {
    final childLines = <Line>[];
    parser.advance();
    while (!parser.isDone) {
      final currentLine = parser.current.content.trimRight();
      if (currentLine.endsWith(ending)) {
        // the end
        childLines.add(Line(currentLine.substring(0, currentLine.length - 2)));
        parser.advance();
        return childLines;
      }
      childLines.add(Line(currentLine));
      parser.advance();
    }
    return childLines;
  }

  @override
  Node parse(BlockParser parser) {
    final lines = parseChildLines(parser);
    final content = lines.map((e) => e.content).join('\n').trim();
    final textElement = Element.text('latex', content);
    textElement.attributes['MathStyle'] = 'display';
    return Element('p', [textElement]);
  }
}