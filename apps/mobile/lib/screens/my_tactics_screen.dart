import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import 'debug_menu.dart';

class MyTacticsScreen extends StatelessWidget {
  const MyTacticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MOJE TAKTIKE'), actions: const [if (kDebugMode) DebugMenu()]),
      body: BlocBuilder<TacticsBloc, TacticsState>(
        builder: (context, state) => switch (state) {
          TacticsLoading() => const LoadingView(),
          TacticsFailure() => FailureView(onRetry: () => context.read<TacticsBloc>().add(const TacticsRequested())),
          TacticsEmpty() => const EmptyView(title: 'Još nemate taktika.'),
          TacticsLoaded() => switch (state.mine) {
            [] => const EmptyView(title: 'Još nemate taktika.'),
            final mine => ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final kind in TacticStatusKind.values)
                  if (mine.where((t) => t.status.kind == kind).toList() case final group when group.isNotEmpty)
                    TacticSection(label: kind.label, tactics: group),
              ],
            ),
          },
        },
      ),
    );
  }
}
