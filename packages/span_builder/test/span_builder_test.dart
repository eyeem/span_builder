import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:span_builder/span_builder.dart';
// ignore_for_file: avoid_as

void main() {
  setUp(() {
    SpanBuilderWidget.debugPrint = true;
  });

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
      text: SpanBuilder("The quick brown fox")
        ..apply(const TextSpan(text: "brown"), onTap: () {
          tapped = true;
        })
        ..apply(const TextSpan(text: "🦊"), whereText: "fox"),
      textDirection: TextDirection.ltr,
    ));

    expect(find.byType(SpanBuilderWidget), findsOneWidget);
    expect(find.byType(RichText), findsOneWidget);
    expect(tapped, isFalse);

    final textWidget = tester.widget<RichText>(find.byType(RichText));
    final span = textWidget.text as TextSpan;
    final spans = span.children!;
    expect(spans, hasLength(4));

    // fake tap
    ((spans[1] as TextSpan).recognizer as TapGestureRecognizer).onTap!();

    expect(tapped, isTrue);
  });

  testWidgets('changing state', (WidgetTester tester) async {
    await tester.pumpWidget(_FakeSpanShifter());

    final buttonFinder = find.text("PRESS ME");

    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  });

  test('__TORA__ TORA TORA', () async {
    const bold = TextStyle(fontWeight: FontWeight.bold);
    final spans = SpanBuilder("TORA TORA TORA")
        .apply(const TextSpan(text: "TORA", style: bold))
        .build();
    expect(spans, hasLength(2));
    expect(spans[0], isInstanceOf<TextSpan>());
    expect((spans[0] as TextSpan).style, bold);
  });

  test('TORA __TORA__ TORA', () async {
    const bold = TextStyle(fontWeight: FontWeight.bold);
    final spans = SpanBuilder("TORA TORA TORA")
        .apply(const TextSpan(text: "TORA", style: bold), from: 1)
        .build();
    expect(spans, hasLength(3));
    expect(spans[1], isInstanceOf<TextSpan>());
    expect((spans[1] as TextSpan).style, bold);
  });

  test('TORA TORA __TORA__', () async {
    const bold = TextStyle(fontWeight: FontWeight.bold);
    final spans = SpanBuilder("TORA TORA TORA")
        .apply(const TextSpan(text: "TORA", style: bold), from: 6)
        .build();
    expect(spans, hasLength(2));
    expect(spans[1], isInstanceOf<TextSpan>());
    expect((spans[1] as TextSpan).style, bold);
  });
}

class _FakeSpanShifter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FakeSpanShifterState();
}

class _FakeSpanShifterState extends State<StatefulWidget> {
  final texts = <SpanBuilder>[
    SpanBuilder("The quick brown fox")
        .apply(const TextSpan(text: "brown"), onTap: () {})
        .apply(const TextSpan(text: "🦊"), whereText: "fox"),
    SpanBuilder("The quicker brown fox")
        .apply(const TextSpan(text: "brown"), onTap: () {})
        .apply(const TextSpan(text: "🦊"), whereText: "fox", onTap: () {}),
    SpanBuilder("The quickest brown fox")
        .apply(const TextSpan(text: "brown"), onTap: () {})
        .apply(const TextSpan(text: "🦊"), whereText: "fox")
  ];
  var counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
            child: const Text("PRESS ME", textDirection: TextDirection.ltr),
            onTap: () {
              setState(() {
                counter++;
              });
            }),
        SpanBuilderWidget(
            text: texts[counter % texts.length],
            textDirection: TextDirection.ltr),
      ],
    );
  }
}
