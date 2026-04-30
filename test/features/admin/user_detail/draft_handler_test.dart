import "package:easy_localization/easy_localization.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/user_detail/draft_handler.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";

void main() {
  late UserDetailsDraftHandler handler;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    handler = UserDetailsDraftHandler();
  });

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------
  UserDetailViewModel buildVm({String? userId}) {
    final vm = UserDetailViewModel();

    // ✅ REQUIRED: seed islamic dropdown options (otherwise applyDraft crashes)
    vm.islamicRelationshipUserOptions = [
      Reference(
        id: 0,
        name: "requestInformation.requestInformation.yes".tr(),
      ),
      Reference(
        id: 1,
        name: "requestInformation.requestInformation.no".tr(),
      ),
    ];

    if (userId != null) {
      vm.userDetails = User(
        id: userId,
        name: "Test User",
        userName: "test.user",
        email: "test@test.com",
        designation: "Engineer",
        department: "IT",
        createdBy: "system",
        createdDate: "2024-01-01",
        approveOnBehalfOf: true,
        approvalAccess: true,
        tranApprovalAccess: false,
        accessToVipCust: true,
        isIslamic: true,
        active: true,
        authenticated: true,
        regions: ["UAE"],
        segments: ["Retail"],
        availableRoles: [Role(code: "ADMIN")],
      );
    }

    return vm;
  }

  // ---------------------------------------------------------------------------
  // resolveDraftKey
  // ---------------------------------------------------------------------------
  test("resolveDraftKey uses userDetails id when available", () {
    final vm = buildVm(userId: "123");

    final key = handler.resolveDraftKey(vm);

    expect(key, "${vm.draftFormKey}_123");
  });

  test("resolveDraftKey falls back to draftFormKey when userDetails is null",
      () {
    final vm = buildVm();

    final key = handler.resolveDraftKey(vm);

    expect(key, vm.draftFormKey);
  });

  test("resolveDraftKey uses selectUserListItem id when present", () {
    final vm = UserDetailViewModel();
    vm.selectUserListItem = User(id: "456", name: "Selected User");

    final key = handler.resolveDraftKey(vm);

    expect(key, "${vm.draftFormKey}_456");
  });

  // ---------------------------------------------------------------------------
  // buildDraftData
  // ---------------------------------------------------------------------------
  test("buildDraftData builds full payload", () {
    final vm = buildVm(userId: "123");

    final data = handler.buildDraftData(vm);
    final user = data["user"] as Map<String, dynamic>;

    expect(user["userId"], "123");
    expect(user["name"], "Test User");
    expect(user["regions"], ["UAE"]);
    expect(user["segments"], ["Retail"]);
    expect(user["roleCodes"], ["ADMIN"]);
    expect(user["approveOnBehalfOf"], true);
  });

  // ---------------------------------------------------------------------------
  // applyDraft — guard clauses
  // ---------------------------------------------------------------------------
  test("applyDraft returns when user json missing", () {
    final vm = buildVm(userId: "123");

    handler.applyDraft(vm, {});

    expect(vm.userDetails!.name, "Test User");
  });

  test("applyDraft returns when vm.userDetails is null", () {
    final vm = buildVm();

    handler.applyDraft(vm, {
      "user": {"userId": "123"},
    });

    expect(vm.userDetails, isNull);
  });

  test("applyDraft ignores mismatched user id", () {
    final vm = buildVm(userId: "999");

    handler.applyDraft(vm, {
      "user": {"userId": "123"},
    });

    expect(vm.userDetails!.id, "999");
  });

  // ---------------------------------------------------------------------------
  // applyDraft — restore paths (NOW SAFE)
  // ---------------------------------------------------------------------------
  test("applyDraft restores roles when roleCodes provided", () {
    final vm = buildVm(userId: "123");

    handler.applyDraft(vm, {
      "user": {
        "userId": "123",
        "roleCodes": ["USER", "VIEWER"],
      },
    });

    expect(
      vm.userDetails!.availableRoles!.map((r) => r.code).toList(),
      ["USER", "VIEWER"],
    );
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  test("applyDraft clears roles when roleCodes empty", () {
    final vm = buildVm(userId: "123");

    handler.applyDraft(vm, {
      "user": {
        "userId": "123",
        "roleCodes": [],
      },
    });

    expect(vm.userDetails!.availableRoles, isEmpty);
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });

  test("applyDraft restores boolean flags correctly", () {
    final vm = buildVm(userId: "123");

    handler.applyDraft(vm, {
      "user": {
        "userId": "123",
        "approveOnBehalfOf": false,
        "approvalAccess": false,
        "tranApprovalAccess": true,
        "accessToVipCust": false,
        "isIslamic": false,
        "isActive": false,
        "authenticated": false,
      },
    });

    final user = vm.userDetails!;
    expect(user.approveOnBehalfOf, false);
    expect(user.approvalAccess, false);
    expect(user.tranApprovalAccess, true);
    expect(user.accessToVipCust, false);
    expect(user.isIslamic, false);
    expect(user.active, false);
    expect(user.authenticated, false);
    expect(vm.state.loaderStatus, LoadingStatus.loaded);
  });
}
