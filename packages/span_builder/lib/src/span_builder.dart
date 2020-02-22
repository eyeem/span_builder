import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

extension AsTapSpanExtension on String {
  /// this should be used from within [SpanBuilderWidget] which will
  /// take care of disposing recognizers
  TextSpan asTapSpan(void Function() onTap, {TextStyle style}) => TextSpan(
      text: this,
      style: style,
      recognizer: TapGestureRecognizer()..onTap = onTap);
}

/// represents position of a span in some plain text
class SpanPosition {
  const SpanPosition(
      {@required this.start, @required this.end, @required this.span})
      : assert(start >= 0),
        assert(end > start);

  final int start;
  final int end;
  final InlineSpan span;
}

/// given some plain text, e.g.: "The quick brown fox" allows you to [apply]
/// multiple spans at multiple positions. Positions can be specified by
/// word, that is e.g. "brown" or range (from=10, to=15) and spans are
/// subclasses of [InlineSpan]
/// Once you are done using SpanBuilder, use [build] to return calculated list of spans.
/// The rest of the text, that has no span either inherits [TextStyle] from parent span or can be forced
/// to use [defaultStyle]
///
/// USAGE:
///
/// ```dart
/// SpanBuilder("The quick brown fox")
///   .apply(TextSpan(text: "brown", style: TextStyle(fontWeight: FontWeight.bold)))
///   .apply(TextSpan(text: "🦊"), whereText: "fox")
///   .build()
/// ```
class SpanBuilder {
  SpanBuilder(this.sourceText);
  final String sourceText;
  final entities = <SpanPosition>[];
  bool isDisposed = false;

  SpanBuilder apply(InlineSpan span, {String whereText, int from, int to}) {
    if (whereText == null && from == null && to == null) {
      if (span is TextSpan) {
        whereText = span.text;
      } else {
        return this;
      }
    }

    if (whereText != null) {
      from = sourceText.indexOf(whereText);
      to = from + whereText.length;
    }

    entities.add(SpanPosition(start: from, end: to, span: span));
    return this;
  }

  /// due to some [poor design choices](https://github.com/flutter/flutter/issues/10623#issuecomment-345790443)
  /// you need to dispose text links
  void dispose() {
    isDisposed = true;
    for (final entity in entities) {
      if (entity.span is TextSpan) {
        final TextSpan textSpan = entity.span;
        textSpan.recognizer?.dispose();
      }
    }
  }

  List<InlineSpan> build() =>
      isDisposed ? [] : _computeSpans(sourceText, entities);
}

/// poorly designed facility widget to help dispose recognizers from TextSpans
/// ...off product of some [poor design choices](https://github.com/flutter/flutter/issues/10623#issuecomment-345790443)
class SpanBuilderWidget extends StatefulWidget {
  const SpanBuilderWidget({
    Key key,
    @required this.format,
    @required this.richTextBuilder,
    @required this.text,
    this.defaultStyle,
  }) : super(key: key);
  final Function(SpanBuilder text) format;
  final RichText Function(InlineSpan inlineSpan) richTextBuilder;
  final String text;
  final TextStyle defaultStyle;

  @override
  State<StatefulWidget> createState() => _SpanBuilderWidgetState();
}

class _SpanBuilderWidgetState extends State<SpanBuilderWidget> {
  SpanBuilder _spanBuilder;
  SpanBuilder _instigate() {
    final builder = SpanBuilder(widget.text);
    widget.format(builder);
    return builder;
  }

  @override
  void initState() {
    super.initState();
    _spanBuilder = _instigate();
  }

  @override
  void didUpdateWidget(SpanBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _spanBuilder?.dispose();
      _spanBuilder = _instigate();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => widget.richTextBuilder(
      TextSpan(children: _spanBuilder.build(), style: widget.defaultStyle));

  @override
  void dispose() {
    super.dispose();
    _spanBuilder?.dispose();
  }
}

/// CONTRACT: entities must come sorted by their appearance and should not overlap
List<InlineSpan> _computeSpans(String text, List<SpanPosition> entities) {
  final output = <InlineSpan>[];
  var currentIndex = 0;
  for (final entity in entities) {
    if (currentIndex < entity.start) {
      output.add(TextSpan(text: text.substring(currentIndex, entity.start)));
    }
    output.add(entity.span);
    currentIndex = entity.end;
  }
  if (currentIndex < text.length) {
    output.add(TextSpan(text: text.substring(currentIndex, text.length)));
  }
  return output;
}
