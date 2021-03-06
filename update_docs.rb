#!/usr/bin/env ruby
# Makes combined readme out of packages/span_builder/README.md & packages/span_builder_test/README.md

span_builder_md = File.read('packages/span_builder/README.md').strip
span_builder_test_md = File.read('packages/span_builder_test/README.md').strip

readme = """#{span_builder_md}

#{span_builder_test_md}

### Related Content

- [RichText (Flutter Widget of the Week)](https://www.youtube.com/watch?v=rykDVh-QFfw)
- [Make text styling more effective with RichText widget](https://medium.com/flutter-community/make-text-styling-more-effective-with-richtext-widget-b0e0cb4771ef) by _Darshan Kawar_
- [CSS Text Flutter Library](https://pub.dev/packages/css_text)
"""

File.write("README.md", readme)

# populate root CHANGELOG to packages
`cp CHANGELOG.md packages/span_builder/CHANGELOG.md`
`cp CHANGELOG.md packages/span_builder_test/CHANGELOG.md`