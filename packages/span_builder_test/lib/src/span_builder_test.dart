import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// found nothing better than this
/// https://github.com/flutter/flutter/blob/master/packages/flutter/test/widgets/hyperlink_test.dart#L47
/// sooo...
extension WidgetTesterRichEditExtension on WidgetTester {
  Iterable<InlineSpan> findSpans(Finder spanWidgetFinder,
      {bool Function(InlineSpan) predicate}) {
    final richTextFinder =
        find.descendant(of: spanWidgetFinder, matching: find.byType(RichText));
    final richText = widget<RichText>(richTextFinder);
    expect(richText.text, isInstanceOf<TextSpan>());
    final TextSpan innerText = richText.text;
    return predicate == null
        ? innerText.children
        : innerText.children.where(predicate);
  }
}
