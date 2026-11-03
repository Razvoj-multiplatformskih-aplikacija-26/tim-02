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
    this.onHide,
    this.onRestore,
    this.busy = false,
  });

  final Tactic tactic;
  final Tier? tier;
  final int variant;
  final bool early;
  final ValueChanged<int> onVariantSelected;
  final ValueChanged<bool> onEarlySelected;
  final VoidCallback onClose;
  final VoidCallback? onHide;
  final VoidCallback? onRestore;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: switch ((onHide, onRestore)) {
                      (final hide?, _) => OutlinedButton.icon(
                        onPressed: busy ? null : hide,
                        icon: const Icon(Icons.visibility_off_outlined),
                        label: Text(TacticAction.hide.label),
                      ),
                      (_, final restore?) => FilledButton.icon(
                        onPressed: busy ? null : restore,
                        icon: const Icon(Icons.visibility_outlined),
                        label: Text(TacticAction.restore.label),
                      ),
                      _ => null,
                    },
                  ),
                ),
                IconButton(tooltip: 'Zatvori', onPressed: onClose, icon: const Icon(Icons.close)),
              ],
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
