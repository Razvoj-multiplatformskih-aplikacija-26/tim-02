import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class TacticTable extends StatelessWidget {
  const TacticTable({
    super.key,
    required this.tactics,
    required this.tierList,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Tactic> tactics;
  final TierList tierList;
  final TacticId? selectedId;
  final ValueChanged<Tactic> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle.merge(
          style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          child: const _TableRow(
            cells: [Text('Naslov'), Text('Autor'), Text('Stanje'), Text('Tier'), Text('Izmenjeno')],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: tactics.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tactic = tactics[index];
              final selected = tactic.id == selectedId;
              final row = Semantics(
                selected: selected,
                child: Material(
                  color: selected ? scheme.surfaceContainerHigh : Colors.transparent,
                  child: InkWell(
                    canRequestFocus: false,
                    onTap: () => onSelect(tactic),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          start: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 3),
                        ),
                      ),
                      child: _TableRow(
                        cells: [
                          Row(
                            spacing: 12,
                            children: [
                              ChampionHex(champion: tactic.carry, size: 36),
                              Expanded(
                                child: Text(
                                  tactic.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          Text(tactic.authorName),
                          StatusBadge(status: tactic.status),
                          Text(tierList.tierOf(tactic)?.label ?? '—'),
                          Text(formatDate(tactic.updatedAt)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              return selected ? _Revealed(key: ValueKey(tactic.id), child: row) : row;
            },
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.cells});

  static const _flex = [5, 2, 2, 2, 2];

  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        spacing: 16,
        children: [
          for (final (index, cell) in cells.indexed)
            Expanded(
              flex: _flex[index],
              child: Align(alignment: AlignmentDirectional.centerStart, child: cell),
            ),
        ],
      ),
    );
  }
}

class _Revealed extends StatefulWidget {
  const _Revealed({super.key, required this.child});

  final Widget child;

  @override
  State<_Revealed> createState() => _RevealedState();
}

class _RevealedState extends State<_Revealed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(context, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
      Scrollable.ensureVisible(context, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
