import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/securities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/securities_summary/state.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";
import "package:wcas_frontend/repositories/facility_security_repository.dart";
import "../../../../test_config.dart";

class MockFacilitySecurityRepository extends Mock
    implements FacilitySecurityRepository {}

class MockAlertManager extends Mock implements AlertManager {}

void main() {
  late SecuritiesSummaryViewModel viewModel;
  late MockFacilitySecurityRepository mockRepository;
  late MockAlertManager mockAlertManager;
  const connectivityChannel =
      MethodChannel("dev.fluttercommunity.plus/connectivity");

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
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
    mockRepository = MockFacilitySecurityRepository();
    mockAlertManager = MockAlertManager();
    viewModel = SecuritiesSummaryViewModel()..repository = mockRepository;
    AlertManager.overrideInstance(mockAlertManager);

    registerFallbackValue(<int?>[]);
  });

  group("SecuritiesSummaryViewModel Tests", () {
    test("constructor should initialize with loading state", () {
      final vm = SecuritiesSummaryViewModel();
      expect(vm.state.loaderStatus, LoadingStatus.loading);
      expect(vm.securities, isEmpty);
      expect(vm.filteredData, isEmpty);
    });

    test("init should fetch securities successfully", () async {
      final mockSecurities = [
        Security(
          securityId: 1,
          securityNumber: "SEC001",
          securityCode: "TYPE1",
        ),
        Security(
          securityId: 2,
          securityNumber: "SEC002",
          securityCode: "TYPE2",
        ),
      ];

      when(() => mockRepository.getSecuritySummaryList())
          .thenAnswer((_) async => mockSecurities);

      await viewModel.init();

      expect(viewModel.securities.length, 2);
      expect(viewModel.filteredData.length, 2);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getSecurities should fetch securities and emit loaded state",
        () async {
      final mockSecurities = [
        Security(
          securityId: 1,
          securityNumber: "SEC001",
          securityCode: "TYPE1",
        ),
        Security(
          securityId: 2,
          securityNumber: "SEC002",
          securityCode: "TYPE2",
        ),
      ];

      when(() => mockRepository.getSecuritySummaryList())
          .thenAnswer((_) async => mockSecurities);

      final states = <SecuritiesSummaryState>[];
      final subscription = viewModel.stream.listen(states.add);

      await viewModel.getSecurities();

      expect(viewModel.securities.length, 2);
      expect(viewModel.filteredData.length, 2);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      await subscription.cancel();
    });

    test("getSecurities should handle errors and emit error state", () async {
      when(() => mockRepository.getSecuritySummaryList())
          .thenThrow(Exception("Failed to fetch securities"));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      final states = <SecuritiesSummaryState>[];
      final subscription = viewModel.stream.listen(states.add);

      await viewModel.getSecurities();

      expect(states.last.loaderStatus, LoadingStatus.error);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);

      await subscription.cancel();
    });

    test("filterBySecurityNumber should filter securities by number", () async {
      viewModel.securities = [
        Security(
          securityId: 1,
          securityNumber: "SEC001",
          securityCode: "TYPE1",
        ),
        Security(
          securityId: 2,
          securityNumber: "SEC002",
          securityCode: "TYPE2",
        ),
        Security(
          securityId: 3,
          securityNumber: "SEC001",
          securityCode: "TYPE3",
        ),
      ];

      final states = <SecuritiesSummaryState>[];
      final subscription = viewModel.stream.listen(states.add);

      viewModel.filterBySecurityNumber("SEC001");

      await Future.delayed(const Duration(milliseconds: 10));

      expect(viewModel.securities.length, 2);
      expect(
        viewModel.securities.every((s) => s.securityNumber == "SEC001"),
        true,
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      await subscription.cancel();
    });

    test("filterBySecurityType should filter securities by type", () async {
      viewModel.securities = [
        Security(
          securityId: 1,
          securityNumber: "SEC001",
          securityCode: "TYPE1",
        ),
        Security(
          securityId: 2,
          securityNumber: "SEC002",
          securityCode: "TYPE2",
        ),
        Security(
          securityId: 3,
          securityNumber: "SEC003",
          securityCode: "TYPE1",
        ),
      ];

      final states = <SecuritiesSummaryState>[];
      final subscription = viewModel.stream.listen(states.add);

      viewModel.filterBySecurityType("TYPE1");

      await Future.delayed(const Duration(milliseconds: 10));

      expect(viewModel.securities.length, 2);
      expect(
        viewModel.securities.every((s) => s.securityCode == "TYPE1"),
        true,
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      await subscription.cancel();
    });

    test("deleteSecurityDetails should delete securities successfully",
        () async {
      final mockSecurities = [
        Security(
          securityId: 1,
          securityNumber: "SEC001",
          securityCode: "TYPE1",
        ),
      ];

      when(() => mockRepository.deleteSecurityDetails(1))
          .thenAnswer((_) async => Future.value());
      when(() => mockRepository.getSecuritySummaryList())
          .thenAnswer((_) async => mockSecurities);

      await viewModel.deleteSecurityDetails(1);

      expect(viewModel.state.deleteButtonStatus, LoadingStatus.loaded);
      verify(() => mockRepository.deleteSecurityDetails(1)).called(1);
    });

    test("deleteSecurityDetails should handle errors", () async {
      when(() => mockRepository.deleteSecurityDetails(1))
          .thenThrow(Exception("Failed to delete"));
      when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);

      await viewModel.deleteSecurityDetails(1);

      expect(viewModel.state.deleteButtonStatus, LoadingStatus.loaded);
      verify(() => mockAlertManager.showFailureToast(any())).called(1);
    });

    test("onFilter with securityNumber should filter correctly", () async {
      viewModel
        ..securities = [
          Security(
            securityId: 1,
            securityNumber: "SEC001",
            securityCode: "TYPE1",
          ),
          Security(
            securityId: 2,
            securityNumber: "SEC002",
            securityCode: "TYPE2",
          ),
          Security(
            securityId: 3,
            securityNumber: "SEC003",
            securityCode: "TYPE1",
          ),
        ]
        ..onFilter(Filter.securityNumber, value: "sec001");

      await Future.delayed(const Duration(milliseconds: 10));

      expect(viewModel.filteredData.length, 1);
      expect(viewModel.filteredData.first.securityNumber, "SEC001");
      expect(viewModel.securityNumber, "sec001");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onFilter with securityType should filter correctly", () async {
      viewModel
        ..securities = [
          Security(
            securityId: 1,
            securityNumber: "SEC001",
            securityCode: "TYPE1",
          ),
          Security(
            securityId: 2,
            securityNumber: "SEC002",
            securityCode: "TYPE2",
          ),
          Security(
            securityId: 3,
            securityNumber: "SEC003",
            securityCode: "TYPE1",
          ),
        ]
        ..onFilter(Filter.securityType, value: "type1");

      await Future.delayed(const Duration(milliseconds: 10));

      expect(viewModel.filteredData.length, 2);
      expect(
        viewModel.filteredData.every((s) => s.securityCode == "TYPE1"),
        true,
      );
      expect(viewModel.securityType, "type1");
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onFilter should handle empty filter value", () async {
      viewModel
        ..securities = [
          Security(
            securityId: 1,
            securityNumber: "SEC001",
            securityCode: "TYPE1",
          ),
          Security(
            securityId: 2,
            securityNumber: "SEC002",
            securityCode: "TYPE2",
          ),
        ]
        ..onFilter(Filter.securityNumber, value: "");

      expect(viewModel.filteredData.length, 2);
      expect(viewModel.securityNumber, "");
    });

    test("onFilter should handle partial matches", () async {
      viewModel
        ..securities = [
          Security(
            securityId: 1,
            securityNumber: "SEC001",
            securityCode: "MORTGAGE",
          ),
          Security(
            securityId: 2,
            securityNumber: "SEC002",
            securityCode: "PROPERTY",
          ),
          Security(
            securityId: 3,
            securityNumber: "SEC003",
            securityCode: "MORTGAGE_TYPE2",
          ),
        ]
        ..onFilter(Filter.securityType, value: "mort");

      expect(viewModel.filteredData.length, 2);
      expect(
        viewModel.filteredData.every(
          (s) => s.securityCode?.toUpperCase().contains("MORT") ?? false,
        ),
        true,
      );
    });
  });
}
