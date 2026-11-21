import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../text/serbian.dart';

Future<bool> confirmArchive(BuildContext context, Tactic tactic) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: const Text('Arhivirati taktiku?'),
      content: Text(
        tactic.status is Draft
            ? 'Arhivirani nacrt ne može da se vrati.'
            : 'Arhivirana taktika više nije javno dostupna i ne može da se vrati.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(TacticAction.archive.label)),
      ],
    ),
  );
  return confirmed ?? false;
}
