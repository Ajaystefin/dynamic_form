import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/sublimit_conditions_dialog/model.dart";
import "package:wcas_frontend/models/request/facility_security/facility_detail.dart";

class ConditionStub extends Mock implements Condition {
  ConditionStub({
    int? facilityMasterId,
    bool? isSelected,
    bool? isAmended,
    bool? isWaivedOff,
  })  : _facilityMasterId = facilityMasterId,
        _isSelected = isSelected,
        _isAmended = isAmended,
        _isWaivedOff = isWaivedOff;

  final int? _facilityMasterId;
  bool? _isSelected;
  bool? _isAmended;
  bool? _isWaivedOff;

  @override
  int? get facilityMasterId => _facilityMasterId;

  @override
  bool? get isSelected => _isSelected;

  @override
  set isSelected(bool? value) {
    _isSelected = value;
  }

  @override
  bool? get isAmended => _isAmended;

  @override
  set isAmended(bool? value) {
    _isAmended = value;
  }

  @override
  bool? get isWaivedOff => _isWaivedOff;

  @override
  set isWaivedOff(bool? value) {
    _isWaivedOff = value;
  }
}

SubLimitConditionsViewModel buildViewModel({
  List<Condition>? standardConditions,
  List<Condition>? nonStandardConditions,
  bool canEdit = true,
  void Function()? onAddNonStandard,
  int initialPageStandard = 0,
  int initialPageNonStandard = 0,
}) {
  return SubLimitConditionsViewModel(
    standardConditions: standardConditions ?? <Condition>[ConditionStub()],
    nonStandardConditions:
        nonStandardConditions ?? <Condition>[ConditionStub()],
    canEdit: canEdit,
    onAddNonStandard: onAddNonStandard ?? () {},
    initialPageStandard: initialPageStandard,
    initialPageNonStandard: initialPageNonStandard,
  );
}

void main() {
  group("SubLimitConditionsViewModel", () {
    test("initial state should be loaded", () {
      final viewModel = buildViewModel();

      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      expect(viewModel.initialPageStandard, 0);
      expect(viewModel.initialPageNonStandard, 0);
    });

    test("initial page values should be assigned from constructor", () {
      final viewModel = buildViewModel(
        initialPageStandard: 2,
        initialPageNonStandard: 3,
      );

      expect(viewModel.initialPageStandard, 2);
      expect(viewModel.initialPageNonStandard, 3);
    });

    group("canDeleteNonStandard", () {
      test("returns false when canEdit is false", () {
        final viewModel = buildViewModel(
          canEdit: false,
          nonStandardConditions: <Condition>[
            ConditionStub(facilityMasterId: 0),
          ],
        );

        expect(viewModel.canDeleteNonStandard(0), isFalse);
      });

      test("returns true when canEdit is true and facilityMasterId is null",
          () {
        final viewModel = buildViewModel(
          nonStandardConditions: <Condition>[
            ConditionStub(),
          ],
        );

        expect(viewModel.canDeleteNonStandard(0), isTrue);
      });

      test("returns true when canEdit is true and facilityMasterId is 0", () {
        final viewModel = buildViewModel(
          nonStandardConditions: <Condition>[
            ConditionStub(facilityMasterId: 0),
          ],
        );

        expect(viewModel.canDeleteNonStandard(0), isTrue);
      });

      test(
          "returns false when canEdit is true and facilityMasterId is non-zero",
          () {
        final viewModel = buildViewModel(
          nonStandardConditions: <Condition>[
            ConditionStub(facilityMasterId: 123),
          ],
        );

        expect(viewModel.canDeleteNonStandard(0), isFalse);
      });
    });

    test("addNonStandard triggers callback and keeps loaded state", () {
      var called = 0;

      final viewModel = buildViewModel(
        onAddNonStandard: () {
          called++;
        },
      )..addNonStandard();

      expect(called, 1);
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    group("changeStandardConditionSelect", () {
      test("when value=true sets isSelected=true and resets amended/waivedOff",
          () {
        final standard = ConditionStub(
          isSelected: false,
          isAmended: true,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          standardConditions: <Condition>[standard],
        )..changeStandardConditionSelect(0, value: true);

        expect(standard.isSelected, isTrue);
        expect(standard.isAmended, isFalse);
        expect(standard.isWaivedOff, isFalse);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      test("when value=false only updates isSelected", () {
        final standard = ConditionStub(
          isSelected: true,
          isAmended: true,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          standardConditions: <Condition>[standard],
        )..changeStandardConditionSelect(0, value: false);

        expect(standard.isSelected, isFalse);
        expect(standard.isAmended, isTrue);
        expect(standard.isWaivedOff, isTrue);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });
    });

    group("changeAmendStandardConditionSelect", () {
      test("when value=true sets amended=true and resets waivedOff/selected",
          () {
        final standard = ConditionStub(
          isSelected: true,
          isAmended: false,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          standardConditions: <Condition>[standard],
        )..changeAmendStandardConditionSelect(0, value: true);

        expect(standard.isAmended, isTrue);
        expect(standard.isWaivedOff, isFalse);
        expect(standard.isSelected, isFalse);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      test("when value=false only updates amended", () {
        final standard = ConditionStub(
          isSelected: true,
          isAmended: true,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          standardConditions: <Condition>[standard],
        )..changeAmendStandardConditionSelect(0, value: false);

        expect(standard.isAmended, isFalse);
        expect(standard.isWaivedOff, isTrue);
        expect(standard.isSelected, isTrue);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });
    });

    group("changeWaivedOffStandardConditionSelect", () {
      test("when value=true sets waivedOff=true and resets amended/selected",
          () {
        final standard = ConditionStub(
          isSelected: true,
          isAmended: true,
          isWaivedOff: false,
        );

        final viewModel = buildViewModel(
          standardConditions: <Condition>[standard],
        )..changeWaivedOffStandardConditionSelect(0, value: true);

        expect(standard.isWaivedOff, isTrue);
        expect(standard.isAmended, isFalse);
        expect(standard.isSelected, isFalse);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      test("when value=false only updates waivedOff", () {
        final standard = ConditionStub(
          isSelected: true,
          isAmended: true,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          standardConditions: <Condition>[standard],
        )..changeWaivedOffStandardConditionSelect(0, value: false);

        expect(standard.isWaivedOff, isFalse);
        expect(standard.isAmended, isTrue);
        expect(standard.isSelected, isTrue);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });
    });

    group("changeNonStandardConditionSelect", () {
      test("when value=true sets isSelected=true and resets amended/waivedOff",
          () {
        final nonStandard = ConditionStub(
          isSelected: false,
          isAmended: true,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          nonStandardConditions: <Condition>[nonStandard],
        )..changeNonStandardConditionSelect(0, value: true);

        expect(nonStandard.isSelected, isTrue);
        expect(nonStandard.isAmended, isFalse);
        expect(nonStandard.isWaivedOff, isFalse);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      test("when value=false only updates isSelected", () {
        final nonStandard = ConditionStub(
          isSelected: true,
          isAmended: true,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          nonStandardConditions: <Condition>[nonStandard],
        )..changeNonStandardConditionSelect(0, value: false);

        expect(nonStandard.isSelected, isFalse);
        expect(nonStandard.isAmended, isTrue);
        expect(nonStandard.isWaivedOff, isTrue);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });
    });

    group("changeAmendNonStandardConditionSelect", () {
      test("when value=true sets amended=true and resets waivedOff/selected",
          () {
        final nonStandard = ConditionStub(
          isSelected: true,
          isAmended: false,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          nonStandardConditions: <Condition>[nonStandard],
        )..changeAmendNonStandardConditionSelect(0, value: true);

        expect(nonStandard.isAmended, isTrue);
        expect(nonStandard.isWaivedOff, isFalse);
        expect(nonStandard.isSelected, isFalse);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      test("when value=false only updates amended", () {
        final nonStandard = ConditionStub(
          isSelected: true,
          isAmended: true,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          nonStandardConditions: <Condition>[nonStandard],
        )..changeAmendNonStandardConditionSelect(0, value: false);

        expect(nonStandard.isAmended, isFalse);
        expect(nonStandard.isWaivedOff, isTrue);
        expect(nonStandard.isSelected, isTrue);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });
    });

    group("changeWaivedOffNonStandardConditionSelect", () {
      test("when value=true sets waivedOff=true and resets amended/selected",
          () {
        final nonStandard = ConditionStub(
          isSelected: true,
          isAmended: true,
          isWaivedOff: false,
        );

        final viewModel = buildViewModel(
          nonStandardConditions: <Condition>[nonStandard],
        )..changeWaivedOffNonStandardConditionSelect(0, value: true);

        expect(nonStandard.isWaivedOff, isTrue);
        expect(nonStandard.isAmended, isFalse);
        expect(nonStandard.isSelected, isFalse);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });

      test("when value=false only updates waivedOff", () {
        final nonStandard = ConditionStub(
          isSelected: true,
          isAmended: true,
          isWaivedOff: true,
        );

        final viewModel = buildViewModel(
          nonStandardConditions: <Condition>[nonStandard],
        )..changeWaivedOffNonStandardConditionSelect(0, value: false);

        expect(nonStandard.isWaivedOff, isFalse);
        expect(nonStandard.isAmended, isTrue);
        expect(nonStandard.isSelected, isTrue);
        expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
      });
    });

    group("removeNonStandard (optional)", () {
      test(
        "removes item from list if repository singleton is test-safe",
        () async {
          final nonStandardConditions = <Condition>[
            ConditionStub(),
            ConditionStub(),
          ];

          final viewModel = buildViewModel(
            nonStandardConditions: nonStandardConditions,
          );

          await viewModel.removeNonStandard(0, facilityConditionId: 1);
          expect(viewModel.nonStandardConditions.length, 1);
          expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
        },
        skip: true,
      );
    });
  });
}
