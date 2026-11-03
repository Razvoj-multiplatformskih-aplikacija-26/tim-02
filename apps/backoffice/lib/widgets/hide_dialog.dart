import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

Future<void> confirmHide(BuildContext context, Tactic tactic) async {
  final bloc = context.read<TacticsBloc>();
  final reason = await showDialog<HideReason>(context: context, builder: (context) => const _HideDialog());
  if (reason == null) return;
  bloc.add(TacticActionRequested(tactic.id, TacticAction.hide, reason: reason));
}

class _HideDialog extends StatefulWidget {
  const _HideDialog();

  @override
  State<_HideDialog> createState() => _HideDialogState();
}

class _HideDialogState extends State<_HideDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, value, child) {
        final parsed = HideReason.parse(value.text);
        final reason = parsed.valueOrNull;
        void submit() => Navigator.pop(context, reason);
        return AlertDialog(
          title: const Text('Sakriti taktiku?'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Taktika nestaje sa Kompozicija dok je administrator ne vrati. Autor vidi obrazloženje.'),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Obrazloženje',
                    errorText: value.text.isEmpty ? null : parsed.errorOrNull?.message,
                  ),
                  onSubmitted: reason == null ? null : (_) => submit(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
            FilledButton(onPressed: reason == null ? null : submit, child: Text(TacticAction.hide.label)),
          ],
        );
      },
    );
  }
}
