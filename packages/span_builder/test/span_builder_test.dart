import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:span_builder/span_builder.dart';
// ignore_for_file: avoid_as

void main() {
  test('test span builder', () async {
    final spans = SpanBuilder("The quick brown fox")
        .apply(const TextSpan(
            text: "brown", style: TextStyle(fontWeight: FontWeight.bold)))
        .apply(const TextSpan(text: "🦊"), whereText: "fox")
        .build();
    expect(spans, hasLength(4));
    expect(spans[0], isInstanceOf<TextSpan>());
    expect((spans[0] as TextSpan).text, equals("The quick "));
    expect(spans[1], isInstanceOf<TextSpan>());
    expect((spans[1] as TextSpan).text, equals("brown"));
    expect(spans[2], isInstanceOf<TextSpan>());
    expect((spans[2] as TextSpan).text, equals(" "));
    expect(spans[3], isInstanceOf<TextSpan>());
    expect((spans[3] as TextSpan).text, equals("🦊"));
  });

  testWidgets('test span builder widget', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(SpanBuilderWidget(
      text: "The quick brown fox",
      format: (text) => text
          .apply("brown".asTapSpan(() {
            tapped = true;
          }))
          .apply(const TextSpan(text: "🦊"), whereText: "fox"),
      richTextBuilder: (spans) => RichText(
        text: TextSpan(children: spans),
        textDirection: TextDirection.ltr,
      ),
    ));

    expect(find.byType(SpanBuilderWidget), findsOneWidget);
    expect(find.byType(RichText), findsOneWidget);
    expect(tapped, isFalse);

    final textWidget = tester.widget<RichText>(find.byType(RichText));
    final TextSpan span = textWidget.text;
    final spans = span.children;
    expect(spans, hasLength(4));

    // fake tap
    ((spans[1] as TextSpan).recognizer as TapGestureRecognizer).onTap();

    expect(tapped, isTrue);
  });
}