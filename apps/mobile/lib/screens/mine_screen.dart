import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'debug_menu.dart';
import 'sign_in_screen.dart';
import 'tactic_detail_screen.dart';

class MineScreen extends StatelessWidget {
  const MineScreen({super.key, required this.archived});

  final bool archived;

  Future<void> _refresh(TacticsBloc bloc) {
    final refresh = TacticsRefreshed();
    bloc.add(refresh);
    return refresh.handled;
  }

  List<Widget> _sections(BuildContext context, List<Tactic> mine) {
    List<Widget> tactics(Set<TacticStatusKind> kinds) => [
      for (final tactic in mine)
        if (kinds.contains(tactic.status.kind))
          ChampionTile(
            champion: tactic.carry,
            title: tactic.title,
            onOpen: () => context.push(
              tactic.status is Draft ? '/drafts/${tactic.id.value}' : TacticDetailScreen.pathFor(tactic.id),
            ),
          ),
    ];
    final sections = archived
        ? [
            (null, tactics({TacticStatusKind.archived})),
          ]
        : [
            (TacticStatusKind.published.label, tactics({TacticStatusKind.published, TacticStatusKind.hidden})),
            (TacticStatusKind.draft.label, tactics({TacticStatusKind.draft})),
          ];
    return [
      for (final (label, tiles) in sections)
        if (tiles.isNotEmpty) TileSection(label: label, columns: 3, children: tiles),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<SessionBloc>().state is SignedIn;
    return Scaffold(
      appBar: AppBar(
        title: Text(archived ? 'ARHIVIRANE' : 'MOJE KOMPOZICIJE'),
        actions: [
          if (signedIn)
            IconButton(
              isSelected: archived,
              icon: const Icon(Icons.archive_outlined),
              selectedIcon: const Icon(Icons.archive),
              tooltip: 'Arhivirane',
              onPressed: () => archived ? context.pop() : context.push('/mine?archived=1'),
            ),
          if (kDebugMode && signedIn) const DebugMenu(),
          const AccountButton(),
        ],
      ),
      floatingActionButton: archived || !signedIn
          ? null
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => context.push('/drafts/new'),
              icon: const Icon(Icons.add),
              label: const Text('Novi nacrt'),
            ),
      body: !signedIn
          ? const _SignedOutView()
          : RefreshIndicator(
              onRefresh: () => _refresh(context.read<TacticsBloc>()),
              child: BlocBuilder<TacticsBloc, TacticsState>(
                builder: (context, state) => switch (state) {
                  TacticsFailure(:final cause) => FailureView(
                    cause: cause,
                    onRetry: () => context.read<TacticsBloc>().add(const TacticsRequested()),
                  ),
                  TacticsLoading() => const LoadingView(),
                  _ => switch (_sections(context, state is TacticsLoaded ? state.mine : const [])) {
                    [] => EmptyView(
                      title: archived ? 'Nemate arhiviranih kompozicija.' : 'Još nemate svojih kompozicija.',
                    ),
                    final sections => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: sections),
                  },
                },
              ),
            ),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 56, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 20),
            Text(
              'Prijavite se da biste videli i čuvali svoje nacrte.',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => context.push('/login'), child: const Text('Prijavi se')),
          ],
        ),
      ),
    );
  }
}
