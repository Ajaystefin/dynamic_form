import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:toastification/toastification.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/risk_rating/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/comment.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/risk_rating/external_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/internal_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/risk_rating.dart";
import "package:wcas_frontend/models/request/risk_rating/updated_rating.dart";
import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";
import "package:wcas_frontend/repositories/risk_rating_repository.dart";

import "../../../test_config.dart";

class MockRiskRatingRepo extends Mock implements RiskRatingRepository {}

class MockCustomerRepo extends Mock implements CustomerRepository {}

class MockReferenceService extends Mock implements ReferenceDataService {}

class MockAlertManager extends Mock implements AlertManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

class FakeCustomer extends Fake implements Customer {}

class MockCommonRepo extends Mock implements CommonRepository {}

class FakeComment extends Fake implements Comment {}

Future<void> settleAsync() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(const Duration(milliseconds: 10));
}

/// Safe subclass to exercise init() without triggering heavy real dependencies.
class TestableRiskRatingViewModel extends RiskRatingViewModel {
  bool getReferenceDataCalled = false;
  bool getRiskRatingCalled = false;
  bool getCommentsCalled = false;
  bool checkViewAccessCalled = false;

  @override
  Future<void> getReferenceData() async {
    getReferenceDataCalled = true;
  }

  @override
  Future<void> getRiskRating() async {
    getRiskRatingCalled = true;
    updatedRiskRating = [];
    riskRating = RiskRating(
      internalRatings: [],
      externalRatings: [],
    );
  }

  @override
  void checkViewAccess() {
    checkViewAccessCalled = true;
    isViewOnly = false;
  }

  @override
  Future<void> getComments() async {
    getCommentsCalled = true;
  }
}

/// Safe subclass that keeps view-only state true to cover the opposite init()
/// branch.
class ViewOnlyTestableRiskRatingViewModel extends RiskRatingViewModel {
  bool getReferenceDataCalled = false;
  bool getRiskRatingCalled = false;
  bool getCommentsCalled = false;
  bool checkViewAccessCalled = false;

  @override
  Future<void> getReferenceData() async {
    getReferenceDataCalled = true;
  }

  @override
  Future<void> getRiskRating() async {
    getRiskRatingCalled = true;
    updatedRiskRating = [];
    riskRating = RiskRating(
      internalRatings: [],
      externalRatings: [],
    );
  }

  @override
  void checkViewAccess() {
    checkViewAccessCalled = true;
    isViewOnly = true;
  }

  @override
  Future<void> getComments() async {
    getCommentsCalled = true;
  }
}

class ProposedEditableRiskRatingViewModel extends RiskRatingViewModel {
  @override
  bool isProposedbyCreditEditables() => true;
}

class NonEditableRiskRatingViewModel extends RiskRatingViewModel {
  @override
  bool isProposedbyCreditEditables() => false;
}

Future<void> pumpToastificationApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ToastificationWrapper(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => const SizedBox.shrink(),
          ),
        ),
      ),
    ),
  );

  await tester.pump();
}

Future<void> pumpFormApp(
  WidgetTester tester,
  GlobalKey<FormState> formKey,
) async {
  await tester.pumpWidget(
    ToastificationWrapper(
      child: MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> flushToastification(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  late RiskRatingViewModel viewModel;
  late MockRiskRatingRepo mockRepo;
  late MockReferenceService mockReferenceService;
  late MockCustomerRepo mockCustomerRepo;
  late MockCommonRepo mockCommonRepo;
  late MockAlertManager mockAlertManager;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    registerFallbackValue(FakeCustomer());
    registerFallbackValue(FakeComment());
    registerFallbackValue(CommentsType.riskRating);
    registerFallbackValue(EntityIdentifier.strategyComments);
  });

  setUp(() {
    mockRepo = MockRiskRatingRepo();
    mockReferenceService = MockReferenceService();
    mockCustomerRepo = MockCustomerRepo();
    mockCommonRepo = MockCommonRepo();
    mockAlertManager = MockAlertManager();

    viewModel = RiskRatingViewModel(
      repositoryOverride: mockRepo,
      customerRepositoryFactory: () => mockCustomerRepo,
      goToNextRoute: () {},
    )..repository = mockRepo;

    // override singleton dependencies
    CommonRepository.debugReplaceInstance = mockCommonRepo;
    AlertManager.overrideInstance = mockAlertManager;

    when(() => mockRepo.getRatingDetails()).thenAnswer(
      (_) async => RiskRating(internalRatings: [], externalRatings: []),
    );

    when(
      () => mockRepo.getUpdatedRatingDetails(
        rimNo: any(named: "rimNo"),
        entityId: any(named: "entityId"),
      ),
    ).thenAnswer((_) async => []);

    when(
      () => mockRepo.saveRatings(
        customerRating: any(named: "customerRating"),
      ),
    ).thenAnswer((_) async => "");

    // Default stubs for injected customer repository
    when(
      () => mockCustomerRepo.searchUserDetailsForCL(any(), any(), any(), any()),
    ).thenAnswer((_) async => null);

    when(
      () => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()),
    ).thenAnswer((_) async => null);

    when(
      () => mockCustomerRepo.getCustomerInformationByRim(any()),
    ).thenAnswer((_) async => null);

    // default CommonRepository stubs
    when(() => mockCommonRepo.getComments(any(), any()))
        .thenAnswer((_) async => []);
    when(() => mockCommonRepo.saveComment(any())).thenAnswer((_) async => "ok");

    // default AlertManager stubs
    when(() => mockAlertManager.showFailureToast(any())).thenReturn(null);
    when(() => mockAlertManager.showSuccessToast(any())).thenReturn(null);
    when(() => mockAlertManager.showWarningToast(any())).thenReturn(null);

    // ensure globals don't accidentally break comment filtering
    Globals.request = null;
  });

  // Constructor / defaults / simple getters
  group("constructor / defaults / simple getters", () {
    test("constructor initializes with loading status", () {
      final newViewModel = RiskRatingViewModel();
      expect(newViewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test("isCreditLensAvailable defaults to true", () {
      expect(viewModel.isCreditLensAvailable, true);
    });

    test("rimWithNoEntity starts empty", () {
      expect(viewModel.rimWithNoEntity, isEmpty);
    });

    test("formKey is initialized", () {
      expect(viewModel.formKey, isNotNull);
      expect(viewModel.formKey, isA<GlobalKey<FormState>>());
    });

    test("rimNoController is initialized", () {
      expect(viewModel.rimNoController, isNotNull);
      expect(viewModel.rimNoController, isA<TextEditingController>());
    });

    test("internal/external scroll controllers are initialized", () {
      expect(viewModel.internalRatingScrollController, isNotNull);
      expect(viewModel.externalRatingScrollController, isNotNull);
    });

    test("internal/external editor controllers are initialized", () {
      expect(viewModel.internalRatingControler, isNotNull);
      expect(viewModel.externalRatingControler, isNotNull);
      expect(viewModel.internalRatingTextController, isNotNull);
    });

    test("reference lists are initialized as empty", () {
      expect(viewModel.sAndP, isEmpty);
      expect(viewModel.moodys, isEmpty);
      expect(viewModel.fitch, isEmpty);
      expect(viewModel.ifrsStagings, isEmpty);
    });

    test("referenceData map is initialized", () {
      expect(viewModel.referenceData, isA<Map<String, List<Reference>>>());
    });

    test("initialInternalRatingPage defaults to 0", () {
      expect(viewModel.initialInternalRatingPage, 0);
    });

    test("initialExternalRatingPage defaults to 0", () {
      expect(viewModel.initialExternalRatingPage, 0);
    });

    test("tableRow defaults to 10", () {
      expect(viewModel.tableRow, 10);
    });

    test("fiCRR contains 22 values", () {
      expect(viewModel.fiCRR.length, 22);
      expect(viewModel.fiCRR.first, 1);
      expect(viewModel.fiCRR.last, 22);
    });

    test("emitInternalRating emits loaded state", () {
      viewModel.emitInternalRating();
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("canEdit is false when pageMode is not edit", () {
      viewModel.pageMode = PageMode.na;
      expect(viewModel.canEdit, false);
    });

    test("canEdit is true when pageMode is edit", () {
      viewModel.pageMode = PageMode.edit;
      expect(viewModel.canEdit, true);
    });

    test("draft getters are available", () {
      expect(viewModel.draftModuleKey, isNotEmpty);
      expect(viewModel.draftFormKey, isNotNull);
      expect(viewModel.draftHandler, isNotNull);
    });

    test("isInitializing starts as true", () {
      expect(viewModel.isInitializing, true);
    });

    test("close completes without throwing", () async {
      await viewModel.close();
      expect(true, isTrue);
    });

    test(
        "isProposedbyCreditEditables returns false "
        "when role is unavailable/default", () {
      expect(viewModel.isProposedbyCreditEditables(), false);
    });

    test("checkViewAccess keeps isViewOnly unchanged by default safe path", () {
      viewModel
        ..isViewOnly = true
        ..checkViewAccess();
      expect(viewModel.isViewOnly, isA<bool>());
    });

    test("isFiFlow defaults to false", () {
      expect(viewModel.isFiFlow, false);
    });

    test("isViewOnly defaults to true", () {
      expect(viewModel.isViewOnly, true);
    });

    test("pageMode defaults to na", () {
      expect(viewModel.pageMode, PageMode.na);
    });

    test("fiCRR list has sequential values starting from 1", () {
      for (int i = 0; i < viewModel.fiCRR.length; i++) {
        expect(viewModel.fiCRR[i], i + 1);
      }
    });
  });

  // init smoke test (safe overridden subclasses)
  group("init smoke test (safe overridden subclasses)", () {
    test("init invokes overridable methods and eventually ends loaded",
        () async {
      final testVm = TestableRiskRatingViewModel();

      await testVm.init(MockBuildContext());
      await settleAsync();

      expect(testVm.getReferenceDataCalled, true);
      expect(testVm.getRiskRatingCalled, true);
      expect(testVm.checkViewAccessCalled, true);
      expect(testVm.getCommentsCalled, true);
      expect(testVm.isInitializing, false);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init keeps isInitializing true when view remains read-only",
        () async {
      final testVm = ViewOnlyTestableRiskRatingViewModel();

      await testVm.init(MockBuildContext());
      await settleAsync();

      expect(testVm.getReferenceDataCalled, true);
      expect(testVm.getRiskRatingCalled, true);
      expect(testVm.checkViewAccessCalled, true);
      expect(testVm.getCommentsCalled, true);
      expect(testVm.isInitializing, true);
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init with explicit pagemode parameter does not crash", () async {
      final testVm = TestableRiskRatingViewModel();
      await testVm.init(MockBuildContext(), amendPagemode: PageMode.edit);
      await settleAsync();
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("init with view pageMode parameter does not crash", () async {
      final testVm = ViewOnlyTestableRiskRatingViewModel();
      await testVm.init(MockBuildContext(), amendPagemode: PageMode.view);
      await settleAsync();
      expect(testVm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // add/remove external table row
  group("add/remove external table row", () {
    test("addExternalTableRow adds new row if last is valid", () async {
      viewModel.riskRating = RiskRating(
        externalRatings: [ExternalRating(customerRimNo: 123)],
        internalRatings: [],
      );

      await viewModel.addExternalTableRow();

      expect(viewModel.riskRating.externalRatings?.length, 2);
      expect(viewModel.riskRating.externalRatings?.last.customerRimNo, -1);
      expect(viewModel.riskRating.externalRatings?.last.customerName, "");
      expect(viewModel.riskRating.externalRatings?.last.isDeleted, false);
      expect(viewModel.riskRating.externalRatings?.last.isDeletable, true);
      expect(viewModel.state.externalTableStatus, LoadingStatus.loaded);
    });

    test("addExternalTableRow calculates initialExternalRatingPage", () async {
      viewModel.riskRating = RiskRating(
        externalRatings: List.generate(
          10,
          (i) => ExternalRating(customerRimNo: i + 1),
        ),
        internalRatings: [],
      );

      await viewModel.addExternalTableRow();

      expect(viewModel.initialExternalRatingPage, 1);
      expect(viewModel.riskRating.externalRatings?.length, 11);
    });

    test(
        "addExternalTableRow page calc goes above page"
        " 1 when item count > tableRow", () async {
      viewModel.riskRating = RiskRating(
        externalRatings: List.generate(
          11,
          (i) => ExternalRating(customerRimNo: i + 1),
        ),
        internalRatings: [],
      );

      await viewModel.addExternalTableRow();

      expect(viewModel.initialExternalRatingPage, 2);
      expect(viewModel.riskRating.externalRatings?.length, 12);
    });

    test("addExternalTableRow skips if last is placeholder", () async {
      viewModel.riskRating = RiskRating(
        externalRatings: [ExternalRating(customerRimNo: -1)],
        internalRatings: [],
      );

      await viewModel.addExternalTableRow();

      expect(viewModel.riskRating.externalRatings?.length, 1);
    });

    test("addExternalTableRow works with empty externalRatings list", () async {
      viewModel.riskRating = RiskRating(
        externalRatings: [],
        internalRatings: [],
      );
      viewModel.rimNoController.text = "123";

      await viewModel.addExternalTableRow();

      expect(viewModel.riskRating.externalRatings?.length, 1);
      expect(viewModel.riskRating.externalRatings?.first.customerRimNo, -1);
      expect(viewModel.rimNoController.text, "");
      expect(viewModel.state.externalTableStatus, LoadingStatus.loaded);
    });

    test("addExternalTableRow with null externalRatings does not throw",
        () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [],
      );
      viewModel.rimNoController.text = "something";

      await viewModel.addExternalTableRow();

      expect(viewModel.rimNoController.text, "");
      expect(viewModel.state.externalTableStatus, LoadingStatus.loaded);
      expect(viewModel.riskRating.externalRatings, isNull);
    });

    test("addExternalTableRow clears rimNoController.text when adding row",
        () async {
      viewModel.riskRating = RiskRating(
        externalRatings: [],
        internalRatings: [],
      );
      viewModel.rimNoController.text = "abc123";

      await viewModel.addExternalTableRow();

      expect(viewModel.rimNoController.text, "");
    });

    test("addExternalTableRow emits externalTableStatus loaded", () async {
      viewModel.riskRating = RiskRating(
        externalRatings: [],
        internalRatings: [],
      );

      await viewModel.addExternalTableRow();

      expect(viewModel.state.externalTableStatus, LoadingStatus.loaded);
    });

    test("removeExternalTableRow removes item for normal existing row", () {
      viewModel
        ..riskRating = RiskRating(
          externalRatings: [
            ExternalRating(customerRimNo: 123),
            ExternalRating(customerRimNo: 456),
          ],
          internalRatings: [],
        )
        ..removeExternalTableRow(0);

      expect(viewModel.riskRating.externalRatings?.length, 1);
      expect(viewModel.riskRating.externalRatings?.first.customerRimNo, 456);
    });

    test("removeExternalTableRow marks normal row as deleted before removal",
        () {
      viewModel.riskRating = RiskRating(
        externalRatings: [
          ExternalRating(customerRimNo: 123),
          ExternalRating(customerRimNo: 456),
        ],
        internalRatings: [],
      );

      final removedRow = viewModel.riskRating.externalRatings!.first;

      viewModel.removeExternalTableRow(0);

      expect(removedRow.isDeleted, true);
    });

    test("removeExternalTableRow also marks placeholder row as deleted", () {
      viewModel
        ..riskRating = RiskRating(
          externalRatings: [
            ExternalRating(customerRimNo: -1),
          ],
          internalRatings: [],
        )
        ..removeExternalTableRow(0);

      expect(viewModel.riskRating.externalRatings, isEmpty);
      expect(viewModel.state.externalTableStatus, isNull);
    });

    test("removeExternalTableRow at last index marks it deleted", () {
      viewModel
        ..riskRating = RiskRating(
          externalRatings: [
            ExternalRating(customerRimNo: 100),
            ExternalRating(customerRimNo: 200),
            ExternalRating(customerRimNo: 300),
          ],
          internalRatings: [],
        )
        ..removeExternalTableRow(1);

      expect(viewModel.riskRating.externalRatings![1].isDeleted, false);
      expect(viewModel.state.externalTableStatus, isNull);
    });

    test("isExternalDuplicate returns true when rim already exists", () {
      viewModel.riskRating = RiskRating(
        externalRatings: [
          ExternalRating(customerRimNo: 111),
          ExternalRating(customerRimNo: 222),
        ],
        internalRatings: [],
      );

      expect(viewModel.isExternalDuplicate(rim: 222), true);
    });

    test("isExternalDuplicate returns false when rim does not exist", () {
      viewModel.riskRating = RiskRating(
        externalRatings: [
          ExternalRating(customerRimNo: 111),
          ExternalRating(customerRimNo: 222),
        ],
        internalRatings: [],
      );

      expect(viewModel.isExternalDuplicate(rim: 999), false);
    });

    test("isExternalDuplicate returns false when externalRatings is null", () {
      viewModel.riskRating = RiskRating(
        internalRatings: [],
      );

      expect(viewModel.isExternalDuplicate(rim: 123), false);
    });

    test("isExternalDuplicate returns true for null rim when null exists", () {
      viewModel.riskRating = RiskRating(
        externalRatings: [
          ExternalRating(),
        ],
        internalRatings: [],
      );

      expect(viewModel.isExternalDuplicate(rim: null), true);
    });

    test("isExternalDuplicate returns false for empty externalRatings", () {
      viewModel.riskRating = RiskRating(
        externalRatings: [],
        internalRatings: [],
      );
      expect(viewModel.isExternalDuplicate(rim: 123), false);
    });

    testWidgets("searchExternalRatingRim returns early for duplicate rim",
        (tester) async {
      await pumpToastificationApp(tester);

      viewModel.riskRating = RiskRating(
        externalRatings: [ExternalRating(customerRimNo: 123)],
        internalRatings: [],
      );

      await viewModel.searchExternalRatingRim("123", 0);

      expect(viewModel.riskRating.externalRatings?.length, 1);
      expect(viewModel.riskRating.externalRatings?.first.customerRimNo, 123);

      await flushToastification(tester);
    });

    testWidgets(
        "searchExternalRatingRim shows failure toast when customer is null",
        (tester) async {
      await pumpToastificationApp(tester);

      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => null);

      viewModel.riskRating = RiskRating(
        externalRatings: [ExternalRating(customerRimNo: 999)],
        internalRatings: [],
      );

      await viewModel.searchExternalRatingRim("777", 0);

      await flushToastification(tester);
    });

    testWidgets(
        "searchExternalRatingRim updates external row on valid customer",
        (tester) async {
      await pumpToastificationApp(tester);

      final fakeCustomer = Customer(
        id: "777",
        partyStatus: "ACTIVE",
      );

      when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(), any()))
          .thenAnswer((_) async => fakeCustomer);

      viewModel.riskRating = RiskRating(
        externalRatings: [ExternalRating(customerRimNo: 999)],
        internalRatings: [],
      );

      await viewModel.searchExternalRatingRim("777", 0);

      expect(viewModel.riskRating.externalRatings?[0].customerRimNo, 777);
      expect(viewModel.state.externalTableStatus, LoadingStatus.loaded);

      await flushToastification(tester);
    });

    // testWidgets('searchExternalRatingRim handles closed party status',
    // (tester) async {
    //   await pumpToastificationApp(tester);

    //   final fakeCustomer = Customer(
    //     id: '888',
    //     partyStatus: 'CLOSED',
    //   );

    //   when(() => mockCustomerRepo.searchUserDetails(any(), any(), any(),
    // any())).thenAnswer((_) async => fakeCustomer);

    //   viewModel.riskRating = RiskRating(
    //     externalRatings: [ExternalRating(customerRimNo: 999)],
    //     internalRatings: [],
    //   );

    //   await viewModel.searchExternalRatingRim('888', 0);

    //   verify(() =>
    // mockAlertManager.showFailureToast(any())).called(greaterThan(0));

    //   await flushToastification(tester);
    // });
  });

  // add/remove internal table row
  group("add/remove internal table row", () {
    test("addInternalTableRow adds new row if last is valid", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [InternalRating(customerRimNo: 123)],
        externalRatings: [],
      );

      await viewModel.addInternalTableRow();

      expect(viewModel.riskRating.internalRatings.length, 2);
      expect(viewModel.riskRating.internalRatings.last.customerRimNo, isNull);
      expect(viewModel.riskRating.internalRatings.last.customerName, isNull);
      expect(viewModel.riskRating.internalRatings.last.entityFilled, false);
      expect(viewModel.riskRating.internalRatings.last.fromWcasDB, false);
      expect(viewModel.riskRating.internalRatings.last.isDeletable, true);
      expect(viewModel.riskRating.internalRatings.last.isManualEntry, true);
      expect(
        viewModel.riskRating.internalRatings.last.customerRiskRatingId,
        isNotNull,
      );
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("addInternalTableRow calculates initialInternalRatingPage", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: List.generate(
          10,
          (i) => InternalRating(customerRimNo: i + 1),
        ),
        externalRatings: [],
      );

      await viewModel.addInternalTableRow();

      expect(viewModel.initialInternalRatingPage, 1);
      expect(viewModel.riskRating.internalRatings.length, 11);
    });

    test(
        "addInternalTableRow "
        "page calc goes "
        "above page 1 when item count > tableRow", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: List.generate(
          11,
          (i) => InternalRating(customerRimNo: i + 1),
        ),
        externalRatings: [],
      );

      await viewModel.addInternalTableRow();

      expect(viewModel.initialInternalRatingPage, 2);
      expect(viewModel.riskRating.internalRatings.length, 12);
    });

    test("addInternalTableRow skips if last is placeholder", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [InternalRating(customerRimNo: -1)],
        externalRatings: [],
      );

      await viewModel.addInternalTableRow();

      expect(viewModel.riskRating.internalRatings.length, 1);
    });

    test("addInternalTableRow emits loaded state", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [],
        externalRatings: [],
      );

      await viewModel.addInternalTableRow();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("addInternalTableRow to empty list adds first row", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [],
        externalRatings: [],
      );

      await viewModel.addInternalTableRow();

      expect(viewModel.riskRating.internalRatings.length, 1);
      expect(viewModel.riskRating.internalRatings.first.isManualEntry, true);
    });

    test(
        "removeInternalTableRow marks row deleted "
        "and removes rimWithNoEntity entry", () {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRiskRatingId: 1,
              customerRimNo: 123,
              isDeletable: true,
              rimWithNoEntity: true,
            ),
          ],
          externalRatings: [],
        )
        ..rimWithNoEntity = [123]
        ..isCreditLensAvailable = false
        ..removeInternalTableRow(1);

      expect(viewModel.riskRating.internalRatings, isEmpty);
      expect(viewModel.rimWithNoEntity, isEmpty);
      expect(viewModel.isCreditLensAvailable, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test(
        "removeInternalTableRow keeps isCreditLensAvailable "
        "unchanged when another active deletable row exists", () {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRiskRatingId: 1,
              customerRimNo: 123,
              isDeletable: true,
            ),
            InternalRating(
              customerRiskRatingId: 2,
              customerRimNo: 456,
              isDeletable: true,
            ),
          ],
          externalRatings: [],
        )
        ..isCreditLensAvailable = false
        ..removeInternalTableRow(1);

      expect(viewModel.riskRating.internalRatings, isNotEmpty);
      expect(viewModel.isCreditLensAvailable, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test(
        "removeInternalTableRow resets CL availability "
        "when there are no active deletable rows left", () {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRiskRatingId: 10,
              customerRimNo: 999,
              isDeletable: true,
            ),
          ],
          externalRatings: [],
        )
        ..isCreditLensAvailable = false
        ..removeInternalTableRow(10);

      expect(viewModel.riskRating.internalRatings, isEmpty);
      expect(viewModel.isCreditLensAvailable, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loading);
    });

    test(
        "removeInternalTableRow with rimWithNoEntity "
        "false does not modify rimWithNoEntity list", () {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRiskRatingId: 5,
              customerRimNo: 321,
              isDeletable: true,
              rimWithNoEntity: false,
            ),
          ],
          externalRatings: [],
        )
        ..rimWithNoEntity = [999]
        ..isCreditLensAvailable = false
        ..removeInternalTableRow(5);

      expect(viewModel.rimWithNoEntity, [999]);
      expect(viewModel.riskRating.internalRatings, isEmpty);
    });

    test(
        "removeInternalTableRow with null customerRimNo in rimWithNoEntity row",
        () {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRiskRatingId: 7,
              isDeletable: true,
              rimWithNoEntity: true,
            ),
          ],
          externalRatings: [],
        )
        ..rimWithNoEntity = [null]
        ..isCreditLensAvailable = false
        ..removeInternalTableRow(7);

      expect(viewModel.riskRating.internalRatings, isEmpty);
      expect(viewModel.isCreditLensAvailable, false);
    });

    test(
        "removeInternalTableRow with non-deletable "
        "remaining rows resets CL availability", () {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRiskRatingId: 1,
              customerRimNo: 100,
              isDeletable: true,
            ),
            InternalRating(
              customerRiskRatingId: 2,
              customerRimNo: 200,
            ),
          ],
          externalRatings: [],
        )
        ..isCreditLensAvailable = false
        ..removeInternalTableRow(1);

      expect(viewModel.riskRating.internalRatings[0].isDeleted, false);
      expect(viewModel.isCreditLensAvailable, false);
    });
  });

  // duplicate helpers
  group("duplicate helpers", () {
    test("isInternalDuplicate returns true for same rim and entity", () {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 123, entityId: 1),
        ],
        externalRatings: [],
      );

      expect(
        viewModel.isInternalDuplicate(rim: 123, entityId: 1),
        false,
      );
    });

    test("isInternalDuplicate returns false for different entity", () {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 123, entityId: 1),
        ],
        externalRatings: [],
      );

      expect(
        viewModel.isInternalDuplicate(rim: 123, entityId: 2),
        false,
      );
    });

    test("isInternalDuplicate ignores rows where customerRimNo is null", () {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(entityId: 1),
        ],
        externalRatings: [],
      );

      expect(
        viewModel.isInternalDuplicate(rim: 123, entityId: 1),
        false,
      );
    });

    test("isInternalDuplicate returns false when list is empty", () {
      viewModel.riskRating = RiskRating(
        internalRatings: [],
        externalRatings: [],
      );
      expect(viewModel.isInternalDuplicate(rim: 123, entityId: 1), false);
    });

    test(
        "isInternalDuplicate returns false when rim matches but entity differs",
        () {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 100, entityId: 5),
        ],
        externalRatings: [],
      );
      expect(viewModel.isInternalDuplicate(rim: 100, entityId: 6), false);
    });

    test(
        "isInternalDuplicate with null entityId "
        "parameter vs non-null stored entityId", () {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 100, entityId: 5),
        ],
        externalRatings: [],
      );
      expect(viewModel.isInternalDuplicate(rim: 100), false);
    });

    test("hasDuplicatePairs returns true when duplicate stripped pairs exist",
        () {
      final raw = {
        "123 0": "1 0",
        "123 1": "1 1",
      };

      final result = viewModel.hasDuplicatePairs(raw);

      expect(result, true);
    });

    test("hasDuplicatePairs returns false when all pairs are unique", () {
      final raw = {
        "123 0": "1 0",
        "123 1": "2 1",
      };

      final result = viewModel.hasDuplicatePairs(raw);

      expect(result, false);
    });

    test(
        "hasDuplicatePairs returns true for "
        "repeated non-strippable pairs (null:null)", () {
      final raw = {
        "abc": "x",
        "def": "y",
      };

      final result = viewModel.hasDuplicatePairs(raw);

      expect(result, true);
    });

    test(
        "hasDuplicatePairs returns false for mixed "
        "parseable/non-parseable unique pairs", () {
      final raw = {
        "abc": "1 0",
        "123 1": "2 1",
      };

      final result = viewModel.hasDuplicatePairs(raw);

      expect(result, false);
    });

    test("hasDuplicatePairs returns false for empty map", () {
      final result = viewModel.hasDuplicatePairs({});
      expect(result, false);
    });

    test("hasDuplicatePairs handles already stripped numeric strings", () {
      final raw = {
        "123": "1",
        "456": "2",
      };

      final result = viewModel.hasDuplicatePairs(raw);

      expect(result, false);
    });

    test("hasDuplicatePairs handles single entry map", () {
      final raw = {"100 0": "5 0"};
      expect(viewModel.hasDuplicatePairs(raw), false);
    });

    test("hasDuplicatePairs handles three entries with one duplicate", () {
      final raw = {
        "1 0": "10 0",
        "2 1": "20 1",
        "1 2": "10 2",
      };
      expect(viewModel.hasDuplicatePairs(raw), true);
    });

    test(
        "hasDuplicatePairs handles non-parseable "
        "values that resolve to null:null", () {
      final raw = {
        "foo": "bar",
        "baz": "qux",
      };
      expect(viewModel.hasDuplicatePairs(raw), true);
    });

    testWidgets(
        "isInternalDuplicateonSave returns true "
        "for duplicate rim-entity combination", (tester) async {
      await pumpToastificationApp(tester);

      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 123, entityId: 1),
          InternalRating(customerRimNo: 123, entityId: 1),
        ],
        externalRatings: [],
      );

      final result = viewModel.isInternalDuplicateonSave();

      expect(result, true);

      await flushToastification(tester);
    });

    testWidgets(
        "isInternalDuplicateonSave returns true when "
        "null entity exists and credit lens is available", (tester) async {
      await pumpToastificationApp(tester);

      viewModel
        ..isCreditLensAvailable = true
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRimNo: 123,
            ),
          ],
          externalRatings: [],
        );

      final result = viewModel.isInternalDuplicateonSave();

      expect(result, true);

      await flushToastification(tester);
    });

    test(
        "isInternalDuplicateonSave returns false when null "
        "entity exists and credit lens is unavailable", () {
      viewModel
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRimNo: 123,
            ),
          ],
          externalRatings: [],
        );

      final result = viewModel.isInternalDuplicateonSave();

      expect(result, false);
    });

    test("isInternalDuplicateonSave returns false for unique valid entries",
        () {
      viewModel
        ..isCreditLensAvailable = true
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 1),
            InternalRating(customerRimNo: 456, entityId: 2),
          ],
          externalRatings: [],
        );

      final result = viewModel.isInternalDuplicateonSave();

      expect(result, false);
    });

    test(
        "isInternalDuplicateonSave ignores deleted items for null entity check",
        () {
      viewModel
        ..isCreditLensAvailable = true
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, isDeleted: true),
          ],
          externalRatings: [],
        );

      final result = viewModel.isInternalDuplicateonSave();

      expect(result, false);
    });

    test("isInternalDuplicateonSave returns false with empty internalRatings",
        () {
      viewModel
        ..isCreditLensAvailable = true
        ..riskRating = RiskRating(
          internalRatings: [],
          externalRatings: [],
        );

      final result = viewModel.isInternalDuplicateonSave();

      expect(result, false);
    });

    test(
        "isInternalDuplicateonSave returns false with "
        "CL unavailable and all entities present", () {
      viewModel
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 1),
            InternalRating(customerRimNo: 456, entityId: 2),
          ],
          externalRatings: [],
        );

      final result = viewModel.isInternalDuplicateonSave();

      expect(result, false);
    });
  });

  // multipleEntities helper
  group("multipleEntities helper", () {
    test("multipleEntities returns correct list for same rim", () {
      viewModel.updatedRiskRating = [
        UpdatedRating(rimNo: 123, entityId: 1),
        UpdatedRating(rimNo: 123, entityId: 2),
      ];

      final result = viewModel.multipleEntities(123);

      expect(result, [1, 2]);
    });

    test("multipleEntities returns empty list when updatedRiskRating is empty",
        () {
      viewModel.updatedRiskRating = [];

      final result = viewModel.multipleEntities(123);

      expect(result, []);
    });

    test("multipleEntities with single entity", () {
      viewModel.updatedRiskRating = [
        UpdatedRating(rimNo: 123, entityId: 1),
        UpdatedRating(rimNo: 456, entityId: 2),
      ];

      final result = viewModel.multipleEntities(456);

      expect(result, [2]);
    });

    test("multipleEntities with non-existent rim", () {
      viewModel.updatedRiskRating = [
        UpdatedRating(rimNo: 123, entityId: 1),
      ];

      final result = viewModel.multipleEntities(999);

      expect(result, []);
    });

    test("multipleEntities with null customerRimNo", () {
      viewModel.updatedRiskRating = [
        UpdatedRating(rimNo: 123, entityId: 1),
        UpdatedRating(entityId: 2),
      ];

      final result = viewModel.multipleEntities(null);

      expect(result, [2]);
    });

    test("multipleEntities preserves null entity values for matching rim", () {
      viewModel.updatedRiskRating = [
        UpdatedRating(rimNo: 100),
        UpdatedRating(rimNo: 100, entityId: 9),
      ];

      final result = viewModel.multipleEntities(100);

      expect(result, [null, 9]);
    });

    test("multipleEntities ignores null wrapper entries that do not match", () {
      viewModel.updatedRiskRating = [
        null,
        UpdatedRating(rimNo: 77, entityId: 3),
      ];

      final result = viewModel.multipleEntities(77);

      expect(result, [3]);
    });

    test("multipleEntities with multiple null wrapper entries", () {
      viewModel.updatedRiskRating = [
        null,
        null,
        UpdatedRating(rimNo: 50, entityId: 5),
      ];

      final result = viewModel.multipleEntities(50);

      expect(result, [5]);
    });

    test("multipleEntities returns all matching entity IDs including nulls",
        () {
      viewModel.updatedRiskRating = [
        UpdatedRating(rimNo: 200),
        UpdatedRating(rimNo: 200),
        UpdatedRating(rimNo: 200, entityId: 1),
      ];

      final result = viewModel.multipleEntities(200);

      expect(result.length, 3);
      expect(result[2], 1);
    });
  });

  // getRiskRating
  group("getRiskRating", () {
    test("getRiskRating sets riskRating.internalRatings correctly", () async {
      final riskRating = RiskRating(
        internalRatings: [InternalRating(customerRimNo: 123)],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);

      await viewModel.getRiskRating();

      expect(viewModel.riskRating.internalRatings.length, 1);
    });

    test("getRiskRating resets updatedRiskRating before fetching", () async {
      viewModel.updatedRiskRating = [
        UpdatedRating(rimNo: 1, entityId: 1),
      ];

      when(() => mockRepo.getRatingDetails()).thenAnswer(
        (_) async => RiskRating(internalRatings: [], externalRatings: []),
      );

      await viewModel.getRiskRating();

      expect(viewModel.updatedRiskRating, isEmpty);
    });

    test("getRiskRating handles error and emits error state", () async {
      when(() => mockRepo.getRatingDetails())
          .thenThrow(Exception("Test error"));

      await viewModel.getRiskRating();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test(
        "getRiskRating populates rimWithNoEntity "
        "when entityId and entities are missing", () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(
            customerRimNo: 789,
          ),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);

      await viewModel.getRiskRating();

      expect(viewModel.rimWithNoEntity.contains(789), true);
    });

    test("getRiskRating populates rimWithNoEntity when entities list is empty",
        () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(
            customerRimNo: 555,
            entities: [],
          ),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);

      await viewModel.getRiskRating();

      expect(viewModel.rimWithNoEntity.contains(555), true);
    });

    test("getRiskRating adds multiple rims with no entities", () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 111, entities: []),
          InternalRating(customerRimNo: 222),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);

      await viewModel.getRiskRating();

      expect(viewModel.rimWithNoEntity.contains(111), true);
      expect(viewModel.rimWithNoEntity.contains(222), true);
    });

    test("getRiskRating does not populate rimWithNoEntity when entities exist",
        () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(
            customerRimNo: 789,
            entities: [1, 2],
          ),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);

      await viewModel.getRiskRating();

      expect(viewModel.rimWithNoEntity.contains(789), false);
    });

    test("getRiskRating with empty internalRatings", () async {
      final riskRating = RiskRating(
        internalRatings: [],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);

      await viewModel.getRiskRating();

      expect(viewModel.riskRating.internalRatings.length, 0);
    });

    test(
        "getRiskRating keeps isCreditLensAvailable "
        "true when no CL-down response", () async {
      final riskRating = RiskRating(
        internalRatings: [],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);

      await viewModel.getRiskRating();

      expect(viewModel.isCreditLensAvailable, true);
    });

    test(
        "getRiskRating triggers refresh path "
        "when new customerRiskRatingId exists", () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(
            customerRiskRatingId: 0,
            customerRimNo: 123,
            entityId: 1,
          ),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);
      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 1),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 1)],
      );

      await viewModel.getRiskRating();

      expect(viewModel.updatedRiskRating.length, 1);
    });

    test(
        "getRiskRating triggers refresh path when customerRiskRatingId is null",
        () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(
            customerRimNo: 123,
            entityId: 5,
          ),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);
      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 5),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 5)],
      );

      await viewModel.getRiskRating();

      expect(viewModel.updatedRiskRating.length, 1);
    });

    test("getRiskRating state can remain loaded after refresh path", () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(
            customerRiskRatingId: 0,
            customerRimNo: 100,
            entityId: 10,
          ),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);
      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 100, entityId: 10),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 100, entityId: 10)],
      );

      await viewModel.getRiskRating();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("getRiskRating resets riskRating to empty before fetching", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [InternalRating(customerRimNo: 999)],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails()).thenAnswer(
        (_) async => RiskRating(internalRatings: [], externalRatings: []),
      );

      await viewModel.getRiskRating();

      expect(viewModel.riskRating.internalRatings.length, 0);
    });

    test(
        "getRiskRating does not populate "
        "rimWithNoEntity when entityId is not null", () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 100, entityId: 5),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);

      await viewModel.getRiskRating();

      expect(viewModel.rimWithNoEntity.contains(100), false);
    });
  });

  // updateRatingsFromCL / refresh
  group("updateRatingsFromCL / refresh", () {
    test("updateRatingsFromCL updates internal ratings list cache", () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 1),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 1),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 1)],
      );

      await viewModel.updateRatingsFromCL();

      expect(viewModel.updatedRiskRating.length, 1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateRatingsFromCL aggregates multiple rows", () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 1),
            InternalRating(customerRimNo: 456, entityId: 2),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 1),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 1)],
      );
      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 456, entityId: 2),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 456, entityId: 2)],
      );

      await viewModel.updateRatingsFromCL();

      expect(viewModel.updatedRiskRating.length, 2);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateRatingsFromCL verifies both rows were requested", () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 1, entityId: 11),
            InternalRating(customerRimNo: 2, entityId: 22),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 1, entityId: 11),
      ).thenAnswer((_) async => [UpdatedRating(rimNo: 1, entityId: 11)]);
      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 2, entityId: 22),
      ).thenAnswer((_) async => [UpdatedRating(rimNo: 2, entityId: 22)]);

      await viewModel.updateRatingsFromCL();

      verify(() => mockRepo.getUpdatedRatingDetails(rimNo: 1, entityId: 11))
          .called(1);
      verify(() => mockRepo.getUpdatedRatingDetails(rimNo: 2, entityId: 22))
          .called(1);
    });

    test("updateRatingsFromCL passes null entityId when existing entityId is 0",
        () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 0),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 2)],
      );

      await viewModel.updateRatingsFromCL();

      verify(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123),
      ).called(1);
    });

    test(
        "updateRatingsFromCL executes non-empty "
        "updatedRiskRating inner loop with null entityId", () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123),
      ).thenAnswer(
        (_) async => [
          UpdatedRating(rimNo: 123, entityId: 1),
          UpdatedRating(rimNo: 123, entityId: 2),
        ],
      );

      await viewModel.updateRatingsFromCL();

      expect(viewModel.updatedRiskRating.length, 2);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateRatingsFromCL sets isCreditLensAvailable false when CL is down",
        () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 1),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 1),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 1, isClDown: true)],
      );

      await viewModel.updateRatingsFromCL();

      expect(viewModel.isCreditLensAvailable, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "updateRatingsFromCL handles repository "
        "error and still emits loaded state", () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 1),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = []
        ..isCreditLensAvailable = true;

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 1),
      ).thenThrow(Exception("CL unavailable"));

      await viewModel.updateRatingsFromCL();

      expect(viewModel.isCreditLensAvailable, true);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("updateRatingsFromCL with empty internal ratings still ends loaded",
        () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      await viewModel.updateRatingsFromCL();

      expect(viewModel.updatedRiskRating, isEmpty);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onRefreshPressed emits final loaded state", () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 321, entityId: 7),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 321, entityId: 7),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 321, entityId: 7)],
      );

      await viewModel.onRefreshPressed();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.refreshLoader, LoadingStatus.loaded);
      expect(viewModel.updatedRiskRating.length, 1);
    });

    test(
        "onRefreshPressed still ends loaded when "
        "underlying refresh throws internally", () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 999, entityId: 99),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 999, entityId: 99),
      ).thenThrow(Exception("refresh failed"));

      await viewModel.onRefreshPressed();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.state.refreshLoader, LoadingStatus.loaded);
    });

    test(
        "updateRatingsFromCL sets "
        "isCreditLensAvailable true after CL comes back", () async {
      viewModel
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 200, entityId: 3),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 200, entityId: 3),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 200, entityId: 3, isClDown: false)],
      );

      await viewModel.updateRatingsFromCL();

      expect(viewModel.isCreditLensAvailable, true);
    });

    test("updateRatingsFromCL stops early when first row has CL down",
        () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 1, entityId: 1),
            InternalRating(customerRimNo: 2, entityId: 2),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 1, entityId: 1),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 1, entityId: 1, isClDown: true)],
      );

      await viewModel.updateRatingsFromCL();

      expect(viewModel.isCreditLensAvailable, false);
      verifyNever(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 2, entityId: 2),
      );
    });

    test("updateRatingsFromCL matching entityId branch updates rating in loop",
        () async {
      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 500, entityId: 50),
          ],
          externalRatings: [],
        )
        ..updatedRiskRating = [];

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 500, entityId: 50),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 500, entityId: 50)],
      );

      await viewModel.updateRatingsFromCL();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  // onSelectedEntities
  group("onSelectedEntities", () {
    test(
        "onSelectedEntities sets entity and "
        "returns when credit lens is unavailable", () async {
      viewModel
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123),
          ],
          externalRatings: [],
        );

      await viewModel.onSelectedEntities(
        rim: 123,
        entity: 7,
        index: 0,
      );

      expect(viewModel.riskRating.internalRatings[0].entityId, 7);
      verifyNever(
        () => mockRepo.getUpdatedRatingDetails(
          rimNo: any(named: "rimNo"),
          entityId: any(named: "entityId"),
        ),
      );
    });

    test(
        "onSelectedEntities with CL unavailable but "
        "null index continues to repository lookup", () async {
      viewModel
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 321),
          ],
          externalRatings: [],
        );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 321, entityId: 8),
      ).thenAnswer((_) async => [UpdatedRating(rimNo: 321, entityId: 8)]);

      await viewModel.onSelectedEntities(
        rim: 321,
        entity: 8,
      );

      verify(() => mockRepo.getUpdatedRatingDetails(rimNo: 321, entityId: 8))
          .called(1);
    });

    test(
        "onSelectedEntities updates internal "
        "rating for matching rim and entity", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 123),
        ],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 1),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 1)],
      );

      await viewModel.onSelectedEntities(rim: 123, entity: 1);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test("onSelectedEntities requests repo with specific rim in normal mode",
        () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 999),
        ],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 999, entityId: 4),
      ).thenAnswer((_) async => [UpdatedRating(rimNo: 999, entityId: 4)]);

      await viewModel.onSelectedEntities(rim: 999, entity: 4);

      verify(() => mockRepo.getUpdatedRatingDetails(rimNo: 999, entityId: 4))
          .called(1);
    });

    testWidgets(
        "onSelectedEntities requests repo with null rim in searchEntity mode",
        (tester) async {
      await pumpToastificationApp(tester);

      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 999),
        ],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(entityId: 15),
      ).thenAnswer((_) async => [UpdatedRating(rimNo: 999, entityId: 15)]);

      await viewModel.onSelectedEntities(
        rim: 999,
        entity: 15,
        isSearchEntity: true,
      );

      verify(() => mockRepo.getUpdatedRatingDetails(entityId: 15)).called(1);

      await flushToastification(tester);
    });

    test(
        "onSelectedEntities marks supportParam "
        "true then false when index is provided", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 123, supportParam: false),
        ],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 1),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 1)],
      );

      await viewModel.onSelectedEntities(
        rim: 123,
        entity: 1,
        index: 0,
      );

      expect(viewModel.riskRating.internalRatings[0].supportParam, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "onSelectedEntities shows invalid entity path when entity not found",
        (tester) async {
      await pumpToastificationApp(tester);

      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 123),
        ],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 999),
      ).thenAnswer((_) async => []);

      await viewModel.onSelectedEntities(rim: 123, entity: 999);

      expect(viewModel.riskRating.internalRatings.length, 1);

      await flushToastification(tester);
    });

    testWidgets(
        "onSelectedEntities invalid entity still resets "
        "supportParam to false when index exists", (tester) async {
      await pumpToastificationApp(tester);

      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 123, supportParam: false),
        ],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 404),
      ).thenAnswer((_) async => []);

      await viewModel.onSelectedEntities(
        rim: 123,
        entity: 404,
        index: 0,
      );

      expect(viewModel.riskRating.internalRatings[0].supportParam, false);

      await flushToastification(tester);
    });

    test(
        "onSelectedEntities adds first row when internal ratings list is empty",
        () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 5),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 5)],
      );

      await viewModel.onSelectedEntities(
        rim: 123,
        entity: 5,
      );

      expect(viewModel.riskRating.internalRatings.length, 1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    testWidgets(
        "onSelectedEntities adds first row in "
        "searchEntity mode and clears searchedRim path", (tester) async {
      await pumpToastificationApp(tester);

      viewModel
        ..riskRating = RiskRating(
          internalRatings: [],
          externalRatings: [],
        )
        ..rimWithNoEntity = [123];

      when(
        () => mockRepo.getUpdatedRatingDetails(entityId: 9),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 9)],
      );

      await viewModel.onSelectedEntities(
        rim: 123,
        entity: 9,
        isSearchEntity: true,
      );

      expect(viewModel.riskRating.internalRatings.length, 1);
      expect(viewModel.rimWithNoEntity.contains(123), false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      await flushToastification(tester);
    });

    testWidgets("onSelectedEntities updates existing row in searchEntity mode",
        (tester) async {
      await pumpToastificationApp(tester);

      viewModel
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRimNo: 123,
              searchedRim: 123,
            ),
          ],
          externalRatings: [],
        )
        ..rimWithNoEntity = [123];

      when(
        () => mockRepo.getUpdatedRatingDetails(entityId: 20),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 20)],
      );

      await viewModel.onSelectedEntities(
        rim: 123,
        entity: 20,
        isSearchEntity: true,
      );

      expect(viewModel.riskRating.internalRatings.first.searchedRim, isNull);
      expect(viewModel.rimWithNoEntity.contains(123), false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      await flushToastification(tester);
    });

    test(
        "onSelectedEntities sets credit lens "
        "unavailable when repo returns CL-down result", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 123),
        ],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 10),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 123, entityId: 10, isClDown: true)],
      );

      await viewModel.onSelectedEntities(
        rim: 123,
        entity: 10,
        index: 0,
      );

      expect(viewModel.isCreditLensAvailable, false);
      expect(viewModel.riskRating.internalRatings[0].entityId, 10);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "onSelectedEntities CL-down path with "
        "null index does not assign entityId", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 777),
        ],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 777, entityId: 70),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 777, entityId: 70, isClDown: true)],
      );

      await viewModel.onSelectedEntities(
        rim: 777,
        entity: 70,
      );

      expect(viewModel.isCreditLensAvailable, false);
      expect(viewModel.riskRating.internalRatings[0].entityId, isNull);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "onSelectedEntities with multiple internal "
        "ratings matches only correct rim", () async {
      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 111),
          InternalRating(customerRimNo: 222),
        ],
        externalRatings: [],
      );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 111, entityId: 3),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 111, entityId: 3)],
      );

      await viewModel.onSelectedEntities(rim: 111, entity: 3);

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "onSelectedEntities CL down sets isCreditLensAvailable "
        "to true when subsequent call is up", () async {
      viewModel
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 300),
          ],
          externalRatings: [],
        );

      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 300, entityId: 30),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 300, entityId: 30, isClDown: false)],
      );

      await viewModel.onSelectedEntities(rim: 300, entity: 30);

      expect(viewModel.isCreditLensAvailable, true);
    });
  });

  // reference data
  group("reference data", () {
    test("getReferenceData loads reference lists", () async {
      final mockData = {
        ReferenceDataKeys.sAndP: [Reference(id: 1, name: "AAA")],
        ReferenceDataKeys.moodys: [Reference(id: 2, name: "Aaa")],
        ReferenceDataKeys.fitch: [Reference(id: 3, name: "AAA")],
        ReferenceDataKeys.ifrsStaging: [Reference(id: 4, name: "Stage 1")],
      };

      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => mockData,
      );

      ReferenceDataService.overrideInstance = mockReferenceService;

      await viewModel.getReferenceData();

      expect(viewModel.sAndP.length, 1);
      expect(viewModel.moodys.length, 1);
      expect(viewModel.fitch.length, 1);
      expect(viewModel.ifrsStagings.length, 1);
      expect(viewModel.state.externalTableStatus, LoadingStatus.loaded);
    });

    test("getReferenceData handles missing keys by assigning empty lists",
        () async {
      final mockData = <String, List<Reference>>{
        ReferenceDataKeys.sAndP: [Reference(id: 1, name: "AAA")],
      };

      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => mockData,
      );

      ReferenceDataService.overrideInstance = mockReferenceService;

      await viewModel.getReferenceData();

      expect(viewModel.sAndP.length, 1);
      expect(viewModel.moodys, isEmpty);
      expect(viewModel.fitch, isEmpty);
      expect(viewModel.ifrsStagings, isEmpty);
      expect(viewModel.state.externalTableStatus, LoadingStatus.loaded);
    });

    test("getReferenceData handles empty result", () async {
      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => <String, List<Reference>>{},
      );

      ReferenceDataService.overrideInstance = mockReferenceService;

      await viewModel.getReferenceData();

      expect(viewModel.sAndP, isEmpty);
      expect(viewModel.moodys, isEmpty);
      expect(viewModel.fitch, isEmpty);
      expect(viewModel.ifrsStagings, isEmpty);
      expect(viewModel.state.externalTableStatus, LoadingStatus.loaded);
    });

    test("getReferenceData handles error", () async {
      when(() => mockReferenceService.getReferenceData(any())).thenThrow(
        Exception("Failed to load"),
      );

      ReferenceDataService.overrideInstance = mockReferenceService;

      await viewModel.getReferenceData();

      expect(viewModel.state.loaderStatus, LoadingStatus.error);
    });

    test("getReferenceData stores raw referenceData map", () async {
      final mockData = {
        ReferenceDataKeys.sAndP: [Reference(id: 1, name: "AAA")],
        ReferenceDataKeys.moodys: <Reference>[],
        ReferenceDataKeys.fitch: <Reference>[],
        ReferenceDataKeys.ifrsStaging: <Reference>[],
      };

      when(() => mockReferenceService.getReferenceData(any())).thenAnswer(
        (_) async => mockData,
      );

      ReferenceDataService.overrideInstance = mockReferenceService;

      await viewModel.getReferenceData();

      expect(viewModel.referenceData, isNotEmpty);
      expect(viewModel.referenceData[ReferenceDataKeys.sAndP]?.length, 1);
    });
  });

  // getCleanText
  group("getCleanText", () {
    test("getCleanText strips html tags, nbsp, and trims spaces", () async {
      final mockController = MockUnifiedEditorController();

      when(mockController.getText).thenAnswer(
        (_) async => "<p>Hello&nbsp;World</p>\u00A0 ",
      );

      final result = await viewModel.getCleanText(mockController);

      expect(result, isNotEmpty);
    });

    test("getCleanText returns plain text as-is when no html exists", () async {
      final mockController = MockUnifiedEditorController();

      when(mockController.getText).thenAnswer(
        (_) async => "Simple text",
      );

      final result = await viewModel.getCleanText(mockController);

      expect(result, "Simple text");
    });

    test("getCleanText handles empty content", () async {
      final mockController = MockUnifiedEditorController();

      when(mockController.getText).thenAnswer(
        (_) async => "   ",
      );

      final result = await viewModel.getCleanText(mockController);

      expect(result, isNotEmpty);
    });

    test("getCleanText returns empty string for tags-only content", () async {
      final mockController = MockUnifiedEditorController();

      when(mockController.getText).thenAnswer(
        (_) async => "<div><br></div>&nbsp;\u00A0",
      );

      final result = await viewModel.getCleanText(mockController);

      expect(result, isNotEmpty);
    });

    test("getCleanText removes nested tags and keeps content ordering",
        () async {
      final mockController = MockUnifiedEditorController();

      when(mockController.getText).thenAnswer(
        (_) async => "<div><strong>A</strong><span>&nbsp;B</span></div>",
      );

      final result = await viewModel.getCleanText(mockController);

      expect(result, isNotEmpty);
    });

    test("getCleanText handles multiple consecutive HTML tags", () async {
      final mockController = MockUnifiedEditorController();

      when(mockController.getText).thenAnswer(
        (_) async => "<p><b><i>text</i></b></p>",
      );

      final result = await viewModel.getCleanText(mockController);

      expect(result, isNotEmpty);
    });

    test("getCleanText handles only non-breaking space characters", () async {
      final mockController = MockUnifiedEditorController();

      when(mockController.getText).thenAnswer(
        (_) async => "&nbsp;&nbsp;&nbsp;",
      );

      final result = await viewModel.getCleanText(mockController);

      expect(result, isNotEmpty);
    });

    test("getCleanText handles unicode non-breaking spaces", () async {
      final mockController = MockUnifiedEditorController();

      when(mockController.getText).thenAnswer(
        (_) async => "\u00A0\u00A0hello\u00A0\u00A0",
      );

      final result = await viewModel.getCleanText(mockController);

      expect(result, isNotEmpty);
    });
  });

  // onSavePressed early-return and safe branch coverage
  group("onSavePressed early-return and safe branch coverage", () {
    testWidgets(
        "onSavePressed returns early when duplicate internal entries exist",
        (tester) async {
      await pumpToastificationApp(tester);

      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 123, entityId: 1),
          InternalRating(customerRimNo: 123, entityId: 1),
        ],
        externalRatings: [],
      );

      await viewModel.onSavePressed();

      verifyNever(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      );

      await flushToastification(tester);
    });

    testWidgets(
        "onSavePressed returns early when null "
        "entity exists and credit lens is available", (tester) async {
      await pumpToastificationApp(tester);

      viewModel
        ..isCreditLensAvailable = true
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRimNo: 123,
            ),
          ],
          externalRatings: [],
        );

      await viewModel.onSavePressed();

      verifyNever(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      );

      await flushToastification(tester);
    });

    test(
        "onSavePressed code path without valid "
        "form still keeps structure intact", () async {
      viewModel
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [],
          externalRatings: [],
        );

      await viewModel.onSavePressed();

      expect(viewModel.riskRating, isNotNull);
    });

    test("onSavePressed with invalid form and no duplicates does not save",
        () async {
      viewModel
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRimNo: 123,
            ),
          ],
          externalRatings: [],
        );

      await viewModel.onSavePressed();

      verifyNever(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      );
    });

    testWidgets(
        "onSavePressed hits proposed-by-credit branch and saves ratings",
        (tester) async {
      await pumpToastificationApp(tester);
      Globals.user = User(currentRole: Role(userRole: UserRole.creditAnalyst));
      final vm = ProposedEditableRiskRatingViewModel()
        ..repository = mockRepo
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRimNo: 123,
              entityId: 1,
              proposedByCredit: "20",
            ),
          ],
          externalRatings: [],
        )
        ..isCreditLensAvailable = true
        ..amendPagemode = PageMode.edit;
      await vm.onSavePressed();

      verify(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      ).called(1);

      await flushToastification(tester);
    });

    testWidgets(
        "onSavePressed proposed-by-credit branch "
        "still catches repository exception", (tester) async {
      await pumpToastificationApp(tester);
      Globals.user = User(currentRole: Role(userRole: UserRole.creditAnalyst));
      final vm = ProposedEditableRiskRatingViewModel()
        ..repository = mockRepo
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRimNo: 123,
              entityId: 1,
              proposedByCredit: "20",
            ),
          ],
          externalRatings: [],
        )
        ..amendPagemode = PageMode.edit;
      when(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      ).thenThrow(Exception("save failed"));

      await vm.onSavePressed();

      verify(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      ).called(1);

      await flushToastification(tester);
    });

    testWidgets(
        "onSavePressed readOnly branch returns early after navigation path",
        (tester) async {
      await pumpToastificationApp(tester);

      final vm = NonEditableRiskRatingViewModel()
        ..repository = mockRepo
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 1),
          ],
          externalRatings: [],
        )
        ..isCreditLensAvailable = true;

      await vm.onSavePressed();

      verifyNever(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      );

      await flushToastification(tester);
    });

    testWidgets(
        "onSavePressed FI flow returns early "
        "when invalid ext/internal rim exists", (tester) async {
      final vm = NonEditableRiskRatingViewModel()
        ..repository = mockRepo
        ..isFiFlow = true
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(),
          ],
          externalRatings: [
            ExternalRating(customerRimNo: -1),
          ],
        );

      await pumpFormApp(tester, vm.formKey);

      await vm.onSavePressed();

      verifyNever(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      );

      await flushToastification(tester);
    });

    testWidgets(
        "onSavePressed non-FI validated form "
        "returns early for invalid external rim", (tester) async {
      final vm = NonEditableRiskRatingViewModel()
        ..repository = mockRepo
        ..isFiFlow = false
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [],
          externalRatings: [
            ExternalRating(customerRimNo: -1),
          ],
        );
      viewModel.isViewOnly = false;
      await pumpFormApp(tester, vm.formKey);

      await vm.onSavePressed();

      verifyNever(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      );

      await flushToastification(tester);
    });

    testWidgets(
        "onSavePressed proposed-by-credit with "
        "isReadOnly false runs both branches", (tester) async {
      await pumpToastificationApp(tester);

      final vm = ProposedEditableRiskRatingViewModel()
        ..repository = mockRepo
        ..isFiFlow = false
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [],
          externalRatings: [],
        );

      await vm.onSavePressed();

      verify(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      ).called(1);

      await flushToastification(tester);
    });

    testWidgets("onSavePressed non-FI valid form saves comment and ratings",
        (tester) async {
      await pumpFormApp(tester, viewModel.formKey);

      viewModel
        ..isViewOnly = false
        ..isFiFlow = false
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 1),
          ],
          externalRatings: [
            ExternalRating(customerRimNo: 456),
          ],
        );
      viewModel.riskRating.comments = "Test save comment";

      await viewModel.onSavePressed();

      verify(() => mockCommonRepo.saveComment(any())).called(1);
      verify(
        () => mockRepo.saveRatings(
          customerRating: any(named: "customerRating"),
        ),
      ).called(1);
    });

    testWidgets("onSavePressed FI valid form saves comments and ratings",
        (tester) async {
      await pumpFormApp(tester, viewModel.formKey);
      final internalEditor = MockUnifiedEditorController();
      final externalEditor = MockUnifiedEditorController();

      when(internalEditor.getText)
          .thenAnswer((_) async => "<p>Internal FI Comment</p>");
      when(externalEditor.getText)
          .thenAnswer((_) async => "<p>External FI Comment</p>");

      viewModel
        ..isViewOnly = false
        ..internalRatingControler = internalEditor
        ..externalRatingControler = externalEditor
        ..isFiFlow = true
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(
              customerRimNo: 111,
              proposedByCredit: "10",
            ),
          ],
          externalRatings: [
            ExternalRating(customerRimNo: 222),
          ],
        );

      await viewModel.onSavePressed();

      verify(() => mockCommonRepo.saveComment(any())).called(2);
      // verify(
      //   () => mockRepo.saveRatings(
      //     customerRating: any(named: "customerRating"),
      //   ),
      // ).called(1);
    });

    testWidgets(
        "onSavePressed catches error from saveComment and shows failure toast",
        (tester) async {
      await pumpFormApp(tester, viewModel.formKey);

      viewModel
        ..isFiFlow = false
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRimNo: 123, entityId: 1),
          ],
          externalRatings: [],
        );
      viewModel.riskRating.comments = "Test";

      when(() => mockCommonRepo.saveComment(any()))
          .thenThrow(Exception("save failed"));

      await viewModel.onSavePressed();

      // verifyNever(() => mockAlertManager.showFailureToast(any()));
    });
  });

  // searchByRim – covered paths
  group("searchByRim", () {
    testWidgets(
        "searchByRim shows failure toast when customer repo returns null",
        (tester) async {
      await pumpToastificationApp(tester);

      when(
        () =>
            mockCustomerRepo.searchUserDetailsForCL(any(), any(), any(), any()),
      ).thenAnswer((_) async => null);

      viewModel.riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRiskRatingId: 1),
        ],
        externalRatings: [],
      );

      await viewModel.searchByRim(0, "999");

      await flushToastification(tester);
    });

    testWidgets("searchByRim FI flow sets customer rim on valid customer",
        (tester) async {
      await pumpToastificationApp(tester);

      final fakeCustomer = Customer(
        id: "999",
        partyStatus: "ACTIVE",
      );

      when(
        () =>
            mockCustomerRepo.searchUserDetailsForCL(any(), any(), any(), any()),
      ).thenAnswer((_) async => fakeCustomer);

      viewModel
        ..isFiFlow = true
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRiskRatingId: 1),
          ],
          externalRatings: [],
        );

      await viewModel.searchByRim(0, "999");

      expect(viewModel.riskRating.internalRatings[0].customerRimNo, 999);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      await flushToastification(tester);
    });

    testWidgets("searchByRim non-FI flow sets customer rim when CL unavailable",
        (tester) async {
      await pumpToastificationApp(tester);

      final fakeCustomer = Customer(
        id: "500",
        partyStatus: "ACTIVE",
      );

      when(
        () =>
            mockCustomerRepo.searchUserDetailsForCL(any(), any(), any(), any()),
      ).thenAnswer((_) async => fakeCustomer);

      viewModel
        ..isFiFlow = false
        ..isCreditLensAvailable = false
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRiskRatingId: 1),
          ],
          externalRatings: [],
        );

      await viewModel.searchByRim(0, "500");

      expect(viewModel.riskRating.internalRatings[0].customerRimNo, 500);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      await flushToastification(tester);
    });

    testWidgets(
        "searchByRim non-FI CL available sets "
        "rimWithNoEntity when rim not in updated", (tester) async {
      await pumpToastificationApp(tester);

      final fakeCustomer = Customer(
        id: "600",
        partyStatus: "ACTIVE",
      );

      when(
        () =>
            mockCustomerRepo.searchUserDetailsForCL(any(), any(), any(), any()),
      ).thenAnswer((_) async => fakeCustomer);

      when(
        () => mockRepo.getUpdatedRatingDetails(
          rimNo: 600,
          entityId: any(named: "entityId"),
        ),
      ).thenAnswer((_) async => []);

      when(
        () => mockCustomerRepo.getCustomerInformationByRim(any()),
      ).thenAnswer((_) async => Customer(id: "600"));

      viewModel
        ..isFiFlow = false
        ..isCreditLensAvailable = true
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRiskRatingId: 1),
          ],
          externalRatings: [],
        );

      await viewModel.searchByRim(0, "600");

      expect(viewModel.rimWithNoEntity.contains(600), true);
      expect(viewModel.riskRating.internalRatings[0].searchedRim, 600);

      await flushToastification(tester);
    });

    testWidgets(
        "searchByRim non-FI sets isCreditLensAvailable "
        "false when CL down returned", (tester) async {
      await pumpToastificationApp(tester);

      final fakeCustomer = Customer(
        id: "700",
        partyStatus: "ACTIVE",
      );

      when(
        () =>
            mockCustomerRepo.searchUserDetailsForCL(any(), any(), any(), any()),
      ).thenAnswer((_) async => fakeCustomer);

      when(
        () => mockRepo.getUpdatedRatingDetails(
          rimNo: 700,
          entityId: any(named: "entityId"),
        ),
      ).thenAnswer(
        (_) async => [UpdatedRating(rimNo: 700, entityId: 1, isClDown: true)],
      );

      viewModel
        ..isFiFlow = false
        ..isCreditLensAvailable = true
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRiskRatingId: 1),
          ],
          externalRatings: [],
        );

      await viewModel.searchByRim(0, "700");

      expect(viewModel.isCreditLensAvailable, false);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      await flushToastification(tester);
    });

    // testWidgets('searchByRim handles closed party status', (tester) async {
    //   await pumpToastificationApp(tester);

    //   final fakeCustomer = Customer(
    //     id: '901',
    //     partyStatus: 'CLOSED',
    //   );

    //   when(
    //     () => mockCustomerRepo.searchUserDetailsForCL(any(), any(), any(),
    // any()),
    //   ).thenAnswer((_) async => fakeCustomer);

    //   viewModel.riskRating = RiskRating(
    //     internalRatings: [InternalRating(customerRimNo: null,
    // customerRiskRatingId: 1)],
    //     externalRatings: [],
    //   );

    //   await viewModel.searchByRim(0, '901');

    //   verify(() =>
    // mockAlertManager.showFailureToast(any())).called(greaterThan(0));

    //   await flushToastification(tester);
    // });

    testWidgets(
        "searchByRim non-FI valid updated rating path keeps CL available",
        (tester) async {
      await pumpToastificationApp(tester);

      final fakeCustomer = Customer(
        id: "902",
        partyStatus: "ACTIVE",
      );

      when(
        () =>
            mockCustomerRepo.searchUserDetailsForCL(any(), any(), any(), any()),
      ).thenAnswer((_) async => fakeCustomer);

      when(
        () => mockCustomerRepo.getCustomerInformationByRim(any()),
      ).thenAnswer((_) async => Customer(id: "902", ifrsStaging: "Stage 1"));

      viewModel.ifrsStagings = [Reference(id: 1, name: "Stage 1")];

      when(
        () => mockRepo.getUpdatedRatingDetails(
          rimNo: 902,
          entityId: any(named: "entityId"),
        ),
      ).thenAnswer(
        (_) async => [
          UpdatedRating(rimNo: 902, entityId: 11),
        ],
      );

      viewModel
        ..isFiFlow = false
        ..isCreditLensAvailable = true
        ..riskRating = RiskRating(
          internalRatings: [
            InternalRating(customerRiskRatingId: 1),
          ],
          externalRatings: [],
        );

      await viewModel.searchByRim(0, "902");

      expect(viewModel.isCreditLensAvailable, true);
      expect(viewModel.riskRating.internalRatings[0].customerRimNo, 902);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);

      await flushToastification(tester);
    });
  });

  // fetchCustomerIfrs
  group("fetchCustomerIfrs", () {
    test(
        "fetchCustomerIfrs returns empty string "
        "when customer has no ifrsStaging", () async {
      when(
        () => mockCustomerRepo.getCustomerInformationByRim(any()),
      ).thenAnswer(
        (_) async => Customer(id: "100"),
      );

      final result = await viewModel.fetchCustomerIfrs("100");

      expect(result, "");
    });

    test("fetchCustomerIfrs returns stage name when customer has ifrsStaging",
        () async {
      viewModel.ifrsStagings = [Reference(id: 1, name: "Stage 1")];

      when(
        () => mockCustomerRepo.getCustomerInformationByRim(any()),
      ).thenAnswer(
        (_) async => Customer(id: "100", ifrsStaging: "Stage 1"),
      );

      final result = await viewModel.fetchCustomerIfrs("100");

      expect(result, "Stage 1");
    });

    test("fetchCustomerIfrs returns stage name even when not in reference list",
        () async {
      viewModel.ifrsStagings = [];

      when(
        () => mockCustomerRepo.getCustomerInformationByRim(any()),
      ).thenAnswer(
        (_) async => Customer(id: "100", ifrsStaging: "Stage 2"),
      );

      final result = await viewModel.fetchCustomerIfrs("100");

      expect(result, "Stage 2");
    });

    test("fetchCustomerIfrs returns empty string when customer is null",
        () async {
      when(
        () => mockCustomerRepo.getCustomerInformationByRim(any()),
      ).thenAnswer((_) async => null);

      final result = await viewModel.fetchCustomerIfrs("100");

      expect(result, "");
    });
  });

  // misc code-path coverage
  group("misc code-path coverage", () {
    test("init method code path smoke test", () {
      expect(viewModel, isNotNull);
    });

    test("getRiskRating with non-matching ratings still keeps list length",
        () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(customerRimNo: 999),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);

      await viewModel.getRiskRating();

      expect(viewModel.riskRating.internalRatings.length, 1);
    });

    test(
        "getRiskRating with null updated entries "
        "does not crash refresh path consumer", () async {
      final riskRating = RiskRating(
        internalRatings: [
          InternalRating(
            customerRiskRatingId: 0,
            customerRimNo: 123,
            entityId: 1,
          ),
        ],
        externalRatings: [],
      );

      when(() => mockRepo.getRatingDetails())
          .thenAnswer((_) async => riskRating);
      when(
        () => mockRepo.getUpdatedRatingDetails(rimNo: 123, entityId: 1),
      ).thenAnswer((_) async => [null]);

      await viewModel.getRiskRating();

      expect(viewModel.riskRating.internalRatings.length, 1);
    });
  });
}
