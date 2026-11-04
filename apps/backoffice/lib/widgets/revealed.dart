import 'package:flutter/widgets.dart';

class Revealed extends StatefulWidget {
  const Revealed({super.key, required this.child});

  final Widget child;

  @override
  State<Revealed> createState() => _RevealedState();
}

class _RevealedState extends State<Revealed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(context, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
      Scrollable.ensureVisible(context, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
