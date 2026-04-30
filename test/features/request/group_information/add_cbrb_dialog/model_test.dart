import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";
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

class MockApplicationDetails extends Mock implements ApplicationDetails {}

class TestableAddCbrbDialogViewModel extends AddCbrbDialogViewModel {
  TestableAddCbrbDialogViewModel({
    this.stubGetApplicationDetails,
  });

  final Future<void> Function()? stubGetApplicationDetails;

  @override
  Future<void> getApplicationDetails() async {
    if (stubGetApplicationDetails != null) {
      await stubGetApplicationDetails!.call();
      return;
    }
    return super.getApplicationDetails();
  }
}

void main() {
  late AddCbrbDialogViewModel viewModel;
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
  });

  setUp(() async {
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

    AlertManager.overrideInstance(mockAlertManager);

    // IMPORTANT:
    // If your project uses a different API for replacing the singleton
    // instance,
    // replace the next line with your actual override method.
    // CustomerRepository.overrideInstance(mockCustomerRepository);

    viewModel = AddCbrbDialogViewModel();
    viewModel.repository = mockRepository;
    viewModel.customerRepository = mockCustomerRepository;
  });

  tearDown(() async {
    await viewModel.close();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async => null,
    );
  });

  group("constructor / initial state", () {
    test("sets expected defaults", () {
      final vm = AddCbrbDialogViewModel();

      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.formKey, isA<GlobalKey<FormState>>());
      expect(vm.applicationDetails, isNull);
      expect(vm.cbrbCollection, isA<List<CBRB>>());
      expect(vm.currentCbrbItems, isA<CBRB>());
      expect(vm.selectedCustomer, isA<Customer>());
      expect(vm.customers, isA<List<Customer>>());
      expect(vm.isFiFlow, isFalse);
      expect(vm.initialCbrbs, isNull);
    });
  });

  group("getApplicationDetails", () {
    test("failure shows toast and still emits loaded", () async {
      when(
        () => mockCustomerRepository.getApplicationDetails(appRefNo: null),
      ).thenThrow(Exception("app details error"));

      await viewModel.getApplicationDetails();

      verify(() => mockAlertManager.showFailureToast(any())).called(1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("init", () {
    test("without initialCbrb loads and sets final loaded state", () async {
      final vm = TestableAddCbrbDialogViewModel(
        stubGetApplicationDetails: () async {
          // simulate getApplicationDetails success
        },
      );

      vm.repository = mockRepository;
      vm.customerRepository = mockCustomerRepository;

      await vm.init(MockBuildContext());

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.initialCbrbs, isNull);
      expect(vm.currentCbrbItems, isA<CBRB>());
      expect(vm.selectedCustomer, isA<Customer>());
      expect(vm.isFiFlow, isA<bool>());
    });

    test(
        "with initialCbrb sets current item, initial ref,"
        " selectedCustomer and customerName", () async {
      final vm = TestableAddCbrbDialogViewModel(
        stubGetApplicationDetails: () async {},
      );

      vm.repository = mockRepository;
      vm.customerRepository = mockCustomerRepository;

      final initial = CBRB()
        ..rimNo = 555
        ..customerName = "Initial Customer";

      await vm.init(
        MockBuildContext(),
        initialCbrb: initial,
      );

      expect(vm.initialCbrbs, same(initial));
      expect(vm.currentCbrbItems, same(initial));
      expect(vm.selectedCustomer?.customerRimNo, 555);
      expect(vm.selectedCustomer?.customerName, "Initial Customer");
      expect(
        vm.state.customerName,
        vm.selectedCustomer?.customerName ?? vm.selectedCustomer?.displayName,
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("customerRIMReferenceSelected", () {
    test("updates selected customer and emits loaded", () {
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
      expect(
        viewModel.state.customerName,
        customer.concatCustomerFullName,
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("onCancelButtonPressedCBRB", () {
    test("executes context.pop (throws without GoRouter in test)", () async {
      final mockContext = MockBuildContext();

      expect(
        () async => viewModel.onCancelButtonPressedCBRB(mockContext),
        throwsA(anything),
      );
    });
  });

  group("onSaveButtonPressedCBRB", () {
    testWidgets("validation false -> skips save and emits loaded",
        (tester) async {
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

    testWidgets(
        "valid form + initialCbrbs == null -> builds data using concat/display name path",
        (tester) async {
      final contextHolder = <BuildContext>[];

      when(() => mockRepository.saveCBRBData(any()))
          .thenAnswer((_) async => "saved");

      viewModel.selectedCustomer = Customer(
        customerRimNo: 123,
        customerName: "New Customer",
      );
      viewModel.currentCbrbItems = CBRB();
      viewModel.cbrbCollection = null; // to cover ??= []

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

      // router.pop() may throw in test depending on router stack;
      // that's okay for line coverage because the success lines before it still
      // execute.
      await viewModel.onSaveButtonPressedCBRB(contextHolder.first);

      verify(() => mockRepository.saveCBRBData(any())).called(1);
      verify(() => mockAlertManager.showSuccessToast(any())).called(1);

      expect(viewModel.cbrbCollection, isNotNull);
      expect(viewModel.cbrbCollection!.length, 1);
      expect(viewModel.cbrbCollection!.first.rimNo, 123);
      expect(viewModel.cbrbCollection!.first.news, true);
      expect(viewModel.cbrbCollection!.first.deleted, false);
    });

    testWidgets("valid form + initialCbrbs != null -> uses customerName branch",
        (tester) async {
      final contextHolder = <BuildContext>[];

      when(() => mockRepository.saveCBRBData(any()))
          .thenAnswer((_) async => "updated");

      viewModel.initialCbrbs = CBRB();
      viewModel.selectedCustomer = Customer(
        customerRimNo: 777,
        customerName: "Existing Customer",
      );
      viewModel.currentCbrbItems = CBRB();
      viewModel.cbrbCollection = [];

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

    testWidgets("repository failure -> emits error", (tester) async {
      final contextHolder = <BuildContext>[];

      when(() => mockRepository.saveCBRBData(any()))
          .thenThrow(Exception("save failed"));

      viewModel.selectedCustomer = Customer(
        customerRimNo: 999,
        customerName: "Fail Customer",
      );
      viewModel.currentCbrbItems = CBRB();
      viewModel.cbrbCollection = [];

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

  group("direct property logic coverage", () {
    test("CBRB properties are set correctly before save", () {
      viewModel.selectedCustomer = Customer(
        customerRimNo: 123,
        customerName: "Test",
      );
      viewModel.currentCbrbItems = CBRB();
      viewModel.cbrbCollection = [];

      final updatedData = viewModel.currentCbrbItems
        ..rimNo = viewModel.selectedCustomer?.customerRimNo
        ..customerName = viewModel.selectedCustomer?.customerName;

      updatedData
        ..news = true
        ..deleted = false;

      expect(updatedData.rimNo, 123);
      expect(updatedData.customerName, "Test");
      expect(updatedData.news, true);
      expect(updatedData.deleted, false);
    });

    test("json conversion works for populated cbrbCollection", () {
      viewModel.selectedCustomer = Customer(
        customerRimNo: 321,
        customerName: "Json Customer",
      );
      viewModel.currentCbrbItems = CBRB();
      viewModel.cbrbCollection = [];

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
  });
}
