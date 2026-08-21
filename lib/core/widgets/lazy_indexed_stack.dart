import 'package:flutter/material.dart';

/// 🔥 نسخة Lazy من IndexedStack: بيُبني الطفل لما يصير visible لأول مرة فقط.
/// بيحل مشكلة استدعاءات API الزائدة يلي بتصير لما كل التابات بتُبنى فوراً.
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  final Set<int> _builtIndexes = {};

  @override
  Widget build(BuildContext context) {
    _builtIndexes.add(widget.index);

    return IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      children: List.generate(widget.children.length, (i) {
        return _builtIndexes.contains(i)
            ? widget.children[i]
            : const SizedBox.shrink();
      }),
    );
  }
}