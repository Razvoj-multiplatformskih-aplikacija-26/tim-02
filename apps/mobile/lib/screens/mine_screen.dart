import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'debug_menu.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(archived ? 'ARHIVIRANE' : 'MOJE KOMPOZICIJE'),
        actions: [
          IconButton(
            isSelected: archived,
            icon: const Icon(Icons.archive_outlined),
            selectedIcon: const Icon(Icons.archive),
            tooltip: 'Arhivirane',
            onPressed: () => archived ? context.pop() : context.push('/mine?archived=1'),
          ),
          if (kDebugMode) const DebugMenu(),
        ],
      ),
      floatingActionButton: archived
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/drafts/new'),
              icon: const Icon(Icons.add),
              label: const Text('Novi nacrt'),
            ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context.read<TacticsBloc>()),
        child: BlocBuilder<TacticsBloc, TacticsState>(
          builder: (context, state) => switch (state) {
            TacticsFailure() => FailureView(onRetry: () => context.read<TacticsBloc>().add(const TacticsRequested())),
            TacticsLoading() => const LoadingView(),
            _ => switch (_sections(context, state is TacticsLoaded ? state.mine : const [])) {
              [] => EmptyView(title: archived ? 'Nemate arhiviranih kompozicija.' : 'Još nemate svojih kompozicija.'),
              final sections => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: sections),
            },
          },
        ),
      ),
    );
  }
}
