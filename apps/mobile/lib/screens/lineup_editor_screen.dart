import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class LineupEditorScreen extends StatelessWidget {
  const LineupEditorScreen({super.key});

  void _onStateChanged(BuildContext context, LineupEditorState state) {
    final messenger = ScaffoldMessenger.of(context);
    switch (state) {
      case LineupEditorState(status: LineupEditorStatus.saved, :final saved?):
        context.read<TacticsBloc>().add(TacticSaved(saved));
        messenger
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(content: Text('Nacrt je sačuvan.')));
        context.go('/mine');
      case LineupEditorState(status: LineupEditorStatus.deleted, :final id?):
        context.read<TacticsBloc>().add(TacticDeleted(id));
        messenger
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(content: Text('Nacrt je obrisan.')));
        context.go('/mine');
      case LineupEditorState(:final error?):
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
      case LineupEditorState(status: LineupEditorStatus.failed, catalog: _?):
        messenger.showSnackBar(const SnackBar(content: Text('Izmena nije sačuvana.')));
      case _:
    }
  }

  Future<void> _delete(BuildContext context) async {
    final bloc = context.read<LineupEditorBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Obrisati nacrt?'),
        content: const Text('Obrisani nacrt ne može da se vrati.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Obriši')),
        ],
      ),
    );
    if (confirmed ?? false) bloc.add(const LineupEditorDeleted());
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LineupEditorBloc>();
    return BlocConsumer<LineupEditorBloc, LineupEditorState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || (current.error != null && previous.error != current.error),
      listener: _onStateChanged,
      builder: (context, state) {
        final saving = state.status == LineupEditorStatus.saving;
        return PopScope(
          canPop: !state.dirty,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && await confirmDiscard(context) && context.mounted) context.pop();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(state.id == null ? 'NOVI NACRT' : 'UREDI NACRT'),
              actions: [
                if (state.id != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Obriši nacrt',
                    onPressed: saving ? null : () => _delete(context),
                  ),
              ],
            ),
            body: switch (state.catalog) {
              null when state.status == LineupEditorStatus.failed => FailureView(
                onRetry: () => bloc.add(const LineupEditorStarted()),
              ),
              null => const LoadingView(),
              final catalog => _Editor(state: state, catalog: catalog),
            },
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton(
                onPressed: saving || state.catalog == null ? null : () => bloc.add(const LineupEditorSubmitted()),
                child: saving
                    ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : const Text('Sačuvaj'),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _remove(BuildContext context, Placement placement) {
  final bloc = context.read<LineupEditorBloc>();
  bloc.add(LineupChampionRemoved(placement.position));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Šampion je uklonjen sa table.'),
        persist: false,
        action: SnackBarAction(label: 'Poništi', onPressed: () => bloc.add(LineupChampionRestored(placement))),
      ),
    );
}

class _Editor extends StatelessWidget {
  const _Editor({required this.state, required this.catalog});

  final LineupEditorState state;
  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<LineupEditorBloc>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        TextFormField(
          initialValue: state.name,
          decoration: InputDecoration(labelText: 'Naslov', errorText: state.nameError?.message),
          textCapitalization: TextCapitalization.sentences,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onChanged: (text) => bloc.add(LineupNameChanged(text)),
        ),
        const SizedBox(height: 24),
        LineupBoard(
          lineup: state.lineup,
          selected: state.hex,
          onTap: (position) => bloc.add(LineupHexChosen(position)),
          onMove: (from, to) => bloc.add(LineupChampionMoved(from, to)),
        ),
        const SizedBox(height: 24),
        switch (state.hex) {
          null => Text(
            'Izaberite polje na tabli.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          final hex => _HexForm(state: state, catalog: catalog, hex: hex),
        },
        if (state.lineup.placements.isNotEmpty) const SizedBox(height: 24),
        for (final placement in state.lineup.placements)
          ListTile(
            contentPadding: EdgeInsets.zero,
            selected: placement.position == state.hex,
            leading: UnitHex(unit: placement.unit, size: 44),
            title: Text(placement.unit.champion.name),
            subtitle: Text('Red ${placement.position.row + 1} · Kolona ${placement.position.column + 1}'),
            onTap: () => bloc.add(LineupHexChosen(placement.position)),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Ukloni',
              onPressed: () => _remove(context, placement),
            ),
          ),
      ],
    );
  }
}

class _HexForm extends StatelessWidget {
  const _HexForm({required this.state, required this.catalog, required this.hex});

  final LineupEditorState state;
  final Catalog catalog;
  final HexPosition hex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<LineupEditorBloc>();
    final placed = state.placed;
    final current = state.lineup.placements.where((placement) => placement.position == hex).firstOrNull;
    return Column(
      key: ValueKey(hex),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Red ${hex.row + 1} · Kolona ${hex.column + 1}',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        CatalogPicker<Champion>(
          label: 'Šampion',
          options: catalog.champions,
          name: (champion) => champion.name,
          icon: (champion) => ChampionHex(champion: champion, size: 28),
          initial: state.champion,
          onSelected: (champion) => bloc.add(LineupUnitChanged(champion: champion)),
        ),
        const SizedBox(height: 16),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 1, label: Text('1 ★')),
            ButtonSegment(value: 2, label: Text('2 ★')),
            ButtonSegment(value: 3, label: Text('3 ★')),
          ],
          selected: {state.stars},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => bloc.add(LineupUnitChanged(stars: selection.single)),
        ),
        const SizedBox(height: 16),
        if (state.items.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (index, item) in state.items.indexed)
                InputChip(
                  avatar: ItemIcon(item: item, size: 24),
                  label: Text(item.name),
                  deleteButtonTooltipMessage: 'Ukloni',
                  onDeleted: () => bloc.add(LineupItemRemoved(index)),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        CatalogPicker<Item>(
          key: ValueKey(state.items.length),
          label: 'Dodaj predmet',
          options: catalog.items,
          name: (item) => item.name,
          icon: (item) => ItemIcon(item: item, size: 24),
          onSelected: (item) => bloc.add(LineupItemAdded(item)),
        ),
        if (placed case Failure(:final error))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(error.message, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: placed is Success<Lineup> ? () => bloc.add(const LineupChampionPlaced()) : null,
          icon: const Icon(Icons.check),
          label: const Text('Postavi na tablu'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: current == null ? null : () => _remove(context, current),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Ukloni sa table'),
        ),
      ],
    );
  }
}
