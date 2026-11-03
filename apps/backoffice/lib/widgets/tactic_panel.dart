import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class TacticPanel extends StatelessWidget {
  const TacticPanel({
    super.key,
    required this.tactic,
    required this.tier,
    required this.variant,
    required this.early,
    required this.onVariantSelected,
    required this.onEarlySelected,
    required this.onClose,
  });

  final Tactic tactic;
  final Tier? tier;
  final int variant;
  final bool early;
  final ValueChanged<int> onVariantSelected;
  final ValueChanged<bool> onEarlySelected;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(tooltip: 'Zatvori', onPressed: onClose, icon: const Icon(Icons.close)),
            ),
          ),
          Expanded(
            child: TacticDetails(
              tactic: tactic,
              tier: tier,
              variant: variant,
              early: early,
              onVariantSelected: onVariantSelected,
              onEarlySelected: onEarlySelected,
            ),
          ),
        ],
      ),
    );
  }
}
