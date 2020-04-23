![span_builder](https://user-images.githubusercontent.com/121164/75353447-b6ef2800-58ab-11ea-984c-3d346d20af71.png)

Facilitates creation of spans from plain text and provides an automated disposal of `GestureRecognizers`.

### Description

Given some plain text, e.g.: __"The quick brown fox"__ allows you to `apply` multiple spans at multiple positions. Positions can be specified by a matching word (`whereText`), e.g. __"brown"__ and/or range `from=10, to=15`. Spans are subclasses of `InlineSpan`. If the span you are trying to apply is `TextSpan` you don't need to pass `whereText` as it will be inferred from text within the provided span.

Once you are done using `SpanBuilder`, use `build()` to return calculated list of spans. Spans can't overlap.

### Usage:

```dart
final spans = SpanBuilder("The quick brown fox")
  .apply(TextSpan(text: "brown", style: TextStyle(fontWeight: FontWeight.bold)))
  .apply(TextSpan(text: "🦊"), whereText: "fox")
  .build()
```

From there you can use these spans in your RichText, e.g.:

```dart
RichText(
  text: TextSpan(children: spans)
)
```

If you plan to make your text "tappable" read on.

#### Handling GestrueRecognizer (text taps)

If you try passing `GestrueRecognizer` as a field in `TextSpan` it will get stripped away - [HERE IS WHY](https://github.com/flutter/flutter/issues/10623#issuecomment-345790443).

__TL;DR__: We don't want to leak `GestureRecognizer` but `TextSpan` has no idea about the lifecycle of `Widget` so you need a stateful widget to keep a reference to the recognizer untill you're done with it. [Sounds like a mess](https://api.flutter.dev/flutter/painting/TextSpan/recognizer.html), right?

__The workaround__ is to provide a builder for the recognizer like this:

```dart
apply(TextSpan(text: "jumps"),
  recognizerBuilder: () => TapGestureRecognizer()..onTap = () {
    // your code here
  })
```

Then you can use this `SpanBuilder` together with `SpanBuilderWidget` which will manage creating and disposing of `TapGestrueRecognizer` at the right time:

```dart
SpanBuilderWidget(
  text: SpanBuilder("fox jumps")
    ..apply(TextSpan(text: "jumps"),
      recognizerBuilder: () => TapGestureRecognizer()..onTap = () {
        // your code here
      })
)
```

If you care only about `onTap` interaction you can use this API shortcut:

```dart
apply(TextSpan(text: "jumps"),
  onTap: () {
    // your code here
  }
)
```

### Testing:

There are [little resources](https://github.com/flutter/flutter/blob/master/packages/flutter/test/widgets/hyperlink_test.dart#L47) on how to test RichText in general. For this reason there is helper testing library `span_builder_test` that can help you verify state of your spans in your UI tests.

```dart
void main() {
  testWidgets('MyApp test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    final spanFinder = find.byKey(span_key);

    expect(spanFinder, findsOneWidget);
    final allSpans = tester.findSpans(spanFinder).length;
    expect(allSpans, 8);

    final foxSpans = tester.findSpans(spanFinder, predicate: (span) {
      return span is TextSpan && span.text == "🦊"; 
    });
    expect(foxSpans.length, 1);
  });
}
```