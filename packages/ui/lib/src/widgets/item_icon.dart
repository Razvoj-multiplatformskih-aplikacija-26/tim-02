import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

class ItemIcon extends StatelessWidget {
  const ItemIcon({super.key, required this.item, this.size = 20, this.triggerMode});

  final Item item;
  final double size;
  final TooltipTriggerMode? triggerMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: item.name,
      triggerMode: triggerMode,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          'assets/tft/items/${item.id.value}.webp',
          package: 'ui',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Text(item.name[0], style: theme.textTheme.labelSmall),
          ),
        ),
      ),
    );
  }
}
