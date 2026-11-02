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
    switch (state.status) {
      case LineupEditorStatus.saved:
        context.read<LineupsBloc>().add(LineupSaved(state.saved!));
        messenger.showSnackBar(const SnackBar(content: Text('Postava je sačuvana.')));
        context.pop();
      case LineupEditorStatus.failed:
        messenger.showSnackBar(const SnackBar(content: Text('Postava nije sačuvana.')));
      case LineupEditorStatus.editing || LineupEditorStatus.saving:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LineupEditorBloc>();
    return BlocConsumer<LineupEditorBloc, LineupEditorState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStateChanged,
      builder: (context, state) {
        final saving = state.status == LineupEditorStatus.saving;
        return Scaffold(
          appBar: AppBar(title: const Text('NOVA POSTAVA')),
          body: BlocBuilder<LineupsBloc, LineupsState>(
            builder: (context, lineups) => switch (lineups) {
              LineupsLoading() => const LoadingView(),
              LineupsFailure() => FailureView(onRetry: () => context.read<LineupsBloc>().add(const LineupsRequested())),
              LineupsLoaded(:final catalog) => _Editor(state: state, catalog: catalog),
            },
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton(
              onPressed: saving ? null : () => bloc.add(const LineupEditorSubmitted()),
              child: saving
                  ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Sačuvaj'),
            ),
          ),
        );
      },
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.state, required this.catalog});

  final LineupEditorState state;
  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<LineupEditorBloc>();
    final placed = state.placed;
    final error = placed?.errorOrNull;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Naziv postave', errorText: state.nameError?.message),
          textCapitalization: TextCapitalization.sentences,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onChanged: (text) => bloc.add(LineupNameChanged(text)),
        ),
        const SizedBox(height: 32),
        Semantics(
          header: true,
          child: Text('Dodaj šampiona', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        _Picker<Champion>(
          label: 'Šampion',
          value: state.champion,
          options: {for (final champion in catalog.champions) champion: champion.name},
          onChanged: (champion) => bloc.add(LineupUnitChanged(champion: champion)),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Picker<int>(
                label: 'Red',
                value: state.row,
                options: {for (var row = 0; row < HexPosition.rows; row++) row: '${row + 1}'},
                onChanged: (row) => bloc.add(LineupUnitChanged(row: row)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Picker<int>(
                label: 'Kolona',
                value: state.column,
                options: {for (var column = 0; column < HexPosition.columns; column++) column: '${column + 1}'},
                onChanged: (column) => bloc.add(LineupUnitChanged(column: column)),
              ),
            ),
          ],
        ),
        if (error != null && error is! TooManyItems) _ErrorText(error.message),
        const SizedBox(height: 12),
        if (state.items.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (index, item) in state.items.indexed)
                InputChip(
                  avatar: ItemIcon(item: item, size: 24),
                  label: Text(item.name),
                  onDeleted: () => bloc.add(LineupItemRemoved(index)),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        _Picker<Item>(
          label: 'Dodaj predmet',
          value: null,
          options: {for (final item in catalog.items) item: item.name},
          onChanged: (item) => bloc.add(LineupItemAdded(item)),
        ),
        if (error is TooManyItems) _ErrorText(error.message),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: placed is Success ? () => bloc.add(const LineupChampionPlaced()) : null,
          icon: const Icon(Icons.add),
          label: const Text('Postavi na tablu'),
        ),
        const SizedBox(height: 32),
        LineupBoard(lineup: state.lineup),
        const SizedBox(height: 16),
        for (final placement in state.lineup.placements)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: UnitHex(unit: placement.unit, size: 44),
            title: Text(placement.unit.champion.name),
            subtitle: Text('Red ${placement.position.row + 1} · Kolona ${placement.position.column + 1}'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Ukloni',
              onPressed: () => bloc.add(LineupChampionRemoved(placement.position)),
            ),
          ),
      ],
    );
  }
}

class _Picker<T> extends StatelessWidget {
  const _Picker({required this.label, required this.value, required this.options, required this.onChanged});

  final String label;
  final T? value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      isEmpty: value == null,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: [
            for (final MapEntry(key: option, value: text) in options.entries)
              DropdownMenuItem(value: option, child: Text(text)),
          ],
          onChanged: (option) {
            if (option != null) onChanged(option);
          },
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        liveRegion: true,
        child: Text(text, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
      ),
    );
  }
}
