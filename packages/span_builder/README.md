## span_builder

![span_builder](https://user-images.githubusercontent.com/121164/75353447-b6ef2800-58ab-11ea-984c-3d346d20af71.png)

Apply flutter spans to plain text based on position or matching text.

### Description

Given some plain text, e.g.: "The quick brown fox" allows you to `apply` multiple spans at multiple positions. Positions can be specified by word, that is e.g. "brown" or range (from=10, to=15) and spans are subclasses of [InlineSpan].

Once you are done using SpanBuilder, use [build] to return calculated list of spans.
The rest of the text, that has no span either inherits [TextStyle] from parent span or can be forced
to use [defaultStyle]

### Usage:

```dart
SpanBuilder("The quick brown fox")
  .apply(TextSpan(text: "brown", style: TextStyle(fontWeight: FontWeight.bold)))
  .apply(TextSpan(text: "🦊"), whereText: "fox")
  .build()
```

### Testing:


