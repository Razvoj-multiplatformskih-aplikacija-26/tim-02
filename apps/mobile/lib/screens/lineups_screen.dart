import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

class LineupsScreen extends StatelessWidget {
  const LineupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MOJE POSTAVE')),
      body: BlocBuilder<LineupsBloc, LineupsState>(
        builder: (context, state) => switch (state) {
          LineupsLoading() => const LoadingView(),
          LineupsFailure() => FailureView(onRetry: () => context.read<LineupsBloc>().add(const LineupsRequested())),
          LineupsLoaded(lineups: []) => const EmptyView(title: 'Još nemate postava.'),
          LineupsLoaded(:final lineups) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lineup.name.text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            formatChampionCount(lineup.lineup.placements.length),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          LineupBoard(lineup: lineup.lineup),
        ],
      ),
    );
  }
}
