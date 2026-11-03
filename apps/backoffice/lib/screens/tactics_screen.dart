import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../data/fake_tactics.dart';
import '../dependencies.dart';
import '../widgets/tactic_table.dart';

class TacticsScreen extends StatefulWidget {
  const TacticsScreen({super.key, this.filter, this.search = ''});

  final TacticStatusKind? filter;
  final String search;

  static String pathFor(TacticStatusKind? filter, {String search = ''}) {
    final query = {if (filter != null) 'state': filter.name, if (search.isNotEmpty) 'q': search};
    return Uri(path: '/tactics', queryParameters: query.isEmpty ? null : query).toString();
  }

  @override
  State<TacticsScreen> createState() => _TacticsScreenState();
}

class _TacticsScreenState extends State<TacticsScreen> {
  late final _search = TextEditingController(text: widget.search);

  TacticsBloc get _bloc => context.read<TacticsBloc>();

  @override
  void initState() {
    super.initState();
    _syncWithRoute();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TacticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter || oldWidget.search != widget.search) _syncWithRoute();
    if (_search.text != widget.search) _search.text = widget.search;
  }

  void _syncWithRoute() {
    final state = _bloc.state;
    if (state is! TacticsLoaded) return;
    if (state.filter != widget.filter) _bloc.add(TacticsFilterChanged(widget.filter));
    if (state.search != widget.search) _bloc.add(TacticsSearchChanged(widget.search));
  }

  void _simulateOutage(FakeTactics fake) {
    fake.failingRequests = 1;
    _bloc.add(const TacticsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final fake = context.read<BackofficeDependencies>().fakeTactics;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TAKTIKE'),
        actions: [
          if (kDebugMode && fake != null)
            IconButton(
              tooltip: 'Simuliraj grešku',
              onPressed: () => _simulateOutage(fake),
              icon: const Icon(Icons.cloud_off_outlined),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                spacing: 8,
                children: [
                  for (final kind in [null, ...TacticStatusKind.values])
                    ChoiceChip(
                      label: Text(kind?.label ?? 'Sve'),
                      selected: kind == widget.filter,
                      onSelected: (_) => context.go(TacticsScreen.pathFor(kind, search: widget.search)),
                    ),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                        hintText: 'Naslov ili autor',
                        prefixIcon: Icon(Icons.search),
                        prefixIconConstraints: BoxConstraints(minWidth: 40),
                        isDense: true,
                      ),
                      onChanged: (text) =>
                          Router.neglect(context, () => context.go(TacticsScreen.pathFor(widget.filter, search: text))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<TacticsBloc, TacticsState>(
        listenWhen: (previous, current) => previous is! TacticsLoaded && current is TacticsLoaded,
        listener: (context, state) => _syncWithRoute(),
        builder: (context, state) => switch (state) {
          TacticsLoading() => const LoadingView(),
          TacticsFailure() => FailureView(onRetry: () => _bloc.add(const TacticsRequested())),
          TacticsEmpty() => const EmptyView(title: 'Još nema taktika.'),
          TacticsLoaded() => TacticTable(tactics: state.visible),
        },
      ),
    );
  }
}
