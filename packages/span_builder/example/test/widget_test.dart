import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:span_builder_test/span_builder_test.dart';

void main() {
  testWidgets('MyApp test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    final spanFinder = find.byKey(span_key);

    expect(spanFinder, findsOneWidget);
    final allSpans = tester.findSpans(spanFinder)?.length;
    expect(allSpans, 8);

    final foxSpans = tester.findSpans(spanFinder, predicate: (span) {
      return span is TextSpan && span.text == "🦊";
    });
    expect(foxSpans?.length, 1);
  });
}
