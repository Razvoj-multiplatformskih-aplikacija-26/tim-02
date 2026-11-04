import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class GuardedCallbackAction<T extends Intent> extends CallbackAction<T> {
  GuardedCallbackAction({required this.enabled, required super.onInvoke});

  final bool Function() enabled;

  @override
  bool isEnabled(T intent) => enabled();
}

class HideIntent extends Intent {
  const HideIntent();
}

class RestoreIntent extends Intent {
  const RestoreIntent();
}

class EditIntent extends Intent {
  const EditIntent();
}

class ClearSelectionIntent extends Intent {
  const ClearSelectionIntent();
}

Map<ShortcutActivator, Intent> tacticShortcuts() => {
  const SingleActivator(LogicalKeyboardKey.keyH): const HideIntent(),
  const SingleActivator(LogicalKeyboardKey.keyR): const RestoreIntent(),
  const SingleActivator(LogicalKeyboardKey.keyE): const EditIntent(),
  const SingleActivator(LogicalKeyboardKey.escape): const ClearSelectionIntent(),
};
