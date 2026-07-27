import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:toastification/toastification.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/dashboard_repository.dart";

class MockDashboardRepository extends Mock implements DashboardRepository {}

class FakeRequest extends Fake implements Request {}

class FakeReference extends Fake implements Reference {}

class FakeUser extends Fake implements User {}

/// Spy ViewModel to verify internal calls without touching production code.
class SpyAdvancedSearchViewModel extends AdvancedSearchViewModel {
  int getUserListCalls = 0;
  int getFilteredUsersByIdCalls = 0;
  int? lastFilterId;
  List<Reference>? lastRoleData;

  Future<void> Function()? loadReferenceDataStub;
  Future<void> Function(List<Reference>)? getUserListStub;
  Future<void> Function(int)? getFilteredUsersByIdStub;

  @override
  Future<void> loadReferenceData() async {
    if (loadReferenceDataStub != null) {
      return loadReferenceDataStub!.call();
    }
    return super.loadReferenceData();
  }

  @override
  Future<void> getUserList(List<Reference> roleData) async {
    getUserListCalls++;
    lastRoleData = roleData;
    if (getUserListStub != null) {
      return getUserListStub!.call(roleData);
    }
    return super.getUserList(roleData);
  }

  @override
  Future<void> getFilteredUsersById(int filterId) async {
    getFilteredUsersByIdCalls++;
    lastFilterId = filterId;
    if (getFilteredUsersByIdStub != null) {
      return getFilteredUsersByIdStub!.call(filterId);
    }
    return super.getFilteredUsersById(filterId);
  }
}

class TestAssetLoader extends AssetLoader {
  const TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      "common": {
        "error": "Error",
      },
      "dashboard": {
        "advancedSearch": {
          "requiredFeild": "Required field",
        },
        "home": {
          "historicalApplicationTypes": "Historical Application Types",
        },
      },
    };
  }
}

Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child,
) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale("en")],
      path: "unused",
      fallbackLocale: const Locale("en"),
      startLocale: const Locale("en"),
      assetLoader: const TestAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            builder: (context, appChild) {
              return ToastificationWrapper(
                child: appChild ?? const SizedBox.shrink(),
              );
            },
            home: Scaffold(body: child),
          );
        },
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> pumpValidForm(
  WidgetTester tester,
  AdvancedSearchViewModel viewModel,
) async {
  await pumpTestApp(
    tester,
    Form(
      key: viewModel.formKey,
      child: const SizedBox.shrink(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdvancedSearchViewModel viewModel;
  late SpyAdvancedSearchViewModel spyViewModel;
  late MockDashboardRepository mockRepository;

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    registerFallbackValue(FakeRequest());
    registerFallbackValue(FakeReference());
    registerFallbackValue(FakeUser());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (call) async {
      if (call.method == "check") {
        return ["wifi"];
      }
      return null;
    });

    await EasyLocalization.ensureInitialized();
    await EnvConfig.setEnvironment();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
  });

  setUp(() {
    mockRepository = MockDashboardRepository();

    viewModel = AdvancedSearchViewModel()..repository = mockRepository;
    spyViewModel = SpyAdvancedSearchViewModel()..repository = mockRepository;

    Globals.user = null;
  });

  group("constructor / initial state", () {
    test("initial state is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.state.tableLoader, isNot(LoadingStatus.error));
      expect(viewModel.selectedSearchCriteria, isNull);
      expect(viewModel.selectedRegions, isNull);
      expect(viewModel.selectedSegments, isNull);
      expect(viewModel.selectedRoles, isNull);
      expect(viewModel.userModels, isEmpty);
      expect(viewModel.workList, isEmpty);
      expect(viewModel.filteredWorkList, isEmpty);
    });

    test("customApplicationTypeNames starts with CCSYS", () {
      expect(viewModel.customApplicationTypeNames, contains("CCSYS"));
    });

    test("formKey is available", () {
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
    });
  });

  group("init", () {
    test("init calls loadReferenceData and emits loaded", () async {
      bool called = false;
      spyViewModel.loadReferenceDataStub = () async {
        called = true;
      };

      await spyViewModel.init(null);

      expect(called, isTrue);
      expect(spyViewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("openApplication", () {
    test("openApplication success sets appRefIndex and resets it back to -1",
        () async {
      final request = Request(applicationRefNo: "APP-1");

      when(() => mockRepository.openApplication(any()))
          .thenAnswer((_) async {});

      await viewModel.openApplication(request, 2);

      verify(() => mockRepository.openApplication(request)).called(1);
      expect(viewModel.state.appRefIndex, -1);
    });

    // testWidgets('openApplication failure resets appRefIndex back to -1',
    // (tester) async {
    //   await pumpTestApp(tester, const SizedBox.shrink());

    //   final request = Request(applicationRefNo: 'APP-2');

    //   when(() =>
    // mockRepository.openApplication(any())).thenThrow(Exception('open
    // failed'));

    //   await viewModel.openApplication(request, 7);

    //   verify(() => mockRepository.openApplication(request)).called(1);
    //   expect(viewModel.state.appRefIndex, -1);
    // });
  });

  group("onSubmitButtonPress", () {
    // testWidgets('returns early when form is invalid / not attached', (tester) async {
    //   await pumpTestApp(tester, const SizedBox.shrink());

    //   await viewModel.onSubmitButtonPress();

    //   verifyNever(
    //     () => mockRepository.getWorklistSearchCriteria(
    //       rmName: any(named: 'rmName'),
    //       key: any(named: 'key'),
    //       applicationRefNo: any(named: 'applicationRefNo'),
    //       customerRim: any(named: 'customerRim'),
    //       groupId: any(named: 'groupId'),
    //       pendingUser: any(named: 'pendingUser'),
    //       pendingWith: any(named: 'pendingWith'),
    //       segment: any(named: 'segment'),
    //       region: any(named: 'region'),
    //     ),
    //   );
    // });

    testWidgets("uses inProgress key when selected status is In Progress",
        (tester) async {
      await pumpValidForm(tester, viewModel);

      viewModel
        ..selectedRequestStatus = Reference(name: "In Progress")
        ..selectedRM = User(id: "RM1")
        ..selectedUserName = User(id: "U1")
        ..selectedRoles = [
          Reference(reference2: "ROLE_A"),
          Reference(reference2: "ROLE_B"),
        ]
        ..selectedSegments = [
          Reference(name: "SEG1"),
          Reference(name: "SEG2"),
        ]
        ..selectedRegions = [
          Reference(name: "REG1"),
          Reference(name: "REG2"),
        ]
        ..applicationRefNo = "APP123"
        ..customerRimNo = "RIM123"
        ..groupId = "GRP123";

      final repoResult = [
        Request(applicationRefNo: "APP123", customerName: "John"),
      ];

      when(
        () => mockRepository.getWorklistSearchCriteria(
          rmName: any(named: "rmName"),
          key: any(named: "key"),
          applicationRefNo: any(named: "applicationRefNo"),
          customerRim: any(named: "customerRim"),
          groupId: any(named: "groupId"),
          pendingUser: any(named: "pendingUser"),
          pendingWith: any(named: "pendingWith"),
          segment: any(named: "segment"),
          region: any(named: "region"),
        ),
      ).thenAnswer((_) async => repoResult);

      await viewModel.onSubmitButtonPress();

      verify(
        () => mockRepository.getWorklistSearchCriteria(
          rmName: "RM1",
          key: "inProgress",
          applicationRefNo: "APP123",
          customerRim: "RIM123",
          groupId: "GRP123",
          pendingUser: "U1",
          pendingWith: "ROLE_A,ROLE_B",
          segment: "SEG1,SEG2",
          region: "REG1,REG2",
        ),
      ).called(1);

      expect(viewModel.workList, repoResult);
      expect(viewModel.filteredWorkList, repoResult);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    testWidgets("uses completed key when selected status is Completed",
        (tester) async {
      await pumpValidForm(tester, viewModel);

      viewModel.selectedRequestStatus = Reference(name: "Completed");

      when(
        () => mockRepository.getWorklistSearchCriteria(
          rmName: any(named: "rmName"),
          key: any(named: "key"),
          applicationRefNo: any(named: "applicationRefNo"),
          customerRim: any(named: "customerRim"),
          groupId: any(named: "groupId"),
          pendingUser: any(named: "pendingUser"),
          pendingWith: any(named: "pendingWith"),
          segment: any(named: "segment"),
          region: any(named: "region"),
        ),
      ).thenAnswer((_) async => []);

      await viewModel.onSubmitButtonPress();

      verify(
        () => mockRepository.getWorklistSearchCriteria(
          key: "completed",
        ),
      ).called(1);

      expect(viewModel.filteredWorkList, isEmpty);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    testWidgets("uses all key for any other status", (tester) async {
      await pumpValidForm(tester, viewModel);

      viewModel.selectedRequestStatus = Reference(name: "Anything Else");

      when(
        () => mockRepository.getWorklistSearchCriteria(
          rmName: any(named: "rmName"),
          key: any(named: "key"),
          applicationRefNo: any(named: "applicationRefNo"),
          customerRim: any(named: "customerRim"),
          groupId: any(named: "groupId"),
          pendingUser: any(named: "pendingUser"),
          pendingWith: any(named: "pendingWith"),
          segment: any(named: "segment"),
          region: any(named: "region"),
        ),
      ).thenAnswer((_) async => []);

      await viewModel.onSubmitButtonPress();

      verify(
        () => mockRepository.getWorklistSearchCriteria(
          key: "all",
        ),
      ).called(1);

      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    //   testWidgets('error path sets tableLoader to error', (tester) async {
    //     await pumpValidForm(tester, viewModel);

    //     viewModel.selectedRequestStatus = Reference(name: 'In Progress');

    //     when(
    //       () => mockRepository.getWorklistSearchCriteria(
    //         rmName: any(named: 'rmName'),
    //         key: any(named: 'key'),
    //         applicationRefNo: any(named: 'applicationRefNo'),
    //         customerRim: any(named: 'customerRim'),
    //         groupId: any(named: 'groupId'),
    //         pendingUser: any(named: 'pendingUser'),
    //         pendingWith: any(named: 'pendingWith'),
    //         segment: any(named: 'segment'),
    //         region: any(named: 'region'),
    //       ),
    //     ).thenThrow(Exception('search failed'));

    //     await viewModel.onSubmitButtonPress();

    //     expect(viewModel.state.tableLoader, LoadingStatus.error);
    //   });
  });

  group("reset", () {
    test("onResetButtonPress clears all state", () {
      viewModel
        ..selectedRM = User(id: "RM1")
        ..selectedRoles = [Reference(id: 1, name: "Role")]
        ..selectedFilterTypeData = [Request(customerName: "Type")]
        ..applicationRefNo = "APP"
        ..customerRimNo = "RIM"
        ..groupId = "GRP"
        ..selectedRegions = [Reference(name: "Region")]
        ..selectedSegments = [Reference(name: "Segment")]
        ..workList = [Request(customerName: "A")]
        ..filteredWorkList = [Request(customerName: "B")]
        ..selectedSearchCriteria = Reference(name: "Criteria")
        ..referenceData = {
          ReferenceDataKeys.advanceRequestType: [
            Reference(
              id: ServerConstants.advancedRequestTypeId,
              name: "Default Status",
            ),
          ],
        }
        ..onResetButtonPress();

      expect(viewModel.selectedRM, isNull);
      expect(viewModel.selectedRoles, isEmpty);
      expect(viewModel.selectedFilterTypeData, isEmpty);
      expect(viewModel.applicationRefNo, isNull);
      expect(viewModel.customerRimNo, isNull);
      expect(viewModel.groupId, isNull);
      expect(viewModel.selectedRegions, isNull);
      expect(viewModel.selectedSegments, isNull);
      expect(viewModel.workList, isEmpty);
      expect(viewModel.filteredWorkList, isEmpty);
      expect(viewModel.selectedSearchCriteria, isNull);
      expect(viewModel.state.tableLoader, LoadingStatus.empty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.selectedRequestStatus, isNotNull);
    });
  });

  group("onFilter", () {
    test("no filters returns full workList", () {
      (viewModel
            ..workList = [
              Request(applicationRefNo: "A1", customerName: "John"),
              Request(applicationRefNo: "A2", customerName: "Jane"),
            ])
          .onFilter(value: "", filterType: FilterType.applicantName);

      expect(viewModel.filteredWorkList.length, 2);
      expect(viewModel.state.tableLoader, LoadingStatus.loaded);
    });

    test("filters by reference number", () {
      (viewModel
            ..workList = [
              Request(applicationRefNo: "REF123"),
              Request(applicationRefNo: "ABC999"),
            ])
          .onFilter(
        value: "ref123",
        filterType: FilterType.referenceNumber,
      );

      expect(viewModel.filteredWorkList.length, 1);
      expect(viewModel.filteredWorkList.first.applicationRefNo, "REF123");
    });

    test("filters by applicant rim", () {
      (viewModel
            ..workList = [
              Request(customerRimNo: 123456),
              Request(customerRimNo: 999999),
            ])
          .onFilter(value: "123", filterType: FilterType.applicantRim);

      expect(viewModel.filteredWorkList.length, 1);
      expect(viewModel.filteredWorkList.first.customerRimNo, 123456);
    });

    test("filters by applicant name", () {
      (viewModel
            ..workList = [
              Request(customerName: "John Snow"),
              Request(customerName: "Arya Stark"),
            ])
          .onFilter(value: "john", filterType: FilterType.applicantName);

      expect(viewModel.filteredWorkList.length, 1);
      expect(viewModel.filteredWorkList.first.customerName, "John Snow");
    });

    testWidgets("filters by custom request type match", (tester) async {
      await pumpTestApp(tester, const SizedBox.shrink());

      (viewModel
            ..customApplicationTypeNames = ["CCSYS", "TYPE_A"]
            ..workList = [
              Request(reqRefType: Reference(name: "TYPE_A")),
              Request(reqRefType: Reference(name: "TYPE_B")),
            ])
          .onFilter(
        value: "",
        filterType: FilterType.referenceType,
        selectedTypes: [
          Request(reqRefType: Reference(name: "TYPE_A")),
        ],
      );

      expect(viewModel.filteredWorkList.length, 1);
      expect(viewModel.filteredWorkList.first.reqRefType?.name, "TYPE_A");
    });

    testWidgets("filters by historical application types", (tester) async {
      await pumpTestApp(tester, const SizedBox.shrink());

      (viewModel
            ..customApplicationTypeNames = ["CCSYS", "TYPE_A"]
            ..workList = [
              Request(reqRefType: Reference(name: "OLD_TYPE")),
              Request(reqRefType: Reference(name: "TYPE_A")),
            ])
          .onFilter(
        value: "",
        filterType: FilterType.referenceType,
        selectedTypes: [
          Request(
            reqRefType: Reference(name: "Historical Application Types"),
          ),
        ],
      );

      expect(viewModel.filteredWorkList.length, 1);
      expect(viewModel.filteredWorkList.first.reqRefType?.name, "OLD_TYPE");
    });

    testWidgets("combined filters narrow down correctly", (tester) async {
      await pumpTestApp(tester, const SizedBox.shrink());

      viewModel
        ..customApplicationTypeNames = ["CCSYS", "CUSTOM_1"]
        ..workList = [
          Request(
            applicationRefNo: "APP-111",
            customerRimNo: 1001,
            customerName: "John Smith",
            reqRefType: Reference(name: "CUSTOM_1"),
          ),
          Request(
            applicationRefNo: "APP-222",
            customerRimNo: 2002,
            customerName: "Jane Doe",
            reqRefType: Reference(name: "OLD_TYPE"),
          ),
        ]
        ..onFilter(
          value: "APP-111",
          filterType: FilterType.referenceNumber,
        )
        ..onFilter(value: "1001", filterType: FilterType.applicantRim)
        ..onFilter(value: "John", filterType: FilterType.applicantName)
        ..onFilter(
          value: "",
          filterType: FilterType.referenceType,
          selectedTypes: [Request(reqRefType: Reference(name: "CUSTOM_1"))],
        );

      expect(viewModel.filteredWorkList.length, 1);
      expect(viewModel.filteredWorkList.first.customerName, "John Smith");
    });

    testWidgets("non matching selected type removes item", (tester) async {
      await pumpTestApp(tester, const SizedBox.shrink());

      (viewModel
            ..customApplicationTypeNames = ["CCSYS", "TYPE_A"]
            ..workList = [
              Request(reqRefType: Reference(name: "TYPE_B")),
            ])
          .onFilter(
        value: "",
        filterType: FilterType.referenceType,
        selectedTypes: [Request(reqRefType: Reference(name: "TYPE_A"))],
      );

      expect(viewModel.filteredWorkList, isEmpty);
    });
  });

  group("reference helpers", () {
    test("setRequestStatusValue assigns matching reference", () {
      viewModel
        ..referenceData = {
          ReferenceDataKeys.advanceRequestType: [
            Reference(id: 999, name: "X"),
            Reference(
              id: ServerConstants.advancedRequestTypeId,
              name: "Default",
            ),
          ],
        }
        ..setRequestStatusValue();

      expect(viewModel.selectedRequestStatus, isNotNull);
      expect(
        viewModel.selectedRequestStatus?.id,
        ServerConstants.advancedRequestTypeId,
      );
    });

    test("getRoleCodes returns reference3 values", () {
      viewModel.referenceData = {
        ReferenceDataKeys.roleType: [
          Reference(id: 1, reference3: "A"),
          Reference(id: 2, reference3: "B"),
        ],
      };

      final result = viewModel.getRoleCodes();

      expect(result, ["A", "B"]);
    });

    test("getRoleList filters excluded IDs", () {
      viewModel.referenceData = {
        ReferenceDataKeys.roleType: [
          Reference(id: ServerConstants.admId, name: "ADM"),
          Reference(id: ServerConstants.inqusrId, name: "INQUSR"),
          Reference(id: 55555, name: "VALID"),
        ],
      };

      final result = viewModel.getRoleList();

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result.first.name, "VALID");
    });

    test("getRoleList returns null safely when role data is missing", () {
      viewModel.referenceData = {};

      final result = viewModel.getRoleList();

      expect(result, isNull);
    });

    test("getRmUsers is callable (currently no-op)", () {
      viewModel.getRmUsers();
      expect(viewModel.state.loaderStatus, isNotNull);
    });
  });

  group("getUserList", () {
    test("success path de-duplicates users by id and emits loaded", () async {
      final roleData = [
        Reference(reference3: "RM-WCAS"),
        Reference(reference3: "OPS-WCAS"),
      ];

      when(() => mockRepository.getUserByRole(any())).thenAnswer(
        (_) async => [
          User(id: "U1", name: "Alice"),
          User(id: "U2", name: "Bob"),
          User(id: "U1", name: "Alice Dup"),
        ],
      );

      await viewModel.getUserList(roleData);

      expect(viewModel.userList.length, 2);
      expect(viewModel.userList.map((e) => e.id), containsAll(["U1", "U2"]));
      expect(viewModel.state.fieldLoader, isFalse);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      verify(() => mockRepository.getUserByRole(["RM-WCAS", "OPS-WCAS"]))
          .called(1);
    });

    test("ignores null/empty reference3 values", () async {
      final roleData = [
        Reference(reference3: "RM-WCAS"),
        Reference(reference3: ""),
        Reference(),
      ];

      when(() => mockRepository.getUserByRole(any()))
          .thenAnswer((_) async => [User(id: "1", name: "A")]);

      await viewModel.getUserList(roleData);

      verify(() => mockRepository.getUserByRole(["RM-WCAS"])).called(1);
      expect(viewModel.userList.length, 1);
    });

    // testWidgets('failure path emits error', (tester) async {
    //   await pumpTestApp(tester, const SizedBox.shrink());

    //   final roleData = [Reference(reference3: 'RM-WCAS')];

    //   when(() =>
    // mockRepository.getUserByRole(any())).thenThrow(Exception('user fetch
    // failed'));

    //   await viewModel.getUserList(roleData);

    //   expect(viewModel.state.fieldLoader, isFalse);
    //   expect(viewModel.state.loaderStatus, LoadingStatus.error);
    // });
  });

  group("search criteria selection", () {
    test(
        "onSearchCriteriaSelected for RM Name calls"
        " getUserList and getFilteredUsersById", () async {
      spyViewModel
        ..getUserListStub = (_) async {}
        ..getFilteredUsersByIdStub = (_) async {};

      await spyViewModel.onSearchCriteriaSelected(
        Reference(id: ServerConstants.rmNameId, name: "RM Name"),
      );

      expect(spyViewModel.selectedSearchCriteria?.id, ServerConstants.rmNameId);
      expect(spyViewModel.getUserListCalls, 1);
      expect(spyViewModel.lastRoleData, isNotNull);
      expect(spyViewModel.lastRoleData!.single.reference3, "RM-WCAS");
      expect(spyViewModel.getFilteredUsersByIdCalls, 1);
      expect(spyViewModel.lastFilterId, ServerConstants.rmNameId);
    });

    test(
        "onSearchCriteriaSelected "
        "for Pending "
        "With calls only getFilteredUsersById", () async {
      spyViewModel.getFilteredUsersByIdStub = (_) async {};

      await spyViewModel.onSearchCriteriaSelected(
        Reference(id: ServerConstants.pendingWithId, name: "Pending With"),
      );

      expect(
        spyViewModel.selectedSearchCriteria?.id,
        ServerConstants.pendingWithId,
      );
      expect(spyViewModel.getUserListCalls, 0);
      expect(spyViewModel.getFilteredUsersByIdCalls, 1);
      expect(spyViewModel.lastFilterId, ServerConstants.pendingWithId);
    });

    test("onSearchCriteriaSelected for ordinary criteria only sets selection",
        () async {
      await spyViewModel.onSearchCriteriaSelected(
        Reference(
          id: ServerConstants.applicationReferenceNumberId,
          name: "App Ref",
        ),
      );

      expect(
        spyViewModel.selectedSearchCriteria?.id,
        ServerConstants.applicationReferenceNumberId,
      );
      expect(spyViewModel.getUserListCalls, 0);
      expect(spyViewModel.getFilteredUsersByIdCalls, 0);
      expect(spyViewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getFilteredUsersById", () {
    test("RM path keeps only users whose currentRole id matches rmId",
        () async {
      await (viewModel
            ..userList = [
              User(
                id: "1",
                name: "RM User",
                currentRole: Role(id: ServerConstants.rmId),
              ),
              User(
                id: "2",
                name: "Other User",
                currentRole: Role(id: 9999),
              ),
            ])
          .getFilteredUsersById(ServerConstants.rmNameId);

      expect(viewModel.userModels.length, 1);
      expect(viewModel.userModels.first.name, "RM User");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "Pending With path maps users from selected roles and sets currentRole",
        () async {
      final role1 = Role(
        roleId: 101,
        name: "Role1",
        users: [
          User(id: "U1", name: "Alice"),
          User(id: "U2", name: "Bob"),
        ],
      );

      final role2 = Role(
        roleId: 102,
        name: "Role2",
        users: [
          User(id: "U3", name: "Charlie"),
        ],
      );

      await (viewModel
            ..users = [role1, role2]
            ..selectedRoles = [
              Reference(id: 101, name: "Role1"),
              Reference(id: 102, name: "Role2"),
            ])
          .getFilteredUsersById(ServerConstants.pendingWithId);

      expect(viewModel.userModels.length, 3);
      expect(viewModel.userModels[0].currentRole, role1);
      expect(viewModel.userModels[2].currentRole, role2);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("Pending With path with no selected roles leaves list empty",
        () async {
      viewModel.userModels = [User(id: "existing", name: "Existing")];
      await (viewModel..selectedRoles = [])
          .getFilteredUsersById(ServerConstants.pendingWithId);

      expect(viewModel.userModels, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("catch path emits error when RM filtering hits null currentRole",
        () async {
      await (viewModel
            ..userList = [
              User(id: "1", name: "Broken User"),
            ])
          .getFilteredUsersById(ServerConstants.rmNameId);

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });
  });

  group("role selection / mapping", () {
    test("onRoleSelected sets selectedRoles and calls getUserList", () async {
      bool called = false;
      spyViewModel.getUserListStub = (_) async {
        called = true;
      };

      final roles = [
        Reference(id: 1, name: "Role1", reference3: "R1"),
        Reference(id: 2, name: "Role2", reference3: "R2"),
      ];

      await spyViewModel.onRoleSelected(roles);

      expect(spyViewModel.selectedRoles, roles);
      expect(called, isTrue);
      expect(spyViewModel.getUserListCalls, 1);
    });

    test("getMappedUsers populates userModels and sets currentRole", () {
      final role = Role(
        roleId: 126,
        name: "Role126",
        users: [
          User(id: "1", name: "User1"),
          User(id: "2", name: "User2"),
        ],
      );

      viewModel
        ..selectedRoles = [Reference(id: 126, name: "Role126")]
        ..users = [role]
        ..getMappedUsers();

      expect(viewModel.selectedUserName, isNull);
      expect(viewModel.userModels.length, 2);
      expect(viewModel.userModels.first.currentRole, role);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getMappedUsers clears userModels when no selected roles", () {
      viewModel
        ..userModels = [User(id: "X", name: "Old")]
        ..selectedRoles = null
        ..getMappedUsers();

      expect(viewModel.selectedUserName, isNull);
      expect(viewModel.userModels, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getMappedUsers handles role without users", () {
      viewModel
        ..selectedRoles = [Reference(id: 999, name: "Missing")]
        ..users = [Role(roleId: 999)]
        ..getMappedUsers();

      expect(viewModel.userModels, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("show field helpers", () {
    test("showApplicationRefIdField", () {
      viewModel.selectedSearchCriteria = Reference(
        id: ServerConstants.applicationReferenceNumberId,
      );
      expect(viewModel.showApplicationRefIdField(), isTrue);
    });

    test("showCustomerRimNoField", () {
      viewModel.selectedSearchCriteria = Reference(
        id: ServerConstants.customerRIMNumberId,
      );
      expect(viewModel.showCustomerRimNoField(), isTrue);
    });

    test("showGroupIdField", () {
      viewModel.selectedSearchCriteria = Reference(id: ServerConstants.groupId);
      expect(viewModel.showGroupIdField(), isTrue);
    });

    test("showRegionField", () {
      viewModel.selectedSearchCriteria = Reference(
        id: ServerConstants.bySegmentOrRegionId,
      );
      expect(viewModel.showRegionField(), isTrue);
    });

    test("showRoleIdField", () {
      viewModel.selectedSearchCriteria = Reference(
        id: ServerConstants.pendingWithId,
      );
      expect(viewModel.showRoleIdField(), isTrue);
    });

    test("showRmNameField", () {
      viewModel.selectedSearchCriteria = Reference(
        id: ServerConstants.rmNameId,
      );
      expect(viewModel.showRmNameField(), isTrue);
    });
  });

  group("user selection methods", () {
    test("onUserNameSelected sets selectedUserName", () {
      final user = User(id: "12", name: "User");
      viewModel.userNameSelected = user;
      expect(viewModel.selectedUserName, user);
    });

    test("onRMNameSelected sets selectedRM", () {
      final user = User(id: "13", name: "RM User");
      viewModel.onRMNameSelected(user);
      expect(viewModel.selectedRM, user);
    });
  });

  group("criteria list", () {
    setUp(() {
      viewModel.referenceData = {
        ReferenceDataKeys.searchCriteria: [
          Reference(id: ServerConstants.rmNameId, name: "RM Name"),
          Reference(id: ServerConstants.pendingWithId, name: "Pending With"),
          Reference(
            id: ServerConstants.applicationReferenceNumberId,
            name: "App Ref",
          ),
        ],
      };
    });

    test("filters out RM Name and Pending With for RM user", () {
      Globals.user = User(currentRole: Role(id: ServerConstants.rmId));

      final result = viewModel.getCriteriaList();

      expect(result.length, 1);
      expect(result.first.id, ServerConstants.applicationReferenceNumberId);
    });

    test("filters out RM Name and Pending With for RO user", () {
      Globals.user = User(currentRole: Role(id: ServerConstants.roId));

      final result = viewModel.getCriteriaList();

      expect(result.length, 1);
      expect(result.first.id, ServerConstants.applicationReferenceNumberId);
    });

    test("returns all criteria for normal user", () {
      Globals.user = User(currentRole: Role(id: 99999));

      final result = viewModel.getCriteriaList();

      expect(result.length, 3);
    });

    test("returns all criteria when Globals.user is null", () {
      Globals.user = null;

      final result = viewModel.getCriteriaList();

      expect(result.length, 3);
    });
  });

  group("chip deletion", () {
    test("onRegionChipDeleted removes region", () {
      viewModel
        ..selectedRegions = [
          Reference(name: "R1"),
          Reference(name: "R2"),
        ]
        ..onRegionChipDeleted(0);

      expect(viewModel.selectedRegions!.length, 1);
      expect(viewModel.selectedRegions!.first.name, "R2");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onSegmentChipDeleted removes segment", () {
      viewModel
        ..selectedSegments = [
          Reference(name: "S1"),
          Reference(name: "S2"),
        ]
        ..onSegmentChipDeleted(1);

      expect(viewModel.selectedSegments!.length, 1);
      expect(viewModel.selectedSegments!.first.name, "S1");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onRoleChipDeleted removes role", () {
      viewModel
        ..selectedRoles = [
          Reference(name: "A"),
          Reference(name: "B"),
        ]
        ..onRoleChipDeleted(0);

      expect(viewModel.selectedRoles!.length, 1);
      expect(viewModel.selectedRoles!.first.name, "B");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("getRequestStatusNameById", () {
    test("returns empty string for null", () {
      expect(viewModel.getRequestStatusNameById(null), "");
    });

    test("returns same value for non-int string", () {
      expect(viewModel.getRequestStatusNameById("NOT_INT"), "NOT_INT");
    });

    test("returns mapped title for valid numeric string", () {
      final firstEntry = ServerConstants.requestStatusId.entries.first;
      final idString = firstEntry.value.toString();
      final expected = ServerConstants.requestStatusTitle[firstEntry.key];

      expect(viewModel.getRequestStatusNameById(idString), expected);
    });
  });

  group("simple property assignments", () {
    test("applicationRefNo / customerRimNo / groupId can be assigned", () {
      viewModel
        ..applicationRefNo = "APP123"
        ..customerRimNo = "RIM456"
        ..groupId = "GRP789";

      expect(viewModel.applicationRefNo, "APP123");
      expect(viewModel.customerRimNo, "RIM456");
      expect(viewModel.groupId, "GRP789");
    });

    test("filter properties can be assigned", () {
      viewModel
        ..reqRefNoFilter = "REF-1"
        ..applicantRimFilter = "RIM-2"
        ..applicantNameFilter = "John"
        ..requestTypeFilter = Reference(name: "Type");

      expect(viewModel.reqRefNoFilter, "REF-1");
      expect(viewModel.applicantRimFilter, "RIM-2");
      expect(viewModel.applicantNameFilter, "John");
      expect(viewModel.requestTypeFilter?.name, "Type");
    });

    test("selectedFilterTypeData can be assigned", () {
      final filters = [Request(customerName: "X")];
      viewModel.selectedFilterTypeData = filters;

      expect(viewModel.selectedFilterTypeData, filters);
      expect(viewModel.selectedFilterTypeData.length, 1);
    });

    test("workList and filteredWorkList can be assigned", () {
      final list = [
        Request(customerName: "One"),
        Request(customerName: "Two"),
      ];

      viewModel
        ..workList = list
        ..filteredWorkList = list;

      expect(viewModel.workList.length, 2);
      expect(viewModel.filteredWorkList.length, 2);
    });

    test("users and userModels can be assigned", () {
      final roles = [
        Role(roleId: 1, name: "Admin"),
        Role(roleId: 2, name: "User"),
      ];
      final models = [
        User(id: "1", name: "U1"),
        User(id: "2", name: "U2"),
      ];

      viewModel
        ..users = roles
        ..userModels = models;

      expect(viewModel.users.length, 2);
      expect(viewModel.userModels.length, 2);
    });

    test("selectedUserName and selectedRM can be assigned", () {
      final user1 = User(id: "1", name: "Selected User");
      final user2 = User(id: "2", name: "Selected RM");

      viewModel
        ..selectedUserName = user1
        ..selectedRM = user2;

      expect(viewModel.selectedUserName, user1);
      expect(viewModel.selectedRM, user2);
    });
  });
}
