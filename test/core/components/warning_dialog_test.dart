import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/warning_dialog.dart";
import "package:wcas_frontend/core/services/session/cubit.dart";

class MockSessionCubit extends Mock implements SessionCubit {}

class TestSessionWarningDialog extends SessionWarningDialog {
  const TestSessionWarningDialog({super.key});

  static int logoutPressedCount = 0;

  static void reset() {
    logoutPressedCount = 0;
  }

  @override
  Future<void> onLogoutPressed() async {
    logoutPressedCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSessionCubit mockSessionCubit;

  setUpAll(() {
    registerFallbackValue(SessionState());
  });

  setUp(() {
    mockSessionCubit = MockSessionCubit();
    TestSessionWarningDialog.reset();

    when(() => mockSessionCubit.stream)
        .thenAnswer((_) => const Stream<SessionState>.empty());
    when(() => mockSessionCubit.state).thenReturn(SessionState());
    when(() => mockSessionCubit.continueSession()).thenReturn(null);
    when(() => mockSessionCubit.userInteracted()).thenReturn(null);
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    SessionState? state,
    Widget? child,
  }) async {
    tester.view.physicalSize = const Size(2200, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    when(() => mockSessionCubit.state).thenReturn(state ?? SessionState());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SessionCubit>.value(
          value: mockSessionCubit,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 1800,
                child: child ?? const SessionWarningDialog(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
  }

  group("SessionWarningDialog - constructor", () {
    test("creates widget without key", () {
      const widget = SessionWarningDialog();

      expect(widget, isA<SessionWarningDialog>());
      expect(widget, isA<StatelessWidget>());
      expect(widget.key, isNull);
    });

    test("creates widget with key", () {
      const key = Key("session-warning-dialog");
      const widget = SessionWarningDialog(key: key);

      expect(widget.key, key);
    });
  });

  group("SessionWarningDialog - build", () {
    testWidgets("displays popup content localization key", (tester) async {
      await pumpDialog(tester);

      expect(
        find.text("common.session.gracePeriodPopupContent"),
        findsOneWidget,
      );
    });

    testWidgets("displays logout and continue button localization keys",
        (tester) async {
      await pumpDialog(tester);

      expect(
        find.text("common.session.gracePeriodLogoutButton"),
        findsOneWidget,
      );
      expect(
        find.text("common.session.gracePeriodContinueButton"),
        findsOneWidget,
      );
    });

    testWidgets("displays 00:00 when minute and second are null",
        (tester) async {
      await pumpDialog(
        tester,
        state: SessionState(),
      );

      expect(find.text("00:00"), findsOneWidget);
    });

    testWidgets("displays padded minute and second values", (tester) async {
      await pumpDialog(
        tester,
        state: SessionState(
          minuteRemaining: 2,
          secondsRemaining: 5,
        ),
      );

      expect(find.text("02:05"), findsOneWidget);
    });

    testWidgets("displays already two digit minute and second values",
        (tester) async {
      await pumpDialog(
        tester,
        state: SessionState(
          minuteRemaining: 12,
          secondsRemaining: 45,
        ),
      );

      expect(find.text("12:45"), findsOneWidget);
    });

    testWidgets("displays zero minute and positive second", (tester) async {
      await pumpDialog(
        tester,
        state: SessionState(
          minuteRemaining: 0,
          secondsRemaining: 9,
        ),
      );

      expect(find.text("00:09"), findsOneWidget);
    });

    testWidgets("displays positive minute and zero second", (tester) async {
      await pumpDialog(
        tester,
        state: SessionState(
          minuteRemaining: 7,
          secondsRemaining: 0,
        ),
      );

      expect(find.text("07:00"), findsOneWidget);
    });

    testWidgets("timer text has center alignment and custom style",
        (tester) async {
      await pumpDialog(
        tester,
        state: SessionState(
          minuteRemaining: 1,
          secondsRemaining: 30,
        ),
      );

      final timerText = tester.widget<Text>(find.text("01:30"));

      expect(timerText.textAlign, TextAlign.center);
      expect(timerText.style?.fontSize, 24);
      expect(timerText.style?.color, isNotNull);
    });

    testWidgets("content text has left alignment", (tester) async {
      await pumpDialog(tester);

      final contentText = tester.widget<Text>(
        find.text("common.session.gracePeriodPopupContent"),
      );

      expect(contentText.textAlign, TextAlign.left);
    });
  });

  group("SessionWarningDialog - button structure", () {
    testWidgets("buttons are inside flexible widgets", (tester) async {
      await pumpDialog(tester);

      expect(find.byType(Flexible), findsNWidgets(2));
      expect(find.byType(CustomButton), findsNWidgets(2));
    });
  });

  group("SessionWarningDialog - interactions", () {
    testWidgets("continue button pops dialog and calls continueSession",
        (tester) async {
      tester.view.physicalSize = const Size(2200, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockSessionCubit.state).thenReturn(
        SessionState(
          minuteRemaining: 1,
          secondsRemaining: 10,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SessionCubit>.value(
            value: mockSessionCubit,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (_) {
                            return BlocProvider<SessionCubit>.value(
                              value: mockSessionCubit,
                              child: const AlertDialog(
                                content: SizedBox(
                                  width: 1800,
                                  child: SessionWarningDialog(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text("Open Dialog"),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text("Open Dialog"));
      await tester.pumpAndSettle();

      expect(find.byType(SessionWarningDialog), findsOneWidget);
      expect(find.text("01:10"), findsOneWidget);

      await tester.tap(find.text("common.session.gracePeriodContinueButton"));
      await tester.pumpAndSettle();

      verify(() => mockSessionCubit.continueSession()).called(1);
      expect(find.byType(SessionWarningDialog), findsNothing);
    });

    testWidgets("logout button calls onLogoutPressed callback path",
        (tester) async {
      await pumpDialog(
        tester,
        child: const TestSessionWarningDialog(),
      );

      expect(TestSessionWarningDialog.logoutPressedCount, 0);

      await tester.tap(find.text("common.session.gracePeriodLogoutButton"));
      await tester.pump();

      expect(TestSessionWarningDialog.logoutPressedCount, 1);
    });
  });

  group("SessionWarningDialog - direct method coverage", () {
    testWidgets(
        "onContinuePressed directly pops navigator and continues session",
        (tester) async {
      tester.view.physicalSize = const Size(2200, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      const dialog = SessionWarningDialog();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SessionCubit>.value(
            value: mockSessionCubit,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) {
                          return BlocProvider<SessionCubit>.value(
                            value: mockSessionCubit,
                            child: Builder(
                              builder: (dialogContext) {
                                return AlertDialog(
                                  content: ElevatedButton(
                                    onPressed: () async {
                                      await dialog.onContinuePressed(
                                        dialogContext,
                                      );
                                    },
                                    child: const Text("Continue Direct"),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("Open Direct Dialog"),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text("Open Direct Dialog"));
      await tester.pumpAndSettle();

      expect(find.text("Continue Direct"), findsOneWidget);

      await tester.tap(find.text("Continue Direct"));
      await tester.pumpAndSettle();

      verify(() => mockSessionCubit.continueSession()).called(1);
      expect(find.text("Continue Direct"), findsNothing);
    });
  });
}
