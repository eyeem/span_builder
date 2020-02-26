![span_builder](https://user-images.githubusercontent.com/121164/75353447-b6ef2800-58ab-11ea-984c-3d346d20af71.png)

Facilitates creation of spans from plain text and provides automated disposal of `GestureRecognizers`.

### Description

Given some plain text, e.g.: __"The quick brown fox"__ allows you to `apply` multiple spans at multiple positions. Positions can be specified by a matching word (`whereText`), that is e.g. __"brown"__ or/and range `from=10, to=15`. Spans are subclasses of `InlineSpan`. If the span you are trying to apply is `TextSpan` you don't need to pass `whereText` as it will be inferred from text within the provided span.

Once you are done using `SpanBuilder`, use `build()` to return calculated list of spans.

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

If you try passing `GestrueRecognizer` as a field in `TextSpan` it will get discarded - here's [why](https://github.com/flutter/flutter/issues/10623#issuecomment-345790443).

__TL;DR__: We don't want to leak `GestureRecognizer` but `TextSpan` has no idea about `Widget's` lifecycle so you need a stateful widget to keep a reference to the recognizer untill you're done with it.

__The workaround__ is to provide a builder for the recognizer like this:

```dart
apply(TextSpan(text: "jumps"),
  recognizerBuilder: () => TapGestureRecognizer()..onTap = () {
    // your code here
  })
```

...and then use `SpanBuilder` together with `SpanBuilderWidget` which will manage creating and disposing `TapGestrueRecognizer` at right time:

```dart
SpanBuilderWidget(
  text: SpanBuilder("fox jumps")
    ..apply(TextSpan(text: "jumps"),
      recognizerBuilder: () => TapGestureRecognizer()..onTap = () {
        // your code here
      })
)
```

If you care only about `onTap` and don't need other gestures, you can use this API shortcut:

```dart
SpanBuilderWidget(
  text: SpanBuilder("fox jumps")
    ..apply(TextSpan(text: "jumps"),
      onTap: () {
        // your code here
      })
)
```

### Testing:


