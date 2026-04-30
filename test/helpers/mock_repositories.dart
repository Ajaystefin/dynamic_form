import "package:wcas_frontend/repositories/common_repository.dart";
import "package:wcas_frontend/repositories/profitability_repository.dart";
import "package:wcas_frontend/repositories/project_repository.dart";
import "package:wcas_frontend/repositories/request_repository.dart";

class RepositoryTestHelper {
  static RequestRepository? _mockRequestRepository;
  static ProjectRepository? _mockProjectRepository;
  static ProfitabilityRepository? _mockProfitabilityRepository;
  static CommonRepository? _mockCommonRepository;

  static void overrideRequestRepository(RequestRepository mockRepository) {
    _mockRequestRepository = mockRepository;
  }

  static void overrideProjectRepository(ProjectRepository mockRepository) {
    _mockProjectRepository = mockRepository;
  }

  static void overrideProfitabilityRepository(
    ProfitabilityRepository mockRepository,
  ) {
    _mockProfitabilityRepository = mockRepository;
  }

  static void overrideCommonRepository(CommonRepository mockRepository) {
    _mockCommonRepository = mockRepository;
  }

  static void resetAll() {
    _mockRequestRepository = null;
    _mockProjectRepository = null;
    _mockProfitabilityRepository = null;
    _mockCommonRepository = null;
  }
}

// Extension to override RequestRepository.instance
extension RequestRepositoryTestExtension on RequestRepository {
  static RequestRepository get testableInstance =>
      RepositoryTestHelper._mockRequestRepository ?? RequestRepository.instance;
}

// Extension to override ProjectRepository.instance
extension ProjectRepositoryTestExtension on ProjectRepository {
  static ProjectRepository get testableInstance =>
      RepositoryTestHelper._mockProjectRepository ?? ProjectRepository.instance;
}

// Extension to override ProfitabilityRepository.instance
extension ProfitabilityRepositoryTestExtension on ProfitabilityRepository {
  static ProfitabilityRepository get testableInstance =>
      RepositoryTestHelper._mockProfitabilityRepository ??
      ProfitabilityRepository.instance;
}

// Extension to override CommonRepository.instance
extension CommonRepositoryTestExtension on CommonRepository {
  static CommonRepository get testableInstance =>
      RepositoryTestHelper._mockCommonRepository ?? CommonRepository.instance;
}
