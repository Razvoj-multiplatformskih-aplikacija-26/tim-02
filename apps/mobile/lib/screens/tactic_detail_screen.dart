import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'debug_menu.dart';

class TacticDetailScreen extends StatelessWidget {
  const TacticDetailScreen({super.key, required this.id, required this.variant, required this.early});

  static String pathFor(TacticId id, {int variant = 0, bool early = false}) {
    final query = {if (variant > 0) 'variant': '$variant', if (early) 'early': '1'};
    return Uri(path: '/tactics/${id.value}', queryParameters: query.isEmpty ? null : query).toString();
  }

  final TacticId id;
  final int variant;
  final bool early;

  void _showNotice(BuildContext context, TacticsNotice notice) {
    final message = switch (notice) {
      TacticChanged(:final action) => action.doneMessage,
      TacticRejected(:final error) => error.message,
      TacticRequestFailed() => 'Izmena nije sačuvana.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    context.read<TacticsBloc>().add(const TacticsNoticeAcknowledged());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TacticsBloc, TacticsState>(
      listenWhen: (previous, current) => current is TacticsLoaded && current.notice != null,
      listener: (context, state) => _showNotice(context, (state as TacticsLoaded).notice!),
      builder: (context, state) => Scaffold(
        appBar: AppBar(actions: const [if (kDebugMode) DebugMenu(reloads: false)]),
        body: switch (state) {
          TacticsLoading() => const LoadingView(),
          TacticsFailure() => FailureView(onRetry: () => context.read<TacticsBloc>().add(const TacticsRequested())),
          TacticsEmpty() => const EmptyView(title: 'Taktika nije pronađena.'),
          TacticsLoaded() => switch (state.tactic(id)) {
            null => const EmptyView(title: 'Taktika nije pronađena.'),
            final tactic => TacticDetails(
              tactic: tactic,
              tier: state.tierList.tierOf(tactic),
              variant: variant,
              early: early,
              onVariantSelected: (index) => context.replace(pathFor(id, variant: index, early: early)),
              onEarlySelected: (value) => context.replace(pathFor(id, variant: variant, early: value)),
            ),
          },
        },
        bottomNavigationBar: switch (state) {
          TacticsLoaded() => _actions(context, state),
          _ => null,
        },
      ),
    );
  }

  Widget? _actions(BuildContext context, TacticsLoaded state) {
    final tactic = state.tactic(id);
    if (tactic == null) return null;
    final copy = switch (context.watch<LineupsBloc>().state) {
      LineupsLoaded(:final lineups) => lineups.where((lineup) => lineup.basedOn == id).firstOrNull,
      _ => null,
    };
    final Widget button;
    if (state.actionsFor(id).contains(TacticAction.archive)) {
      button = state.inFlightId == id
          ? OutlinedButton.icon(
              onPressed: null,
              icon: const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.5)),
              label: const Text('Arhiviranje…'),
            )
          : OutlinedButton.icon(
              onPressed: state.isBusy ? null : () => _confirmArchive(context, tactic),
              icon: const Icon(Icons.archive_outlined),
              label: Text(TacticAction.archive.label),
            );
    } else if (copy != null) {
      button = FilledButton.tonalIcon(
        onPressed: () => context.push('/lineups/${copy.id.value}', extra: copy),
        icon: const Icon(Icons.bookmark_outlined),
        label: const Text('Otvori postavu'),
      );
    } else if (tactic.authorId != state.user.id && tactic.status is Published && tactic.variants.isNotEmpty) {
      final query = {'from': id.value, if (variant > 0) 'variant': '$variant', if (early) 'early': '1'};
      button = FilledButton.tonalIcon(
        onPressed: () => context.push(Uri(path: '/lineups/new', queryParameters: query).toString()),
        icon: const Icon(Icons.bookmark_add_outlined),
        label: const Text('Sačuvaj kao postavu'),
      );
    } else {
      return null;
    }
    return SafeArea(minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: button);
  }
}

Future<void> _confirmArchive(BuildContext context, Tactic tactic) async {
  final bloc = context.read<TacticsBloc>();
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
  if (confirmed != true) return;
  bloc.add(TacticActionRequested(tactic.id, TacticAction.archive));
}
