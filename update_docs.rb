#!/usr/bin/env ruby
# Makes combined readme out of packages/span_builder/README.md & packages/span_builder_test/README.md

span_builder_md = File.read('packages/span_builder/README.md').strip
span_builder_test_md = File.read('packages/span_builder_test/README.md').strip

readme = """#Span Builder For Flutter

#{span_builder_md}

#{span_builder_test_md}
"""

File.write("README.md", readme)

# populate root CHANGELOG to packages
`cp CHANGELOG.md packages/span_builder/CHANGELOG.md`
`cp CHANGELOG.md packages/span_builder_test/CHANGELOG.md`