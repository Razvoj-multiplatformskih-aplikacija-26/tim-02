import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../text/serbian.dart';
import 'state_views.dart';
import 'tactic_section.dart';

class CompsView extends StatelessWidget {
  const CompsView({super.key, required this.patch, required this.comps});

  final PatchId patch;
  final Map<Tier, List<Tactic>> comps;

  @override
  Widget build(BuildContext context) {
    if (comps.values.every((tactics) => tactics.isEmpty)) {
      return const EmptyView(title: 'Za ovaj patch još nema kompozicija.');
    }
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ListTile(
          leading: Icon(Icons.update, color: theme.colorScheme.primary),
          title: Text('Patch ${patch.value}', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Trenutni patch'),
          trailing: const Icon(Icons.chevron_right),
          tileColor: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        const SizedBox(height: 24),
        for (final MapEntry(key: tier, value: tactics) in comps.entries)
          if (tactics.isNotEmpty) TacticSection(label: tier.label, tactics: tactics, highlighted: tier == Tier.s),
      ],
    );
  }
}
