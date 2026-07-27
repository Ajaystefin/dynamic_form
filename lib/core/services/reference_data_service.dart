import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/home_repository.dart";

/// Reference Data Service
///
/// Manages reference data retrieval and caching using local storage
/// and API sources. Missing reference data is loaded from the API,
/// cached locally, and made available in memory for reuse.
class ReferenceDataService {
  /// Returns the singleton instance of the service.
  factory ReferenceDataService() => _instance;

  ReferenceDataService._internal();
  static ReferenceDataService _instance = ReferenceDataService._internal();

  /// Returns the singleton instance for testing.
  @visibleForTesting
  static ReferenceDataService get overrideInstance => _instance;

  /// Overrides the singleton instance for testing.
  @visibleForTesting
  static set overrideInstance(ReferenceDataService instance) {
    _instance = instance;
  }

  /// Cached reference data indexed by reference key.
  Map<String, List<Reference>> referenceData = {};

  /// Stores reference data type IDs indexed by reference key.
  ///
  /// Stores referenceDataTypeId per key — populated in getFromRefrenceList()
  /// from element.id = responseData[\x].referenceDataTypeId
  Map<String, int> referenceTypeIds = {};

  // Dependencies for testing
  LocalStorageService? _localStorageService;
  HomeRepository? _homeRepository;
  bool _skipStorageForTesting = false;

  /// Configures dependencies used during testing.
  void setDependencies({
    LocalStorageService? localStorageService,
    HomeRepository? homeRepository,
    bool skipStorageForTesting = false,
  }) {
    _localStorageService = localStorageService;
    _homeRepository = homeRepository;
    _skipStorageForTesting = skipStorageForTesting;
  }

  /// Returns the configured local storage service or the default instance.
  LocalStorageService get _getLocalStorageService =>
      _localStorageService ?? LocalStorageService();

  /// Returns the configured repository or the default instance.
  HomeRepository get _getHomeRepository => _homeRepository ?? HomeRepository();

  /// Retrieves reference data for the specified keys from cache,
  /// local storage, or the API.
  Future<Map<String, List<Reference>>> getReferenceData(
    List<String> keys,
  ) async {
    try {
      final missingKeys = await getFromLocalStorage(keys);
      // Fetch reference data from Local storage
      if (missingKeys.isEmpty) {
        return referenceData;
      }
      // Fetch reference data from API
      await getFromAPI(missingKeys);
      logger.i(referenceData);
      return referenceData;
    } on Object {
      rethrow;
    }
  }

  /// Clears cached reference data for the specified key.
  ///
  /// NEW — removes a key from in-memory map AND local storage so the next
  /// getReferenceData() call is forced to fetch fresh data from the API.
  /// Use this after a save to ensure the table shows the newly saved row.
  Future<void> clearCache(String key) async {
    referenceData.remove(key);
    try {
      await _getLocalStorageService.delete(
        LocalStorageBoxes.referenceData,
        key,
      );
    } on Object catch (_) {}
  }

  /// Retrieves missing reference data from the API.
  Future<void> getFromAPI(List<String> missingKeys) async {
    try {
      final response = await _getHomeRepository.getReferenceData(missingKeys);
      final referenceDataTypeList = response;

      if (referenceDataTypeList.isNotEmpty) {
        // for loop for checking missing keys
        for (final key in missingKeys) {
          // for loop for checking reference data list
          getFromRefrenceList(referenceDataTypeList, key);
        }
      }
    } on Object catch (e) {
      throw Exception("Error fetching reference data: $e");
    }
  }

  /// Loads reference data for a specific key from the API response.
  void getFromRefrenceList(
    List<ReferenceType> referenceDataTypeList,
    String key,
  ) {
    for (final element in referenceDataTypeList) {
      if (element.name == key) {
        // Capture referenceDataTypeId for callers that need it for save
        if (element.id != null) {
          referenceTypeIds[key] = element.id!;
        }

        referenceData[key] = element.references ?? [];

        final mapReferenceData = <int, dynamic>{
          for (final data in (element.references ?? <Reference>[]))
            if (data.id != null) data.id!: data.toJson(),
        };

        if (!_skipStorageForTesting) {
          _getLocalStorageService.put(
            LocalStorageBoxes.referenceData,
            key,
            mapReferenceData,
          );
        }
      }
    }
  }

  /// Retrieves reference data from local storage and returns
  /// any keys that are not found.
  Future<List<String>> getFromLocalStorage(List<String> keys) async {
    final missingKeys = <String>[];
    for (final key in keys) {
      try {
        final data = await _getLocalStorageService.get(
          LocalStorageBoxes.referenceData,
          key,
        );
        logger.i("data: $data");
        if (data != null) {
          final dataList = <Reference>[];
          data.values.map((value) {
            dataList.add(
              Reference.fromJson((value as Map).cast<String, dynamic>()),
            );
          }).toList();
          referenceData[key] = dataList;
        } else {
          missingKeys.add(key);
        }
      } on Object catch (_) {
        missingKeys.add(key);
      }
    }
    return missingKeys;
  }
}
