import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/services/session/cubit.dart';

class SessionWrapper extends StatelessWidget {
  final Widget child;
  final FocusNode _focusNode = FocusNode();
  SessionWrapper({super.key, required this.child});

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
          child: child),
    );
  }
}
