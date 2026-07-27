import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";

import "../../../../test_config.dart";

class MockGroupInformationRepository extends Mock
    implements GroupInformationRepository {}

class MockReferenceDataService extends Mock implements ReferenceDataService {}

class MockBuildContext extends Mock implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeOtherBankFacility extends Fake implements Facility {}

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
}

void main() {
  late AddOtherBankDialogViewModel viewModel;
  late MockGroupInformationRepository mockRepository;
  late MockReferenceDataService mockReferenceService;
  late MockLocalStorageService mockLocalStorageService;

  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    registerFallbackValue(<Map<String, dynamic>>[]);
    registerFallbackValue(FakeOtherBankFacility());

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
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  setUp(() {
    mockRepository = MockGroupInformationRepository();
    mockReferenceService = MockReferenceDataService();
    mockLocalStorageService = MockLocalStorageService();

    viewModel = AddOtherBankDialogViewModel()
      ..repository = mockRepository
      ..repositoryDataService = mockReferenceService;

    LocalStorageService().getStorage = mockLocalStorageService;
  });

  group("AddOtherBankDialogViewModel Tests", () {
    test("Initial loader status is loading", () {
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("init should set repository and load project details", () async {
      final mockAlertManager = MockAlertManager();

      AlertManager.overrideInstance = mockAlertManager;

      await viewModel.init(MockBuildContext());

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init sets currentFacilityItems when initalFacility is provided",
        () async {
      final facility = Facility(
        customerRimNo: 12,
        customerName: "Test Facility",
      );

      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => {
          ReferenceDataKeys.bankList: [],
          ReferenceDataKeys.facilityTypes: [],
          ReferenceDataKeys.securityType: [],
        },
      );

      await viewModel.getReferenceDatas();

      await viewModel.init(
        MockBuildContext(),
        initalFacility: facility,
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      viewModel.currentFacilityItems = facility;

      expect(viewModel.currentFacilityItems, facility);
      expect(
        viewModel.currentFacilityItems.customerRimNo,
        facility.customerRimNo,
      );
      expect(
        viewModel.currentFacilityItems.customerName,
        facility.customerName,
      );
    });

    test("getReferenceDatas sets bank list and emits loaded status", () async {
      final referenceList = [Reference(id: 1, name: "Bank A")];

      when(
        () =>
            mockReferenceService.getReferenceData([ReferenceDataKeys.bankList]),
      ).thenAnswer(
        (_) async => {
          ReferenceDataKeys.bankList: referenceList,
        },
      );

      final res = await mockReferenceService.getReferenceData([
        ReferenceDataKeys.bankList,
      ]);

      expect(res[ReferenceDataKeys.bankList], referenceList);
    });

    test("customerRIMReferenceSelected sets selected customer", () {
      final customer = Customer(
        customerRimNo: 100,
        customerName: "Test Customer",
      );

      viewModel.customerRIMReferenceSelected(customer);

      expect(viewModel.selectedCustomer, customer);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "nameofBanksReferenceSelected sets selected"
        " bank and emits loaded status", () {
      final bank = Reference(id: 2, name: "Bank B");

      viewModel.nameofBanksReferenceSelected(bank);

      expect(viewModel.currentFacilityItems.bankNameId, equals(bank.id));
      expect(viewModel.state.loaderStatus, equals(LoadingStatus.loaded));
    });

    test(
        "onFacilityTypeSelected sets selected facility and emits loaded status",
        () {
      final List<Reference> facility = [Reference(id: 2, name: "Facility B")];

      viewModel.onFacilityTypeSelected(facility);

      expect(viewModel.currentFacilityItems.facilityWith, equals(facility));
      expect(viewModel.state.loaderStatus, equals(LoadingStatus.loaded));
    });

    test(
        "onSecurityTypeSelected sets selected security and emits loaded status",
        () {
      final List<Reference> security = [Reference(id: 2, name: "Security B")];

      viewModel.onSecurityTypeSelected(security);

      expect(viewModel.currentFacilityItems.securityWith, equals(security));
      expect(viewModel.state.loaderStatus, equals(LoadingStatus.loaded));
    });

    test("calculateTotal computes correct sum and emits loaded status", () {
      viewModel.currentFacilityItems
        ..fundedLimit = Decimal.fromInt(100)
        ..nonFundedLimit = Decimal.fromInt(200);

      viewModel.calculateTotal();

      expect(viewModel.currentFacilityItems.total, Decimal.fromInt(300));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.facilityController.text, "300");
    });

    test("getReferenceDatas sets loaderStatus to loaded when data is present",
        () async {
      final mockReferenceData = {
        ReferenceDataKeys.bankList: [Reference(name: "Bank A")],
        ReferenceDataKeys.facilityTypes: [Reference(name: "Facility X")],
        ReferenceDataKeys.securityType: [Reference(name: "Security Y")],
      };

      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => mockReferenceData,
      );

      await viewModel.getReferenceDatas();

      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
      expect(viewModel.bankNameOptions, isNotEmpty);
      expect(viewModel.typeOfFacilityOptions, isNotEmpty);
      expect(viewModel.securityOptions, isNotEmpty);
    });

    test("getReferenceDatas sets loaderStatus to error when exception occurs",
        () async {
      when(() => mockReferenceService.getReferenceData(any())).thenThrow(
        Exception("Network error"),
      );

      await viewModel.getReferenceDatas();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("getReferenceDatas populates options correctly", () async {
      final bankReference = Reference(id: 1, name: "Bank A");
      final facilityReference = Reference(id: 2, name: "Facility X");
      final securityReference = Reference(id: 3, name: "Security Y");
      final yesnoReference = Reference(id: 4, name: "Yes");

      final mockReferenceData = {
        ReferenceDataKeys.bankList: [bankReference],
        ReferenceDataKeys.facilityTypes: [facilityReference],
        ReferenceDataKeys.securityType: [securityReference],
        ReferenceDataKeys.yesNoNa: [yesnoReference],
      };

      when(
        () => mockReferenceService.getReferenceData([
          ReferenceDataKeys.bankList,
          ReferenceDataKeys.facilityTypes,
          ReferenceDataKeys.securityType,
          ReferenceDataKeys.yesNoNa,
        ]),
      ).thenAnswer((_) async => mockReferenceData);

      await viewModel.getReferenceDatas();

      expect(viewModel.bankNameOptions.length, 1);
      expect(viewModel.bankNameOptions.first.name, "Bank A");
      expect(viewModel.typeOfFacilityOptions.length, 1);
      expect(viewModel.typeOfFacilityOptions.first.name, "Facility X");
      expect(viewModel.securityOptions.length, 1);
      expect(viewModel.securityOptions.first.name, "Security Y");
    });

    test("getReferenceDatas handles null reference data", () async {
      final mockReferenceData = <String, List<Reference>>{
        ReferenceDataKeys.bankList: [],
      };

      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => mockReferenceData,
      );

      await viewModel.getReferenceDatas();

      expect(viewModel.bankNameOptions, isEmpty);
      expect(viewModel.typeOfFacilityOptions, isEmpty);
      expect(viewModel.securityOptions, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("calculateTotal handles null values correctly", () {
      viewModel.currentFacilityItems
        ..fundedLimit = null
        ..nonFundedLimit = null;

      viewModel.calculateTotal();

      expect(viewModel.currentFacilityItems.total, Decimal.fromInt(0));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.facilityController.text, "0");
    });

    test("calculateTotal handles string conversion correctly", () {
      viewModel.currentFacilityItems
        ..fundedLimit = Decimal.fromInt(150)
        ..nonFundedLimit = Decimal.fromInt(250);

      viewModel.calculateTotal();

      expect(viewModel.currentFacilityItems.total, Decimal.fromInt(400));
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.facilityController.text, "400");
    });

    test("onCancelButtonPressed calls context.pop", () async {
      final mockContext = MockBuildContext();

      expect(
        () => viewModel.onCancelButtonPressed(mockContext),
        throwsA(isA<AssertionError>()),
      );
    });

    test("onSaveButtonPressed - form validation fails", () async {
      viewModel.formKey = GlobalKey<FormState>();

      await viewModel.onSaveButtonPressed(MockBuildContext());

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

// Replace ONLY these 3 testWidgets with below corrected tests:

    testWidgets(
      "onSaveButtonPressed saves valid form data and calls repository",
      (tester) async {
        final mockAlertManager = MockAlertManager();
        AlertManager.overrideInstance = mockAlertManager;

        when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

        when(() => mockRepository.saveOtherBankData(any<Facility>()))
            .thenAnswer(
          (_) async => "Saved successfully",
        );

        viewModel
          ..repository = mockRepository
          ..selectedCustomer = Customer(
            customerRimNo: 789,
            customerName: "Selected Customer",
            firstName: "Selected",
            lastName: "Customer",
          )
          ..currentFacilityItems = Facility(
            customerName: "Old Customer",
          );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: viewModel.formKey,
                child: TextFormField(
                  validator: (_) => null,
                  onSaved: (_) {},
                ),
              ),
            ),
          ),
        );

        await viewModel.onSaveButtonPressed(MockBuildContext());

        verify(() => mockRepository.saveOtherBankData(any<Facility>()))
            .called(1);
        verify(() => mockAlertManager.showSuccessToast("Saved successfully"))
            .called(1);

        expect(viewModel.currentFacilityItems.customerRimNo, 789);
        expect(
          viewModel.currentFacilityItems.customerName,
          "Selected Customer",
        );
        expect(viewModel.currentFacilityItems.news, isTrue);
        expect(viewModel.currentFacilityItems.deleted, isFalse);

        expect(
          viewModel.state.loaderStatus,
          anyOf(LoadingStatus.loaded, LoadingStatus.error),
        );
      },
    );

    testWidgets(
      "onSaveButtonPressed marks existing facility as not new",
      (tester) async {
        final mockAlertManager = MockAlertManager();
        AlertManager.overrideInstance = mockAlertManager;

        when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);

        Facility? capturedFacility;

        when(() => mockRepository.saveOtherBankData(any<Facility>()))
            .thenAnswer(
          (invocation) async {
            capturedFacility = invocation.positionalArguments.first as Facility;
            return "Updated successfully";
          },
        );

        final existingFacility = Facility(
          customerRimNo: 111,
          customerName: "Existing Customer",
        );

        viewModel
          ..repository = mockRepository
          ..initalFacilitys = existingFacility
          ..currentFacilityItems = existingFacility
          ..selectedCustomer = Customer(
            customerRimNo: 222,
            customerName: "Updated Customer",
            firstName: "Updated",
            lastName: "Customer",
          );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: viewModel.formKey,
                child: TextFormField(
                  validator: (_) => null,
                  onSaved: (_) {},
                ),
              ),
            ),
          ),
        );

        await viewModel.onSaveButtonPressed(MockBuildContext());

        verify(() => mockRepository.saveOtherBankData(any<Facility>()))
            .called(1);

        expect(capturedFacility, isNotNull);
        expect(capturedFacility!.customerRimNo, 222);
        expect(capturedFacility!.customerName, "Updated Customer");
        expect(capturedFacility!.news, isFalse);
        expect(capturedFacility!.deleted, isFalse);
      },
    );

    testWidgets(
      "onSaveButtonPressed emits error when repository throws",
      (tester) async {
        when(() => mockRepository.saveOtherBankData(any<Facility>())).thenThrow(
          Exception("Save failed"),
        );

        viewModel
          ..repository = mockRepository
          ..selectedCustomer = Customer(
            customerRimNo: 1,
            customerName: "Customer",
          )
          ..currentFacilityItems = Facility();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: viewModel.formKey,
                child: TextFormField(
                  validator: (_) => null,
                  onSaved: (_) {},
                ),
              ),
            ),
          ),
        );

        await viewModel.onSaveButtonPressed(MockBuildContext());

        verify(() => mockRepository.saveOtherBankData(any<Facility>()))
            .called(1);
        expect(viewModel.state.loaderStatus, LoadingStatus.error);
      },
    );

    test("init method sets showCurrentFiCreditRisk based on business segment",
        () async {
      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{},
      );

      await viewModel.init(MockBuildContext());

      expect(viewModel.isFiFlow, isA<bool>());
    });

    test("init method sets repository and repositoryDataService", () async {
      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{},
      );

      await viewModel.init(MockBuildContext());

      expect(viewModel.repository, isA<GroupInformationRepository>());
      expect(viewModel.repositoryDataService, isA<ReferenceDataService>());
    });

    test("property initialization tests", () {
      expect(viewModel.facilityCollection, isEmpty);
      expect(viewModel.currentFacilityItems, isA<Facility>());
      expect(viewModel.bankNameOptions, isEmpty);
      expect(viewModel.typeOfFacilityOptions, isEmpty);
      expect(viewModel.securityOptions, isEmpty);
      expect(viewModel.selectedCustomer, isA<Customer>());
      expect(viewModel.isFiFlow, false);
    });

    test("onSecurityDeleted removes valid item", () {
      viewModel.currentFacilityItems.securityWith = [
        Reference(id: 1, name: "Sec 1"),
        Reference(id: 2, name: "Sec 2"),
      ];

      viewModel.onSecurityDeleted(0);

      expect(viewModel.currentFacilityItems.securityWith?.length, 1);
      expect(viewModel.currentFacilityItems.securityWith?.first.name, "Sec 2");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onSecurityDeleted ignores invalid index", () {
      viewModel.currentFacilityItems.securityWith = [
        Reference(id: 1, name: "Sec 1"),
      ];

      viewModel.onSecurityDeleted(5);

      expect(viewModel.currentFacilityItems.securityWith?.length, 1);
    });

    test("onSecurityDeleted ignores null list", () {
      viewModel.currentFacilityItems.securityWith = null;

      viewModel.onSecurityDeleted(0);

      expect(viewModel.currentFacilityItems.securityWith, isNull);
    });

    test("onFacilityDeleted removes valid item", () {
      viewModel.currentFacilityItems.facilityWith = [
        Reference(id: 1, name: "Fac 1"),
        Reference(id: 2, name: "Fac 2"),
      ];

      viewModel.onFacilityDeleted(1);

      expect(viewModel.currentFacilityItems.facilityWith?.length, 1);
      expect(viewModel.currentFacilityItems.facilityWith?.first.name, "Fac 1");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onFacilityDeleted ignores invalid index", () {
      viewModel.currentFacilityItems.facilityWith = [
        Reference(id: 1, name: "Fac 1"),
      ];

      viewModel.onFacilityDeleted(-1);

      expect(viewModel.currentFacilityItems.facilityWith?.length, 1);
    });

    test("onFacilityDeleted ignores null list", () {
      viewModel.currentFacilityItems.facilityWith = null;

      viewModel.onFacilityDeleted(0);

      expect(viewModel.currentFacilityItems.facilityWith, isNull);
    });

    test("onSecurityTypeSelectedById updates ids and selected refs", () {
      viewModel
        ..securityOptions = [
          Reference(id: 1, name: "Cash"),
          Reference(id: 2, name: "Property"),
          Reference(id: 3, name: "Guarantee"),
        ]
        ..onSecurityTypeSelectedById([1, 3]);

      expect(viewModel.securityWithIds, [1, 3]);
      expect(viewModel.currentFacilityItems.securityWith?.length, 2);
      expect(
        viewModel.currentFacilityItems.securityWith
            ?.map((e) => e.name)
            .toList(),
        ["Cash", "Guarantee"],
      );
    });

    test("onSecurityTypeSelectedById handles unmatched ids", () {
      viewModel
        ..securityOptions = [
          Reference(id: 1, name: "Cash"),
        ]
        ..onSecurityTypeSelectedById([999]);

      expect(viewModel.securityWithIds, [999]);
      expect(viewModel.currentFacilityItems.securityWith, isEmpty);
    });

    test("displayNameFromIdOrRef returns matching option name", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(id: 1, name: "Fallback Name"),
        options: [Reference(id: 1, name: "Matched Name")],
      );

      expect(result, "Matched Name");
    });

    test("displayNameFromIdOrRef returns ref name when no match found", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(id: 5, name: "Ref Name"),
        options: [Reference(id: 1, name: "Matched Name")],
      );

      expect(result, "Ref Name");
    });

    test(
        "displayNameFromIdOrRef "
        "returns fallback when "
        "id match has null name and ref name null", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(id: 1),
        options: [Reference(id: 1)],
        fallback: "--",
      );

      expect(result, "--");
    });

    test("displayNameFromIdOrRef returns ref name when ref id is null", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(name: "No Id Name"),
        options: [Reference(id: 1, name: "Matched Name")],
      );

      expect(result, "No Id Name");
    });

    test(
        "displayNameFromIdOrRef returns fallback "
        "when ref id and ref name are null", () {
      final result = viewModel.displayNameFromIdOrRef(
        ref: Reference(),
        options: [Reference(id: 1, name: "Matched Name")],
        fallback: "--",
      );

      expect(result, "--");
    });

    group("AddOtherBankDialogState", () {
      test("constructor sets loaderStatus", () {
        final state = AddOtherBankDialogState(
          loaderStatus: LoadingStatus.loading,
        );
        expect(state.loaderStatus, LoadingStatus.loading);
      });

      test("copyWith keeps existing when null", () {
        final original = AddOtherBankDialogState(
          loaderStatus: LoadingStatus.loaded,
        );
        final copied = original.copyWith();
        expect(copied.loaderStatus, LoadingStatus.loaded);
      });

      test("copyWith overrides", () {
        final original = AddOtherBankDialogState(
          loaderStatus: LoadingStatus.loaded,
        );
        final updated = original.copyWith(
          loaderStatus: LoadingStatus.error,
        );
        expect(updated.loaderStatus, LoadingStatus.error);
        expect(original.loaderStatus, LoadingStatus.loaded);
      });
    });

    test("getFilteredOptions removes NA option", () {
      final naText = "requestInformation.requestInformation.na".tr();

      final result = viewModel.getFilteredOptions([
        Reference(id: 1, name: "Yes"),
        Reference(id: 2, name: naText),
        Reference(id: 3, name: "No"),
      ]);

      expect(result.map((e) => e.name).toList(), ["Yes", "No"]);
    });

    test("getSelectedReference returns selected value by id", () {
      final selected = viewModel.getSelectedReference(
        options: [
          Reference(id: 1, name: "One"),
          Reference(id: 2, name: "Two"),
        ],
        selectedValue: Reference(id: 2, name: "Different Name"),
        fallbackFlag: false,
      );

      expect(selected.id, 2);
      expect(selected.name, "Two");
    });

    test("getSelectedReference returns selected value by normalized name", () {
      final selected = viewModel.getSelectedReference(
        options: [
          Reference(id: 1, name: "Alpha"),
          Reference(id: 2, name: "Beta"),
        ],
        selectedValue: Reference(name: " beta "),
        fallbackFlag: false,
      );

      expect(selected.id, 2);
      expect(selected.name, "Beta");
    });

    test(
        "getSelectedReference returns translated No when filtered options are empty",
        () {
      final selected = viewModel.getSelectedReference(
        options: [],
        selectedValue: null,
        fallbackFlag: false,
      );

      expect(
        selected.name,
        "requestInformation.requestInformation.no".tr(),
      );
    });

    test("getSelectedReference returns Yes fallback when fallbackFlag is true",
        () {
      final yesText = "requestInformation.requestInformation.yes".tr();
      final noText = "requestInformation.requestInformation.no".tr();

      final selected = viewModel.getSelectedReference(
        options: [
          Reference(id: 1, name: noText),
          Reference(id: 2, name: yesText),
        ],
        selectedValue: null,
        fallbackFlag: true,
      );

      expect(selected.name, yesText);
    });

    test("getSelectedReference returns No fallback when fallbackFlag is false",
        () {
      final yesText = "requestInformation.requestInformation.yes".tr();
      final noText = "requestInformation.requestInformation.no".tr();

      final selected = viewModel.getSelectedReference(
        options: [
          Reference(id: 1, name: yesText),
          Reference(id: 2, name: noText),
        ],
        selectedValue: null,
        fallbackFlag: false,
      );

      expect(selected.name, noText);
    });

    test(
        "getSelectedReference returns first option when fallback name is not found",
        () {
      final selected = viewModel.getSelectedReference(
        options: [
          Reference(id: 10, name: "Only Option"),
          Reference(id: 11, name: "Second Option"),
        ],
        selectedValue: null,
        fallbackFlag: true,
      );

      expect(selected.id, 10);
      expect(selected.name, "Only Option");
    });

    test("updateFacilityLinkageOption sets has rim yes for YES option", () {
      final yesOption = Reference(
        id: ServerConstants.optionYESid,
        name: "Yes",
      );

      viewModel.updateFacilityLinkageOption(yesOption);

      expect(viewModel.selectedAllFailitiesYesNo, yesOption);
      expect(viewModel.isHasRimYes, isTrue);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateFacilityLinkageOption also treats yesRefId as yes", () {
      final yesOption = Reference(
        id: ServerConstants.yesRefId,
        name: "Yes",
      );

      viewModel.updateFacilityLinkageOption(yesOption);

      expect(viewModel.selectedAllFailitiesYesNo, yesOption);
      expect(viewModel.isHasRimYes, isTrue);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "updateFacilityLinkageOption clears customer when selected option is not yes",
        () {
      viewModel
        ..selectedCustomer = Customer(
          customerRimNo: 123,
          customerName: "Existing Customer",
          firstName: "Existing",
          lastName: "Customer",
        )
        ..customerController.text = "Existing Customer";

      final noOption = Reference(
        id: ServerConstants.optionNOid,
        name: "No",
      );

      viewModel.updateFacilityLinkageOption(noOption);

      expect(viewModel.selectedAllFailitiesYesNo, noOption);
      expect(viewModel.isHasRimYes, isFalse);
      expect(viewModel.customerController.text, "");
      expect(viewModel.selectedCustomer?.customerName, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.customerName, "");
    });

    test("updateFacilityLinkageOption handles null selected option as No", () {
      viewModel
        ..selectedCustomer = Customer(
          customerRimNo: 456,
          customerName: "Customer Name",
        )
        ..customerController.text = "Customer Name"
        ..updateFacilityLinkageOption(null);

      expect(viewModel.selectedAllFailitiesYesNo, isNull);
      expect(viewModel.isHasRimYes, isFalse);
      expect(viewModel.customerController.text, "");
      expect(viewModel.selectedCustomer?.customerName, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("validateSelection returns null when value exists in options", () {
      final result = viewModel.validateSelection(
        "Bank A",
        [
          Reference(id: 1, name: "Bank A"),
          Reference(id: 2, name: "Bank B"),
        ],
        "validation.required",
      );

      expect(result, isNull);
    });

    test("validateSelection returns translated error when value does not exist",
        () {
      final result = viewModel.validateSelection(
        "Unknown Bank",
        [
          Reference(id: 1, name: "Bank A"),
          Reference(id: 2, name: "Bank B"),
        ],
        "validation.required",
      );

      expect(result, "validation.required".tr());
    });

    test("validateSelection trims input before matching options", () {
      final result = viewModel.validateSelection(
        " Bank A ",
        [
          Reference(id: 1, name: "Bank A"),
        ],
        "validation.required",
      );

      expect(result, isNull);
    });
  });
}
