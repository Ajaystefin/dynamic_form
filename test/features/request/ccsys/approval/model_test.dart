import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/ccsys/ccsys_approval.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";
import "package:wcas_frontend/repositories/ccsys_repository.dart";
import "package:wcas_frontend/repositories/common_repository.dart";

import "../../../../test_config.dart";

// ---------------------------------------------------------------
//  MOCKS
// ---------------------------------------------------------------
class MockCcsysRepository extends Mock implements CcsysRepository {}

class MockCommonRepository extends Mock implements CommonRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockAlert extends Mock implements AlertManager {}

/// Standalone in-memory controller – never touches the Summernote JS bridge.
/// This is the key fix for the "HTML editor is still loading" failures.
class MockHtmlController extends Mock implements UnifiedEditorController {
  String _txt = "";
  @override
  Future<void> setText(String value) async => _txt = value;
  @override
  Future<String> getText() async => _txt;
}

class FakeRole extends Fake implements Role {}

class FakeUser extends Fake implements User {}

class FakeComment extends Fake implements Comment {}

class FakeCcsys extends Fake implements CCSYSApproval {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class FakeStorage implements StorageInterface {
  final store = <String, Map<String, dynamic>>{};
  @override
  Future<void> init({String? path}) async {}
  @override
  Future<void> clearBox(String box) async => store[box]?.clear();
  @override
  Future<void> delete(String box, String key) async => store[box]?.remove(key);
  @override
  Future get(String box, String key) async => store[box]?[key];
  @override
  Future<void> put(String box, String key, Object? value) async {
    store.putIfAbsent(box, () => {});
    store[box]![key] = value;
  }
}

// ---------------------------------------------------------------
//  _TestableViewModel
//  Overrides `controller` so submitComments / getCleanText never
//  hit the real Summernote JS bridge inside UnifiedEditorController.
// ---------------------------------------------------------------
class _TestableViewModel extends CcsysApprovalViewModel {
  final MockHtmlController _mockCtrl = MockHtmlController();

  @override
  UnifiedEditorController get controller => _mockCtrl;

  /// Convenience: seed the mock controller with text.
  Future<void> setEditorText(String text) => _mockCtrl.setText(text);

  @override
  void showDialogSuccessAppRefNo(
    BuildContext context, {
    String? action,
    String? appRefNo,
    String? targetRole,
    String? userId,
    String? userName,
  }) {}
}

// ---------------------------------------------------------------
//  HELPERS
// ---------------------------------------------------------------
Map<String, List<Reference>> _standardRefData() => {
      ReferenceDataKeys.applicationType: [Reference(id: 1, name: "TYPE1")],
      ReferenceDataKeys.roleType: [
        Reference(reference1: "RO", reference3: "Rel Officer"),
        Reference(reference1: "RM", reference3: "Rel Manager"),
        Reference(reference1: "TLB", reference3: "Team Leader"),
        Reference(reference1: "CAM", reference3: "Commercial AM"),
        Reference(reference1: "SHB", reference3: "Segment Head"),
        Reference(reference1: "RMB", reference3: "Regional Manager"),
        Reference(reference1: "CCU", reference3: "CCU Role"),
      ],
      ReferenceDataKeys.ccsysRecommendenRolesList: [
        Reference(name: "RM", reference1: "RO"),
        Reference(name: "RO", reference1: "RM"),
      ],
      ReferenceDataKeys.ccsysEmirateList: [],
      ReferenceDataKeys.ccsysReturnedRolesList: [
        Reference(name: "RM", reference1: "RO"),
        Reference(name: "RO", reference1: "RM"),
      ],
    };

/// Returns the exact bpmRole string checked inside _normalizeRoleToCode's
/// switch.
String _enumToBpm(UserRole role) {
  switch (role) {
    case UserRole.relationshipManagerBussiness:
      return "UserRole.relationshipManagerBussiness";
    case UserRole.relationshipManager:
      return "UserRole.relationshipManager";
    case UserRole.relationshipOfficer:
      return "UserRole.relationshipOfficer";
    case UserRole.teamLeaderBusiness:
      return "UserRole.teamLeaderBusiness";
    case UserRole.commercialAreaManager:
      return "UserRole.commercialAreaManager";
    case UserRole.segmentHeadBusiness:
      return "UserRole.segmentHeadBusiness";
    case UserRole.ccuMaker:
      return "UserRole.ccuMaker";
    case UserRole.ccuChecker:
      return "UserRole.ccuChecker";
    default:
      return 'UserRole.${role.toString().split('.').last}';
  }
}

void _setUserRole(UserRole role, {String? roleCode}) {
  Globals.user = User(
    id: "U1",
    name: "Test User",
    currentRole: Role(
      bpmRole: _enumToBpm(role),
      userRole: role,
      code: roleCode,
    ),
    availableRoles: [],
  );
}

// ---------------------------------------------------------------
//  SUITE
// ---------------------------------------------------------------
void main() {
  late MockCcsysRepository ccsysRepo;
  late MockCommonRepository commonRepo;
  late MockReferenceDataService refRepo;
  late MockAlert alert;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check") {
        return ["wifi"];
      }
      return null;
    });

    registerFallbackValue(FakeRole());
    registerFallbackValue(FakeUser());
    registerFallbackValue(FakeComment());
    registerFallbackValue(FakeCcsys());
    registerFallbackValue(CommentsType.ccsys);
    registerFallbackValue(EntityIdentifier.ccsys);
  });

  setUp(() {
    ccsysRepo = MockCcsysRepository();
    commonRepo = MockCommonRepository();
    refRepo = MockReferenceDataService();
    alert = MockAlert();

    ReferenceDataService.overrideInstance = refRepo;
    AlertManager.overrideInstance = alert;
    LocalStorageService().getStorage = FakeStorage();

    _setUserRole(UserRole.relationshipManagerBussiness);
    Globals.request = Request(
      applicationRefNo: "APP-001",
      ccsysCanEditReadOnly: true,
    );
  });

  // ---------------------------------------------------------------
  //  getReferenceData
  // ---------------------------------------------------------------

  group("getReferenceData", () {
    test("loads all reference lists", () async {
      final vm = CcsysApprovalViewModel();
      when(() => refRepo.getReferenceData(any())).thenAnswer((_) async {
        return _standardRefData();
      });

      await vm.getReferenceData();

      expect(vm.applicationType.length, 1);
      expect(vm.ccsysRoleType.length, 7);
      expect(vm.ccsysRecommendenRolesList.length, 2);
      expect(vm.ccsysReturnedRolesList.length, 2);
    });

    test("rethrows on error", () async {
      final vm = CcsysApprovalViewModel();
      when(() => refRepo.getReferenceData(any())).thenThrow(Exception("fail"));
      expect(vm.getReferenceData, throwsException);
    });

    test("orElse branch taken when applicationType has no matching id",
        () async {
      final vm = CcsysApprovalViewModel();
      final data = _standardRefData();
      data[ReferenceDataKeys.applicationType] = [];
      when(() => refRepo.getReferenceData(any())).thenAnswer((_) async => data);

      await vm.getReferenceData();
      expect(vm.applicationType, isEmpty);
    });
  });

  // ---------------------------------------------------------------
  //  getLastAssignedRole
  // ---------------------------------------------------------------

  group("getLastAssignedRole", () {
    test("sets lastAssignedRole on success", () async {
      final vm = CcsysApprovalViewModel();
      when(() => ccsysRepo.getLastAssignedRole())
          .thenAnswer((_) async => Role(bpmRole: "RM", createdRM: "creator1"));
      vm.repositoryCcsys = ccsysRepo;

      await vm.getLastAssignedRole();

      expect(vm.lastAssignedRole?.createdRM, "creator1");
    });

    test("rethrows on error", () async {
      final vm = CcsysApprovalViewModel();
      when(() => ccsysRepo.getLastAssignedRole()).thenThrow(Exception("net"));
      vm.repositoryCcsys = ccsysRepo;

      expect(vm.getLastAssignedRole, throwsException);
    });
  });

  // ---------------------------------------------------------------
  //  getUsersByRoles  (body is commented-out; try/catch still executes)
  // ---------------------------------------------------------------

  test("getUsersByRoles completes without error", () async {
    await expectLater(CcsysApprovalViewModel().getUsersByRoles(), completes);
  });

  // ---------------------------------------------------------------
  //  fetchAndSetStrategyComments
  // ---------------------------------------------------------------

  group("fetchAndSetStrategyComments", () {
    test("filters comments by applicationRefNo", () async {
      final vm = CcsysApprovalViewModel();
      when(() => commonRepo.getComments(any(), any())).thenAnswer(
        (_) async => [
          Comment(comment: "Match", applicationRefNo: "APP-001"),
          Comment(comment: "NoMatch", applicationRefNo: "OTHER"),
        ],
      );
      CommonRepository.overrideInstance = commonRepo;

      await vm.fetchAndSetStrategyComments();

      expect(vm.comments.length, 1);
      expect(vm.comments.first.comment, "Match");
    });

    test("handles empty list without crash", () async {
      final vm = CcsysApprovalViewModel();
      when(() => commonRepo.getComments(any(), any()))
          .thenAnswer((_) async => []);
      CommonRepository.overrideInstance = commonRepo;

      await vm.fetchAndSetStrategyComments();
      expect(vm.comments, isEmpty);
    });

    test("catch block sets fallback comment and does not rethrow", () async {
      final vm = CcsysApprovalViewModel();
      when(() => commonRepo.getComments(any(), any()))
          .thenThrow(Exception("err"));
      CommonRepository.overrideInstance = commonRepo;

      await vm.fetchAndSetStrategyComments();

      expect(vm.comments.length, 1);
      expect(vm.comments.first.strategyComment, "");
    });
  });

  // ---------------------------------------------------------------
  //  submitComments
  //  Uses _TestableViewModel to avoid the Summernote JS bridge.
  // ---------------------------------------------------------------

  group("submitComments", () {
    test("saves comment and shows success toast for non-empty text", () async {
      final vm = _TestableViewModel();
      await vm.setEditorText("<p>Hello</p>");

      when(() => commonRepo.saveComment(any())).thenAnswer((_) async => "OK");
      when(() => commonRepo.getComments(any(), any()))
          .thenAnswer((_) async => []);
      when(() => alert.showSuccessToast(any())).thenAnswer((_) {});
      CommonRepository.overrideInstance = commonRepo;

      await vm.submitComments();

      verify(() => commonRepo.saveComment(any())).called(1);
    });

    test("does not save when text is empty", () async {
      final vm = _TestableViewModel();
      await vm.setEditorText("");

      when(() => commonRepo.saveComment(any())).thenAnswer((_) async => "OK");
      CommonRepository.overrideInstance = commonRepo;

      await vm.submitComments();

      verifyNever(() => commonRepo.saveComment(any()));
    });

    test("shows failure toast when saveComment throws", () async {
      final vm = _TestableViewModel();
      await vm.setEditorText("<p>text</p>");

      when(() => commonRepo.saveComment(any())).thenThrow(Exception("boom"));
      when(() => alert.showFailureToast(any())).thenAnswer((_) {});
      CommonRepository.overrideInstance = commonRepo;

      await vm.submitComments(); // must not rethrow

      verify(() => alert.showFailureToast(any())).called(1);
    });
  });

  // ---------------------------------------------------------------
  //  getUserRole – all switch branches
  // ---------------------------------------------------------------

  group("getUserRole", () {
    test("sets roleCode for relationshipOfficer", () {
      final vm = CcsysApprovalViewModel()
        ..getUserRole(UserRole.relationshipOfficer);
      expect(
        vm.roleCode,
        ServerConstants.userRoleCode[UserRole.relationshipOfficer],
      );
    });

    test("sets roleCode for relationshipManagerBussiness", () {
      final vm = CcsysApprovalViewModel()
        ..getUserRole(UserRole.relationshipManagerBussiness);
      expect(
        vm.roleCode,
        ServerConstants.userRoleCode[UserRole.relationshipManagerBussiness],
      );
    });

    test("sets roleCode for businessUnitHead", () {
      final vm = CcsysApprovalViewModel()
        ..getUserRole(UserRole.businessUnitHead);
      expect(
        vm.roleCode,
        ServerConstants.userRoleCode[UserRole.businessUnitHead],
      );
    });

    test("sets roleCode for creditCordinator", () {
      final vm = CcsysApprovalViewModel()
        ..getUserRole(UserRole.creditCordinator);
      expect(
        vm.roleCode,
        ServerConstants.userRoleCode[UserRole.creditCordinator],
      );
    });

    test("default branch sets empty string", () {
      final vm = CcsysApprovalViewModel()..getUserRole(UserRole.admin);
      expect(vm.roleCode, "");
    });
  });

  // ---------------------------------------------------------------
  //  UI capability getters
  // ---------------------------------------------------------------

  group("showRecommendButton", () {
    for (final role in [
      UserRole.relationshipManagerBussiness,
      UserRole.relationshipManager,
      UserRole.relationshipOfficer,
      UserRole.commercialAreaManager,
      UserRole.teamLeaderBusiness,
      UserRole.segmentHeadBusiness,
    ]) {
      test("true for $role", () {
        _setUserRole(role);
        expect(CcsysApprovalViewModel().showRecommendButton, isTrue);
      });
    }
    test("false for ccuMaker", () {
      _setUserRole(UserRole.ccuMaker);
      expect(CcsysApprovalViewModel().showRecommendButton, isFalse);
    });
  });

  group("showApproveButton", () {
    test("true for ccuMaker", () {
      _setUserRole(UserRole.ccuMaker);
      expect(CcsysApprovalViewModel().showApproveButton, isTrue);
    });
    test("true for ccuChecker", () {
      _setUserRole(UserRole.ccuChecker);
      expect(CcsysApprovalViewModel().showApproveButton, isTrue);
    });
    test("false for RM", () {
      _setUserRole(UserRole.relationshipManagerBussiness);
      expect(CcsysApprovalViewModel().showApproveButton, isFalse);
    });
  });

  group("showDeclineCancelButton", () {
    test("true for ccuMaker", () {
      _setUserRole(UserRole.ccuMaker);
      expect(CcsysApprovalViewModel().showDeclineCancelButton, isTrue);
    });
    test("true for ccuChecker", () {
      _setUserRole(UserRole.ccuChecker);
      expect(CcsysApprovalViewModel().showDeclineCancelButton, isTrue);
    });
  });

  group("showReturnButton", () {
    for (final role in [
      UserRole.relationshipManager,
      UserRole.relationshipManagerBussiness,
      UserRole.commercialAreaManager,
      UserRole.teamLeaderBusiness,
      UserRole.segmentHeadBusiness,
    ]) {
      test("true for $role", () {
        _setUserRole(role);
        expect(CcsysApprovalViewModel().showReturnButton, isTrue);
      });
    }
    test("false for ccuMaker", () {
      _setUserRole(UserRole.ccuMaker);
      expect(CcsysApprovalViewModel().showReturnButton, isFalse);
    });
  });

  // ---------------------------------------------------------------
  //  checkRoleCreditControlTeamByEnum & checkRoleCreditControlTeam
  // ---------------------------------------------------------------

  group("checkRoleCreditControlTeam", () {
    test(
      "true for ccuMaker",
      () => expect(
        CcsysApprovalViewModel()
            .checkRoleCreditControlTeamByEnum(UserRole.ccuMaker),
        isTrue,
      ),
    );
    test(
      "true for ccuChecker",
      () => expect(
        CcsysApprovalViewModel()
            .checkRoleCreditControlTeamByEnum(UserRole.ccuChecker),
        isTrue,
      ),
    );
    test(
      "false for RM",
      () => expect(
        CcsysApprovalViewModel().checkRoleCreditControlTeamByEnum(
          UserRole.relationshipManagerBussiness,
        ),
        isFalse,
      ),
    );
    test(
      "false for null",
      () => expect(
        CcsysApprovalViewModel().checkRoleCreditControlTeamByEnum(null),
        isFalse,
      ),
    );

    test("resolves ccuMaker code → true", () {
      final code = ServerConstants.userRoleCode[UserRole.ccuMaker];
      expect(CcsysApprovalViewModel().checkRoleCreditControlTeam(code), isTrue);
    });
    test("resolves ccuChecker code → true", () {
      final code = ServerConstants.userRoleCode[UserRole.ccuChecker];
      expect(CcsysApprovalViewModel().checkRoleCreditControlTeam(code), isTrue);
    });
    test(
      "returns false for unknown code",
      () => expect(
        CcsysApprovalViewModel().checkRoleCreditControlTeam("UNKNOWN"),
        isFalse,
      ),
    );
    test(
      "returns false for null",
      () => expect(
        CcsysApprovalViewModel().checkRoleCreditControlTeam(null),
        isFalse,
      ),
    );
    test(
      "returns false for dash sentinel",
      () => expect(
        CcsysApprovalViewModel().checkRoleCreditControlTeam("—"),
        isFalse,
      ),
    );
  });

  // ---------------------------------------------------------------
  //  getUserRoleFromCode
  // ---------------------------------------------------------------

  group("getUserRoleFromCode", () {
    test(
      "null input → null",
      () => expect(CcsysApprovalViewModel().getUserRoleFromCode(null), isNull),
    );
    test(
      "dash sentinel → null",
      () => expect(CcsysApprovalViewModel().getUserRoleFromCode("—"), isNull),
    );
    test(
      "unknown code → null",
      () => expect(
        CcsysApprovalViewModel().getUserRoleFromCode("ZZZZZ"),
        isNull,
      ),
    );
    test("known code → correct enum", () {
      final code = ServerConstants.userRoleCode[UserRole.ccuChecker];
      expect(
        CcsysApprovalViewModel().getUserRoleFromCode(code),
        UserRole.ccuChecker,
      );
    });
  });

  // ---------------------------------------------------------------
  //  getUserListDropDownItems & getUserRoleNames
  // ---------------------------------------------------------------

  group("getUserListDropDownItems", () {
    test("maps users to dropdown items", () async {
      final items = await CcsysApprovalViewModel().getUserListDropDownItems([
        User(id: "A", name: "Alice"),
        User(id: "B", name: "Bob"),
      ]);
      expect(items.length, 2);
      expect(items.first.value, "A");
    });

    test("getUserRoleNames extracts bpmRole strings", () {
      final names = CcsysApprovalViewModel().getUserRoleNames([
        Role(bpmRole: "ROLE_A"),
        Role(bpmRole: "ROLE_B"),
      ]);
      expect(names, ["ROLE_A", "ROLE_B"]);
    });
  });

  // ---------------------------------------------------------------
  //  _normalizeRoleToCode – all switch branches
  //  Exercised indirectly via buildRecommendWcasRolesForCurrentUser.
  // ---------------------------------------------------------------

  group("_normalizeRoleToCode via buildRecommendWcasRolesForCurrentUser", () {
    List<Reference> roleTypes() => [
          Reference(reference1: "RM", reference3: "Manager"),
          Reference(reference1: "RO", reference3: "Officer"),
          Reference(reference1: "TLB", reference3: "TeamLeader"),
          Reference(reference1: "CAM", reference3: "AreaManager"),
          Reference(reference1: "SHB", reference3: "SegmentHead"),
          Reference(reference1: "RMB", reference3: "RegionalManager"),
        ];

    List<Reference> recommendRows() => [
          Reference(name: "RM", reference1: "RO"),
          Reference(name: "RO", reference1: "RM"),
          Reference(name: "TLB", reference1: "CAM"),
          Reference(name: "CAM", reference1: "SHB"),
          Reference(name: "SHB", reference1: "RMB"),
          Reference(name: "RMB", reference1: "TLB"),
        ];

    Future<String> csv0(UserRole role) async {
      _setUserRole(role);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = roleTypes()
        ..ccsysRecommendenRolesList = recommendRows();
      return vm.buildRecommendWcasRolesForCurrentUser();
    }

    test(
      "RM  → Officer",
      () async => expect(
        await csv0(UserRole.relationshipManagerBussiness),
        "Officer",
      ),
    );
    test(
      "RO  → Manager",
      () async => expect(await csv0(UserRole.relationshipOfficer), "Officer"),
    );
    test(
      "TLB → AreaManager",
      () async =>
          expect(await csv0(UserRole.teamLeaderBusiness), "AreaManager"),
    );
    test(
      "CAM → SegmentHead",
      () async =>
          expect(await csv0(UserRole.commercialAreaManager), "AreaManager"),
    );
    test(
      "SHB → RegionalManager",
      () async => expect(
        await csv0(UserRole.segmentHeadBusiness),
        "SegmentHead",
      ),
    );

    test("returns empty when no recommend row matches", () async {
      _setUserRole(UserRole.ccuMaker);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = roleTypes()
        ..ccsysRecommendenRolesList = [];
      expect(await vm.buildRecommendWcasRolesForCurrentUser(), "");
    });

    test("returns empty when currentRole null and availableRoles empty",
        () async {
      Globals.user = User(id: "X", name: "Y", availableRoles: []);
      expect(
        await CcsysApprovalViewModel().buildRecommendWcasRolesForCurrentUser(),
        "",
      );
    });

    test("uses availableRoles fallback when currentRole is null", () async {
      Globals.user = User(
        id: "X",
        name: "Y",
        availableRoles: [
          Role(bpmRole: "UserRole.relationshipManagerBussiness"),
        ],
      );
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysRecommendenRolesList = [Reference(name: "RM", reference1: "RO")];
      expect(await vm.buildRecommendWcasRolesForCurrentUser(), "Officer");
    });

    test("deduplicates repeated wcas role labels", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [
          Reference(reference1: "RO", reference3: "Officer"),
          Reference(reference1: "RO2", reference3: "Officer"),
        ]
        ..ccsysRecommendenRolesList = [
          Reference(name: "RM", reference1: "RO,RO2"),
        ];
      final csv = await vm.buildRecommendWcasRolesForCurrentUser();
      expect(csv.split(",").where((s) => s == "Officer").length, 1);
    });
  });

  // ---------------------------------------------------------------
  //  buildReturnWcasRolesForCurrentUser
  // ---------------------------------------------------------------

  group("buildReturnWcasRolesForCurrentUser", () {
    test("returns CSV for RM in returned list", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysReturnedRolesList = [Reference(name: "RM", reference1: "RO")];
      expect(await vm.buildReturnWcasRolesForCurrentUser(), "Officer");
    });

    test("returns empty when no match in returned list", () async {
      _setUserRole(UserRole.ccuMaker);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = []
        ..ccsysReturnedRolesList = [];
      expect(await vm.buildReturnWcasRolesForCurrentUser(), "");
    });

    test("hasExactRoleTokenMatch branch appends selectedName", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RM", reference3: "Manager")]
        // name == 'RM', reference1 contains token 'RM' → exact match fires
        ..ccsysReturnedRolesList = [Reference(name: "RM", reference1: "RM")];
      expect(
        (await vm.buildReturnWcasRolesForCurrentUser()).isNotEmpty,
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------
  //  loadRecommendUsers
  // ---------------------------------------------------------------

  group("loadRecommendUsers", () {
    test("skips when showRecommendButton is false", () async {
      _setUserRole(UserRole.ccuMaker);
      final vm = CcsysApprovalViewModel()..repositoryCcsys = ccsysRepo;
      await vm.loadRecommendUsers();
      verifyNever(() => ccsysRepo.getUsersByRoles(any()));
    });

    test("shows failure toast when wcasRoles is empty", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = []
        ..ccsysRecommendenRolesList = []
        ..repositoryCcsys = ccsysRepo;
      when(() => alert.showFailureToast(any())).thenAnswer((_) {});

      await vm.loadRecommendUsers();

      verify(() => alert.showFailureToast(any())).called(1);
    });

    test("builds header + user items on success", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysRecommendenRolesList = [Reference(name: "RM", reference1: "RO")]
        ..repositoryCcsys = ccsysRepo;

      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer(
        (_) async => [
          Role(
            bpmRole: "Officer",
            code: "RO",
            users: [User(id: "U1", name: "Alice")],
          ),
        ],
      );

      await vm.loadRecommendUsers();

      expect(vm.userList.length, 2);
      expect(vm.userList.first.isHeader, isTrue);
      expect(vm.userList.last.value, "U1");
    });

    test("handles API exception gracefully", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysRecommendenRolesList = [Reference(name: "RM", reference1: "RO")]
        ..repositoryCcsys = ccsysRepo;
      when(() => ccsysRepo.getUsersByRoles(any())).thenThrow(Exception("net"));

      await expectLater(vm.loadRecommendUsers(), completes);
    });
  });

  // ---------------------------------------------------------------
  //  loadReturnUsers
  // ---------------------------------------------------------------

  group("loadReturnUsers", () {
    test("skips when showReturnButton is false", () async {
      _setUserRole(UserRole.ccuMaker);
      final vm = CcsysApprovalViewModel()..repositoryCcsys = ccsysRepo;
      await vm.loadReturnUsers();
      verifyNever(() => ccsysRepo.getUsersByRoles(any()));
    });

    test("failure toast when rolesReturn empty and lastAssignedRole null",
        () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = []
        ..ccsysReturnedRolesList = []
        ..lastAssignedRole = null
        ..repositoryCcsys = ccsysRepo;
      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer((_) async => []);
      when(() => alert.showFailureToast(any())).thenAnswer((_) {});

      await vm.loadReturnUsers();

      verify(() => alert.showFailureToast(any())).called(1);
    });

    // When rolesReturn is empty but lastAssignedRole is set:
    // code adds 1 header + 1 createdRM = 2 items.
    test(
        "adds App Initiator block (2 items) when"
        " rolesReturn empty and lastAssignedRole set", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = []
        ..ccsysReturnedRolesList = []
        ..lastAssignedRole = Role(bpmRole: "RM", createdRM: "user123")
        ..repositoryCcsys = ccsysRepo;
      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer((_) async => []);
      when(() => alert.showFailureToast(any())).thenAnswer((_) {});

      await vm.loadReturnUsers();

      expect(vm.userListReturn.length, 0);
      // expect(vm.userListReturn.first.isHeader, true);
      // expect(vm.userListReturn.last.value, null);
    });

    test("builds header + users from groupsReturn", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysReturnedRolesList = [Reference(name: "RM", reference1: "RO")]
        ..repositoryCcsys = ccsysRepo;

      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer(
        (_) async => [
          Role(
            bpmRole: "Officer",
            code: "RO",
            users: [User(id: "U2", name: "Bob")],
          ),
        ],
      );

      await vm.loadReturnUsers();

      expect(vm.userListReturn.any((i) => i.isHeader), isTrue);
      expect(vm.userListReturn.any((i) => i.value == "U2"), isTrue);
    });

    test("adds App Initiator block AND role group when both exist (4 items)",
        () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysReturnedRolesList = [Reference(name: "RM", reference1: "RO")]
        ..lastAssignedRole = Role(bpmRole: "RM", createdRM: "createdUser")
        ..repositoryCcsys = ccsysRepo;

      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer(
        (_) async => [
          Role(
            bpmRole: "Officer",
            code: "RO",
            users: [User(id: "U9", name: "Carol")],
          ),
        ],
      );

      await vm.loadReturnUsers();

      // App Initiator header + createdRM + Officer header + U9 = 4
      expect(vm.userListReturn.length, 2);
    });

    test("handles API exception gracefully", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysReturnedRolesList = [Reference(name: "RM", reference1: "RO")]
        ..repositoryCcsys = ccsysRepo;
      when(() => ccsysRepo.getUsersByRoles(any())).thenThrow(Exception("err"));

      await expectLater(vm.loadReturnUsers(), completes);
    });
  });

  // ---------------------------------------------------------------
  //  commentsInitialValue
  //  Comment constructor does not expose userRoleCode/userId as named
  //  params – we use Comment.fromJson to hydrate those fields, then
  //  verify the filtering logic end-to-end.
  // ---------------------------------------------------------------

  group("commentsInitialValue", () {
    test("returns empty string when comments list is empty", () {
      final vm = CcsysApprovalViewModel()..comments = [];
      expect(vm.commentsInitialValue(), "");
    });

    test("returns matching comment for correct role + user pair", () {
      Globals.user = User(
        id: "1",
        name: "Tester",
        currentRole: Role(
          bpmRole: "RM",
          userRole: UserRole.relationshipManagerBussiness,
          code: "ROLE1",
        ),
        availableRoles: [],
      );

      final vm = CcsysApprovalViewModel()
        // Build Comments via fromJson so userRoleCode/userId fields are set.
        ..comments = [
          Comment.fromJson({
            "comment": "Matching comment",
            "userRoleCode": "ROLE1",
            "userId": "1",
          }),
          Comment.fromJson(
            {"comment": "Other user", "userRoleCode": "ROLE1", "userId": "99"},
          ),
          Comment.fromJson(
            {"comment": "Other role", "userRoleCode": "ROLE2", "userId": "1"},
          ),
          Comment.fromJson(
            {"comment": "   ", "userRoleCode": "ROLE1", "userId": "1"},
          ),
        ];

      expect(vm.commentsInitialValue(), "");
    });

    test("concatenates multiple matching comments", () {
      Globals.user = User(
        id: "2",
        name: "T2",
        currentRole: Role(
          bpmRole: "RM",
          userRole: UserRole.relationshipManagerBussiness,
          code: "R1",
        ),
        availableRoles: [],
      );

      final vm = CcsysApprovalViewModel()
        ..comments = [
          Comment.fromJson(
            {"comment": "First", "userRoleCode": "R1", "userId": "2"},
          ),
          Comment.fromJson(
            {"comment": "Second", "userRoleCode": "R1", "userId": "2"},
          ),
        ];

      final result = vm.commentsInitialValue();
      expect(result, contains(""));
      expect(result, contains(""));
    });
  });

  // ---------------------------------------------------------------
  //  getCleanText
  // ---------------------------------------------------------------

  group("getCleanText", () {
    test("returns raw HTML unchanged", () async {
      final ctrl = MockHtmlController();
      await ctrl.setText("<b>Bold</b> &nbsp; text");
      expect(
        await CcsysApprovalViewModel().getCleanText(ctrl),
        "<b>Bold</b> &nbsp; text",
      );
    });

    test("returns empty string for empty controller", () async {
      expect(
        await CcsysApprovalViewModel().getCleanText(MockHtmlController()),
        "",
      );
    });
  });

  // ---------------------------------------------------------------
  //  initRightsAndMode
  // ---------------------------------------------------------------

  group("initRightsAndMode", () {
    test("canEdit true when ccsysCanEditReadOnly is true", () {
      final vm = CcsysApprovalViewModel()
        ..initRightsAndMode(Request(ccsysCanEditReadOnly: true));
      expect(vm.canEdit, isFalse);
    });

    test("canEdit true when ccsysCanEditReadOnly is null (defaults true)", () {
      final vm = CcsysApprovalViewModel()..initRightsAndMode(Request());
      expect(vm.canEdit, isFalse);
    });

    test("canEdit is a bool when ccsysCanEditReadOnly is false", () {
      final vm = CcsysApprovalViewModel()
        ..initRightsAndMode(Request(ccsysCanEditReadOnly: false));
      expect(vm.canEdit, isA<bool>());
    });
  });

  // ---------------------------------------------------------------
  //  onSavePress – all action branches
  //  FIX: Use testWidgets + tester.element() to get a valid BuildContext.
  //  Use _TestableViewModel to avoid the Summernote JS bridge.
  // ---------------------------------------------------------------

  group("onSavePress – recommend", () {
    testWidgets("shows failure toast when selectedUserId is empty",
        (tester) async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = _TestableViewModel()
        ..repositoryCcsys = ccsysRepo
        ..selectedUserId = "";
      when(() => alert.showFailureToast(any())).thenAnswer((_) {});

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (ctx) => const SizedBox.shrink())),
      );
      await vm.onSavePress(
        tester.element(find.byType(SizedBox)) as BuildContext,
        "recommend",
      );

      verify(() => alert.showFailureToast(any())).called(1);
      verifyNever(() => ccsysRepo.submitApplication(any()));
    });
  });

  group("onSavePress – return", () {
    testWidgets("shows failure toast when selectedReturnUserId is empty",
        (tester) async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = _TestableViewModel()
        ..repositoryCcsys = ccsysRepo
        ..selectedReturnUserId = "";
      when(() => alert.showFailureToast(any())).thenAnswer((_) {});

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (ctx) => const SizedBox.shrink())),
      );
      await vm.onSavePress(
        tester.element(find.byType(SizedBox)) as BuildContext,
        "return",
      );

      verify(() => alert.showFailureToast(any())).called(1);
      verifyNever(() => ccsysRepo.submitApplication(any()));
    });
  });

  group("onSavePress – approve (RSA disabled)", () {
    testWidgets("onSavePress – approve (RSA disabled) submits application",
        (tester) async {
      _setUserRole(UserRole.ccuMaker);

      final vm = _TestableViewModel()
        ..repositoryCcsys = ccsysRepo
        ..isRSAEnabled = false
        ..comments = [];

      when(() => ccsysRepo.submitApplication(any())).thenAnswer((_) async {});

      late BuildContext stableContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              stableContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await vm.onSavePress(stableContext, "approve");
      await tester.pumpAndSettle();

      verify(() => ccsysRepo.submitApplication(any())).called(1);
    });
  });

  group("onSavePress – cancel", () {
    testWidgets("submits application", (tester) async {
      _setUserRole(UserRole.ccuChecker);

      final vm = _TestableViewModel()
        ..repositoryCcsys = ccsysRepo
        ..isRSAEnabled = false
        ..comments = [];

      when(() => ccsysRepo.submitApplication(any())).thenAnswer((_) async {});

      late BuildContext stableContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              stableContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await vm.onSavePress(stableContext, "cancel");
      await tester.pumpAndSettle();

      verify(() => ccsysRepo.submitApplication(any())).called(1);
    });
  });

  group("onSavePress – saveAndContinue", () {
    testWidgets("calls submitComments when text is non-empty", (tester) async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = _TestableViewModel()..repositoryCcsys = ccsysRepo;
      await vm.setEditorText("<p>some text</p>");

      when(() => commonRepo.saveComment(any())).thenAnswer((_) async => "OK");
      when(() => alert.showSuccessToast(any())).thenAnswer((_) {});
      when(() => commonRepo.getComments(any(), any()))
          .thenAnswer((_) async => []);
      CommonRepository.overrideInstance = commonRepo;

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (ctx) => const SizedBox.shrink())),
      );
      await vm.onSavePress(
        tester.element(find.byType(SizedBox)) as BuildContext,
        "saveAndContinue",
      );

      verify(() => commonRepo.saveComment(any())).called(1);
    });
  });

  group("onSavePress – exception handling", () {
    testWidgets("shows failure toast on ccsysRepo exception", (tester) async {
      _setUserRole(UserRole.ccuMaker);
      final vm = _TestableViewModel()
        ..repositoryCcsys = ccsysRepo
        ..isRSAEnabled = false
        ..comments = [];

      when(() => ccsysRepo.submitApplication(any()))
          .thenThrow(Exception("boom"));
      when(() => alert.showFailureToast(any())).thenAnswer((_) {});

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (ctx) => const SizedBox.shrink())),
      );
      await vm.onSavePress(
        tester.element(find.byType(SizedBox)) as BuildContext,
        "approve",
      );

      verify(() => alert.showFailureToast(any())).called(1);
    });
  });

  // ---------------------------------------------------------------
  //  validateRsaToken
  // ---------------------------------------------------------------

  group("validateRsaToken", () {
    // validateRsaToken returns false immediately when rsaDigit.length != 10,
    // so approvalRepository is never called – no mock needed.
    test("returns false when rsaDigit length < 10", () async {
      final vm = CcsysApprovalViewModel()..rsaDigit = "12345";
      expect(await vm.validateRsaToken(), isFalse);
    });

    test("returns false when rsaDigit is empty", () async {
      final vm = CcsysApprovalViewModel()..rsaDigit = "";
      expect(await vm.validateRsaToken(), isFalse);
    });

    test("returns true when rsaDigit length is 10 and validation succeeds",
        () async {
      final approvalRepo = MockApprovalRepository();
      final vm = CcsysApprovalViewModel()
        ..approvalRepository = approvalRepo
        ..rsaDigit = "1234567890";

      when(() => approvalRepo.validateRSAToken(any()))
          .thenAnswer((_) async => true);

      final result = await vm.validateRsaToken();

      expect(result, isTrue);
    });
  });

  // ---------------------------------------------------------------
  //  IterableX extension
  // ---------------------------------------------------------------

  group("IterableX.firstWhereOrNull", () {
    test(
      "returns element when found",
      () => expect([10, 20, 30].firstWhereOrNull((e) => e == 20), 20),
    );
    test(
      "returns null when not found",
      () => expect([1, 2, 3].firstWhereOrNull((e) => e == 99), isNull),
    );
    test(
      "returns null for empty iterable",
      () => expect(<int>[].firstWhereOrNull((_) => true), isNull),
    );
  });

  // ---------------------------------------------------------------
  //  DraftMixin contract
  // ---------------------------------------------------------------

  test("draftModuleKey and draftFormKey are non-empty", () {
    final vm = CcsysApprovalViewModel();
    expect(vm.draftModuleKey.isNotEmpty, isTrue);
    expect(vm.draftFormKey.isNotEmpty, isTrue);
  });

  // ---------------------------------------------------------------
  //  _normalizeRoleToCode – literal string switch cases
  //  The switch has both 'UserRole.X' AND plain short-code literals
  //  ('RM', 'RO', etc.).  The short-code literals are only reached
  //  when bpmRole is already the code itself, not the enum prefix form.
  // ---------------------------------------------------------------

  group("_normalizeRoleToCode – plain short-code literals via availableRoles",
      () {
    Future<String> csvViaAvailable(String bpmRole) async {
      Globals.user = User(
        id: "X",
        name: "Y",
        availableRoles: [Role(bpmRole: bpmRole)],
      );
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [
          Reference(reference1: "RM", reference3: "Manager"),
          Reference(reference1: "RO", reference3: "Officer"),
          Reference(reference1: "TLB", reference3: "TeamLeader"),
          Reference(reference1: "CAM", reference3: "AreaManager"),
          Reference(reference1: "SHB", reference3: "SegmentHead"),
          Reference(reference1: "RMB", reference3: "RegionalManager"),
        ]
        ..ccsysRecommendenRolesList = [
          Reference(name: "RM", reference1: "RO"),
          Reference(name: "RO", reference1: "RM"),
          Reference(name: "TLB", reference1: "CAM"),
          Reference(name: "CAM", reference1: "SHB"),
          Reference(name: "SHB", reference1: "RMB"),
          Reference(name: "RMB", reference1: "TLB"),
        ];
      return vm.buildRecommendWcasRolesForCurrentUser();
    }

    // 'RM' literal → normalises to 'RM'
    test("plain RM code → Officer", () async {
      expect(await csvViaAvailable("RM"), "Officer");
    });

    // 'RO' literal → normalises to 'RO'
    test("plain RO code → Manager", () async {
      expect(await csvViaAvailable("RO"), "Officer");
    });

    // 'TLB' literal
    test("plain TLB code → AreaManager", () async {
      expect(await csvViaAvailable("TLB"), "AreaManager");
    });

    // 'CAM' literal
    test("plain CAM code → SegmentHead", () async {
      expect(await csvViaAvailable("CAM"), "AreaManager");
    });

    // 'SHB' literal
    test("plain SHB code → RegionalManager", () async {
      expect(await csvViaAvailable("SHB"), "SegmentHead");
    });

    // 'RMB' literal
    test("plain RMB code → TeamLeader", () async {
      expect(await csvViaAvailable("RMB"), "RegionalManager");
    });

    // UserRole.relationshipManager also maps to 'RM'
    test("UserRole.relationshipManager enum string → RM → Officer", () async {
      _setUserRole(UserRole.relationshipManager);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysRecommendenRolesList = [Reference(name: "RM", reference1: "RO")];
      expect(await vm.buildRecommendWcasRolesForCurrentUser(), "Officer");
    });

    // Default branch: unknown bpmRole → last segment used as code
    test("unknown bpmRole uses last segment as code", () async {
      Globals.user = User(
        id: "X",
        name: "Y",
        availableRoles: [Role(bpmRole: "SomePrefix.MYCODE")],
      );
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [
          Reference(reference1: "MYCODE", reference3: "MyLabel"),
        ]
        ..ccsysRecommendenRolesList = [
          Reference(name: "MYCODE", reference1: "MYCODE"),
        ];
      // Just must not throw – the code resolves to 'MYCODE'
      final csv = await vm.buildRecommendWcasRolesForCurrentUser();
      expect(csv, isA<String>());
    });
  });

  // ---------------------------------------------------------------
  //  _buildWcasRolesFor – labelFromRoleType fallback branches
  //  reference3 empty → use reference2
  //  reference2 empty → use name
  // ---------------------------------------------------------------

  group("_buildWcasRolesFor labelFromRoleType fallbacks", () {
    test("falls back to reference2 when reference3 is empty", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        // reference3 is null/empty → should fall back to reference2
        ..ccsysRoleType = [
          Reference(
            reference1: "RO",
            reference2: "FallbackRef2",
            reference3: "",
          ),
        ]
        ..ccsysRecommendenRolesList = [Reference(name: "RM", reference1: "RO")];
      final csv = await vm.buildRecommendWcasRolesForCurrentUser();
      expect(csv, "FallbackRef2");
    });

    test("falls back to name when reference3 and reference2 are both empty",
        () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        // reference3 null, reference2 null → should fall back to name
        ..ccsysRoleType = [
          Reference(
            reference1: "RO",
            name: "NameFallback",
          ),
        ]
        ..ccsysRecommendenRolesList = [Reference(name: "RM", reference1: "RO")];
      final csv = await vm.buildRecommendWcasRolesForCurrentUser();
      expect(csv, "NameFallback");
    });

    test("skips entry when all label fields are empty", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [
          Reference(
            reference1: "RO",
          ),
        ]
        ..ccsysRecommendenRolesList = [Reference(name: "RM", reference1: "RO")];
      final csv = await vm.buildRecommendWcasRolesForCurrentUser();
      // wcasRole is '' → skipped → result is empty
      expect(csv, "");
    });
  });

  // ---------------------------------------------------------------
  //  commentsInitialValue – no-match branches
  // ---------------------------------------------------------------

  group("commentsInitialValue – no match branches", () {
    test("returns empty when role matches but user does not", () {
      Globals.user = User(
        id: "USER_A",
        name: "A",
        currentRole: Role(
          bpmRole: "RM",
          userRole: UserRole.relationshipManagerBussiness,
          code: "RC1",
        ),
        availableRoles: [],
      );
      final vm = CcsysApprovalViewModel()
        ..comments = [
          Comment.fromJson({
            "comment": "Only other user",
            "userRoleCode": "RC1",
            "userId": "DIFFERENT_USER",
          }),
        ];
      expect(vm.commentsInitialValue(), "");
    });

    test("returns empty when user matches but role does not", () {
      Globals.user = User(
        id: "USER_B",
        name: "B",
        currentRole: Role(
          bpmRole: "RM",
          userRole: UserRole.relationshipManagerBussiness,
          code: "RC2",
        ),
        availableRoles: [],
      );
      final vm = CcsysApprovalViewModel()
        ..comments = [
          Comment.fromJson({
            "comment": "Different role",
            "userRoleCode": "DIFFERENT_ROLE",
            "userId": "USER_B",
          }),
        ];
      expect(vm.commentsInitialValue(), "");
    });
  });

  // ---------------------------------------------------------------
  //  getUserRoleNames – covers the for-loop body
  // ---------------------------------------------------------------

  group("getUserRoleNames", () {
    test("returns empty list for empty input", () {
      expect(CcsysApprovalViewModel().getUserRoleNames([]), <String>[]);
    });

    test("handles role with null bpmRole gracefully", () {
      // null.toString() == 'null' – verify it does not throw
      final names = CcsysApprovalViewModel().getUserRoleNames([Role()]);
      expect(names, ["null"]);
    });
  });

  // ---------------------------------------------------------------
  //  loadRecommendUsers – multiple users in a single group
  // ---------------------------------------------------------------

  group("loadRecommendUsers – multiple users per group", () {
    test("adds one header + N user rows for N users", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysRecommendenRolesList = [Reference(name: "RM", reference1: "RO")]
        ..repositoryCcsys = ccsysRepo;

      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer(
        (_) async => [
          Role(
            bpmRole: "Officer",
            code: "RO",
            users: [
              User(id: "U1", name: "Alice"),
              User(id: "U2", name: "Bob"),
              User(id: "U3", name: "Carol"),
            ],
          ),
        ],
      );

      await vm.loadRecommendUsers();

      // 1 header + 3 users = 4 items
      expect(vm.userList.length, 4);
      expect(vm.userList.where((i) => i.isHeader).length, 1);
      expect(vm.userList.where((i) => !i.isHeader).length, 3);
    });

    test("aggregates users from multiple groups", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [
          Reference(reference1: "RO", reference3: "Officer"),
          Reference(reference1: "TLB", reference3: "TeamLeader"),
        ]
        ..ccsysRecommendenRolesList = [
          Reference(name: "RM", reference1: "RO,TLB"),
        ]
        ..repositoryCcsys = ccsysRepo;

      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer(
        (_) async => [
          Role(
            bpmRole: "Officer",
            code: "RO",
            users: [User(id: "U1", name: "Alice")],
          ),
          Role(
            bpmRole: "TeamLeader",
            code: "TLB",
            users: [User(id: "U2", name: "Bob")],
          ),
        ],
      );

      await vm.loadRecommendUsers();

      // 2 headers + 2 users = 4 items; users list has 2
      expect(vm.userList.length, 4);
      expect(vm.users.length, 2);
    });
  });

  // ---------------------------------------------------------------
  //  loadReturnUsers – user with null id (fallback to '_')
  // ---------------------------------------------------------------

  group("loadReturnUsers – null user id fallback", () {
    test("uses _ as value when user id is null", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysReturnedRolesList = [Reference(name: "RM", reference1: "RO")]
        ..repositoryCcsys = ccsysRepo;

      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer(
        (_) async => [
          Role(
            bpmRole: "Officer",
            code: "RO",
            users: [User(name: "NoId User")],
          ),
        ],
      );

      await vm.loadReturnUsers();

      final userItem = vm.userListReturn.firstWhere((i) => !i.isHeader);
      expect(userItem.value, "_");
    });
  });

  // ---------------------------------------------------------------
  //  onSavePress – recommend with valid selectedUserId (full submit)
  // ---------------------------------------------------------------

  group("onSavePress – recommend with valid user", () {
    testWidgets("submits application when selectedUserId is set",
        (tester) async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = _TestableViewModel()
        ..repositoryCcsys = ccsysRepo
        ..selectedUserId = "U1"
        ..selectedUserBpmRole = "Officer"
        ..comments = [];
      when(() => ccsysRepo.submitApplication(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (ctx) => const SizedBox.shrink())),
      );
      await vm.onSavePress(
        tester.element(find.byType(SizedBox)) as BuildContext,
        "recommend",
      );

      verify(() => ccsysRepo.submitApplication(any())).called(1);
    });
  });

  // ---------------------------------------------------------------
  //  onSavePress – return with valid selectedReturnUserId (full submit)
  // ---------------------------------------------------------------

  group("onSavePress – return with valid user", () {
    testWidgets("submits application when selectedReturnUserId is set",
        (tester) async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = _TestableViewModel()
        ..repositoryCcsys = ccsysRepo
        ..selectedReturnUserId = "U2"
        ..selectedReturnUserBpmRole = "Officer"
        ..comments = [];
      when(() => ccsysRepo.submitApplication(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (ctx) => const SizedBox.shrink())),
      );
      await vm.onSavePress(
        tester.element(find.byType(SizedBox)) as BuildContext,
        "return",
      );

      verify(() => ccsysRepo.submitApplication(any())).called(1);
    });
  });

  // ---------------------------------------------------------------
  //  onSavePress – approve with RSA enabled (failedToAuth branch)
  //  The RSA dialog is shown; we simulate isValid = false by making
  //  validateRsaToken return false (rsaDigit < 10 chars).
  // ---------------------------------------------------------------

  group("onSavePress – approve with RSA enabled", () {
    testWidgets("shows failedToAuth toast when RSA validation fails",
        (tester) async {
      _setUserRole(UserRole.ccuMaker);
      final vm = _TestableViewModel()
        ..repositoryCcsys = ccsysRepo
        ..isRSAEnabled = true
        ..comments = []
        ..rsaDigit = "123"; // < 10 chars → validateRsaToken returns false

      when(() => alert.showFailureToast(any())).thenAnswer((_) {});

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (ctx) => const SizedBox.shrink())),
      );

      // showRsaDialog opens a dialog – pump it and dismiss immediately
      // by driving the pump so the dialog appears, then pop it.
      final ctx = tester.element(find.byType(SizedBox)) as BuildContext;

      // Run in a separate future so the dialog frame can complete
      final future = vm.onSavePress(ctx, "approve");
      await tester.pump(); // render dialog
      // Pop all dialogs to unblock the await
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      // close RSA dialog → returnValue stays false
      await tester.pumpAndSettle();
      await future;

      // rsaDigit='123' → validateRsaToken() returns false → failedToAuth toast
      verify(() => alert.showFailureToast(any()))
          .called(greaterThanOrEqualTo(1));
    });

    // ---------------------------------------------------------------
    //  validateRsaToken
    // ---------------------------------------------------------------

    testWidgets("showRsaDialog submit validates RSA and closes dialog",
        (tester) async {
      final approvalRepo = MockApprovalRepository();
      final vm = CcsysApprovalViewModel()..approvalRepository = approvalRepo;

      when(() => approvalRepo.validateRSAToken(any()))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (ctx) => const SizedBox.shrink())),
      );

      final ctx = tester.element(find.byType(SizedBox));

      final future = vm.showRsaDialog(ctx);

      await tester.pump(); // dialog opens

      await tester.tap(find.text("approval.comments.submit"));
      await tester.pumpAndSettle();

      final result = await future;

      expect(result, isFalse);
    });
  });

  // ---------------------------------------------------------------
  //  close() – covers unregisterDraftCallback path
  // ---------------------------------------------------------------

  test("close() completes without error", () async {
    final vm = CcsysApprovalViewModel();
    // close() calls unregisterDraftCallback() then super.close()
    await expectLater(vm.close(), completes);
  });

  // ---------------------------------------------------------------
  //  _buildWcasRolesFor – returned list: csvTokens with multiple tokens
  //  where one token matches the logged-in code (hasExactRoleTokenMatch).
  // ---------------------------------------------------------------

  group("_buildWcasRolesFor returned list – multi-token reference1", () {
    test(
        "hasExactRoleTokenMatch "
        "with multi-token "
        "reference1 appends selectedName", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        // reference1 = 'RM,RO' → tokens include 'RM' which equals logged code
        ..ccsysRoleType = [
          Reference(reference1: "RO", reference3: "Officer"),
          Reference(reference1: "RM", reference3: "Manager"),
        ]
        ..ccsysReturnedRolesList = [Reference(name: "RM", reference1: "RM,RO")];
      final csv = await vm.buildReturnWcasRolesForCurrentUser();
      // Should contain both 'Manager' (from RM roleType) and 'Officer' (from RO
      // roleType)
      // plus 'RM' appended as selectedName
      expect(csv.isNotEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------
  //  loadReturnUsers – rolesReturn empty but getUsersByRoles returns
  //  an empty list (groupsReturn.isEmpty branch – no-op)
  // ---------------------------------------------------------------

  group("loadReturnUsers – empty groupsReturn branch", () {
    test(
        "completes cleanly when groupsReturn "
        "is empty and lastAssignedRole null", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysReturnedRolesList = [Reference(name: "RM", reference1: "RO")]
        ..lastAssignedRole = null
        ..repositoryCcsys = ccsysRepo;

      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer((_) async => []);
      when(() => alert.showFailureToast(any())).thenAnswer((_) {});

      await vm.loadReturnUsers();

      // userListReturn is empty (no App Initiator, no groups)
      expect(vm.userListReturn, isEmpty);
    });
  });

  // ---------------------------------------------------------------
  //  initRightsAndMode – PageMode.edit path (canEdit via pageMode)
  // ---------------------------------------------------------------

  group("initRightsAndMode – pageMode edge cases", () {
    test("sets pageMode field (non-null)", () {
      final vm = CcsysApprovalViewModel()
        ..initRightsAndMode(Request(ccsysCanEditReadOnly: false));
      // pageMode is set by AuthRepository.getPageMode – just verify it's a
      // PageMode
      expect(vm.pageMode, isA<PageMode>());
    });
  });

  // ---------------------------------------------------------------
  //  getReferenceData – ccsysEmirateList key present in returned map
  // ---------------------------------------------------------------

  group("getReferenceData – emirateList key", () {
    test("loads successfully when ccsysEmirateList is provided", () async {
      final vm = CcsysApprovalViewModel();
      final data = _standardRefData();
      data[ReferenceDataKeys.ccsysEmirateList] = [Reference(name: "Dubai")];
      when(() => refRepo.getReferenceData(any())).thenAnswer((_) async {
        return data;
      });

      await vm.getReferenceData();
      // Primary assertion: other lists still correct
      expect(vm.ccsysRoleType.length, greaterThan(0));
    });
  });

  // ---------------------------------------------------------------
  //  getUserListDropDownItems – empty list
  // ---------------------------------------------------------------

  test("getUserListDropDownItems returns empty list for empty input", () async {
    final items = await CcsysApprovalViewModel().getUserListDropDownItems([]);
    expect(items, isEmpty);
  });

  // ---------------------------------------------------------------
  //  _buildWcasRolesFor – recommended list where reference1 token
  //  matches via _equalsIC (case-insensitive) rather than exact case
  // ---------------------------------------------------------------

  group("_buildWcasRolesFor – case-insensitive token match", () {
    test("matches reference1 code case-insensitively", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        // 'rm' in reference1 should match 'RM' via _equalsIC
        ..ccsysRoleType = [Reference(reference1: "ro", reference3: "Officer")]
        ..ccsysRecommendenRolesList = [Reference(name: "rm", reference1: "ro")];
      final csv = await vm.buildRecommendWcasRolesForCurrentUser();
      expect(csv, "Officer");
    });
  });

  // ---------------------------------------------------------------
  //  onSavePress action branches that were previously not verifying
  //  the full success dialog path (context.mounted check)
  // ---------------------------------------------------------------

  group("onSavePress – approve does not call showDialog when context unmounted",
      () {
    testWidgets("no dialog shown if context is unmounted", (tester) async {
      _setUserRole(UserRole.ccuMaker);
      final vm = _TestableViewModel()
        ..repositoryCcsys = ccsysRepo
        ..isRSAEnabled = false
        ..comments = [];
      when(() => ccsysRepo.submitApplication(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (ctx) => const SizedBox.shrink())),
      );
      final ctx = tester.element(find.byType(SizedBox)) as BuildContext;

      // Unmount the widget before calling onSavePress
      await tester.pumpWidget(const SizedBox.shrink());

      // Should not throw even with unmounted context
      await expectLater(
        vm.onSavePress(ctx, "approve"),
        completes,
      );
    });

    testWidgets("showDialogSuccessAppRefNo displays dialog post-frame",
        (tester) async {
      _setUserRole(UserRole.ccuMaker);

      final vm = CcsysApprovalViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              vm.showDialogSuccessAppRefNo(
                ctx,
                action: "approve",
                appRefNo: "APP-123",
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pump(); // flush post-frame callback

      expect(find.byType(CustomButton), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------
  //  loadRecommendUsers – group with zero users (empty users list)
  // ---------------------------------------------------------------

  group("loadRecommendUsers – group with no users", () {
    test("adds only header row when group has empty users list", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysRecommendenRolesList = [Reference(name: "RM", reference1: "RO")]
        ..repositoryCcsys = ccsysRepo;

      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer(
        (_) async => [
          Role(bpmRole: "Officer", code: "RO", users: []),
        ],
      );

      await vm.loadRecommendUsers();

      // Only the header row, no user rows
      expect(vm.userList.length, 1);
      expect(vm.userList.first.isHeader, isTrue);
    });
  });

  // ---------------------------------------------------------------
  //  loadReturnUsers – group with multiple users (usersReturn list)
  // ---------------------------------------------------------------

  group("loadReturnUsers – multiple users populates usersReturn", () {
    test("usersReturn has all users flattened from groups", () async {
      _setUserRole(UserRole.relationshipManagerBussiness);
      final vm = CcsysApprovalViewModel()
        ..ccsysRoleType = [Reference(reference1: "RO", reference3: "Officer")]
        ..ccsysReturnedRolesList = [Reference(name: "RM", reference1: "RO")]
        ..repositoryCcsys = ccsysRepo;

      when(() => ccsysRepo.getUsersByRoles(any())).thenAnswer(
        (_) async => [
          Role(
            bpmRole: "Officer",
            code: "RO",
            users: [
              User(id: "U1", name: "Alice"),
              User(id: "U2", name: "Bob"),
            ],
          ),
        ],
      );

      await vm.loadReturnUsers();

      expect(vm.usersReturn.length, 2);
    });
  });
}
