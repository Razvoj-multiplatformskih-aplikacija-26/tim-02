import 'package:flutter/material.dart';

Future<bool> confirmDiscard(BuildContext context) async {
  final discard = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: const Text('Odbaciti izmene?'),
      content: const Text('Izmene koje nisu sačuvane biće izgubljene.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Odbaci')),
      ],
    ),
  );
  return discard ?? false;
}
