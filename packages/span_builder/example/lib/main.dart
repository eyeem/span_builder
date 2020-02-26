import 'package:flutter/material.dart';
import 'package:span_builder/span_builder.dart';

void main() => runApp(MyApp());

// non breaking space
const nbsp = '\u00A0';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Scaffold(
            appBar: AppBar(title: const Text("span_builder")),
            body: Builder(
                builder: (context) => Center(
                    child: SpanBuilderWidget(
                        text: SpanBuilder(
                            "The quick brown fox jumps${nbsp}over the lazy dog")
                          ..apply(const TextSpan(
                              text: "brown",
                              style: TextStyle(fontWeight: FontWeight.bold)))
                          ..apply(const TextSpan(text: "🦊"), whereText: "fox")
                          ..apply(
                              const TextSpan(
                                  text: "jumps",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline)),
                              onTap: () {
                            Scaffold.of(context).showSnackBar(
                                const SnackBar(content: Text("weeeee")));
                          })
                          ..apply(const TextSpan(text: "🐶"), whereText: "dog"),
                        defaultStyle:
                            TextStyle(color: Colors.black, fontSize: 32.0),
                        textAlign: TextAlign.center)))));
  }
}
