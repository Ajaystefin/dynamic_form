import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/model.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/state.dart";
import "package:wcas_frontend/models/request/approval/output_form.dart";
import "package:wcas_frontend/repositories/approval_repository.dart";

class MockApprovalRepository extends Mock implements ApprovalRepository {}

class MockAlertManager extends Mock implements AlertManager {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ListOutputFormsDialogViewModel viewModel;
  late MockApprovalRepository mockRepository;
  late MockAlertManager mockAlert;

  setUpAll(() async {
    await EnvConfig.setEnvironment();
  });

  setUp(() {
    mockRepository = MockApprovalRepository();
    mockAlert = MockAlertManager();

    // ✅ override singletons
    ApprovalRepository.overrideInstance = mockRepository;
    AlertManager.overrideInstance = mockAlert;

    viewModel = ListOutputFormsDialogViewModel()..repository = mockRepository;
  });

  tearDown(() async {
    await viewModel.close();
  });

  // ================= INIT =================

  test("init covers real flow", () async {
    final forms = [OutputForm(name: "Init", id: 1, url: "")];

    when(() => mockRepository.getOutputForms()).thenAnswer((_) async => forms);

    final vm = ListOutputFormsDialogViewModel();

    await vm.init(FakeBuildContext());

    expect(vm.outputForms.length, 1);
    expect(vm.state.loaderStatus, LoadingStatus.loaded);

    verify(() => mockRepository.getOutputForms()).called(1);

    await vm.close();
  });

  // ================= FETCH =================

  test("fetchOutputForms success", () async {
    final forms = [OutputForm(name: "A", id: 1, url: "")];

    when(() => mockRepository.getOutputForms()).thenAnswer((_) async => forms);

    await viewModel.fetchOutputForms();

    expect(viewModel.outputForms, forms);
    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  test("fetchOutputForms error", () async {
    when(() => mockRepository.getOutputForms()).thenThrow(Exception());

    await viewModel.fetchOutputForms();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  // ================= DOWNLOAD =================

  test("downloadOutputForm with selected item", () async {
    final forms = [
      OutputForm(name: "A", id: 1, isSelected: true, url: ""),
    ];

    when(() => mockRepository.getOutputForms()).thenAnswer((_) async => forms);

    when(
      () => mockRepository.downloadOutputForms(
        any(),
        isDownload: any(named: "isDownload"),
        any(),
      ),
    ).thenAnswer((_) async {});

    await viewModel.fetchOutputForms();

    await viewModel.downloadOutputForm("PDF", isDownload: true);

    verify(
      () => mockRepository.downloadOutputForms(
        any(),
        isDownload: true,
        "PDF",
      ),
    ).called(1);
  });

  test("downloadOutputForm without selection shows toast", () async {
    final forms = [
      OutputForm(name: "A", id: 1, url: ""),
    ];

    when(() => mockRepository.getOutputForms()).thenAnswer((_) async => forms);

    when(() => mockAlert.showFailureToast(any())).thenReturn(null);

    when(
      () => mockRepository.downloadOutputForms(
        any(),
        isDownload: any(named: "isDownload"),
        any(),
      ),
    ).thenAnswer((_) async {});

    await viewModel.fetchOutputForms();

    await viewModel.downloadOutputForm("PDF", isDownload: false);

    verify(() => mockAlert.showFailureToast(any())).called(1);
  });

  test("downloadOutputForm exception handled", () async {
    final forms = [
      OutputForm(name: "A", id: 1, isSelected: true, url: ""),
    ];

    when(() => mockRepository.getOutputForms()).thenAnswer((_) async => forms);

    when(
      () => mockRepository.downloadOutputForms(
        any(),
        isDownload: any(named: "isDownload"),
        any(),
      ),
    ).thenThrow(Exception("fail"));

    when(() => mockAlert.showFailureToast(any())).thenReturn(null);

    await viewModel.fetchOutputForms();

    await viewModel.downloadOutputForm("PDF", isDownload: true);

    verify(() => mockAlert.showFailureToast(any())).called(1);
  });

  // ================= TOGGLE =================

  test("toggleSelection valid", () async {
    final forms = [
      OutputForm(name: "A", id: 1, url: ""),
    ];

    when(() => mockRepository.getOutputForms()).thenAnswer((_) async => forms);

    await viewModel.fetchOutputForms();

    viewModel.toggleSelection(0);

    expect(viewModel.outputForms[0].isSelected, true);
  });

  test("toggleSelection invalid index", () {
    viewModel..toggleSelection(-1)
    ..toggleSelection(5);

    expect(viewModel.outputForms, isEmpty);
  });

  // ================= STATE =================

  test("state copyWith", () {
    const s = ListOutputFormsDialogState(
      loaderStatus: LoadingStatus.loading,
    );

    final n = s.copyWith(loaderStatus: LoadingStatus.loaded);

    expect(n.loaderStatus, LoadingStatus.loaded);
  });
}
