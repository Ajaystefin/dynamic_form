import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/draft_handler.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/model.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment_fi/state.dart";

class MockCreditAssessmentFIViewModel extends Mock
    implements CreditAssessmentFIViewModel {}

class MockCreditAssessmentFIState extends Mock
    implements CreditAssessmentFIState {}

class MockUnifiedEditorController extends Mock
    implements UnifiedEditorController {}

void main() {
  late CreditAssessmentFIDraftHandler handler;
  late MockCreditAssessmentFIViewModel vm;
  late MockCreditAssessmentFIState initialState;
  late MockCreditAssessmentFIState loadingState;
  late MockCreditAssessmentFIState loadedState;
  late MockUnifiedEditorController rim1001Controller;
  late MockUnifiedEditorController rim1002Controller;

  setUp(() {
    handler = CreditAssessmentFIDraftHandler();
    vm = MockCreditAssessmentFIViewModel();

    initialState = MockCreditAssessmentFIState();
    loadingState = MockCreditAssessmentFIState();
    loadedState = MockCreditAssessmentFIState();

    rim1001Controller = MockUnifiedEditorController();
    rim1002Controller = MockUnifiedEditorController();

    when(() => vm.state).thenReturn(initialState);

    when(
      () => initialState.copyWith(loaderStatus: LoadingStatus.loading),
    ).thenReturn(loadingState);

    when(
      () => initialState.copyWith(loaderStatus: LoadingStatus.loaded),
    ).thenReturn(loadedState);
  });

  group("CreditAssessmentFIDraftHandler", () {
    test("buildDraftData returns rimData from rimController entries", () {
      when(() => rim1001Controller.currentText).thenReturn("RIM 1001 value");
      when(() => rim1002Controller.currentText).thenReturn("RIM 1002 value");

      when(() => vm.rimController).thenReturn(
        <int, UnifiedEditorController>{
          1001: rim1001Controller,
          1002: rim1002Controller,
        },
      );

      final Map<String, dynamic> result = handler.buildDraftData(vm);

      expect(
        result,
        <String, dynamic>{
          "rimData": <String, dynamic>{
            "1001": "RIM 1001 value",
            "1002": "RIM 1002 value",
          },
        },
      );
    });

    test("applyDraft applies rimData and emits loading then loaded", () {
      when(() => rim1001Controller.currentText).thenReturn("new value 1");
      when(() => rim1002Controller.currentText).thenReturn("new value 2");

      when(() => vm.rimController).thenReturn(
        <int, UnifiedEditorController>{
          1001: rim1001Controller,
          1002: rim1002Controller,
        },
      );

      handler.applyDraft(
        vm,
        <String, dynamic>{
          "rimData": <String, dynamic>{
            "1001": "new value 1",
            "1002": "new value 2",
          },
        },
      );

      verify(() => vm.emit(loadingState)).called(1);
      verify(() => rim1001Controller.setText("new value 1")).called(1);
      verify(() => rim1002Controller.setText("new value 2")).called(1);
      verify(() => vm.emit(loadedState)).called(1);
    });

    test("applyDraft handles null rimData and still emits loading then loaded", () {
      handler.applyDraft(
        vm,
        <String, dynamic>{
          "rimData": null,
        },
      );

      verify(() => vm.emit(loadingState)).called(1);
      verify(() => vm.emit(loadedState)).called(1);
      verifyNever(() => vm.rimController);
    });

    test("applyDraft converts invalid rim key to zero", () {
      final MockUnifiedEditorController rimZeroController =
          MockUnifiedEditorController();

      when(() => rimZeroController.currentText).thenReturn("updated zero");

      when(() => vm.rimController).thenReturn(
        <int, UnifiedEditorController>{
          0: rimZeroController,
        },
      );

      handler.applyDraft(
        vm,
        <String, dynamic>{
          "rimData": <String, dynamic>{
            "invalid-key": "updated zero",
          },
        },
      );

      verify(() => vm.emit(loadingState)).called(1);
      verify(() => rimZeroController.setText("updated zero")).called(1);
      verify(() => vm.emit(loadedState)).called(1);
    });

    test("applyDraft ignores rimData key when controller is missing", () {
      when(() => vm.rimController).thenReturn(
        <int, UnifiedEditorController>{},
      );

      handler.applyDraft(
        vm,
        <String, dynamic>{
          "rimData": <String, dynamic>{
            "9999": "missing controller value",
          },
        },
      );

      verify(() => vm.emit(loadingState)).called(1);
      verify(() => vm.emit(loadedState)).called(1);
    });
  });
}
