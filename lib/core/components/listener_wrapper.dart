import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/services/session/cubit.dart";

/// Wraps the application content and tracks user interaction
/// to keep the session active.
class SessionWrapper extends StatelessWidget {
  /// Creates a [SessionWrapper].
  SessionWrapper({
    required this.child,
    super.key,
  });

  /// Child widget.
  final Widget child;

  /// Focus node used to listen for keyboard interactions.
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final sessionCubit = context.read<SessionCubit>();

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        sessionCubit.userInteracted();
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: sessionCubit.userInteracted,
        onPanDown: (_) => sessionCubit.userInteracted(),
        child: child,
      ),
    );
  }
}
