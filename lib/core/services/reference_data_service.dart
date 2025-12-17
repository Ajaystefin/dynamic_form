import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/local_storage_service.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/admin/reference_type.dart';
import 'package:wcas_frontend/repositories/home_repository.dart';

class ReferenceDataService {
  static ReferenceDataService _instance = ReferenceDataService._internal();

  factory ReferenceDataService() => _instance;

  ReferenceDataService._internal();

  @visibleForTesting
  static void overrideInstance(ReferenceDataService instance) {
    _instance = instance;
  }

  Map<String, List<Reference>> referenceData = {};

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
      List<String> keys) async {
    try {
      List<String> missingKeys = [];
      // Fetch reference data from Local storage
      missingKeys = await getFromLocalStorage(keys);
      if (missingKeys.isEmpty) return referenceData;
      // Fetch reference data from API
      await getFromAPI(missingKeys);
      logger.i(referenceData);
      return referenceData;
    } catch (e) {
      rethrow;
    }
  }

  // Future<Map<String, List<Reference>>> getFromAPI2(List<String> keys) async {
  //   try {
  //     final response = await _getHomeRepository.getReferenceData(keys);
  //     List<ReferenceType> referenceDataTypeList = response;

  //     if (referenceDataTypeList.isNotEmpty) {
  //       for (String key in keys) {
  //         getFromRefrenceList(referenceDataTypeList, key);
  //       }
  //     }
  //     return referenceData;
  //   } catch (e) {
  //     throw Exception("Error fetching reference data: $e");
  //   }
  // }

  Future<void> getFromAPI(List<String> missingKeys) async {
    try {
      await _getHomeRepository.getReferenceData(missingKeys).then((response) {
        List<ReferenceType> referenceDataTypeList = response;

        if (referenceDataTypeList.isNotEmpty) {
          // for loop for checking missing keys
          for (String key in missingKeys) {
            // for loop for checking reference data list
            getFromRefrenceList(referenceDataTypeList, key);
          }
        }
      });
    } catch (e) {
      throw Exception("Error fetching reference data: $e");
    }
  }

  void getFromRefrenceList(
      List<ReferenceType> referenceDataTypeList, String key) {
    for (ReferenceType element in referenceDataTypeList) {
      if (element.name == key) {
        // for loop for reference value inside the data list
        Map<int, dynamic> mapReferenceData = {
          for (Reference data in element.references ?? [])
            data.id!: data.toJson(),
        };
        referenceData[key] = element.references ?? [];

        // Skip storage for testing if flag is set
        if (!_skipStorageForTesting) {
          _getLocalStorageService.put(
              LocalStorageBoxes.referenceData, key, mapReferenceData);
        }
      }
    }
  }

  Future<List<String>> getFromLocalStorage(
    List<String> keys,
  ) async {
    List<String> missingKeys = [];
    for (String key in keys) {
      try {
        dynamic data = await _getLocalStorageService.get(
            LocalStorageBoxes.referenceData, key);
        logger.i("data: $data");
        if (data != null) {
          List<Reference> dataList = [];
          data.values
              .map((value) => dataList.add(
                  Reference.fromJson((value as Map).cast<String, dynamic>())))
              .toList();

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
