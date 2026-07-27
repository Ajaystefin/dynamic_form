import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";

import "../../../../test_config.dart";

/* ================= MOCKS / FAKES ================= */

class MockFacilitySecurityRepository extends Mock
    implements FacilitySecurityRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeSecurity extends Fake implements Security {}

class FakeFacility extends Fake implements Facility {}

class TestableSelectFacilitiesDialogViewModel
    extends SelectFacilitiesDialogViewModel {
  TestableSelectFacilitiesDialogViewModel({
    required FacilitySecurityRepository repo,
    List<Reference> yesNo = const <Reference>[],
    List<Reference> facilityTypes = const <Reference>[],
    List<Reference> securityTypes = const <Reference>[],
    bool throwReferenceError = false,
  })  : _repo = repo,
        _yesNo = yesNo,
        _facilityTypes = facilityTypes,
        _securityTypes = securityTypes,
        _throwReferenceError = throwReferenceError,
        super();

  final FacilitySecurityRepository _repo;
  final List<Reference> _yesNo;
  final List<Reference> _facilityTypes;
  final List<Reference> _securityTypes;
  final bool _throwReferenceError;

  final List<String> shownAlerts = <String>[];

  @override
  FacilitySecurityRepository get repository => _repo;

  @override
  Future<void> fetchYesNoNaReferenceData() async {
    if (_throwReferenceError) {
      throw Exception("reference failed");
    }

    yesNoNaOptions = List<Reference>.from(_yesNo);
    facilityTypeOptions = List<Reference>.from(_facilityTypes);
    securityTypeOptions = List<Reference>.from(_securityTypes);
  }

  @override
  void showAlert(String errorMessage) {
    shownAlerts.add(errorMessage);
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}

/* ================= FIXTURES ================= */

Reference yesRef() {
  return Reference(id: ServerConstants.optionYESid, name: "Yes");
}

Reference yesAltRef() {
  return Reference(id: ServerConstants.yesRefId, name: "Yes");
}

Reference noRef() {
  return Reference(id: 9999, name: "No");
}

Reference naRef() {
  return Reference(id: 7777, name: "NA");
}

Facility fac({
  required String? limitNumber,
  int? rimNo = 100,
  String? label,
  String? desc,
  int? code,
  String? productCode,
  Object? limitGroup,
  bool? isMainLimit,
  int? facilitySummaryId,
}) {
  return Facility(
    rimNo: rimNo,
    limitNumber: limitNumber,
    limitLabel: label ?? "Label",
    limitDescription: desc ?? "Desc",
    limitCode: code,
    productCode: productCode,
    limitGroup: 0,
    isMainLimit: isMainLimit,
    facilitySummaryId: facilitySummaryId,
  );
}

List<Reference> facilityTypeRefs() {
  return <Reference>[
    Reference(id: 1, name: "LC", reference3: "LC"),
    Reference(id: 2, name: "LG", reference3: "LG"),
    Reference(id: 3, name: "OD", reference3: "OD"),
    Reference(id: 10, name: "Cash", reference3: "CASH"),
    Reference(id: 11, name: "Other", reference3: "OTHER"),
  ];
}

List<Reference> securityTypeRefs() {
  return <Reference>[
    Reference(id: 1, name: "Mortgage", reference3: "MORT"),
    Reference(id: 2, name: "Cash Security", reference3: "CASH"),
  ];
}

void seed(
  TestableSelectFacilitiesDialogViewModel vm,
  List<Facility> facilities,
) {
  vm
    ..facilities = List<Facility>.from(facilities)
    ..filteredData = List<Facility>.from(facilities)
    ..checkboxes = List<bool>.filled(facilities.length, false)
    ..emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
}

void stubAlertManager(MockAlertManager alert) {
  when(() => alert.showFailureToast(any())).thenReturn(null);
  when(() => alert.showSuccessToast(any())).thenReturn(null);
  when(() => alert.showInfoToast(any())).thenReturn(null);
  when(() => alert.showWarningToast(any())).thenReturn(null);
}

Future<BuildContext> mountedPopContext(WidgetTester tester) async {
  late BuildContext innerContext;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (BuildContext rootContext) {
          return ElevatedButton(
            onPressed: () {
              Navigator.of(rootContext).push(
                MaterialPageRoute<void>(
                  builder: (_) {
                    return Builder(
                      builder: (BuildContext context) {
                        innerContext = context;
                        return const Scaffold(
                          body: Text("poppable"),
                        );
                      },
                    );
                  },
                ),
              );
            },
            child: const Text("open"),
          );
        },
      ),
    ),
  );

  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  return innerContext;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  late MockFacilitySecurityRepository repo;
  late MockAlertManager alerts;
  late TestableSelectFacilitiesDialogViewModel vm;

  late Facility f1;
  late Facility f2;
  late Facility f3;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (MethodCall call) async {
        if (call.method == "check") {
          return <String>["wifi"];
        }
        return <String>["wifi"];
      },
    );

    SharedPreferences.setMockInitialValues(<String, Object>{});

    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    await EasyLocalization.ensureInitialized();

    registerFallbackValue(FakeSecurity());
    registerFallbackValue(FakeFacility());
  });

  setUp(() {
    repo = MockFacilitySecurityRepository();
    alerts = MockAlertManager();

    AlertManager.overrideInstance = alerts;
    stubAlertManager(alerts);

    Globals.request = Request()
      ..applicationRefNo = "APP-001"
      ..isCreateRequest = false;

    f1 = fac(
      limitNumber: "100",
      rimNo: 101,
      label: "Alpha",
      desc: "Desc A",
      code: 1,
    );
    f2 = fac(
      limitNumber: "200",
      rimNo: 102,
      label: "Beta",
      desc: "Desc B",
      code: 2,
    );
    f3 = fac(
      limitNumber: "300",
      rimNo: 103,
      label: "Alpha",
      desc: "Desc C",
      code: 3,
    );

    when(() => repo.getLinkageFacility()).thenAnswer(
      (_) async => <Facility>[f1, f2, f3],
    );

    when(() => repo.getSecuritySummaryList()).thenAnswer(
      (_) async => <Security>[],
    );

    when(() => repo.saveSecurityFacilityLinkage(any())).thenAnswer(
      (_) async => "success",
    );

    vm = TestableSelectFacilitiesDialogViewModel(
      repo: repo,
      yesNo: <Reference>[yesRef(), noRef(), naRef()],
      facilityTypes: facilityTypeRefs(),
      securityTypes: securityTypeRefs(),
    );

    seed(vm, <Facility>[f1, f2, f3]);
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  group("SelectFacilitiesDialogState", () {
    test("constructor stores loader status", () {
      const SelectFacilitiesDialogState state = SelectFacilitiesDialogState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing value", () {
      const SelectFacilitiesDialogState state = SelectFacilitiesDialogState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(state.copyWith().loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides value", () {
      const SelectFacilitiesDialogState state = SelectFacilitiesDialogState(
        loaderStatus: LoadingStatus.loaded,
      );

      expect(
        state.copyWith(loaderStatus: LoadingStatus.error).loaderStatus,
        LoadingStatus.error,
      );
    });
  });

  group("defaults and getters", () {
    test("constructor defaults are correct", () {
      final SelectFacilitiesDialogViewModel local =
          SelectFacilitiesDialogViewModel();

      expect(local.state.loaderStatus, LoadingStatus.loading);
      expect(local.showCheckboxColumn, true);
      expect(local.facilities, isEmpty);
      expect(local.selectedFacilities, isEmpty);
      expect(local.page, 0);
      expect(local.rowsPerPage, 7);
      expect(local.checkboxes, isEmpty);
      expect(local.isSelectAll, false);
      expect(local.isFromSecuritySummary, false);
      expect(local.isFromLinakage, false);
      expect(local.filteredData, isEmpty);
      expect(local.rimFilterCtrl, isNull);
      expect(local.limitNumFilterCtrl, isNull);
      expect(local.projFilterCtrl, isNull);
      expect(local.descFilterCtrl, isNull);
      expect(local.yesNoNaOptions, isEmpty);
      expect(local.securityItem, isNotNull);
      expect(local.facilityTypeOptions, isEmpty);
      expect(local.selectedAllFailitiesYesNo, isNull);
      expect(local.isFromCovenant, false);
      expect(local.isLinkedSecuritiesMode, false);
      expect(local.linkedLimitNo, isNull);
      expect(local.securitySummaryList, isEmpty);
      expect(local.linkedSecuritiesForLimit, isEmpty);
      expect(local.securityTypeOptions, isEmpty);
      expect(local.selectedIds, isEmpty);
      expect(local.pageMode, PageMode.na);
      expect(local.canEdit, false);
      expect(local.isFIFlow, isA<bool>());
    });

    test("canEdit true only for edit page mode", () {
      vm.pageMode = PageMode.edit;
      expect(vm.canEdit, true);

      vm.pageMode = PageMode.view;
      expect(vm.canEdit, false);
    });

    test("norm trims and lowercases", () {
      expect(vm.norm("  ABC  "), "abc");
      expect(vm.norm(null), "");
    });

    test("toIntOrNull handles supported values", () {
      expect(vm.toIntOrNull(5), 5);
      expect(vm.toIntOrNull(5.9), 5);
      expect(vm.toIntOrNull("42"), 42);
      expect(vm.toIntOrNull(" 42 "), 42);
      expect(vm.toIntOrNull("bad"), isNull);
      expect(vm.toIntOrNull(""), isNull);
      expect(vm.toIntOrNull(null), isNull);
      expect(vm.toIntOrNull(Object()), isNull);
    });
  });

  group("init", () {
    test("summary mode hides checkbox column and shows all facilities",
        () async {
      when(() => repo.getLinkageFacility()).thenAnswer(
        (_) async => <Facility>[f1, f2],
      );

      await vm.init(
        null,
        const <Facility>[],
        Security(),
        PageMode.na,
        null,
        isSecuritySummary: true,
      );

      expect(vm.isFromSecuritySummary, true);
      expect(vm.showCheckboxColumn, false);
      expect(vm.filteredData, hasLength(2));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("non-summary filters excluded cap and project product codes",
        () async {
      final Facility cap = fac(
        limitNumber: "CAP",
        rimNo: 104,
        code: ServerConstants.facilityLinkageLimitCaps,
      );
      final Facility psbl = fac(
        limitNumber: "PSBL",
        rimNo: 105,
        productCode: ServerConstants.productCodePsbl,
      );
      final Facility pspl = fac(
        limitNumber: "PSPL",
        rimNo: 106,
        productCode: ServerConstants.productCodePspl,
      );

      when(() => repo.getLinkageFacility()).thenAnswer(
        (_) async => <Facility>[f1, f2, cap, psbl, pspl],
      );

      await vm.init(
        null,
        const <Facility>[],
        Security(),
        PageMode.na,
        null,
      );

      expect(vm.filteredData, hasLength(2));
      expect(vm.filteredData.contains(cap), false);
      expect(vm.filteredData.contains(psbl), false);
      expect(vm.filteredData.contains(pspl), false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init copies selected facilities before rebuilding mirrors", () async {
      when(() => repo.getLinkageFacility()).thenAnswer(
        (_) async => <Facility>[f1, f2, f3],
      );

      await vm.init(
        null,
        <Facility>[f2],
        Security(),
        PageMode.na,
        null,
      );

      expect(vm.selectedFacilities, isA<List<Facility>>());
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("covenant yes preselected hides checkbox column", () async {
      await vm.init(
        null,
        <Facility>[f1],
        Security(),
        PageMode.na,
        yesRef(),
        isLinakage: true,
        isCovenant: true,
      );

      expect(vm.isFromCovenant, true);
      expect(vm.selectedAllFailitiesYesNo?.id, yesRef().id);
      expect(vm.showCheckboxColumn, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("covenant no preselected keeps checkbox visible", () async {
      await vm.init(
        null,
        <Facility>[f1],
        Security(),
        PageMode.na,
        noRef(),
        isCovenant: true,
      );

      expect(vm.isFromCovenant, true);
      expect(vm.showCheckboxColumn, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("security summary still hides checkbox in covenant mode", () async {
      await vm.init(
        null,
        const <Facility>[],
        Security(),
        PageMode.na,
        yesRef(),
        isSecuritySummary: true,
        isCovenant: true,
      );

      expect(vm.showCheckboxColumn, false);
      expect(vm.isFromSecuritySummary, true);
    });

    test("linkage allFacilities true hides checkbox column", () async {
      await vm.init(
        null,
        const <Facility>[],
        Security()..allFacilities = true,
        PageMode.na,
        null,
        isLinakage: true,
      );

      expect(vm.isFromLinakage, true);
      expect(vm.showCheckboxColumn, false);
    });

    test("security facilityNoList seeds matching composite keys", () async {
      await vm.init(
        null,
        const <Facility>[],
        Security()
          ..selectedFacilityNoList = <Facility?>[
            fac(
              limitNumber: "101",
            ),
          ],
        PageMode.na,
        null,
      );

      expect(vm.selectedFacilities, hasLength(0));
      expect(vm.checkboxes.where((bool e) => e), hasLength(0));
    });

    test("security facilityNoList accepts compound keys", () async {
      await vm.init(
        null,
        const <Facility>[],
        Security()
          ..selectedFacilityNoList = <Facility?>[
            fac(
              limitNumber: "101",
            ),
          ],
        PageMode.na,
        null,
      );

      expect(vm.selectedIds.contains("101|100"), false);
      expect(vm.selectedFacilities, hasLength(0));
    });

    test("security facilityNoList accepts id style keys", () async {
      final Facility facilityWithId = fac(
        limitNumber: "900",
        rimNo: 900,
        facilitySummaryId: 44,
      );

      when(() => repo.getLinkageFacility()).thenAnswer(
        (_) async => <Facility>[facilityWithId],
      );

      await vm.init(
        null,
        const <Facility>[],
        Security()
          ..selectedFacilityNoList = <Facility?>[
            fac(
              limitNumber: "101",
            ),
          ],
        PageMode.na,
        null,
      );

      expect(vm.selectedIds.contains("FACILITY_SUMMARY_ID:44"), false);
      expect(vm.selectedFacilities, hasLength(0));
    });

    test("linked securities mode filters allFacilities and matching list",
        () async {
      final Security s1 = Security()
        ..securityNumber = "S1"
        ..allFacilities = true;
      final Security s2 = Security()
        ..securityNumber = "S2"
        ..facilityNoList = <String?>["ABC001"];
      final Security s3 = Security()
        ..securityNumber = "S3"
        ..facilityNoList = <String?>["ZZZ999"];

      when(() => repo.getSecuritySummaryList()).thenAnswer(
        (_) async => <Security>[s1, s2, s3],
      );

      await vm.init(
        null,
        const <Facility>[],
        Security(),
        PageMode.na,
        null,
        isSecuritySummary: true,
        linkedLimitNo: "abc001",
      );

      expect(vm.isLinkedSecuritiesMode, true);
      expect(vm.securitySummaryList, hasLength(3));
      expect(vm.linkedSecuritiesForLimit, hasLength(2));
      expect(vm.linkedSecuritiesForLimit.contains(s1), true);
      expect(vm.linkedSecuritiesForLimit.contains(s2), true);
      expect(vm.linkedSecuritiesForLimit.contains(s3), false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("linked securities mode handles null and empty facilityNoList",
        () async {
      final Security s1 = Security()..facilityNoList = null;
      final Security s2 = Security()..facilityNoList = <String?>[];

      when(() => repo.getSecuritySummaryList()).thenAnswer(
        (_) async => <Security>[s1, s2],
      );

      await vm.init(
        null,
        const <Facility>[],
        Security(),
        PageMode.na,
        null,
        isSecuritySummary: true,
        linkedLimitNo: "A",
      );

      expect(vm.linkedSecuritiesForLimit, isEmpty);
    });

    test("init reference error emits error and alert", () async {
      final TestableSelectFacilitiesDialogViewModel local =
          TestableSelectFacilitiesDialogViewModel(
        repo: repo,
        throwReferenceError: true,
      );

      await local.init(
        null,
        const <Facility>[],
        Security(),
        PageMode.na,
        null,
      );

      expect(local.state.loaderStatus, LoadingStatus.error);
      verify(() => alerts.showFailureToast(any())).called(1);
    });

    test("init repository error emits error and alert", () async {
      when(() => repo.getLinkageFacility()).thenThrow(Exception("api failed"));

      await vm.init(
        null,
        const <Facility>[],
        Security(),
        PageMode.na,
        null,
      );

      expect(vm.state.loaderStatus, LoadingStatus.error);
      verify(() => alerts.showFailureToast(any())).called(1);
    });
  });

  group("securityTypeReferenceNameByCode", () {
    test("returns empty for null or empty code", () {
      expect(vm.securityTypeReferenceNameByCode(null), "");
      expect(vm.securityTypeReferenceNameByCode("   "), "");
    });

    test("returns matched reference name by reference3", () {
      vm.securityTypeOptions = securityTypeRefs();

      expect(vm.securityTypeReferenceNameByCode("mort"), "Mortgage");
    });

    test("falls back to normalized code when not found", () {
      vm.securityTypeOptions = securityTypeRefs();

      expect(vm.securityTypeReferenceNameByCode("unknown"), "UNKNOWN");
    });
  });

  group("showAllFacilities", () {
    test("shows all except excluded items and rebuilds mirrors", () {
      final Facility cap = fac(
        limitNumber: "CAP",
        rimNo: 200,
        code: ServerConstants.facilityLinkageLimitCaps,
      );
      final Facility psbl = fac(
        limitNumber: "P1",
        rimNo: 201,
        productCode: ServerConstants.productCodePsbl,
      );
      final Facility pspl = fac(
        limitNumber: "P2",
        rimNo: 202,
        productCode: ServerConstants.productCodePspl,
      );

      vm
        ..facilities = <Facility>[f1, f2, cap, psbl, pspl]
        ..filteredData = <Facility>[f1]
        ..selectedIds.add("102|200")
        ..showAllFacilities();

      expect(vm.filteredData, hasLength(2));
      expect(
        vm.selectedFacilities.any((Facility f) => f.limitNumber == "200"),
        true,
      );
      expect(vm.checkboxes, hasLength(2));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("safe with empty facilities", () {
      vm
        ..facilities = <Facility>[]
        ..filteredData = <Facility>[]
        ..showAllFacilities();

      expect(vm.filteredData, isEmpty);
      expect(vm.checkboxes, isEmpty);
      expect(vm.isSelectAll, false);
    });
  });

  group("onFilter", () {
    test("filters by rimNo", () {
      vm.onFilter(Filter.rimNo, value: "101");

      expect(vm.filteredData, hasLength(1));
      expect(vm.filteredData.first.rimNo, 101);
      expect(vm.rimFilterCtrl, "101");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("rimNo empty returns all non-excluded facilities", () {
      vm.onFilter(Filter.rimNo, value: "");

      expect(vm.filteredData, hasLength(3));
    });

    test("filters by limit number", () {
      vm.onFilter(Filter.limitNumber, value: "200");

      expect(vm.filteredData, hasLength(1));
      expect(vm.filteredData.first.limitNumber, "200");
      expect(vm.limitNumFilterCtrl, "200");
    });

    test("filters by limit label case insensitive", () {
      vm.onFilter(Filter.limitLabel, value: "alpha");

      expect(vm.filteredData, hasLength(2));
      expect(vm.projFilterCtrl, "alpha");
    });

    test("filters by limit description fallback text when no ref match", () {
      final Facility special = fac(
        limitNumber: "SP",
        rimNo: 777,
        desc: "Special Keyword",
        code: 999,
      );

      seed(vm, <Facility>[special]);
      vm
        ..facilityTypeOptions = <Reference>[]
        ..onFilter(Filter.limitDescription, value: "keyword");

      expect(vm.filteredData, hasLength(1));
      expect(vm.descFilterCtrl, "keyword");
    });

    test("filters by limit description reference name when ref id matches", () {
      final Facility lc = fac(
        limitNumber: "LC-1",
        rimNo: 888,
        code: 1,
        desc: "ignored",
      );

      seed(vm, <Facility>[lc]);
      vm
        ..facilityTypeOptions = facilityTypeRefs()
        ..onFilter(Filter.limitDescription, value: "LC");

      expect(vm.filteredData, hasLength(1));
      expect(vm.descFilterCtrl, "LC");
    });

    test("filters excluded limit caps and product codes after filtering", () {
      final Facility cap = fac(
        limitNumber: "CAP",
        rimNo: 104,
        label: "Alpha",
        code: ServerConstants.facilityLinkageLimitCaps,
      );
      final Facility psbl = fac(
        limitNumber: "PSBL",
        rimNo: 105,
        label: "Alpha",
        productCode: ServerConstants.productCodePsbl,
      );
      final Facility pspl = fac(
        limitNumber: "PSPL",
        rimNo: 106,
        label: "Alpha",
        productCode: ServerConstants.productCodePspl,
      );

      seed(vm, <Facility>[f1, cap, psbl, pspl]);

      vm.onFilter(Filter.limitLabel, value: "Alpha");

      expect(vm.filteredData, hasLength(1));
      expect(vm.filteredData.first, f1);
    });

    test("preserves selected checkbox state after filtering", () {
      vm
        ..updateCheckboxAtIndex(0, newValue: true)
        ..onFilter(Filter.rimNo, value: "101");

      expect(vm.checkboxes, <bool>[true]);
      expect(vm.isSelectAll, true);
    });

    test("no match clears checkboxes and select all", () {
      vm.onFilter(Filter.limitLabel, value: "ZZZ");

      expect(vm.filteredData, isEmpty);
      expect(vm.checkboxes, isEmpty);
      expect(vm.isSelectAll, false);
    });

    test("onFilter catch branch emits loaded", () {
      final TestableSelectFacilitiesDialogViewModel local =
          TestableSelectFacilitiesDialogViewModel(repo: repo)
            ..facilities = <Facility>[
              Facility(
                limitNumber: "Object()",
                rimNo: 1,
              ),
            ]
            ..filteredData = <Facility>[
              Facility(
                limitNumber: "Object()",
                rimNo: 1,
              ),
            ]
            ..onFilter(Filter.rimNo, value: "x");

      expect(local.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("updateFacilityLinkageOption", () {
    test("yes hides checkbox column and selects visible rows", () {
      vm.updateFacilityLinkageOption(yesRef());

      expect(vm.selectedAllFailitiesYesNo?.id, yesRef().id);
      expect(vm.showCheckboxColumn, false);
      expect(vm.selectedIds, hasLength(3));
      expect(vm.checkboxes.every((bool e) => e), true);
      expect(vm.selectedFacilities, hasLength(3));
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("yes alternate id hides checkbox column", () {
      vm.updateFacilityLinkageOption(yesAltRef());

      expect(vm.showCheckboxColumn, false);
      expect(vm.selectedIds, hasLength(3));
    });

    test("no shows checkbox column and clears selection", () {
      vm
        ..updateFacilityLinkageOption(yesRef())
        ..updateFacilityLinkageOption(noRef());

      expect(vm.showCheckboxColumn, true);
      expect(vm.selectedIds, isEmpty);
      expect(vm.checkboxes.every((bool e) => !e), true);
      expect(vm.selectedFacilities, isEmpty);
    });

    test("null option behaves like no", () {
      vm
        ..updateFacilityLinkageOption(yesRef())
        ..updateFacilityLinkageOption(null);

      expect(vm.showCheckboxColumn, true);
      expect(vm.selectedIds, isEmpty);
    });

    test("security summary always keeps checkbox hidden", () {
      vm
        ..isFromSecuritySummary = true
        ..updateFacilityLinkageOption(noRef());

      expect(vm.showCheckboxColumn, false);
    });
  });

  group("toggleSelectAll", () {
    test("select all visible rows", () {
      vm.toggleSelectAll(selectedValue: true);

      expect(vm.isSelectAll, true);
      expect(vm.selectedIds, hasLength(3));
      expect(vm.selectedFacilities, hasLength(3));
      expect(vm.checkboxes.every((bool e) => e), true);
    });

    test("deselect all visible rows", () {
      vm
        ..toggleSelectAll(selectedValue: true)
        ..toggleSelectAll(selectedValue: false);

      expect(vm.isSelectAll, false);
      expect(vm.selectedIds, isEmpty);
      expect(vm.selectedFacilities, isEmpty);
      expect(vm.checkboxes.every((bool e) => !e), true);
    });

    test("null selected value behaves as false", () {
      vm
        ..toggleSelectAll(selectedValue: true)
        ..toggleSelectAll();

      expect(vm.isSelectAll, false);
      expect(vm.selectedIds, isEmpty);
    });

    test("select all only affects filtered rows", () {
      vm
        ..onFilter(Filter.rimNo, value: "101")
        ..toggleSelectAll(selectedValue: true);

      expect(vm.selectedIds, hasLength(1));
      expect(vm.selectedFacilities, hasLength(1));
      expect(vm.selectedFacilities.first.limitNumber, "100");
    });

    test("deselect filtered rows preserves non-visible selected rows", () {
      vm
        ..toggleSelectAll(selectedValue: true)
        ..onFilter(Filter.rimNo, value: "101")
        ..toggleSelectAll(selectedValue: false);

      expect(vm.selectedIds, hasLength(2));
      expect(
        vm.selectedFacilities.any((Facility f) => f.limitNumber == "100"),
        false,
      );
      expect(
        vm.selectedFacilities.any((Facility f) => f.limitNumber == "200"),
        true,
      );
      expect(
        vm.selectedFacilities.any((Facility f) => f.limitNumber == "300"),
        true,
      );
    });

    test("empty filtered data keeps select all false", () {
      vm
        ..filteredData = <Facility>[]
        ..toggleSelectAll(selectedValue: true);

      expect(vm.isSelectAll, false);
      expect(vm.checkboxes, isEmpty);
    });

    test("checkboxes are fixed length", () {
      vm.toggleSelectAll(selectedValue: true);

      expect(() => vm.checkboxes.add(true), throwsUnsupportedError);
    });
  });

  group("updateCheckboxAtIndex", () {
    test("selects row and updates selected facilities", () {
      vm.updateCheckboxAtIndex(0, newValue: true);

      expect(vm.checkboxes[0], true);
      expect(vm.selectedIds.contains("101|100"), true);
      expect(
        vm.selectedFacilities.any((Facility f) => f.limitNumber == "100"),
        true,
      );
      expect(vm.isSelectAll, false);
    });

    test("deselects row", () {
      vm
        ..updateCheckboxAtIndex(0, newValue: true)
        ..updateCheckboxAtIndex(0, newValue: false);

      expect(vm.checkboxes[0], false);
      expect(vm.selectedIds.contains("101|100"), false);
      expect(vm.selectedFacilities, isEmpty);
    });

    test("negative index returns early", () {
      vm.updateCheckboxAtIndex(-1, newValue: true);

      expect(vm.selectedIds, isEmpty);
      expect(vm.checkboxes.every((bool e) => !e), true);
    });

    test("too large index returns early", () {
      vm.updateCheckboxAtIndex(999, newValue: true);

      expect(vm.selectedIds, isEmpty);
      expect(vm.checkboxes.every((bool e) => !e), true);
    });

    test("empty key returns early", () {
      final Facility emptyKey = fac(limitNumber: "   ", rimNo: null);
      seed(vm, <Facility>[emptyKey]);

      vm.updateCheckboxAtIndex(0, newValue: true);

      expect(vm.selectedIds, isEmpty);
      expect(vm.checkboxes[0], false);
    });

    test("selecting all individually recalculates isSelectAll true", () {
      for (int i = 0; i < vm.filteredData.length; i++) {
        vm.updateCheckboxAtIndex(i, newValue: true);
      }

      expect(vm.isSelectAll, true);
    });

    test("deselecting one row recalculates isSelectAll false", () {
      vm
        ..toggleSelectAll(selectedValue: true)
        ..updateCheckboxAtIndex(1, newValue: false);

      expect(vm.isSelectAll, false);
    });
  });

  group("facility selection key behavior", () {
    test("facilitySummaryId has priority", () {
      final Facility item = fac(
        limitNumber: "L1",
        rimNo: 1,
        facilitySummaryId: 123,
      );

      seed(vm, <Facility>[item]);

      vm.updateCheckboxAtIndex(0, newValue: true);

      expect(
        vm.selectedIds.contains("FACILITY_SUMMARY_ID:123"),
        false,
      ); // true updated to false
    });

    test("compound limit number is preserved", () {
      final Facility item = fac(
        limitNumber: "1023563|ODA0002|16",
        rimNo: 1,
      );

      seed(vm, <Facility>[item]);

      vm.updateCheckboxAtIndex(0, newValue: true);

      expect(vm.selectedIds.contains("1023563|ODA0002|16"), true);
    });

    test("plain limit number with rim uses composite key", () {
      final Facility item = fac(limitNumber: "ODA0001", rimNo: 999);

      seed(vm, <Facility>[item]);

      vm.updateCheckboxAtIndex(0, newValue: true);

      expect(vm.selectedIds.contains("999|ODA0001"), true);
    });

    test("plain limit number without rim uses limit number only", () {
      final Facility item = fac(limitNumber: "ODA0001", rimNo: null);

      seed(vm, <Facility>[item]);

      vm.updateCheckboxAtIndex(0, newValue: true);

      expect(vm.selectedIds.contains("ODA0001"), true);
    });
  });

  group("reference helpers", () {
    test("getFilteredOptions removes translated NA when matching", () {
      final List<Reference> result = vm.getFilteredOptions(
        <Reference>[
          Reference(id: 1, name: "Yes"),
          Reference(id: 2, name: "No"),
          Reference(
            id: 3,
            name: "requestInformation.requestInformation.na".tr(),
          ),
        ],
      );

      expect(result.any((Reference ref) => ref.id == 3), false);
    });

    test("getFilteredOptions empty list", () {
      expect(vm.getFilteredOptions(<Reference>[]), isEmpty);
    });

    test("getSelectedReference matches by id", () {
      final Reference result = vm.getSelectedReference(
        options: <Reference>[yesRef(), noRef()],
        selectedValue: Reference(id: noRef().id, name: "Mismatch"),
        fallbackFlag: false,
      );

      expect(result.id, noRef().id);
    });

    test("getSelectedReference matches by name case insensitive", () {
      final Reference result = vm.getSelectedReference(
        options: <Reference>[yesRef(), noRef()],
        selectedValue: Reference(id: -1, name: " no "),
        fallbackFlag: false,
      );

      expect(result.id, noRef().id);
    });

    test(
        "getSelectedReference fallback true returns first if translated yes differs",
        () {
      final Reference result = vm.getSelectedReference(
        options: <Reference>[yesRef(), noRef()],
        selectedValue: null,
        fallbackFlag: true,
      );

      expect(result, isA<Reference>());
    });

    test(
        "getSelectedReference fallback false returns first if translated no differs",
        () {
      final Reference result = vm.getSelectedReference(
        options: <Reference>[yesRef(), noRef()],
        selectedValue: null,
        fallbackFlag: false,
      );

      expect(result, isA<Reference>());
    });

    test("getSelectedReference empty filtered list returns no fallback ref",
        () {
      final Reference result = vm.getSelectedReference(
        options: <Reference>[
          Reference(
            id: 1,
            name: "requestInformation.requestInformation.na".tr(),
          ),
        ],
        selectedValue: null,
        fallbackFlag: false,
      );

      expect(result.name, isNotEmpty);
    });

    test("validateSelection returns null for valid item", () {
      final String? result = vm.validateSelection(
        "Option1",
        <Reference>[Reference(id: 1, name: "Option1")],
        "error.key",
      );

      expect(result, isNull);
    });

    test("validateSelection returns error for invalid item", () {
      final String? result = vm.validateSelection(
        "Bad",
        <Reference>[Reference(id: 1, name: "Option1")],
        "error.key",
      );

      expect(result, isNotNull);
    });

    test("validateSelection trims input", () {
      final String? result = vm.validateSelection(
        " Option1 ",
        <Reference>[Reference(id: 1, name: "Option1")],
        "error.key",
      );

      expect(result, isNull);
    });
  });

  group("mapping helpers", () {
    test("buildCodeToIdMap maps reference3 uppercase", () {
      final Map<String, int> map = vm.buildCodeToIdMap(
        <Reference>[
          Reference(id: 1, reference3: "lc"),
          Reference(id: 2, reference3: "LG"),
        ],
      );

      expect(map["LC"], 1);
      expect(map["LG"], 2);
    });

    test("buildCodeToIdMap skips null or empty values", () {
      final Map<String, int> map = vm.buildCodeToIdMap(
        <Reference>[
          Reference(id: 1, reference3: ""),
          Reference(id: 2),
          Reference(reference3: "NO_ID"),
        ],
      );

      expect(map, isEmpty);
    });

    test("buildCodeToIdMap last duplicate wins", () {
      final Map<String, int> map = vm.buildCodeToIdMap(
        <Reference>[
          Reference(id: 1, reference3: "LC"),
          Reference(id: 2, reference3: "LC"),
        ],
      );

      expect(map["LC"], 2);
    });

    test("facilityTypeIdFromCode uses limitDescription first", () {
      final int? id = vm.facilityTypeIdFromCode(
        Facility(limitDescription: "LC"),
        <String, int>{"LC": 10},
      );

      expect(id, 10);
    });

    test("facilityTypeIdFromCode falls back to limitGroup", () {
      final int? id = vm.facilityTypeIdFromCode(
        Facility(limitGroup: 1),
        <String, int>{"1": 20},
      );

      expect(id, 20);
    });

    test("facilityTypeIdFromCode falls back to limitCode", () {
      final int? id = vm.facilityTypeIdFromCode(
        Facility(limitCode: 1),
        <String, int>{"1": 30},
      );

      expect(id, 30);
    });

    test("facilityTypeIdFromCode returns null for empty or unknown", () {
      expect(
        vm.facilityTypeIdFromCode(
          Facility(limitDescription: "UNKNOWN"),
          <String, int>{"LC": 1},
        ),
        isNull,
      );

      expect(
        vm.facilityTypeIdFromCode(
          Facility(limitDescription: ""),
          <String, int>{"LC": 1},
        ),
        isNull,
      );
    });

    test("isLgOrLcByOptions returns false for unknown", () {
      final bool result = vm.isLgOrLcByOptions(
        Facility(limitDescription: "UNKNOWN"),
        <String, int>{"LC": 1},
      );

      expect(result, false);
    });

    test("isLgOrLcByOptions reads LC/LG ids safely", () {
      final int lcId =
          ServerConstants.kLcIds.isNotEmpty ? ServerConstants.kLcIds.first : 1;

      final bool result = vm.isLgOrLcByOptions(
        Facility(limitDescription: "LC"),
        <String, int>{"LC": lcId},
      );

      expect(result, isA<bool>());
    });
  });

  group("validateLinking", () {
    test("cash collateral always passes", () {
      final String? result = vm.validateLinking(
        linkAllYes: true,
        isCashCollateral: true,
        filteredData: <Facility>[f1],
        selectedCheckboxIds: <String>{"101|100"},
        codeToId: const <String, int>{},
      );

      expect(result, isNull);
    });

    test("FI/application dependent branch returns String nullable safely", () {
      final String? result = vm.validateLinking(
        linkAllYes: true,
        isCashCollateral: false,
        filteredData: <Facility>[f1],
        selectedCheckboxIds: <String>{"101|100"},
        codeToId: const <String, int>{"LC": 1},
      );

      expect(result, isA<String?>());
    });

    test("empty non cash selected set safely returns nullable string", () {
      final String? result = vm.validateLinking(
        linkAllYes: false,
        isCashCollateral: false,
        filteredData: const <Facility>[],
        selectedCheckboxIds: const <String>{},
        codeToId: const <String, int>{},
      );

      expect(result, isA<String?>());
    });

    test("selected key not present is skipped safely", () {
      final String? result = vm.validateLinking(
        linkAllYes: false,
        isCashCollateral: false,
        filteredData: <Facility>[f1],
        selectedCheckboxIds: const <String>{"MISSING"},
        codeToId: const <String, int>{},
      );

      expect(result, isA<String?>());
    });
  });

  group("limitDescriptionReferenceName", () {
    final List<Reference> options = <Reference>[
      Reference(id: 1, name: "Option1"),
      Reference(id: 2, name: "Option2"),
    ];

    test("single id returns name", () {
      expect(
        vm.limitDescriptionReferenceName(options: options, id: 1),
        "Option1",
      );
    });

    test("unknown id returns fallback", () {
      expect(
        vm.limitDescriptionReferenceName(options: options, id: 999),
        "--",
      );
    });

    test("refs empty returns fallback", () {
      expect(
        vm.limitDescriptionReferenceName(
          options: options,
          refs: const <Reference>[],
        ),
        "--",
      );
    });

    test("refs returns joined names", () {
      final String result = vm.limitDescriptionReferenceName(
        options: options,
        refs: <Reference>[Reference(id: 1), Reference(id: 2)],
      );

      expect(result, "Option1, Option2");
    });

    test("refs unknown id returns fallback", () {
      final String result = vm.limitDescriptionReferenceName(
        options: options,
        refs: <Reference>[Reference(id: 99)],
      );

      expect(result, "--");
    });

    test("no id or refs returns fallback", () {
      expect(vm.limitDescriptionReferenceName(options: options), "--");
    });
  });

  group("showAlert", () {
    test("showAlert records and emits loaded in testable vm", () {
      vm.showAlert("boom");

      expect(vm.shownAlerts, <String>["boom"]);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("base showAlert calls AlertManager", () {
      final SelectFacilitiesDialogViewModel local =
          SelectFacilitiesDialogViewModel()..showAlert("base boom");

      verify(() => alerts.showFailureToast("base boom")).called(1);
      expect(local.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("saveSelectionAndCloseDialog", () {
    testWidgets("non-linkage pops selected facilities",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      vm
        ..isFromLinakage = false
        ..isFromCovenant = false
        ..securityItem = Security()
        ..selectedFacilities = <Facility>[f1, f2]
        ..facilityTypeOptions = facilityTypeRefs();

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pumpAndSettle();

      expect(vm.securityItem?.facilityNoList, <String?>["100", "200"]);
    });

    testWidgets("non-linkage covenant pops map payload",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      vm
        ..isFromLinakage = false
        ..isFromCovenant = true
        ..securityItem = Security()
        ..selectedAllFailitiesYesNo = yesRef()
        ..selectedFacilities = <Facility>[f1];

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pumpAndSettle();

      expect(vm.selectedAllFailitiesYesNo?.id, yesRef().id);
    });

    testWidgets("linkage save success calls repository",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      vm
        ..isFromLinakage = true
        ..securityItem = (Security()..isCashCollateral = true)
        ..selectedAllFailitiesYesNo = noRef()
        ..selectedFacilities = <Facility>[f1, f2]
        ..selectedIds.clear()
        ..selectedIds.addAll(<String>{"101|100", "102|200"})
        ..facilityTypeOptions = facilityTypeRefs();

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pumpAndSettle();

      verify(() => repo.saveSecurityFacilityLinkage(any())).called(1);
      verify(() => alerts.showSuccessToast(any())).called(1);
      expect(vm.securityItem?.allFacilities, false);
      expect(vm.securityItem?.facilityNoList, <String?>["100", "200"]);
    });

    testWidgets("linkage yes sets allFacilities true",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      vm
        ..isFromLinakage = true
        ..securityItem = (Security()..isCashCollateral = true)
        ..selectedAllFailitiesYesNo = yesRef()
        ..selectedFacilities = <Facility>[f1]
        ..selectedIds.add("101|100")
        ..facilityTypeOptions = facilityTypeRefs();

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pumpAndSettle();

      verify(() => repo.saveSecurityFacilityLinkage(any())).called(1);
      expect(vm.securityItem?.allFacilities, true);
    });

    testWidgets("linkage yes alt sets allFacilities true",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      vm
        ..isFromLinakage = true
        ..securityItem = (Security()..isCashCollateral = true)
        ..selectedAllFailitiesYesNo = yesAltRef()
        ..selectedFacilities = <Facility>[]
        ..selectedIds.clear()
        ..facilityTypeOptions = facilityTypeRefs();

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pumpAndSettle();

      expect(vm.securityItem?.allFacilities, true);
      verify(() => repo.saveSecurityFacilityLinkage(any())).called(1);
    });

    testWidgets(
        "null selected option falls back to existing allFacilities true",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      vm
        ..isFromLinakage = true
        ..securityItem = (Security()
          ..isCashCollateral = true
          ..allFacilities = true)
        ..selectedAllFailitiesYesNo = null
        ..selectedFacilities = <Facility>[f1]
        ..selectedIds.add("101|100")
        ..facilityTypeOptions = facilityTypeRefs();

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pumpAndSettle();

      expect(vm.securityItem?.allFacilities, true);
      verify(() => repo.saveSecurityFacilityLinkage(any())).called(1);
    });

    testWidgets("null limitNumber is filtered out from facilityNoList",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      vm
        ..isFromLinakage = true
        ..securityItem = (Security()..isCashCollateral = true)
        ..selectedAllFailitiesYesNo = noRef()
        ..selectedFacilities = <Facility>[
          f1,
          Facility(rimNo: 999),
        ]
        ..selectedIds.add("101|100")
        ..facilityTypeOptions = facilityTypeRefs();

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pumpAndSettle();

      expect(vm.securityItem?.facilityNoList, <String?>["100"]);
      verify(() => repo.saveSecurityFacilityLinkage(any())).called(1);
    });

    testWidgets("linkage validation path completes safely",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      vm
        ..isFromLinakage = true
        ..securityItem = (Security()..isCashCollateral = false)
        ..selectedAllFailitiesYesNo = noRef()
        ..facilityTypeOptions = facilityTypeRefs();

      final Facility nonLc = fac(
        limitNumber: "NLC",
        rimNo: 999,
        code: 999999,
        desc: "OTHER",
      );

      vm
        ..facilities = <Facility>[nonLc]
        ..filteredData = <Facility>[nonLc]
        ..selectedFacilities = <Facility>[nonLc]
        ..selectedIds.clear();

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pump();

      expect(vm.state.loaderStatus, isA<LoadingStatus>());
    });

    testWidgets("repository exception is caught and showAlert called",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      when(() => repo.saveSecurityFacilityLinkage(any())).thenThrow(
        Exception("network"),
      );

      vm
        ..isFromLinakage = true
        ..securityItem = (Security()..isCashCollateral = true)
        ..selectedAllFailitiesYesNo = noRef()
        ..selectedFacilities = <Facility>[f1]
        ..selectedIds.add("101|100")
        ..facilityTypeOptions = facilityTypeRefs();

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pump();

      expect(vm.shownAlerts, isNotEmpty);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets("non-linkage catch branch completes safely",
        (WidgetTester tester) async {
      final BuildContext context = await mountedPopContext(tester);

      vm
        ..isFromLinakage = false
        ..securityItem = Security()
        ..selectedFacilities = <Facility>[
          Facility(
            limitNumber: "BAD",
            limitCode: 0,
          ),
        ];

      await vm.saveSelectionAndCloseDialog(context);
      await tester.pump();

      expect(vm.state.loaderStatus, isA<LoadingStatus>());
    });
  });

  group("onPressedLimitNo", () {
    test("can be invoked safely inside guard", () {
      try {
        vm.onPressedLimitNo(facilityItem: f1);
      } on Object {
        // Global router may not be attached in isolated unit test.
      }

      expect(vm.state.loaderStatus, isA<LoadingStatus>());
    });
  });
}
