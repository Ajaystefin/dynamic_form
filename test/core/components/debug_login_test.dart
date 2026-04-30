import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/debug_login.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAlertManager extends Mock implements AlertManager {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget buildSubject() {
  return const MaterialApp(home: DebugLoginView());
}

void setScreenSize(
  WidgetTester tester, {
  double w = 1200,
  double h = 900,
}) {
  tester.view.physicalSize = Size(w, h);
  tester.view.devicePixelRatio = 1.0;
}

Future<String?> submitWithText(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump(); // controlled pump only
  final tf = tester.widget<TextField>(find.byType(TextField));
  return tf.decoration?.errorText;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockAlertManager mockAlertManager;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAlertManager = MockAlertManager();

    AlertManager.instance = mockAlertManager;

    when(
      () => mockAuthRepository.loginWithSSO(
        tokenResponse: any(named: "tokenResponse"),
        userResponse: any(named: "userResponse"),
      ),
    ).thenAnswer((_) async => null);

    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
  });

  // =========================================================================
  // _parseQueryParams coverage
  // =========================================================================

  group("_parseQueryParams", () {
    testWidgets("extracts sessionID from query string", (tester) async {
      setScreenSize(tester);
      addTearDown(tester.view.reset);

      Globals.user = FakeUser(segments: []);

      await tester.pumpWidget(buildSubject());

      final tokenJson = jsonEncode({"jwtToken": "tok", "expiresIn": 900});
      final userJson = jsonEncode({"userDetailId": 1, "userId": ""});

      final input =
          "?tokenResponse=$tokenJson&userResponse=$userJson&sessionID=SID1";

      final error = await submitWithText(tester, input);

      expect(error, isNot(contains("Missing required fields")));
      expect(Globals.sessionID, equals("SID1"));
    });

    testWidgets("parses hash routing URL", (tester) async {
      setScreenSize(tester);
      addTearDown(tester.view.reset);

      Globals.user = FakeUser(segments: []);

      await tester.pumpWidget(buildSubject());

      final tokenJson = Uri.encodeComponent(
        jsonEncode({"jwtToken": "tok", "expiresIn": 900}),
      );
      final userJson = Uri.encodeComponent(
        jsonEncode({"userDetailId": 1, "userId": ""}),
      );

      final input =
          "https://host/#/login-success?tokenResponse=$tokenJson&userResponse=$userJson&sessionID=SID2";

      final error = await submitWithText(tester, input);

      expect(error, isNot(contains("Missing required fields")));
      expect(Globals.sessionID, equals("SID2"));
    });
  });

  // =========================================================================
  // _handleSubmit error branches
  // =========================================================================

  group("_handleSubmit – errors", () {
    testWidgets("shows error when input is empty", (tester) async {
      setScreenSize(tester);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(buildSubject());

      final error = await submitWithText(tester, "");
      expect(error, equals("Please paste SSO response data"));
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    // testWidgets('shows toast when login throws', (tester) async {
    //   setScreenSize(tester);
    //   addTearDown(tester.view.reset);

    //   when(
    //     () => mockAuthRepository.loginWithSSO(
    //       tokenResponse: any(named: 'tokenResponse'),
    //       userResponse: any(named: 'userResponse'),
    //     ),
    //   ).thenThrow(Exception('SSO failed'));

    //   await tester.pumpWidget(buildSubject());

    //   final tokenJson = Uri.encodeComponent(jsonEncode({'jwtToken': 'tok'}));
    //   final userJson = Uri.encodeComponent(jsonEncode({'userDetailId': 1}));

    //   await submitWithText(
    //     tester,
    //     '?tokenResponse=$tokenJson&userResponse=$userJson',
    //   );

    //   verify(() => mockAlertManager.showFailureToast(any())).called(1);
    // });
  });

  // =========================================================================
  // Role handling
  // =========================================================================
}
// ---------------------------------------------------------------------------
// Fake User
// ---------------------------------------------------------------------------

class FakeUser implements User {
  FakeUser({
    List<dynamic>? segments,
    List<dynamic>? availableRoles,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
