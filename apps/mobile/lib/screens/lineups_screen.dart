import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class LineupsScreen extends StatelessWidget {
  const LineupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MOJE POSTAVE')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/lineups/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nova postava'),
      ),
      body: BlocBuilder<LineupsBloc, LineupsState>(
        builder: (context, state) => switch (state) {
          LineupsLoading() => const LoadingView(),
          LineupsFailure() => FailureView(onRetry: () => context.read<LineupsBloc>().add(const LineupsRequested())),
          LineupsLoaded(lineups: []) => const EmptyView(title: 'Još nemate postava.'),
          LineupsLoaded(:final lineups) => ListView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 96),
            children: [for (final lineup in lineups) _LineupCard(lineup: lineup)],
          ),
        },
      ),
    );
  }
}

class _LineupCard extends StatelessWidget {
  const _LineupCard({required this.lineup});

  final PersonalLineup lineup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/lineups/${lineup.id.value}', extra: lineup),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lineup.name.text,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                formatChampionCount(lineup.lineup.placements.length),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              LineupBoard(lineup: lineup.lineup),
            ],
          ),
        ),
      ),
    );
  }
}
