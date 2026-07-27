import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/components/warning_dialog.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/session/cubit.dart";
import "package:wcas_frontend/core/services/session/manager.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/request.dart";

class MockAlertManager extends Mock implements AlertManager {}

class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, Object? value) async {
    _storage[box] ??= {};
    _storage[box]![key] = value;
  }

  @override
  Future<dynamic> get(String box, String key) async {
    return _storage[box]?[key];
  }

  @override
  Future<void> delete(String box, String key) async {
    _storage[box]?.remove(key);
  }

  @override
  Future<void> clearBox(String box) async {
    _storage[box]?.clear();
  }

  void clearAll() => _storage.clear();
}

class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "common": {
        "error": "Error",
        "ok": "OK",
        "session": {
          "gracePeriodPopupTitle": "Session timeout",
          "gracePeriodPopupContent": "Your session is about to expire.",
          "gracePeriodLogoutButton": "Logout",
          "gracePeriodContinueButton": "Continue",
        },
      },
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionCubit sessionCubit;
  late MockAlertManager mockAlertManager;
  late MockLocalStorageService mockStorage;

  const connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  late Duration originalSessionDuration;
  late Duration originalWarningDuration;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    originalSessionDuration = SessionManager.sessionDuration;
    originalWarningDuration = SessionManager.warningDuration;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check") {
        return ["wifi"];
      }
      return null;
    });
  });

  setUp(() {
    mockStorage = MockLocalStorageService();
    LocalStorageService().getStorage = mockStorage;

    mockAlertManager = MockAlertManager();
    AlertManager.overrideInstance = mockAlertManager;

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

    Globals.user = User(
      id: "1",
      name: "Test User",
      currentRole: Role(roleId: 1, code: "USER", bpmRole: "USER"),
    );

    Globals.request = Request(applicationRefNo: "APP123");

    sessionCubit = SessionCubit()
      ..stopSession()
      ..status = SessionStatus.active
      ..continueSession();
  });

  tearDown(() async {
    sessionCubit.stopSession();
    await sessionCubit.close();

    SessionManager.sessionDuration = originalSessionDuration;
    SessionManager.warningDuration = originalWarningDuration;

    Globals.user = null;
    Globals.request = null;
    Globals.selectedCustomer = null;

    mockStorage.clearAll();
  });

  Future<BuildContext> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(2400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late BuildContext ctx;

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale("en")],
        fallbackLocale: const Locale("en"),
        path: "unused",
        assetLoader: const TestAssetLoader(),
        child: Builder(
          builder: (easyCtx) {
            return BlocProvider.value(
              value: sessionCubit,
              child: MaterialApp(
                navigatorKey: Globals.navigatorKey,
                locale: easyCtx.locale,
                supportedLocales: easyCtx.supportedLocales,
                localizationsDelegates: easyCtx.localizationDelegates,
                home: Builder(
                  builder: (context) {
                    ctx = context;
                    return const Scaffold(body: SizedBox.expand());
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pump();
    return ctx;
  }

  test("initial state is active with empty SessionState", () {
    expect(sessionCubit.status, SessionStatus.active);
    expect(sessionCubit.state.secondsRemaining, isNull);
  });

  test("singleton instance works", () {
    expect(SessionCubit.instance, same(SessionCubit.instance));
  });

  test("userInteracted ignored when inactive", () {
    sessionCubit
      ..status = SessionStatus.inactive
      ..userInteracted();
    expect(sessionCubit.status, SessionStatus.inactive);
  });

  test("continueSession always restores active", () {
    sessionCubit
      ..status = SessionStatus.inactive
      ..continueSession();
    expect(sessionCubit.status, SessionStatus.active);
  });

  testWidgets("warning dialog renders safely", (tester) async {
    final ctx = await pumpApp(tester);
    sessionCubit.showWarningDialog(mockContext: ctx);

    await tester.pumpAndSettle();
    expect(find.byType(SessionWarningDialog), findsOneWidget);

    sessionCubit.stopSession(); // ✅ CRITICAL
  });

  testWidgets("startSession goes inactive after threshold", (tester) async {
    final ctx = await pumpApp(tester);

    SessionManager.sessionDuration = const Duration(milliseconds: 1);
    SessionManager.warningDuration = const Duration(hours: 1);

    sessionCubit.startSession(mockContext: ctx);
    await tester.pump(const Duration(seconds: 2));

    expect(sessionCubit.status, SessionStatus.inactive);

    sessionCubit.stopSession(); // ✅ CRITICAL
  });

  testWidgets("startSession twice does not duplicate timers", (tester) async {
    final ctx = await pumpApp(tester);

    SessionManager.sessionDuration = const Duration(seconds: 10);
    SessionManager.warningDuration = const Duration(seconds: 10);

    sessionCubit
      ..startSession(mockContext: ctx)
      ..startSession(mockContext: ctx);

    await tester.pump(const Duration(seconds: 1));
    expect(sessionCubit.status, SessionStatus.active);

    sessionCubit.stopSession(); // ✅ CRITICAL
  });

  testWidgets("logout triggered after full timeout", (tester) async {
    SessionManager.sessionDuration = Duration.zero;
    SessionManager.warningDuration = Duration.zero;

    sessionCubit.startSession();
    await tester.pump(const Duration(seconds: 2));

    expect(sessionCubit.status, SessionStatus.loggedOut);

    sessionCubit.stopSession(); // ✅ CRITICAL
  });

  test("logout early-return when already loggedOut", () async {
    await (sessionCubit..status = SessionStatus.loggedOut).logout();
    expect(sessionCubit.status, SessionStatus.loggedOut);
  });

  test("close completes safely", () async {
    await expectLater(sessionCubit.close(), completes);
  });
}
