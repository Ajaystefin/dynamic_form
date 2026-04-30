import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/home_repository.dart";

class ReferenceDataService {
  factory ReferenceDataService() => _instance;

  ReferenceDataService._internal();
  static ReferenceDataService _instance = ReferenceDataService._internal();

  @visibleForTesting
  static void overrideInstance(ReferenceDataService instance) {
    _instance = instance;
  }

  Map<String, List<Reference>> referenceData = {};

  // Stores referenceDataTypeId per key — populated in getFromRefrenceList()
  // from element.id = responseData[x].referenceDataTypeId
  Map<String, int> referenceTypeIds = {};

  // Dependencies for testing
  LocalStorageService? _localStorageService;
  HomeRepository? _homeRepository;
  bool _skipStorageForTesting = false;

  /// Set dependencies for testing
  void setDependencies({
    LocalStorageService? localStorageService,
    HomeRepository? homeRepository,
    bool skipStorageForTesting = false,
  }) {
    _localStorageService = localStorageService;
    _homeRepository = homeRepository;
    _skipStorageForTesting = skipStorageForTesting;
  }

  /// Get LocalStorageService instance
  LocalStorageService get _getLocalStorageService =>
      _localStorageService ?? LocalStorageService();

  /// Get HomeRepository instance
  HomeRepository get _getHomeRepository => _homeRepository ?? HomeRepository();

  Future<Map<String, List<Reference>>> getReferenceData(
    List<String> keys,
  ) async {
    try {
      final missingKeys = await getFromLocalStorage(keys);
      // Fetch reference data from Local storage
      if (missingKeys.isEmpty) return referenceData;
      // Fetch reference data from API
      await getFromAPI(missingKeys);
      logger.i(referenceData);
      return referenceData;
    } catch (e) {
      rethrow;
    }
  }

  // NEW — removes a key from in-memory map AND local storage so the next
  // getReferenceData() call is forced to fetch fresh data from the API.
  // Use this after a save to ensure the table shows the newly saved row.
  Future<void> clearCache(String key) async {
    referenceData.remove(key);
    try {
      await _getLocalStorageService.delete(
        LocalStorageBoxes.referenceData,
        key,
      );
    } catch (_) {}
  }

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
    } catch (e) {
      throw Exception("Error fetching reference data: $e");
    }
  }

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
      } catch (_) {
        missingKeys.add(key);
      }
    }
    return missingKeys;
  }
}
