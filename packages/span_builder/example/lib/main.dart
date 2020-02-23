import 'package:flutter/material.dart';
import 'package:span_builder/span_builder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Scaffold(
            appBar: AppBar(title: Text("span_builder")),
            body: Center(
                child: SpanBuilderWidget(
                    text: SpanBuilder(
                            "The quick brown fox jumps over the lazy dog")
                        .apply(TextSpan(
                            text: "brown",
                            style: TextStyle(fontWeight: FontWeight.bold)))
                        .apply(TextSpan(text: "🦊"), whereText: "fox")
                        .apply(TextSpan(text: "🐶"), whereText: "dog"),
                    defaultStyle: TextStyle(color: Colors.black),
                    richTextBuilder: (text) =>
                        RichText(text: text, textAlign: TextAlign.center)))));
  }
}
