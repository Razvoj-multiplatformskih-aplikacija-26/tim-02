import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'champion_hex.dart';

class ChampionTile extends StatelessWidget {
  const ChampionTile({super.key, required this.champion, required this.title, required this.onOpen});

  final Champion? champion;
  final String title;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            switch (champion) {
              null => const EmptyHex(size: 76),
              final champion => ChampionHex(champion: champion, size: 76),
            },
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
