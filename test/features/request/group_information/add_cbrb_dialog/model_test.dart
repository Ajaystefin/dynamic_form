import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/group_information_repository.dart";

import "../../../../test_config.dart";

class MockGroupInformationRepository extends Mock
    implements GroupInformationRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class TestableAddCbrbDialogViewModel extends AddCbrbDialogViewModel {
  TestableAddCbrbDialogViewModel({
    this.stubGetApplicationDetails,
    this.stubGetReferenceDatas,
  });

  final Future<void> Function()? stubGetApplicationDetails;
  final Future<void> Function()? stubGetReferenceDatas;

  final List<AddCbrbDialogState> emittedStates = [];

  bool getApplicationDetailsCalled = false;
  bool getReferenceDatasCalled = false;

  @override
  void emit(AddCbrbDialogState state) {
    super.emit(state);
    emittedStates.add(state);
  }

  @override
  Future<void> getApplicationDetails() async {
    getApplicationDetailsCalled = true;
    if (stubGetApplicationDetails != null) {
      await stubGetApplicationDetails!.call();
      return;
    }
    return super.getApplicationDetails();
  }

  @override
  Future<void> getReferenceDatas() async {
    getReferenceDatasCalled = true;
    if (stubGetReferenceDatas != null) {
      await stubGetReferenceDatas!.call();
      return;
    }
    return super.getReferenceDatas();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestableAddCbrbDialogViewModel viewModel;
  late MockGroupInformationRepository mockRepository;
  late MockCustomerRepository mockCustomerRepository;
  late MockAlertManager mockAlertManager;

  const MethodChannel connectivityChannel = MethodChannel(
    "dev.fluttercommunity.plus/connectivity",
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    await EnvConfig.setEnvironment();
    await TestConfig.setupTestEnvironment();

    registerFallbackValue(<Map<String, dynamic>>[]);
    registerFallbackValue(Customer());
    registerFallbackValue(CBRB());
    registerFallbackValue(ApplicationDetails());
  });

  setUp(() {
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

    mockRepository = MockGroupInformationRepository();
    mockCustomerRepository = MockCustomerRepository();
    mockAlertManager = MockAlertManager();

    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showWarningToast(any())).thenReturn(null);
    when(() => mockAlertManager.showInfoToast(any())).thenReturn(null);

    AlertManager.overrideInstance = mockAlertManager;

    viewModel = TestableAddCbrbDialogViewModel(
      stubGetReferenceDatas: () async {},
      stubGetApplicationDetails: () async {},
    )
      ..repository = mockRepository
      ..customerRepository = mockCustomerRepository;
  });

  tearDown(() async {
    if (!viewModel.isClosed) {
      await viewModel.close();
    }
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async => null,
    );
  });

  group("constructor and initial state", () {
    test("sets expected default values", () {
      final vm = AddCbrbDialogViewModel();

      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.formKey, isA<GlobalKey<FormState>>());
      expect(vm.applicationDetails, isNull);
      expect(vm.cbrbCollection, isA<List<CBRB>>());
      expect(vm.cbrbCollection, isEmpty);
      expect(vm.currentCbrbItems, isA<CBRB>());
      expect(vm.selectedCustomer, isA<Customer>());
      expect(vm.selectedCustomer?.customerName, "");
      expect(vm.customers, isEmpty);
      expect(vm.yesNoNaOptions, isEmpty);
      expect(vm.selectedAllFailitiesYesNo, isNull);
      expect(vm.isHasRimYes, true);
      expect(vm.customerController, isA<TextEditingController>());
      expect(vm.isFiFlow, false);
      expect(vm.isAddNew, true);
      expect(vm.initialCbrbs, isNull);
    });
  });

  group("init", () {
    test("without initialCbrb calls loaders and emits loaded", () async {
      final vm = TestableAddCbrbDialogViewModel(
        stubGetReferenceDatas: () async {},
        stubGetApplicationDetails: () async {},
      )
        ..repository = mockRepository
        ..customerRepository = mockCustomerRepository;

      await vm.init(MockBuildContext());

      expect(vm.getReferenceDatasCalled, true);
      expect(vm.getApplicationDetailsCalled, true);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.initialCbrbs, isNull);
      expect(vm.currentCbrbItems, isA<CBRB>());
      expect(vm.selectedCustomer, isA<Customer>());
      expect(vm.isFiFlow, isA<bool>());

      await vm.close();
    });

    test("with initialCbrb and valid rim sets edit mode values", () async {
      final vm = TestableAddCbrbDialogViewModel(
        stubGetReferenceDatas: () async {},
        stubGetApplicationDetails: () async {},
      )
        ..repository = mockRepository
        ..customerRepository = mockCustomerRepository;

      final initial = CBRB()
        ..rimNo = 555
        ..customerName = "Initial Customer";

      await vm.init(
        MockBuildContext(),
        initialCbrb: initial,
      );

      expect(vm.isAddNew, false);
      expect(vm.initialCbrbs, same(initial));
      expect(vm.currentCbrbItems, same(initial));
      expect(vm.selectedCustomer?.customerRimNo, 555);
      expect(vm.selectedCustomer?.customerName, "Initial Customer");
      expect(vm.customerController.text, "Initial Customer");
      expect(vm.isHasRimYes, true);
      expect(
        vm.state.customerName,
        initial.customerName ?? vm.selectedCustomer?.displayName,
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close();
    });

    test("with initialCbrb and invalid rim sets no-rim state", () async {
      final vm = TestableAddCbrbDialogViewModel(
        stubGetReferenceDatas: () async {},
        stubGetApplicationDetails: () async {},
      )
        ..repository = mockRepository
        ..customerRepository = mockCustomerRepository;

      final initial = CBRB()
        ..rimNo = 0
        ..customerName = "No Rim Customer";

      await vm.init(
        MockBuildContext(),
        initialCbrb: initial,
      );

      expect(vm.isAddNew, false);
      expect(vm.initialCbrbs, same(initial));
      expect(vm.currentCbrbItems, same(initial));
      expect(vm.selectedCustomer?.customerRimNo, isNull);
      expect(vm.selectedCustomer?.customerName, "No Rim Customer");
      expect(vm.customerController.text, "No Rim Customer");
      expect(vm.isHasRimYes, false);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close();
    });
  });

  group("getApplicationDetails", () {
    test("stub success populates customers and emits loaded", () async {
      late TestableAddCbrbDialogViewModel vm;

      final borrower = Customer(
        customerRimNo: 1,
        customerName: "Borrower",
      );
      final nonBorrower = Customer(
        customerRimNo: 2,
        customerName: "Non Borrower",
      );

      vm = TestableAddCbrbDialogViewModel(
        stubGetApplicationDetails: () async {
          vm
            ..applicationDetails = ApplicationDetails()
            ..customers = [borrower, nonBorrower]
            ..emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
        },
      )
        ..repository = mockRepository
        ..customerRepository = mockCustomerRepository;

      await vm.getApplicationDetails();

      expect(vm.applicationDetails, isNotNull);
      expect(vm.customers.length, 2);
      expect(vm.customers.first.customerName, "Borrower");
      expect(vm.customers.last.customerName, "Non Borrower");
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close();
    });

    test("stub failure shows toast and emits loaded", () async {
      late TestableAddCbrbDialogViewModel vm;

      vm = TestableAddCbrbDialogViewModel(
        stubGetApplicationDetails: () async {
          mockAlertManager.showFailureToast("common.noAppRef".tr());
          vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
        },
      )
        ..repository = mockRepository
        ..customerRepository = mockCustomerRepository;

      await vm.getApplicationDetails();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close();
    });
  });

  group("getReferenceDatas", () {
    test("stub success sets yesNoNaOptions", () async {
      late TestableAddCbrbDialogViewModel vm;

      final yes = Reference(
        id: ServerConstants.optionYESid,
        name: "requestInformation.requestInformation.yes".tr(),
      );
      final no = Reference(
        id: ServerConstants.optionNOid,
        name: "requestInformation.requestInformation.no".tr(),
      );

      vm = TestableAddCbrbDialogViewModel(
        stubGetReferenceDatas: () async {
          vm
            ..yesNoNaOptions = [yes, no]
            ..emit(vm.state.copyWith(loaderStatus: LoadingStatus.loaded));
        },
      )
        ..repository = mockRepository
        ..customerRepository = mockCustomerRepository;

      await vm.getReferenceDatas();

      expect(vm.yesNoNaOptions.length, 2);
      expect(vm.yesNoNaOptions.first.id, ServerConstants.optionYESid);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);

      await vm.close();
    });

    test("stub failure emits error", () async {
      late TestableAddCbrbDialogViewModel vm;

      vm = TestableAddCbrbDialogViewModel(
        stubGetReferenceDatas: () async {
          vm.emit(vm.state.copyWith(loaderStatus: LoadingStatus.error));
        },
      )
        ..repository = mockRepository
        ..customerRepository = mockCustomerRepository;

      await vm.getReferenceDatas();

      expect(vm.state.loaderStatus, LoadingStatus.error);

      await vm.close();
    });
  });

  group("customerRIMReferenceSelected", () {
    test("updates selected customer and customerName state", () {
      final customer = Customer(
        customerRimNo: 101,
        customerName: "Test Customer",
      );

      viewModel.customerRIMReferenceSelected(customer);

      expect(viewModel.selectedCustomer, customer);
      expect(
        viewModel.state.customerName,
        viewModel.selectedCustomer?.concatCustomerFullName ??
            viewModel.selectedCustomer?.displayRIMName ??
            "",
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("handles empty customer safely", () {
      final customer = Customer();

      viewModel.customerRIMReferenceSelected(customer);

      expect(viewModel.selectedCustomer, customer);
      expect(viewModel.state.customerName, customer.concatCustomerFullName);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("uses concatCustomerFullName path when names exist", () {
      final customer = Customer(
        firstName: "First",
        middleName: "Middle",
        lastName: "Last",
        customerName: "Fallback",
      );

      viewModel.customerRIMReferenceSelected(customer);

      expect(viewModel.selectedCustomer, customer);
      expect(viewModel.state.customerName, customer.concatCustomerFullName);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("onCancelButtonPressedCBRB", () {
    test("calls context pop path and throws without GoRouter", () async {
      final mockContext = MockBuildContext();

      expect(
        () async => viewModel.onCancelButtonPressedCBRB(mockContext),
        throwsA(anything),
      );
    });
  });

  group("onSaveButtonPressedCBRB", () {
    testWidgets("invalid form skips save and emits loaded", (tester) async {
      final contextHolder = <BuildContext>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              contextHolder.add(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await viewModel.onSaveButtonPressedCBRB(contextHolder.first);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      verifyNever(() => mockRepository.saveCBRBData(any()));
    });

    testWidgets("valid form new item saves data and handles router pop safely",
        (tester) async {
      final contextHolder = <BuildContext>[];

      when(() => mockRepository.saveCBRBData(any()))
          .thenAnswer((_) async => "saved");

      viewModel
        ..selectedCustomer = Customer(
          customerRimNo: 123,
          customerName: "New Customer",
          firstName: "New",
          lastName: "Customer",
        )
        ..currentCbrbItems = CBRB()
        ..cbrbCollection = null
        ..initialCbrbs = null;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              contextHolder.add(context);
              return Scaffold(
                body: Form(
                  key: viewModel.formKey,
                  child: const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      );

      await viewModel.onSaveButtonPressedCBRB(contextHolder.first);

      verify(() => mockRepository.saveCBRBData(any())).called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);

      expect(viewModel.cbrbCollection, isNotNull);
      expect(viewModel.cbrbCollection!.length, 1);
      expect(viewModel.cbrbCollection!.first.rimNo, 123);
      expect(viewModel.cbrbCollection!.first.news, true);
      expect(viewModel.cbrbCollection!.first.deleted, false);
    });

    testWidgets("valid form existing item uses customerName branch",
        (tester) async {
      final contextHolder = <BuildContext>[];

      when(() => mockRepository.saveCBRBData(any()))
          .thenAnswer((_) async => "updated");

      viewModel
        ..initialCbrbs = CBRB()
        ..selectedCustomer = Customer(
          customerRimNo: 777,
          customerName: "Existing Customer",
          firstName: "Existing",
          lastName: "Customer",
        )
        ..currentCbrbItems = CBRB()
        ..cbrbCollection = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              contextHolder.add(context);
              return Scaffold(
                body: Form(
                  key: viewModel.formKey,
                  child: const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      );

      await viewModel.onSaveButtonPressedCBRB(contextHolder.first);

      verify(() => mockRepository.saveCBRBData(any())).called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);

      expect(viewModel.cbrbCollection!.length, 1);
      expect(viewModel.cbrbCollection!.first.rimNo, 777);
      expect(viewModel.cbrbCollection!.first.customerName, "Existing Customer");
      expect(viewModel.cbrbCollection!.first.news, true);
      expect(viewModel.cbrbCollection!.first.deleted, false);
    });

    testWidgets("valid form existing item uses displayRIMName fallback",
        (tester) async {
      final contextHolder = <BuildContext>[];

      when(() => mockRepository.saveCBRBData(any()))
          .thenAnswer((_) async => "updated");

      viewModel
        ..initialCbrbs = CBRB()
        ..selectedCustomer = Customer(
          customerRimNo: 888,
          firstName: "Display",
          lastName: "Fallback",
        )
        ..currentCbrbItems = CBRB()
        ..cbrbCollection = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              contextHolder.add(context);
              return Scaffold(
                body: Form(
                  key: viewModel.formKey,
                  child: const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      );

      await viewModel.onSaveButtonPressedCBRB(contextHolder.first);

      verify(() => mockRepository.saveCBRBData(any())).called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);

      expect(viewModel.cbrbCollection!.length, 1);
      expect(viewModel.cbrbCollection!.first.rimNo, 888);
      expect(viewModel.cbrbCollection!.first.news, true);
      expect(viewModel.cbrbCollection!.first.deleted, false);
    });

    testWidgets("repository failure emits error", (tester) async {
      final contextHolder = <BuildContext>[];

      when(() => mockRepository.saveCBRBData(any()))
          .thenThrow(Exception("save failed"));

      viewModel
        ..selectedCustomer = Customer(
          customerRimNo: 999,
          customerName: "Fail Customer",
        )
        ..currentCbrbItems = CBRB()
        ..cbrbCollection = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              contextHolder.add(context);
              return Scaffold(
                body: Form(
                  key: viewModel.formKey,
                  child: const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      );

      await viewModel.onSaveButtonPressedCBRB(contextHolder.first);

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
      verify(() => mockRepository.saveCBRBData(any())).called(1);
    });
  });

  group("getFilteredOptions", () {
    test("removes NA option", () {
      final naText = "requestInformation.requestInformation.na".tr();

      final options = [
        Reference(id: 1, name: "Yes"),
        Reference(id: 2, name: "No"),
        Reference(id: 3, name: naText),
      ];

      final filtered = viewModel.getFilteredOptions(options);

      expect(filtered.length, 2);
      expect(filtered.any((ref) => ref.name == naText), false);
    });

    test("returns empty list when only NA exists", () {
      final naText = "requestInformation.requestInformation.na".tr();

      final filtered = viewModel.getFilteredOptions([
        Reference(id: 3, name: naText),
      ]);

      expect(filtered, isEmpty);
    });
  });

  group("getSelectedReference", () {
    test("returns selected reference by id", () {
      final yes = Reference(id: 1, name: "Yes");
      final no = Reference(id: 2, name: "No");

      final selected = viewModel.getSelectedReference(
        options: [yes, no],
        selectedValue: Reference(id: 2, name: "Different Name"),
        fallbackFlag: true,
      );

      expect(selected.id, 2);
      expect(selected.name, "No");
    });

    test("returns selected reference by normalized name", () {
      final yes = Reference(id: 1, name: "Yes");
      final no = Reference(id: 2, name: "No");

      final selected = viewModel.getSelectedReference(
        options: [yes, no],
        selectedValue: Reference(name: " no "),
        fallbackFlag: true,
      );

      expect(selected.id, 2);
      expect(selected.name, "No");
    });

    test("returns fallback yes when selected is null and fallbackFlag true",
        () {
      final yesName = "requestInformation.requestInformation.yes".tr();
      final noName = "requestInformation.requestInformation.no".tr();

      final yes = Reference(id: 1, name: yesName);
      final no = Reference(id: 2, name: noName);

      final selected = viewModel.getSelectedReference(
        options: [yes, no],
        selectedValue: null,
        fallbackFlag: true,
      );

      expect(selected.name, yesName);
    });

    test("returns fallback no when selected is null and fallbackFlag false",
        () {
      final yesName = "requestInformation.requestInformation.yes".tr();
      final noName = "requestInformation.requestInformation.no".tr();

      final yes = Reference(id: 1, name: yesName);
      final no = Reference(id: 2, name: noName);

      final selected = viewModel.getSelectedReference(
        options: [yes, no],
        selectedValue: null,
        fallbackFlag: false,
      );

      expect(selected.name, noName);
    });

    test("returns fallback no when filtered options are empty", () {
      final naText = "requestInformation.requestInformation.na".tr();
      final noName = "requestInformation.requestInformation.no".tr();

      final selected = viewModel.getSelectedReference(
        options: [Reference(id: 3, name: naText)],
        selectedValue: null,
        fallbackFlag: true,
      );

      expect(selected.name, noName);
    });

    test("returns first option when fallback name is not found", () {
      final first = Reference(id: 10, name: "A");
      final second = Reference(id: 20, name: "B");

      final selected = viewModel.getSelectedReference(
        options: [first, second],
        selectedValue: null,
        fallbackFlag: true,
      );

      expect(selected.id, 10);
      expect(selected.name, "A");
    });
  });

  group("validateSelection", () {
    test("returns null when value exists in options", () {
      final result = viewModel.validateSelection(
        "Yes",
        [
          Reference(id: 1, name: "Yes"),
          Reference(id: 2, name: "No"),
        ],
        "error.required",
      );

      expect(result, isNull);
    });

    test("trims input value before validating", () {
      final result = viewModel.validateSelection(
        " Yes ",
        [
          Reference(id: 1, name: "Yes"),
          Reference(id: 2, name: "No"),
        ],
        "error.required",
      );

      expect(result, isNull);
    });

    test("returns translated error when value is invalid", () {
      final result = viewModel.validateSelection(
        "Invalid",
        [
          Reference(id: 1, name: "Yes"),
          Reference(id: 2, name: "No"),
        ],
        "error.required",
      );

      expect(result, "error.required".tr());
    });

    test("returns translated error when value is null", () {
      final result = viewModel.validateSelection(
        null,
        [
          Reference(id: 1, name: "Yes"),
          Reference(id: 2, name: "No"),
        ],
        "error.required",
      );

      expect(result, "error.required".tr());
    });
  });

  group("updateFacilityLinkageOption", () {
    test("yes option using optionYESid sets has rim yes", () {
      final selected = Reference(
        id: ServerConstants.optionYESid,
        name: "Yes",
      );

      viewModel.updateFacilityLinkageOption(selected);

      expect(viewModel.selectedAllFailitiesYesNo, selected);
      expect(viewModel.isHasRimYes, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("yes option using yesRefId sets has rim yes", () {
      final selected = Reference(
        id: ServerConstants.yesRefId,
        name: "Yes",
      );

      viewModel.updateFacilityLinkageOption(selected);

      expect(viewModel.selectedAllFailitiesYesNo, selected);
      expect(viewModel.isHasRimYes, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("no option clears customer and controller", () {
      viewModel
        ..selectedCustomer = Customer(
          customerRimNo: 100,
          customerName: "Existing",
          firstName: "Existing",
          lastName: "Customer",
        )
        ..customerController.text = "Existing";

      final selected = Reference(
        id: ServerConstants.optionNOid,
        name: "No",
      );

      viewModel.updateFacilityLinkageOption(selected);

      expect(viewModel.selectedAllFailitiesYesNo, selected);
      expect(viewModel.isHasRimYes, false);
      expect(viewModel.selectedCustomer?.customerName, "");
      expect(viewModel.selectedCustomer?.firstName, "");
      expect(viewModel.selectedCustomer?.middleName, "");
      expect(viewModel.selectedCustomer?.lastName, "");
      expect(viewModel.customerController.text, "");
      expect(viewModel.state.customerName, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("null option behaves as no and clears customer", () {
      viewModel
        ..selectedCustomer = Customer(
          customerRimNo: 101,
          customerName: "Customer",
        )
        ..customerController.text = "Customer"
        ..updateFacilityLinkageOption(null);

      expect(viewModel.selectedAllFailitiesYesNo, isNull);
      expect(viewModel.isHasRimYes, false);
      expect(viewModel.selectedCustomer?.customerName, "");
      expect(viewModel.customerController.text, "");
      expect(viewModel.state.customerName, "");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("direct CBRB data logic", () {
    test("CBRB properties are set correctly before save", () {
      viewModel
        ..selectedCustomer = Customer(
          customerRimNo: 123,
          customerName: "Test",
        )
        ..currentCbrbItems = CBRB()
        ..cbrbCollection = [];

      final updatedData = viewModel.currentCbrbItems
        ..rimNo = viewModel.selectedCustomer?.customerRimNo
        ..customerName = viewModel.selectedCustomer?.customerName
        ..news = true
        ..deleted = false;

      expect(updatedData.rimNo, 123);
      expect(updatedData.customerName, "Test");
      expect(updatedData.news, true);
      expect(updatedData.deleted, false);
    });

    test("json conversion works for populated cbrbCollection", () {
      viewModel
        ..selectedCustomer = Customer(
          customerRimNo: 321,
          customerName: "Json Customer",
        )
        ..currentCbrbItems = CBRB()
        ..cbrbCollection = [];

      final updatedData = viewModel.currentCbrbItems
        ..rimNo = viewModel.selectedCustomer?.customerRimNo
        ..customerName = viewModel.selectedCustomer?.customerName
        ..news = true
        ..deleted = false;

      viewModel.cbrbCollection!.add(updatedData);

      final jsonData =
          viewModel.cbrbCollection!.map((e) => e.toJson()).toList();

      expect(jsonData, isA<List<Map<String, dynamic>>>());
      expect(jsonData.length, 1);
      expect(updatedData.news, true);
      expect(updatedData.deleted, false);
    });

    test("cbrbCollection can be initialized when null", () {
      viewModel.cbrbCollection = null;

      (viewModel.cbrbCollection ??= []).add(CBRB());

      expect(viewModel.cbrbCollection, isNotNull);
      expect(viewModel.cbrbCollection!.length, 1);
    });
  });

  group("AddCbrbDialogState", () {
    test("constructor sets loaderStatus", () {
      final state = AddCbrbDialogState(
        loaderStatus: LoadingStatus.loading,
      );

      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test("copyWith keeps existing values when null", () {
      final original = AddCbrbDialogState(
        loaderStatus: LoadingStatus.loaded,
        customerName: "Customer",
      );

      final copied = original.copyWith();

      expect(copied.loaderStatus, LoadingStatus.loaded);
      expect(copied.customerName, "Customer");
    });

    test("copyWith overrides loaderStatus", () {
      final original = AddCbrbDialogState(
        loaderStatus: LoadingStatus.loaded,
      );

      final updated = original.copyWith(
        loaderStatus: LoadingStatus.error,
      );

      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test("copyWith overrides customerName", () {
      final original = AddCbrbDialogState(
        loaderStatus: LoadingStatus.loaded,
        customerName: "Old",
      );

      final updated = original.copyWith(
        customerName: "New",
      );

      expect(updated.customerName, "New");
      expect(original.customerName, "Old");
    });
  });
}
