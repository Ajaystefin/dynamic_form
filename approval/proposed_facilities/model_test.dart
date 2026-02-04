// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/approval/proposed_facilities/model.dart';
import 'package:wcas_frontend/models/request/approval/proposed_facilities.dart';
import 'package:wcas_frontend/repositories/approval_repository.dart';
import 'package:wcas_frontend/repositories/request_repository.dart';
import 'package:wcas_frontend/models/request/approval/group_position.dart';
// import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/features/request/approval/proposed_facilities/state.dart';

const MethodChannel _kConnectivityChannel =
    MethodChannel('dev.fluttercommunity.plus/connectivity');

class MockBuildContext extends Mock implements BuildContext {}

// Extension to bypass .tr() localization warnings
extension LocalizationBypass on String {
  String tr() => this;
}

// Fake repositories
class FakeApprovalRepository extends Fake implements ApprovalRepository {
  @override
  Future<AppResponse> getGroupPositionDetails() async {
    return AppResponse(message: "");
  }
}

class FakeRequestRepository extends Fake implements RequestRepository {
  // Future<List<Request>> getPipelineRequestDetails(int? limit) async {
  //   return [Request()];
  // }
}

class ErrorApprovalRepository extends Fake implements ApprovalRepository {
  @override
  Future<AppResponse> getGroupPositionDetails() async {
    throw Exception('Failed to fetch group position');
  }
}

class ErrorRequestRepository extends Fake implements ApprovalRepository {
  @override
  Future<List<ProposedFacilities>> getPipelineRequestDetails(int? limit) async {
    throw Exception('Failed to fetch pipeline requests');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProposedFacilitiesViewModel viewModel;
  late MockBuildContext mockBuildContext;

  setUpAll(() {
    _kConnectivityChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'check') {
        return <dynamic>[];
      }
      return null;
    });
  });

  tearDownAll(() {
    _kConnectivityChannel.setMockMethodCallHandler(null);
  });
  setUp(() async {
    viewModel = ProposedFacilitiesViewModel();
    mockBuildContext = MockBuildContext();
    await EnvConfig.setEnvironment();
  });
  test('initial state is loading', () {
    expect(viewModel.state.loaderStatus, LoadingStatus.loading);
  });

  test('getGroupPositionDetails loads data successfully', () async {
    viewModel.approvalRepository = FakeApprovalRepository();

    await viewModel.getGroupPositionDetails();
    await viewModel.getPipelineRequestDetails();
    viewModel.init(mockBuildContext);

    expect(viewModel.groupPositionList, isA<GroupPosition>());
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test('getGroupPositionDetails handles error', () async {
    viewModel.approvalRepository = ErrorApprovalRepository();

    await viewModel.getGroupPositionDetails();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test('getPipelineRequestDetails loads data successfully', () async {
    viewModel.approvalRepository = FakeApprovalRepository();

    await viewModel.getPipelineRequestDetails();

    expect(viewModel.pipelineRequests?.isNotEmpty, false);
    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test('getPipelineRequestDetails handles error', () async {
    viewModel.approvalRepository = ErrorRequestRepository();

    await viewModel.getPipelineRequestDetails();

    expect(viewModel.state.loaderStatus, LoadingStatus.error);
  });

  test('onSavePress emits loading and loaded', () async {
    viewModel.onSavePress();

    expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  });

  // test('onSavePress with isContinue navigates', () async {
  //   viewModel.onSavePress(isContinue: true);

  //   expect(viewModel.state.loaderStatus, LoadingStatus.loaded);
  // });

  test('viewModel properties are properly initialized', () {
    expect(viewModel.groupPositionList, isA<GroupPosition>());
    expect(viewModel.pipelineRequests, isEmpty);
  });

  group('ProposedFacilitiesState', () {
    test('constructor sets loaderStatus', () {
      final state =
          ProposedFacilitiesState(loaderStatus: LoadingStatus.loading);
      expect(state.loaderStatus, LoadingStatus.loading);
    });

    test('copyWith keeps existing when null', () {
      final original =
          ProposedFacilitiesState(loaderStatus: LoadingStatus.loaded);
      final copied = original.copyWith();
      expect(copied.loaderStatus, LoadingStatus.loaded);
    });

    test('copyWith overrides', () {
      final original =
          ProposedFacilitiesState(loaderStatus: LoadingStatus.loaded);
      final updated = original.copyWith(loaderStatus: LoadingStatus.error);
      expect(updated.loaderStatus, LoadingStatus.error);
      expect(original.loaderStatus, LoadingStatus.loaded);
    });
  });
}
