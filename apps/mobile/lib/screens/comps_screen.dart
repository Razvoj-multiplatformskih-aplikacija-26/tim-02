import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

class CompsScreen extends StatelessWidget {
  const CompsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KOMPOZICIJE')),
      body: BlocBuilder<TacticsBloc, TacticsState>(
        builder: (context, state) => switch (state) {
          TacticsLoading() => const LoadingView(),
          TacticsFailure() => FailureView(onRetry: () => context.read<TacticsBloc>().add(const TacticsRequested())),
          TacticsEmpty() => const EmptyView(title: 'Za ovaj patch još nema kompozicija.'),
          TacticsLoaded() => CompsView(patch: state.tierList.patch, comps: state.comps),
        },
      ),
    );
  }
}
