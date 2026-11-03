import 'package:blocs/blocs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'debug_menu.dart';
import 'tactic_detail_screen.dart';

class CompsScreen extends StatelessWidget {
  const CompsScreen({super.key});

  Future<void> _refresh(TacticsBloc bloc) {
    final refresh = TacticsRefreshed();
    bloc.add(refresh);
    return refresh.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KOMPOZICIJE'), actions: const [if (kDebugMode) DebugMenu()]),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context.read<TacticsBloc>()),
        child: BlocBuilder<TacticsBloc, TacticsState>(
          builder: (context, state) => switch (state) {
            TacticsLoading() => const LoadingView(),
            TacticsFailure() => FailureView(onRetry: () => context.read<TacticsBloc>().add(const TacticsRequested())),
            TacticsEmpty() => const EmptyView(title: 'Za ovaj patch još nema kompozicija.'),
            TacticsLoaded() => CompsView(
              patch: state.tierList.patch,
              comps: state.comps,
              onOpen: (tactic) => context.push(TacticDetailScreen.pathFor(tactic.id)),
            ),
          },
        ),
      ),
    );
  }
}
