import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'tactic_editor_event.dart';
part 'tactic_editor_state.dart';

final class TacticEditorBloc extends Bloc<TacticEditorEvent, TacticEditorState> {
  TacticEditorBloc({required this.editTactic, required this.getCatalog, required this.user, required Tactic tactic})
    : super(TacticEditorState.of(tactic)) {
    on<TacticEditorStarted>((event, emit) async {
      try {
        emit(state.copyWith(catalog: await getCatalog(), status: TacticEditorStatus.editing));
      } on Exception {
        emit(state.copyWith(status: TacticEditorStatus.failed));
      }
    });
    on<TacticTitleChanged>((event, emit) => emit(state.copyWith(title: event.text)));
    on<TacticDescriptionChanged>((event, emit) => emit(state.copyWith(description: event.text)));
    on<TacticVariantChosen>((event, emit) => emit(state.copyWith(variant: event.index).withUnit()));
    on<TacticPhaseChosen>((event, emit) => emit(state.copyWith(early: event.early).withUnit()));
    on<TacticHexChosen>((event, emit) => emit(state.selecting(event.position)));
    on<TacticUnitChanged>(
      (event, emit) => emit(
        state.withUnit(
          hex: state.hex,
          champion: event.champion ?? state.champion,
          stars: event.stars ?? state.stars,
          items: state.items,
        ),
      ),
    );
    on<TacticItemAdded>(
      (event, emit) => emit(
        state.withUnit(
          hex: state.hex,
          champion: state.champion,
          stars: state.stars,
          items: [...state.items, event.item],
        ),
      ),
    );
    on<TacticItemRemoved>(
      (event, emit) => emit(
        state.withUnit(
          hex: state.hex,
          champion: state.champion,
          stars: state.stars,
          items: [...state.items]..removeAt(event.index),
        ),
      ),
    );
    on<TacticUnitPlaced>((event, emit) {
      if (state.placed case Success(value: final board)) emit(state.copyWith(variants: state.withBoard(board)));
    });
    on<TacticUnitRemoved>((event, emit) {
      final hex = state.hex;
      if (hex != null) emit(state.copyWith(variants: state.withBoard(state.board.remove(hex))).withUnit(hex: hex));
    });
    on<TacticUnitMoved>(
      (event, emit) =>
          emit(state.copyWith(variants: state.withBoard(state.board.move(event.from, event.to))).selecting(event.to)),
    );
    on<TacticFlexAdded>((event, emit) {
      if (Unit.parse(event.champion) case Success(value: final unit)) {
        emit(state.copyWith(variants: state.withChosen((variant) => variant.copyWith(flex: [...variant.flex, unit]))));
      }
    });
    on<TacticFlexRemoved>(
      (event, emit) => emit(
        state.copyWith(
          variants: state.withChosen((variant) => variant.copyWith(flex: [...variant.flex]..removeAt(event.index))),
        ),
      ),
    );
    on<TacticPriorityAdded>((event, emit) {
      if (state.chosen?.itemPriority.contains(event.item) ?? true) return;
      emit(
        state.copyWith(
          variants: state.withChosen(
            (variant) => variant.copyWith(itemPriority: [...variant.itemPriority, event.item]),
          ),
        ),
      );
    });
    on<TacticPriorityRemoved>(
      (event, emit) => emit(
        state.copyWith(
          variants: state.withChosen(
            (variant) => variant.copyWith(itemPriority: [...variant.itemPriority]..removeAt(event.index)),
          ),
        ),
      ),
    );
    on<TacticTipChanged>(
      (event, emit) => emit(state.copyWith(variants: state.withChosen((variant) => variant.copyWith(tip: event.text)))),
    );
    on<TacticStageTipChanged>((event, emit) {
      emit(
        state.copyWith(
          variants: state.withChosen((variant) {
            final tips = {...variant.stageTips, event.stage: event.text};
            return variant.copyWith(
              stageTips: {
                for (final stage in tips.keys.toList()..sort())
                  if (tips[stage]!.trim().isNotEmpty) stage: tips[stage]!,
              },
            );
          }),
        ),
      );
    });
    on<TacticEditorSubmitted>(_onSubmitted);
  }

  final EditTactic editTactic;
  final GetCatalog getCatalog;
  final User user;

  Future<void> _onSubmitted(TacticEditorSubmitted event, Emitter<TacticEditorState> emit) async {
    if (state.status == TacticEditorStatus.saving) return;
    emit(state.copyWith(status: TacticEditorStatus.saving));
    try {
      final result = await editTactic(
        id: state.tactic.id,
        by: user,
        title: state.title,
        description: state.description,
        variants: state.variants,
      );
      switch (result) {
        case Success(:final value):
          emit(state.copyWith(tactic: value, status: TacticEditorStatus.saved));
        case Failure(:final error):
          emit(state.copyWith(status: TacticEditorStatus.editing, error: error));
      }
    } on Exception {
      emit(state.copyWith(status: TacticEditorStatus.failed));
    }
  }
}
