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
    this.onEdit,
    this.onPlace,
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
  final VoidCallback? onEdit;
  final ValueChanged<Tier?>? onPlace;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (onHide case final hide?)
                        Tooltip(
                          message: 'Sakrij izabranu taktiku sa Kompozicija',
                          child: OutlinedButton.icon(
                            onPressed: busy ? null : hide,
                            icon: const Icon(Icons.visibility_off_outlined),
                            label: Text('${TacticAction.hide.label} (H)'),
                          ),
                        ),
                      if (onRestore case final restore?)
                        Tooltip(
                          message: 'Vrati izabranu taktiku na Kompozicije',
                          child: FilledButton.icon(
                            onPressed: busy ? null : restore,
                            icon: const Icon(Icons.visibility_outlined),
                            label: Text('${TacticAction.restore.label} (R)'),
                          ),
                        ),
                      if (onEdit case final edit?)
                        Tooltip(
                          message: 'Uredi izabranu taktiku',
                          child: OutlinedButton.icon(
                            onPressed: busy ? null : edit,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Uredi (E)'),
                          ),
                        ),
                      if (onPlace case final place?)
                        MenuAnchor(
                          menuChildren: [
                            for (final option in [...Tier.values, null])
                              MenuItemButton(
                                onPressed: option == tier ? null : () => place(option),
                                child: Text(option?.label ?? 'Bez tiera'),
                              ),
                          ],
                          builder: (context, controller, child) => OutlinedButton.icon(
                            onPressed: busy ? null : () => controller.isOpen ? controller.close() : controller.open(),
                            icon: const Icon(Icons.leaderboard_outlined),
                            label: Text('Tier: ${tier?.label ?? 'nema'}'),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(tooltip: 'Zatvori (Esc)', onPressed: onClose, icon: const Icon(Icons.close)),
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
