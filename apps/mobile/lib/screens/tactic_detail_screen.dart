import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class TacticDetailScreen extends StatelessWidget {
  const TacticDetailScreen({super.key, required this.id, required this.variant, required this.early});

  static String pathFor(TacticId id, {int variant = 0, bool early = false}) {
    final query = {if (variant > 0) 'variant': '$variant', if (early) 'early': '1'};
    return Uri(path: '/tactics/${id.value}', queryParameters: query.isEmpty ? null : query).toString();
  }

  final TacticId id;
  final int variant;
  final bool early;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<TacticsBloc, TacticsState>(
        builder: (context, state) => switch (state) {
          TacticsLoading() => const LoadingView(),
          TacticsFailure() => FailureView(onRetry: () => context.read<TacticsBloc>().add(const TacticsRequested())),
          TacticsEmpty() => const EmptyView(title: 'Taktika nije pronađena.'),
          TacticsLoaded() => switch (state.tactic(id)) {
            null => const EmptyView(title: 'Taktika nije pronađena.'),
            final tactic => TacticDetails(
              tactic: tactic,
              patch: state.tierList.patch,
              tier: state.tierList.tierOf(id),
              variant: variant,
              early: early,
              onVariantSelected: (index) => context.replace(pathFor(id, variant: index, early: early)),
              onEarlySelected: (value) => context.replace(pathFor(id, variant: variant, early: value)),
            ),
          },
        },
      ),
    );
  }
}
