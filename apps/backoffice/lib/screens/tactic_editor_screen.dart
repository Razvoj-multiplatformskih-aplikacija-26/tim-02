import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

class TacticEditorScreen extends StatelessWidget {
  const TacticEditorScreen({super.key});

  static String pathFor(TacticId id) => '/tactics/${id.value}/edit';

  void _onChange(BuildContext context, TacticEditorState state) {
    final messenger = ScaffoldMessenger.of(context);
    switch (state) {
      case TacticEditorState(status: TacticEditorStatus.saved):
        context.read<TacticsBloc>().add(TacticSaved(state.tactic));
        messenger.showSnackBar(const SnackBar(content: Text('Taktika je sačuvana.')));
        context.pop();
      case TacticEditorState(error: final error?):
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
      case TacticEditorState(status: TacticEditorStatus.failed, catalog: _?):
        messenger.showSnackBar(const SnackBar(content: Text('Izmena nije sačuvana.')));
      case _:
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TacticEditorBloc, TacticEditorState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || (current.error != null && previous.error != current.error),
      listener: _onChange,
      builder: (context, state) {
        final bloc = context.read<TacticEditorBloc>();
        final saving = state.status == TacticEditorStatus.saving;
        return PopScope(
          canPop: !state.dirty,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && await confirmDiscard(context) && context.mounted) context.pop();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('UREDI TAKTIKU'),
              actions: [
                TextButton(onPressed: () => Navigator.maybePop(context), child: const Text('Odustani')),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: saving || state.catalog == null ? null : () => bloc.add(const TacticEditorSubmitted()),
                  child: saving
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Text('Sačuvaj'),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: switch (state.catalog) {
              null when state.status == TacticEditorStatus.failed => FailureView(
                onRetry: () => bloc.add(const TacticEditorStarted()),
              ),
              null => const LoadingView(),
              final catalog => LayoutBuilder(
                builder: (context, constraints) {
                  final form = _HexForm(state: state, catalog: catalog);
                  if (constraints.maxWidth < 840) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [_Content(state: state, catalog: catalog, form: form)],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          children: [_Content(state: state, catalog: catalog)],
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      SizedBox(
                        width: 360,
                        child: Material(
                          color: Theme.of(context).colorScheme.surfaceContainerLow,
                          child: ListView(padding: const EdgeInsets.all(16), children: [form]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            },
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.catalog, this.form});

  final TacticEditorState state;
  final Catalog catalog;
  final Widget? form;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TacticEditorBloc>();
    final chosen = state.chosen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: state.title,
          decoration: InputDecoration(labelText: 'Naslov', errorText: state.titleError?.message),
          onChanged: (text) => bloc.add(TacticTitleChanged(text)),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.description,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Opis'),
          onChanged: (text) => bloc.add(TacticDescriptionChanged(text)),
        ),
        const SizedBox(height: 32),
        const _Heading('Varijante'),
        if (state.variants.length > 1)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (index, variant) in state.variants.indexed)
                ChoiceChip(
                  label: Text(variant.name),
                  selected: index == state.variant,
                  onSelected: (_) => bloc.add(TacticVariantChosen(index)),
                ),
            ],
          ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Rana igra')),
              ButtonSegment(value: false, label: Text('Kasna igra')),
            ],
            selected: {state.early},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => bloc.add(TacticPhaseChosen(early: selection.single)),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: LineupBoard(
              lineup: state.board,
              selected: state.hex,
              onTap: (position) => bloc.add(TacticHexChosen(position)),
              onMove: (from, to) => bloc.add(TacticUnitMoved(from, to)),
            ),
          ),
        ),
        if (form case final form?) ...[const SizedBox(height: 24), form],
        if (chosen != null) ...[
          const SizedBox(height: 32),
          const _Heading('Fleksibilne jedinice'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (index, unit) in chosen.flex.indexed)
                InputChip(
                  avatar: ChampionHex(champion: unit.champion, size: 24),
                  label: Text(unit.champion.name),
                  deleteButtonTooltipMessage: 'Ukloni',
                  onDeleted: () => bloc.add(TacticFlexRemoved(index)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          CatalogPicker<Champion>(
            key: ValueKey(('flex', state.variant, chosen.flex.length)),
            label: 'Dodaj jedinicu',
            options: catalog.champions,
            name: (champion) => champion.name,
            icon: (champion) => ChampionHex(champion: champion, size: 28),
            onSelected: (champion) => bloc.add(TacticFlexAdded(champion)),
          ),
          const SizedBox(height: 32),
          const _Heading('Prioritet predmeta'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (index, item) in chosen.itemPriority.indexed)
                InputChip(
                  avatar: ItemIcon(item: item, size: 24),
                  label: Text('${index + 1}. ${item.name}'),
                  deleteButtonTooltipMessage: 'Ukloni',
                  onDeleted: () => bloc.add(TacticPriorityRemoved(index)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          CatalogPicker<Item>(
            key: ValueKey(('priority', state.variant, chosen.itemPriority.length)),
            label: 'Dodaj predmet',
            options: catalog.items,
            name: (item) => item.name,
            icon: (item) => ItemIcon(item: item, size: 24),
            onSelected: (item) => bloc.add(TacticPriorityAdded(item)),
          ),
          const SizedBox(height: 32),
          const _Heading('Saveti'),
          TextFormField(
            key: ValueKey(('tip', state.variant)),
            initialValue: chosen.tip,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Savet'),
            onChanged: (text) => bloc.add(TacticTipChanged(text)),
          ),
          for (final stage in const [2, 3, 4]) ...[
            const SizedBox(height: 16),
            TextFormField(
              key: ValueKey(('stage', state.variant, stage)),
              initialValue: chosen.stageTips[stage],
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(labelText: 'Faza $stage'),
              onChanged: (text) => bloc.add(TacticStageTipChanged(stage, text)),
            ),
          ],
        ],
      ],
    );
  }
}

class _HexForm extends StatelessWidget {
  const _HexForm({required this.state, required this.catalog});

  final TacticEditorState state;
  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<TacticEditorBloc>();
    final hex = state.hex;
    if (hex == null) {
      return Text(
        'Izaberite polje na tabli.',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    final placed = state.placed;
    final occupied = state.board.placements.any((p) => p.position == hex);
    return Column(
      key: ValueKey((state.variant, state.early, hex)),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading('Red ${hex.row + 1} · Kolona ${hex.column + 1}'),
        CatalogPicker<Champion>(
          label: 'Šampion',
          options: catalog.champions,
          name: (champion) => champion.name,
          icon: (champion) => ChampionHex(champion: champion, size: 28),
          initial: state.champion,
          onSelected: (champion) => bloc.add(TacticUnitChanged(champion: champion)),
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
          onSelectionChanged: (selection) => bloc.add(TacticUnitChanged(stars: selection.single)),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (index, item) in state.items.indexed)
              InputChip(
                avatar: ItemIcon(item: item, size: 24),
                label: Text(item.name),
                deleteButtonTooltipMessage: 'Ukloni',
                onDeleted: () => bloc.add(TacticItemRemoved(index)),
              ),
          ],
        ),
        if (state.items.isNotEmpty) const SizedBox(height: 12),
        CatalogPicker<Item>(
          key: ValueKey(state.items.length),
          label: 'Dodaj predmet',
          options: catalog.items,
          name: (item) => item.name,
          icon: (item) => ItemIcon(item: item, size: 24),
          onSelected: (item) => bloc.add(TacticItemAdded(item)),
        ),
        if (placed case Failure(:final error)) ...[
          const SizedBox(height: 8),
          Semantics(
            liveRegion: true,
            child: Text(error.message, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: placed is Success<Lineup> ? () => bloc.add(const TacticUnitPlaced()) : null,
          icon: const Icon(Icons.check),
          label: const Text('Postavi na tablu'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: occupied ? () => bloc.add(const TacticUnitRemoved()) : null,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Ukloni sa table'),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        header: true,
        child: Text(text, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
