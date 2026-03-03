import 'package:flutter/material.dart';

/// A Sliver that takes a list of child slivers and returns them directly in a MultiChildRenderObjectWidget.
/// Note: Flutter natively doesn't have a single MultiSliver built-in unless you use sliver_tools package.
/// Since we don't have sliver_tools in pubspec.yaml, we will implement a lightweight wrapper using
/// SliverMainAxisGroup which wraps multiple slivers natively in Flutter 3+.
class MultiSliverWidget extends StatelessWidget {
  final List<Widget> slivers;

  const MultiSliverWidget({super.key, required this.slivers});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: slivers);
  }
}
