import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/listener_wrapper.dart";
import "package:wcas_frontend/core/services/session/cubit.dart";

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(SessionState());
  });

  group("SessionWrapper", () {
    testWidgets("calls userInteracted on tap and pan",
        (WidgetTester tester) async {
      final mockCubit = MockSessionCubit();
      when(mockCubit.userInteracted).thenAnswer((_) {});
      when(() => mockCubit.stream)
          .thenAnswer((_) => const Stream<SessionState>.empty());
      when(() => mockCubit.state).thenReturn(SessionState());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SessionCubit>.value(
            value: mockCubit,
            child: SessionWrapper(
              child: Container(color: Colors.blue, width: 100, height: 100),
            ),
          ),
        ),
      );

      // Tap
      await tester.tap(find.byType(SessionWrapper));
      await tester.pump();
      verify(mockCubit.userInteracted).called(greaterThan(0));

      // Pan
      await tester.drag(find.byType(SessionWrapper), const Offset(10, 0));
      await tester.pump();
      verify(mockCubit.userInteracted).called(greaterThan(0));
    });
  });
}
