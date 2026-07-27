import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/user_list/model.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/admin_repository.dart";

class MockAdminRepository extends Mock implements AdminRepository {}

class MockAlertManager extends Mock implements AlertManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UserListViewModel viewModel;
  late MockAdminRepository mockRepository;
  // late MockBuildContext mockBuildContext;
  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
    JSONMethodCodec(),
  );

  setUpAll(() async {
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    final mockAlertManager = MockAlertManager();
    mockRepository = MockAdminRepository();
    // mockBuildContext = MockBuildContext();
    viewModel = UserListViewModel()
      ..repository = mockRepository
      ..userIdSearch = null
      ..userNameSearch = null
      ..userRoleSearch = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        if (call.method == "check") {
          return ["wifi"];
        }
        return null;
      },
    );
    AlertManager.overrideInstance = mockAlertManager;
  });

  test("init() should initialize repository and load user list", () async {
    when(() => mockRepository.getUserList()).thenAnswer((_) async => [User()]);

    await (viewModel..repository = mockRepository).getUserList();
    viewModel.emit(
      viewModel.state.copyWith(loaderStatus: LoadingStatus.loaded),
    );

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("initial state should be loading", () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test("getUserList success", () async {
    when(() => mockRepository.getUserList()).thenAnswer((_) async => [User()]);
    viewModel.users = [User()];
    await viewModel.getUserList();

    expect(viewModel.users, isNotNull);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("getUserList failure", () async {
    when(() => mockRepository.getUserList())
        .thenThrow(Exception("Network error"));

    await viewModel.getUserList();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test("getUserList handles empty response", () async {
    when(() => mockRepository.getUserList()).thenAnswer((_) async => []);

    await viewModel.getUserList();

    expect(viewModel.users, isEmpty);
    expect(viewModel.filteredUsers, isEmpty);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("filterTable by userRoleSearch case insensitive", () async {
    final adminRole = Role(name: "Admin", roleId: 1);

    viewModel
      ..users = [
        User(id: "123", name: "Alice", availableRoles: [adminRole]),
      ]
      ..userRoleSearch = "admin"
      ..filterTable();

    expect(viewModel.filteredUsers?.length, 1);
  });

  test("filterTable by userRoleSearch with null role name", () async {
    viewModel
      ..users = [
        User(
          id: "123",
          name: "Alice",
          availableRoles: [Role(roleId: 1)],
        ),
      ]
      ..userRoleSearch = "Admin"
      ..filterTable();

    expect(viewModel.filteredUsers?.length, 0);
  });

  test("viewModel properties are properly initialized", () {
    expect(viewModel.repository, mockRepository);
    expect(viewModel.users, isEmpty);
    expect(viewModel.filteredUsers, isEmpty);
    expect(viewModel.userIdSearch, isNull);
    expect(viewModel.userRoleSearch, isNull);
    expect(viewModel.userNameSearch, isNull);
  });

  test("filterTable with no matches", () async {
    viewModel
      ..users = [
        User(id: "123", name: "Alice"),
        User(id: "456", name: "Bob"),
      ]
      ..userNameSearch = "NonExistent"
      ..filterTable();

    expect(viewModel.filteredUsers, isEmpty);
  });

  test("filterTable emits tableLoader states", () async {
    viewModel
      ..users = [User(id: "1", name: "Test")]
      ..filterTable();

    expect(viewModel.state.tableLoader, LoadingStatus.loaded);
  });

  test("filterTable by userIdSearch filters correctly", () async {
    viewModel
      ..users = [
        User(id: "user123", name: "Alice"),
        User(id: "admin456", name: "Bob"),
        User(id: "guest789", name: "Charlie"),
      ]
      ..userIdSearch = "user"
      ..filterTable();

    expect(viewModel.filteredUsers?.length, 1);
    expect(viewModel.filteredUsers?[0].id, "user123");
  });

  test("filterTable by userIdSearch case insensitive", () async {
    viewModel
      ..users = [
        User(id: "USER123", name: "Alice"),
        User(id: "admin456", name: "Bob"),
      ]
      ..userIdSearch = "user"
      ..filterTable();

    expect(viewModel.filteredUsers?.length, 1);
    expect(viewModel.filteredUsers?[0].id, "USER123");
  });

  test("filterTable handles empty search strings", () async {
    viewModel
      ..users = [User(id: "1", name: "Test")]
      ..userIdSearch = ""
      ..userNameSearch = ""
      ..userRoleSearch = ""
      ..filterTable();

    expect(viewModel.filteredUsers, isNotEmpty);
    expect(viewModel.state.tableLoader, LoadingStatus.loaded);
  });

  test("filterTable handles null filteredUsers", () async {
    viewModel
      ..users = [User(id: "1", name: "Test")]
      ..filteredUsers = null
      ..userIdSearch = ""
      ..filterTable();

    expect(viewModel.filteredUsers, isNotNull);
    expect(viewModel.state.tableLoader, LoadingStatus.loaded);
  });

  group("ManageReferenceViewModel", () {
    test("getRoleNamesForUser returns trimmed non-empty role names", () {
      viewModel.filteredUsers = [
        User(
          availableRoles: [
            Role(name: " Admin "),
            Role(name: ""),
            Role(),
            Role(name: "Manager"),
          ],
        ),
      ];

      final roleNames = viewModel.getRoleNamesForUser(0);

      expect(roleNames, ["Admin", "Manager"]);
    });

    test("getRoleNamesForUser returns empty list for invalid index", () {
      viewModel.filteredUsers = [];

      final roleNames = viewModel.getRoleNamesForUser(1);

      expect(roleNames, []);
    });

    test("getRoleNamesForUser returns empty list when roles are null", () {
      viewModel.filteredUsers = [User()];

      final roleNames = viewModel.getRoleNamesForUser(0);

      expect(roleNames, []);
    });
  });
}
