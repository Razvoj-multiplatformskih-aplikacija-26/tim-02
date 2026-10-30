import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dependencies.dart';

class DebugMenu extends StatelessWidget {
  const DebugMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final fake = context.read<AppDependencies>().fakeTactics;
    if (fake == null) return const SizedBox.shrink();
    void reload() => context.read<TacticsBloc>().add(const TacticsRequested());
    return PopupMenuButton<void>(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            fake.failingRequests = 1;
            reload();
          },
          child: const Text('Simuliraj grešku'),
        ),
        PopupMenuItem(
          onTap: () {
            fake.emptyResponses = 1;
            reload();
          },
          child: const Text('Prazan odgovor'),
        ),
      ],
    );
  }
}
