import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/repositories/home_repository.dart";

class MockReferenceDataService implements ReferenceDataService {
  Map<String, List<Reference>> _mockData = {};
  Exception? _mockException;

  @override
  Map<String, List<Reference>> referenceData = {};

  @override
  Map<String, int> referenceTypeIds = {};

  @override
  Future<void> clearCache(String key) async {
    referenceData.remove(key);
    referenceTypeIds.remove(key);
  }

  void setMockReferenceData(Map<String, List<Reference>> data) {
    _mockData = data;
  }

  void setMockException(Exception exception) {
    _mockException = exception;
  }

  void clearMockData() {
    _mockData.clear();
    _mockException = null;
  }

  @override
  Future<Map<String, List<Reference>>> getReferenceData(
    List<String> keys,
  ) async {
    if (_mockException != null) {
      throw _mockException!;
    }

    final Map<String, List<Reference>> result = {};
    for (final String key in keys) {
      result[key] = _mockData[key] ?? [];
    }
    return result;
  }

  @override
  void setDependencies({
    LocalStorageService? localStorageService,
    HomeRepository? homeRepository,
    bool skipStorageForTesting = false,
  }) {
    // Mock implementation - do nothing
  }

  @override
  Future<void> getFromAPI(List<String> missingKeys) async {
    // Mock implementation - do nothing
  }

  @override
  void getFromRefrenceList(List referenceDataTypeList, String key) {
    // Mock implementation - do nothing
  }

  @override
  Future<List<String>> getFromLocalStorage(List<String> keys) async {
    // Mock implementation - return empty list
    return [];
  }

  // @override
  // Future<Map<String, List<Reference>>> getFromAPI2(List<String> keys) async {
  //   return <String, List<Reference>>{}; // - Correct type
//   }
}
