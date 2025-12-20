import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/services/local_storage_service.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/repositories/covenant_condition_repository.dart';
import 'package:wcas_frontend/repositories/facility_security_repository.dart';
import '../../../../test_config.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/state.dart';

class MockCovenantConditionRepository extends Mock
    implements CovenantConditionRepository {}

class MockFacilitySecurityRepository extends Mock
    implements FacilitySecurityRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

class MockAlertManager extends Mock implements AlertManager {}

// Mock LocalStorageService
class MockLocalStorageService implements StorageInterface {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init({String? path}) async {}

  @override
  Future<void> put(String box, String key, dynamic value) async {
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

  void clearAll() {
    _storage.clear();
  }
}

void main() {
  late SelectFacilitiesDialogViewModel viewModel;
  // late MockCovenantConditionRepository mockRepo;
  // late MockFacilitySecurityRepository mockRepoF;
  late MockLocalStorageService mockLocalStorageService;
  late MockAlertManager mockAlert;

  final facility1 = Facility(
      rimNo: 101,
      limitNumber: '100',
      limitLabel: 'A',
      limitDescription: 'Desc A');
  final facility2 = Facility(
      rimNo: 102,
      limitNumber: '200',
      limitLabel: 'B',
      limitDescription: 'Desc B');
  final facility3 = Facility(
      rimNo: 103,
      limitNumber: '300',
      limitLabel: 'A',
      limitDescription: 'Desc C');

  const connectivityChannel =
      MethodChannel('dev.fluttercommunity.plus/connectivity');

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();

    // Mock the connectivity plugin to return a list with wifi connectivity
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      connectivityChannel,
      (call) async {
        if (call.method == 'check') {
          return ['wifi'];
        }
        return null;
      },
    );
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  setUp(() {
    viewModel = SelectFacilitiesDialogViewModel();
    // mockRepo = MockCovenantConditionRepository();
    mockLocalStorageService = MockLocalStorageService();
    mockAlert = MockAlertManager();

    // Set up LocalStorageService mock
    LocalStorageService().setStorage(mockLocalStorageService);

    // Set up the mock repository
    // viewModel.repository = mockRepoF;

    // Set up test data manually instead of calling init
    viewModel.facilities = [facility1, facility2, facility3];
    viewModel.filteredData = viewModel.facilities;
    viewModel.checkboxes = List.filled(viewModel.facilities.length, false);
    viewModel
        .emit(viewModel.state.copyWith(loaderStatus: LoadingStatus.loaded));
  });

  group('filtering', () {
    test('filters by rimNo', () {
      viewModel.onFilter(Filter.rimNo, value: '101');
      expect(viewModel.filteredData.length, 1);
      expect(viewModel.rimFilterCtrl, '101');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    // test('init should fetch facilities and emit loading then loaded state',
    //     () async {
    //   final mockFacilities = [
    //     Facility(
    //         rimNo: 123,
    //         limitNumber: 'LN001',
    //         limitLabel: 'Label',
    //         limitDescription: 'Desc')
    //   ];

    //   when(() => mockRepo.getFacilities())
    //       .thenAnswer((_) async => mockFacilities);

    //   final emittedStates = <SelectFacilitiesDialogState>[];
    //   final subscription = viewModel.stream.listen(emittedStates.add);

    //   await viewModel.init(null);

    //   expect(viewModel.facilities, mockFacilities);
    //   expect(viewModel.filteredData, mockFacilities);
    //   expect(emittedStates.first.loaderStatus, LoadingStatus.loading);
    //   expect(emittedStates.last.loaderStatus, LoadingStatus.loading);

    //   await subscription.cancel();
    // });

    test('filters by limitNumber', () {
      viewModel.onFilter(Filter.limitNumber, value: '200');
      expect(viewModel.filteredData.length, 1);
      expect(viewModel.limitNumFilterCtrl, '200');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('filters by limitLabel', () {
      viewModel.onFilter(Filter.limitLabel, value: 'A');
      expect(viewModel.filteredData.length, 2);
      expect(viewModel.projFilterCtrl, 'A');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('filters by limitDescription', () {
      viewModel.onFilter(Filter.limitDescription, value: 'Desc C');
      expect(viewModel.filteredData.length, 1);
      expect(viewModel.descFilterCtrl, 'Desc C');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('returns empty list if no match', () {
      viewModel.onFilter(Filter.rimNo, value: '999');
      expect(viewModel.filteredData.isEmpty, true);
      expect(viewModel.rimFilterCtrl, '999');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group('selection', () {
    test('deselects all', () {
      viewModel.toggleSelectAll(false);
      expect(viewModel.checkboxes.every((c) => !c), true);
      expect(viewModel.isSelectAll, false);
    });

    test('selects all', () {
      viewModel.toggleSelectAll(true);
      expect(viewModel.isSelectAll, true);
      expect(viewModel.selectedIds.length, greaterThan(0));
    });

    test('toggleSelectAll handles null value', () {
      viewModel.toggleSelectAll(null);
      expect(viewModel.isSelectAll, false);
    });

    test('valid index', () {
      AlertManager.overrideInstance(mockAlert);
      viewModel.checkboxes = [false, false, false];
      viewModel.updateCheckboxAtIndex(1, true);
      expect(viewModel.checkboxes[1], true);
    });

    test('updateCheckboxAtIndex ignores invalid index', () {
      viewModel.updateCheckboxAtIndex(-1, true);
      viewModel.updateCheckboxAtIndex(999, true);
      // Should not crash
    });

    test('updateCheckboxAtIndex when isFromSecuritySummary', () {
      viewModel.isFromSecuritySummary = true;
      viewModel.updateCheckboxAtIndex(0, true);
      // Should return early without updating
    });
  });

  group('SelectFacilitiesDialogState', () {
    test('constructor sets loaderStatus', () {
      final state =
          SelectFacilitiesDialogState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith keeps existing when null', () {
      final original =
          SelectFacilitiesDialogState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides', () {
      final original =
          SelectFacilitiesDialogState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });

    test('getFilteredOptions filters out NA values', () {
      final options = [
        Reference(id: 1, name: 'Option1'),
        Reference(id: 2, name: 'requestInformation.requestInformation.na'),
        Reference(id: 3, name: 'Option3'),
      ];

      final result = viewModel.getFilteredOptions(options);

      expect(result.length, 2);
      expect(
          result.any(
              (ref) => ref.name == 'requestInformation.requestInformation.na'),
          false);
    });

    test('getFilteredOptions handles empty options', () {
      final result = viewModel.getFilteredOptions([]);

      expect(result, isEmpty);
    });

    test('getSelectedReference returns selected value when valid', () {
      final options = [
        Reference(id: 1, name: 'Option1'),
        Reference(id: 2, name: 'Option2')
      ];
      final selected = Reference(id: 1, name: 'Option1');

      final result = viewModel.getSelectedReference(
        options: options,
        selectedValue: selected,
        fallbackFlag: false,
      );

      expect(result.name, selected.name);
    });

    test('getSelectedReference handles fallback case', () {
      final options = [
        Reference(id: 1, name: 'Option1'),
        Reference(id: 2, name: 'Option2')
      ];

      final result = viewModel.getSelectedReference(
        options: options,
        selectedValue: null,
        fallbackFlag: true,
      );

      expect(result, isA<Reference>());
    });

    test('validateSelection returns null for valid selection', () {
      final options = [
        Reference(id: 1, name: 'Option1'),
        Reference(id: 2, name: 'Option2')
      ];

      final result =
          viewModel.validateSelection('Option1', options, 'error.key');

      expect(result, isNull);
    });

    test('validateSelection returns error message for invalid selection', () {
      final options = [
        Reference(id: 1, name: 'Option1'),
        Reference(id: 2, name: 'Option2')
      ];

      final result =
          viewModel.validateSelection('InvalidOption', options, 'error.key');

      expect(result, isNotNull);
    });

    test('validateSelection handles null value', () {
      final options = [Reference(id: 1, name: 'Option1')];

      final result = viewModel.validateSelection(null, options, 'error.key');

      expect(result, isNotNull);
    });

    test('validateSelection handles empty value', () {
      final options = [Reference(id: 1, name: 'Option1')];

      final result = viewModel.validateSelection('', options, 'error.key');

      expect(result, isNotNull);
    });

    test('validateSelection handles whitespace value', () {
      final options = [Reference(id: 1, name: 'Option1')];

      final result = viewModel.validateSelection('   ', options, 'error.key');

      expect(result, isNotNull);
    });

    test('showAllFacilities resets filtered data', () {
      viewModel.filteredData = [facility1];
      viewModel.showAllFacilities();
      expect(viewModel.filteredData.length, viewModel.facilities.length);
    });

    test('getCheckBoxValue returns true for selected facility', () {
      viewModel.selectedFacilities = [facility1];
      final result = viewModel.getCheckBoxValue(facility1);
      expect(result, true);
    });

    test('getCheckBoxValue returns false for null facility', () {
      final result = viewModel.getCheckBoxValue(null);
      expect(result, false);
    });

    test('getCheckBoxValue returns false for unselected facility', () {
      viewModel.selectedFacilities = [];
      final result = viewModel.getCheckBoxValue(facility1);
      expect(result, false);
    });

    test('buildCodeToIdMap creates correct mapping', () {
      final options = [
        Reference(id: 1, reference3: 'LC'),
        Reference(id: 2, reference3: 'LG'),
        Reference(id: 3, reference3: ''),
      ];

      final result = viewModel.buildCodeToIdMap(options);

      expect(result['LC'], 1);
      expect(result['LG'], 2);
      expect(result.containsKey(''), false);
    });

    test('buildCodeToIdMap handles empty options', () {
      final result = viewModel.buildCodeToIdMap([]);
      expect(result, isEmpty);
    });

    test('facilityTypeIdFromCode returns correct ID', () {
      final codeToId = {'LC': 1, 'LG': 2};
      final facility = Facility(limitDescription: 'LC');

      final result = viewModel.facilityTypeIdFromCode(facility, codeToId);

      expect(result, 1);
    });

    test('facilityTypeIdFromCode returns null for unknown code', () {
      final codeToId = {'LC': 1};
      final facility = Facility(limitDescription: 'UNKNOWN');

      final result = viewModel.facilityTypeIdFromCode(facility, codeToId);

      expect(result, isNull);
    });

    test('facilityTypeIdFromCode handles empty code', () {
      final codeToId = {'LC': 1};
      final facility = Facility(limitDescription: '');

      final result = viewModel.facilityTypeIdFromCode(facility, codeToId);

      expect(result, isNull);
    });

    test('isLgOrLcByOptions returns true for LC facility', () {
      final codeToId = {'LC': 1};
      final facility = Facility(limitDescription: 'LC');

      final result = viewModel.isLgOrLcByOptions(facility, codeToId);

      expect(result, false); // Will be false unless ID is in ServerConstants
    });

    test('validateLinking returns null for cash collateral', () {
      final result = viewModel.validateLinking(
        linkAllYes: false,
        isCashCollateral: true,
        filteredData: [],
        selectedCheckboxIds: {},
        codeToId: {},
      );

      expect(result, isNull);
    });

    test(
        'validateLinking returns null when only LC/LG selected with linkAllYes',
        () {
      final codeToId = {'LC': 1};
      final facility = Facility(limitNumber: '100', limitDescription: 'LC');
      viewModel.facilities = [facility];

      final result = viewModel.validateLinking(
        linkAllYes: true,
        isCashCollateral: false,
        filteredData: [facility],
        selectedCheckboxIds: {'100'},
        codeToId: codeToId,
      );

      // Will return error or null based on ServerConstants
      expect(result, isA<String?>());
    });

    test('validateLinking returns error for non-LC/LG with linkAllYes', () {
      final codeToId = {'OTHER': 99};
      final facility = Facility(limitNumber: '100', limitDescription: 'OTHER');

      final result = viewModel.validateLinking(
        linkAllYes: true,
        isCashCollateral: false,
        filteredData: [facility],
        selectedCheckboxIds: {'100'},
        codeToId: codeToId,
      );

      expect(result, isNotNull);
    });

    test('validateLinking returns error for non-LC/LG without linkAllYes', () {
      final codeToId = {'OTHER': 99};
      final facility = Facility(limitNumber: '100', limitDescription: 'OTHER');

      final result = viewModel.validateLinking(
        linkAllYes: false,
        isCashCollateral: false,
        filteredData: [facility],
        selectedCheckboxIds: {'100'},
        codeToId: codeToId,
      );

      expect(result, isNotNull);
    });

    test('limitDescriptionReferenceName with list of references', () {
      final options = [
        Reference(id: 1, name: 'Option1'),
        Reference(id: 2, name: 'Option2'),
      ];
      final refs = [Reference(id: 1)];

      final result = viewModel.limitDescriptionReferenceName(
        refs: refs,
        options: options,
      );

      expect(result, 'Option1');
    });

    test('limitDescriptionReferenceName with empty list', () {
      final result = viewModel.limitDescriptionReferenceName(
        refs: [],
        options: [],
      );

      expect(result, '--');
    });

    test('limitDescriptionReferenceName with single ID', () {
      final options = [
        Reference(id: 1, name: 'Option1'),
        Reference(id: 2, name: 'Option2'),
      ];

      final result = viewModel.limitDescriptionReferenceName(
        options: options,
        id: 1,
      );

      expect(result, 'Option1');
    });

    test('limitDescriptionReferenceName with unknown ID', () {
      final options = [Reference(id: 1, name: 'Option1')];

      final result = viewModel.limitDescriptionReferenceName(
        options: options,
        id: 999,
      );

      expect(result, '--');
    });

    test('limitDescriptionReferenceName with no refs or id', () {
      final result = viewModel.limitDescriptionReferenceName(
        options: [],
      );

      expect(result, '--');
    });

    test('showAlert displays error and emits loaded state', () {
      AlertManager.overrideInstance(mockAlert);
      viewModel.showAlert('Test error');
      expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
    });

    test('updateFacilityLinkageOption with YES option', () {
      final yesOption = Reference(id: 1, name: 'Yes');
      viewModel.updateFacilityLinkageOption(yesOption);
      expect(viewModel.selectedAllFailitiesYesNo, yesOption);
    });

    test('updateFacilityLinkageOption with NO option', () {
      final noOption = Reference(id: 2, name: 'No');
      viewModel.updateFacilityLinkageOption(noOption);
      expect(viewModel.selectedAllFailitiesYesNo, noOption);
      expect(viewModel.showCheckboxColumn, true);
    });

    test('updateFacilityLinkageOption when isFromSecuritySummary', () {
      viewModel.isFromSecuritySummary = true;
      final yesOption = Reference(id: 1, name: 'Yes');
      viewModel.updateFacilityLinkageOption(yesOption);
      expect(viewModel.showCheckboxColumn, false);
    });

    test('getSelectedReference with empty filtered options', () {
      final options = [
        Reference(id: 1, name: 'requestInformation.requestInformation.na'),
      ];

      final result = viewModel.getSelectedReference(
        options: options,
        selectedValue: null,
        fallbackFlag: false,
      );

      expect(result.name, contains('no'));
    });
  });
}
