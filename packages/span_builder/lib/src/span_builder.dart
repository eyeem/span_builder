import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// represents position of a span in some plain text
class SpanEntity {
  const SpanEntity(
      {@required this.start, @required this.end, @required this.span})
      : assert(start >= 0),

        /// we only accept _ManagedTextSpans since we must take care of managing the recognizer
        assert((span is TextSpan && span is _ManagedTextSpan) ||
            !(span is TextSpan)),
        assert(end > start);

  final int start;
  final int end;
  final InlineSpan span;

  bool overlaps(SpanEntity other) {
    return (other.start < end && other.start >= start) ||
        (other.end <= end && other.end >= start);
  }

  @override
  String toString() => "<$start, $end> $span";
}

extension ManagedTextSpanExtension on TextSpan {
  InlineSpan managed([RecognizerBuilder recognizerBuilder]) =>
      _ManagedTextSpan.fromTextSpan(this, recognizerBuilder: recognizerBuilder);
}

typedef RecognizerBuilder = GestureRecognizer Function();
typedef _RecognizerBuilder = GestureRecognizer Function(_ManagedTextSpan);

/// Due to some [poor design choices](https://github.com/flutter/flutter/issues/10623#issuecomment-345790443)
/// you need to dispose "text links" & we don't want to handle recongnizer lifecycle inside [StringBuilder]
/// as we want to reuse [StringBuilder] therefore here is this class that will create us TextSpans with recognizers
/// managed by whoever that is passing [RecognizerBuilder] to the [asManagedTextSpan]
class _ManagedTextSpan extends TextSpan {
  const _ManagedTextSpan({
    this.recognizerBuilder,
    String text,
    TextStyle style,
    String semanticsLabel,
  }) : super(text: text, style: style, semanticsLabel: semanticsLabel);
  _ManagedTextSpan.fromTextSpan(TextSpan textSpan,
      {RecognizerBuilder recognizerBuilder})
      : this(
            text: textSpan.text,
            style: textSpan.style,
            semanticsLabel: textSpan.semanticsLabel,
            recognizerBuilder: recognizerBuilder);
  final RecognizerBuilder recognizerBuilder;

  TextSpan withManagedRecognizer(GestureRecognizer managedRecognizer) {
    return TextSpan(
        style: style,
        text: text,
        semanticsLabel: semanticsLabel,
        recognizer: managedRecognizer);
  }
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
  final _entities = <SpanEntity>[];

  SpanBuilder apply(InlineSpan span,
      {String whereText,
      int from,
      int to,
      Function() onTap,
      RecognizerBuilder recognizerBuilder}) {
    /// turn any [onTap] into [RecognizerBuilder]
    if (onTap != null && recognizerBuilder == null) {
      recognizerBuilder = () => TapGestureRecognizer()..onTap = onTap;
    }

    /// convert [TextSpan] into [_ManagedTextSpan] with a [RecoginzerBuilder]
    if (span is TextSpan) {
      /// ignore: avoid_as
      span = (span as TextSpan).managed(recognizerBuilder);
    }

    /// if [whereText] is not provided then we try to figure it out:
    /// 1. from passed [TextSpan]
    /// 2. from [from, to] range
    if (whereText == null) {
      if (span is TextSpan) {
        whereText = span.text;
      } else {
        if (from == null && to == null) {
          return this;
        }
        whereText = sourceText.substring(from ?? 0, to ?? sourceText.length);
      }
    }

    /// if we pass whereText + from, we will try to do the search starting from that point
    /// therefor we need offset
    final offset = from ?? 0;

    final _sourceText =
        sourceText.substring(from ?? 0, to ?? sourceText.length);

    if (whereText != null) {
      from = _sourceText.indexOf(whereText);
      if (from == -1) {
        return this;
      }
      to = from + whereText.length;
    }

    /// finally we appen calculated SpanPosition
    return add(SpanEntity(start: offset + from, end: offset + to, span: span));
  }

  /// we sort entities when we add them, if any of the entities is overlapping,
  /// we throw [StateError]
  SpanBuilder add(SpanEntity newEntity) {
    var index = 0;
    for (final entity in _entities) {
      if (entity.overlaps(newEntity)) {
        throw StateError(
            "Unable to add $newEntity. Overlaps with existing $entity");
      }
      if (newEntity.end <= entity.start) {
        break;
      }
      index++;
    }
    _entities.insert(index, newEntity);
    return this;
  }

  List<InlineSpan> build({_RecognizerBuilder recognizerBuilder}) =>
      _computeSpans(sourceText, _entities, recognizerBuilder);
}

/// poorly designed facility widget to help dispose recognizers from TextSpans
/// ...off product of some [poor design choices](https://github.com/flutter/flutter/issues/10623#issuecomment-345790443)
class SpanBuilderWidget extends StatefulWidget {
  const SpanBuilderWidget({
    Key key,
    @required this.richTextBuilder,
    @required this.text,
    this.defaultStyle,
  }) : super(key: key);
  final RichText Function(InlineSpan inlineSpan) richTextBuilder;
  final SpanBuilder text;
  final TextStyle defaultStyle;

  @override
  State<StatefulWidget> createState() => _SpanBuilderWidgetState();

  /// usful for verifying if recognizer are indeed being disposed
  static bool debugPrint = false;
}

class _SpanBuilderWidgetState extends State<SpanBuilderWidget> {
  TextSpan _textSpan;
  final _recongnizers = <GestureRecognizer>[];

  GestureRecognizer recognizerBuilder(_ManagedTextSpan textSpan) {
    final recognizer = textSpan.recognizerBuilder?.call();
    if (recognizer != null) {
      if (SpanBuilderWidget.debugPrint) {
        debugPrint("CREATE RECOGNIZER for ${recognizer.hashCode}");
      }
      _recongnizers.add(recognizer);
    }
    return recognizer;
  }

  void _disposeOldRecognizers() {
    for (final recognizer in _recongnizers) {
      if (SpanBuilderWidget.debugPrint) {
        debugPrint("DISPOSE RECOGNIZER for ${recognizer.hashCode}");
      }
      recognizer.dispose();
    }
    _recongnizers.clear();
  }

  void _instigate() {
    _disposeOldRecognizers();
    _textSpan = TextSpan(
        children: widget.text.build(recognizerBuilder: recognizerBuilder),
        style: widget.defaultStyle);
  }

  @override
  void initState() {
    super.initState();
    _instigate();
  }

  @override
  void didUpdateWidget(SpanBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      setState(() {
        _instigate();
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.richTextBuilder(_textSpan);

  @override
  void dispose() {
    super.dispose();
    _disposeOldRecognizers();
  }
}

/// CONTRACT: entities must come sorted by their appearance and should not overlap
List<InlineSpan> _computeSpans(String text, List<SpanEntity> entities,
    _RecognizerBuilder recognizerBuilder) {
  final output = <InlineSpan>[];
  var currentIndex = 0;
  for (final entity in entities) {
    if (currentIndex < entity.start) {
      output.add(TextSpan(text: text.substring(currentIndex, entity.start)));
    }
    final span = entity.span;
    if (span is _ManagedTextSpan) {
      final managedRecognizer = recognizerBuilder?.call(span);
      output.add(span.withManagedRecognizer(managedRecognizer));
    } else {
      output.add(span);
    }
    currentIndex = entity.end;
  }
  if (currentIndex < text.length) {
    output.add(TextSpan(text: text.substring(currentIndex, text.length)));
  }
  return output;
}
