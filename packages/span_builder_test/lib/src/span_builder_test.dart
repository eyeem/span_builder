import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// found nothing better than this
/// https://github.com/flutter/flutter/blob/master/packages/flutter/test/widgets/hyperlink_test.dart#L47
/// sooo...
extension WidgetTesterRichEditExtension on WidgetTester {
  Iterable<InlineSpan> findTextSpans(
      Finder richTextFinder, bool Function(InlineSpan) predicate) {
    final richText = widget<RichText>(richTextFinder);
    expect(richText.text, isInstanceOf<TextSpan>());
    final TextSpan innerText = richText.text;
    return innerText.children.where(predicate);
  }
}

extension SpanBuilderRichTextFinderExtension on Finder {
  /// given a finder for [SpanBuilderWidget] 
  Finder descendingRichText() =>
      find.descendant(of: this, matching: find.byType(RichText));
}
