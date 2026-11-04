import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../data/fake_tactics.dart';
import '../dependencies.dart';
import '../shortcuts.dart';
import '../widgets/hide_dialog.dart';
import '../widgets/tactic_list.dart';
import '../widgets/tactic_panel.dart';
import '../widgets/tactic_table.dart';
import 'tactic_editor_screen.dart';

class TacticsScreen extends StatefulWidget {
  const TacticsScreen({
    super.key,
    this.filter,
    this.search = '',
    this.tier,
    this.selectedId,
    this.variant = 0,
    this.early = false,
  });

  final TacticStatusKind? filter;
  final String search;
  final Tier? tier;
  final TacticId? selectedId;
  final int variant;
  final bool early;

  static String pathFor(
    TacticStatusKind? filter, {
    String search = '',
    Tier? tier,
    TacticId? selected,
    int variant = 0,
    bool early = false,
  }) {
    final query = {
      if (filter != null) 'state': filter.name,
      if (search.isNotEmpty) 'q': search,
      if (tier != null) 'tier': tier.name,
      if (selected != null) 'selected': selected.value,
      if (variant > 0) 'variant': '$variant',
      if (early) 'early': '1',
    };
    return Uri(path: '/tactics', queryParameters: query.isEmpty ? null : query).toString();
  }

  @override
  State<TacticsScreen> createState() => _TacticsScreenState();
}

class _TacticsScreenState extends State<TacticsScreen> {
  final _tableFocus = FocusNode(debugLabel: 'tactics table');
  final _usingKeyboard = ValueNotifier(false);
  late final _search = TextEditingController(text: widget.search);
  final _searchFocus = FocusNode(debugLabel: 'search');

  TacticsBloc get _bloc => context.read<TacticsBloc>();

  @override
  void initState() {
    super.initState();
    _syncWithRoute();
  }

  @override
  void dispose() {
    _tableFocus.dispose();
    _usingKeyboard.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TacticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter ||
        oldWidget.search != widget.search ||
        oldWidget.tier != widget.tier ||
        oldWidget.selectedId != widget.selectedId) {
      _syncWithRoute();
    }
    if (_search.text != widget.search) _search.text = widget.search;
  }

  void _syncWithRoute() {
    final state = _bloc.state;
    if (state is! TacticsLoaded) return;
    if (state.filter != widget.filter) _bloc.add(TacticsFilterChanged(widget.filter));
    if (state.search != widget.search) _bloc.add(TacticsSearchChanged(widget.search));
    if (state.tier != widget.tier) _bloc.add(TacticsTierFilterChanged(widget.tier));
    if (state.selectedId != widget.selectedId) _bloc.add(TacticSelected(widget.selectedId));
  }

  void _goTo({TacticId? selected, int variant = 0, bool early = false}) => context.go(
    TacticsScreen.pathFor(
      widget.filter,
      search: widget.search,
      tier: widget.tier,
      selected: selected,
      variant: variant,
      early: early,
    ),
  );

  Tactic? get _selected => switch (_bloc.state) {
    TacticsLoaded(:final selected) => selected,
    _ => null,
  };

  bool _allows(TacticAction action) {
    final state = _bloc.state;
    final selected = _selected;
    return !_searchFocus.hasFocus &&
        state is TacticsLoaded &&
        !state.isBusy &&
        selected != null &&
        state.actionsFor(selected.id).contains(action);
  }

  void _hide() {
    if (_selected case final tactic?) confirmHide(context, tactic);
  }

  void _restore() {
    if (_selected case final tactic?) _bloc.add(TacticActionRequested(tactic.id, TacticAction.restore));
  }

  bool _editable() {
    final state = _bloc.state;
    final selected = _selected;
    return !_searchFocus.hasFocus &&
        state is TacticsLoaded &&
        !state.isBusy &&
        selected != null &&
        state.canEdit(selected.id);
  }

  void _edit() {
    if (_selected case final tactic?) context.push(TacticEditorScreen.pathFor(tactic.id));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final delta = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => -1,
      LogicalKeyboardKey.arrowDown => 1,
      _ => 0,
    };
    if (delta == 0) return KeyEventResult.ignored;
    _usingKeyboard.value = true;
    _bloc.add(TacticSelectionMoved(delta));
    return KeyEventResult.handled;
  }

  Widget _focusable(Widget child) => Focus(
    focusNode: _tableFocus,
    autofocus: true,
    onKeyEvent: _onKey,
    child: Listener(
      onPointerDown: (_) => _usingKeyboard.value = false,
      child: ListenableBuilder(
        listenable: Listenable.merge([_tableFocus, _usingKeyboard]),
        builder: (context, child) => DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: _tableFocus.hasFocus && _usingKeyboard.value
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
          child: child,
        ),
        child: child,
      ),
    ),
  );

  void _open(Tactic tactic) {
    _tableFocus.requestFocus();
    _goTo(selected: tactic.id);
  }

  void _showNotice(TacticsNotice notice) {
    final message = switch (notice) {
      TacticChanged(:final action) => action.doneMessage,
      TacticRejected(:final error) => error.message,
      TacticPlaced(:final tier) => tierChangedMessage(tier),
      TacticRequestFailed() => 'Izmena nije sačuvana.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    _bloc.add(const TacticsNoticeAcknowledged());
  }

  void _simulateOutage(FakeTactics fake) {
    fake.failingRequests = 1;
    _bloc.add(const TacticsRequested());
  }

  Widget _loaded(TacticsLoaded state, BoxConstraints constraints) {
    final selected = state.selected;
    final panel = selected == null
        ? null
        : TacticPanel(
            key: ValueKey(selected.id),
            tactic: selected,
            tier: state.tierList.tierOf(selected),
            variant: widget.variant,
            early: widget.early,
            onVariantSelected: (index) => _goTo(selected: selected.id, variant: index, early: widget.early),
            onEarlySelected: (value) => _goTo(selected: selected.id, variant: widget.variant, early: value),
            onClose: _goTo,
            busy: state.isBusy,
            onHide: state.actionsFor(selected.id).contains(TacticAction.hide) ? _hide : null,
            onRestore: state.actionsFor(selected.id).contains(TacticAction.restore) ? _restore : null,
            onEdit: state.canEdit(selected.id) ? _edit : null,
            onPlace: state.canPlace(selected.id) ? (tier) => _bloc.add(TacticTierChanged(selected.id, tier)) : null,
          );
    if (constraints.maxWidth < 840) {
      return Column(
        children: [
          Expanded(
            child: _focusable(TacticList(tactics: state.visible, selectedId: state.selectedId, onSelect: _open)),
          ),
          if (panel != null)
            SizedBox(
              height: constraints.maxHeight * 0.6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: panel,
              ),
            ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _focusable(
            TacticTable(
              tactics: state.visible,
              tierList: state.tierList,
              selectedId: state.selectedId,
              onSelect: _open,
            ),
          ),
        ),
        if (panel != null) ...[const VerticalDivider(width: 1), SizedBox(width: 360, child: panel)],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fake = context.read<BackofficeDependencies>().fakeTactics;
    return Shortcuts(
      shortcuts: tacticShortcuts(),
      child: Actions(
        actions: {
          HideIntent: GuardedCallbackAction<HideIntent>(
            enabled: () => _allows(TacticAction.hide),
            onInvoke: (_) => _hide(),
          ),
          RestoreIntent: GuardedCallbackAction<RestoreIntent>(
            enabled: () => _allows(TacticAction.restore),
            onInvoke: (_) => _restore(),
          ),
          EditIntent: GuardedCallbackAction<EditIntent>(enabled: _editable, onInvoke: (_) => _edit()),
          ClearSelectionIntent: CallbackAction<ClearSelectionIntent>(
            onInvoke: (_) {
              _bloc.add(const TacticSelected(null));
              _tableFocus.requestFocus();
              return null;
            },
          ),
        },
        child: Scaffold(
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
                          onSelected: (_) =>
                              context.go(TacticsScreen.pathFor(kind, search: widget.search, tier: widget.tier)),
                        ),
                      MenuAnchor(
                        menuChildren: [
                          for (final tier in [null, ...Tier.values])
                            MenuItemButton(
                              onPressed: () =>
                                  context.go(TacticsScreen.pathFor(widget.filter, search: widget.search, tier: tier)),
                              child: Text(tier?.label ?? 'Svi tierovi'),
                            ),
                        ],
                        builder: (context, controller, child) => ChoiceChip(
                          avatar: const Icon(Icons.leaderboard_outlined),
                          label: Text(switch (widget.tier) {
                            final tier? => 'Tier: ${tier.label}',
                            null => 'Svi tierovi',
                          }),
                          selected: widget.tier != null,
                          showCheckmark: false,
                          onSelected: (_) => controller.isOpen ? controller.close() : controller.open(),
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: TextField(
                          controller: _search,
                          focusNode: _searchFocus,
                          decoration: const InputDecoration(
                            hintText: 'Naslov ili autor',
                            prefixIcon: Icon(Icons.search),
                            prefixIconConstraints: BoxConstraints(minWidth: 40),
                            isDense: true,
                          ),
                          onChanged: (text) => Router.neglect(
                            context,
                            () => context.go(TacticsScreen.pathFor(widget.filter, search: text, tier: widget.tier)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<TacticsBloc, TacticsState>(
                listenWhen: (previous, current) => previous is! TacticsLoaded && current is TacticsLoaded,
                listener: (context, state) => _syncWithRoute(),
              ),
              BlocListener<TacticsBloc, TacticsState>(
                listenWhen: (previous, current) =>
                    previous is TacticsLoaded && current is TacticsLoaded && previous.selectedId != current.selectedId,
                listener: (context, state) {
                  final selectedId = (state as TacticsLoaded).selectedId;
                  if (selectedId != widget.selectedId) _goTo(selected: selectedId);
                },
              ),
            ],
            child: BlocConsumer<TacticsBloc, TacticsState>(
              listenWhen: (previous, current) => current is TacticsLoaded && current.notice != null,
              listener: (context, state) => _showNotice((state as TacticsLoaded).notice!),
              builder: (context, state) => switch (state) {
                TacticsLoading() => const LoadingView(),
                TacticsFailure() => FailureView(onRetry: () => _bloc.add(const TacticsRequested())),
                TacticsEmpty() => const EmptyView(title: 'Još nema taktika.'),
                TacticsLoaded() => LayoutBuilder(builder: (context, constraints) => _loaded(state, constraints)),
              },
            ),
          ),
        ),
      ),
    );
  }
}
