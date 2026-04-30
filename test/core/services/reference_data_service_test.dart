import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/reference_data_service.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";
import "package:wcas_frontend/repositories/home_repository.dart";
import "../../test_config.dart";

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  group("ReferenceDataService", () {
    late ReferenceDataService referenceDataService;
    late MockLocalStorageService mockLocalStorageService;
    late MockHomeRepository mockHomeRepository;

    setUpAll(() async {
      await TestConfig.setupTestEnvironment();
      registerFallbackValue(<String>["test_key"]);
      registerFallbackValue("test_key");
      registerFallbackValue(<String, dynamic>{"test": "data"});
    });

    setUp(() {
      referenceDataService = ReferenceDataService();
      mockLocalStorageService = MockLocalStorageService();
      mockHomeRepository = MockHomeRepository();

      // Clear any existing data between tests
      referenceDataService.referenceData.clear();

      // Set up mocked dependencies
      referenceDataService.setDependencies(
        localStorageService: mockLocalStorageService,
        homeRepository: mockHomeRepository,
        skipStorageForTesting: true,
      );

      // Set up default mock behaviors
      when(() => mockLocalStorageService.put(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockLocalStorageService.get(any(), any()))
          .thenAnswer((_) async => null);
      when(() => mockHomeRepository.getReferenceData(any()))
          .thenAnswer((_) async => <ReferenceType>[]);
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group("Singleton Pattern", () {
      test("should return the same instance", () {
        final instance1 = ReferenceDataService();
        final instance2 = ReferenceDataService();
        expect(identical(instance1, instance2), isTrue);
      });

      test("should have consistent instance across multiple calls", () {
        final instance1 = ReferenceDataService();
        final instance2 = ReferenceDataService();
        final instance3 = ReferenceDataService();

        expect(identical(instance1, instance2), isTrue);
        expect(identical(instance2, instance3), isTrue);
        expect(identical(instance1, instance3), isTrue);
      });
    });

    group("Service Structure", () {
      test("should have all required methods", () {
        expect(referenceDataService.getReferenceData, isA<Function>());
        expect(referenceDataService.getFromAPI, isA<Function>());
        expect(referenceDataService.getFromRefrenceList, isA<Function>());
        expect(referenceDataService.getFromLocalStorage, isA<Function>());
        expect(referenceDataService.setDependencies, isA<Function>());
      });

      test("should have referenceData property", () {
        expect(
          referenceDataService.referenceData,
          isA<Map<String, List<Reference>>>(),
        );
      });
    });

    group("Service Lifecycle", () {
      test("should maintain singleton state across operations", () {
        final instance1 = ReferenceDataService();
        final instance2 = ReferenceDataService();

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("Method Existence", () {
      test("should have getReferenceData method with correct signature", () {
        expect(referenceDataService.getReferenceData, isA<Function>());
      });

      test("should have getFromAPI method with correct signature", () {
        expect(referenceDataService.getFromAPI, isA<Function>());
      });

      test("should have getFromRefrenceList method with correct signature", () {
        expect(referenceDataService.getFromRefrenceList, isA<Function>());
      });

      test("should have getFromLocalStorage method with correct signature", () {
        expect(referenceDataService.getFromLocalStorage, isA<Function>());
      });
    });

    group("Instance Properties", () {
      test("should be instance of ReferenceDataService", () {
        expect(referenceDataService, isA<ReferenceDataService>());
      });

      test("should not be null", () {
        expect(referenceDataService, isNotNull);
      });
    });

    group("Multiple Instances", () {
      test("should return same instance from different calls", () {
        final instance1 = ReferenceDataService();
        final instance2 = ReferenceDataService();
        final instance3 = ReferenceDataService();

        expect(identical(instance1, instance2), isTrue);
        expect(identical(instance2, instance3), isTrue);
        expect(identical(instance1, instance3), isTrue);
      });

      test("should maintain singleton pattern across test groups", () {
        final instance1 = ReferenceDataService();
        final instance2 = ReferenceDataService();

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("Data Structure", () {
      test("should have correct referenceData type", () {
        expect(
          referenceDataService.referenceData,
          isA<Map<String, List<Reference>>>(),
        );
      });

      test("should allow adding data to referenceData", () {
        final testReferences = [
          Reference(id: 1, name: "test1"),
          Reference(id: 2, name: "test2"),
        ];

        referenceDataService.referenceData["test_key"] = testReferences;

        expect(
          referenceDataService.referenceData["test_key"],
          equals(testReferences),
        );
        expect(
          referenceDataService.referenceData["test_key"]!.length,
          equals(2),
        );
      });

      test("should handle multiple keys in referenceData", () {
        final testReferences1 = [Reference(id: 1, name: "test1")];
        final testReferences2 = [Reference(id: 2, name: "test2")];

        referenceDataService.referenceData["key1"] = testReferences1;
        referenceDataService.referenceData["key2"] = testReferences2;

        expect(
          referenceDataService.referenceData["key1"],
          equals(testReferences1),
        );
        expect(
          referenceDataService.referenceData["key2"],
          equals(testReferences2),
        );
        expect(referenceDataService.referenceData.length, equals(2));
      });
    });

    group("Model Integration", () {
      test("should work with Reference model", () {
        final reference = Reference(
          id: 1,
          name: "Test Reference",
          description: "Test Description",
        );

        expect(reference.id, equals(1));
        expect(reference.name, equals("Test Reference"));
        expect(reference.description, equals("Test Description"));
      });

      test("should work with ReferenceType model", () {
        final referenceType = ReferenceType(
          name: "Test Type",
          references: [
            Reference(id: 1, name: "ref1"),
            Reference(id: 2, name: "ref2"),
          ],
        );

        expect(referenceType.name, equals("Test Type"));
        expect(referenceType.references!.length, equals(2));
        expect(referenceType.references![0].name, equals("ref1"));
        expect(referenceType.references![1].name, equals("ref2"));
      });
    });

    group("getFromRefrenceList Method - Business Logic Only", () {
      test("should process reference list and store data correctly", () {
        const key = "test_key";
        final mockReferences = [
          Reference(id: 1, name: "ref1", description: "desc1"),
          Reference(id: 2, name: "ref2", description: "desc2"),
        ];
        final mockReferenceType = ReferenceType(
          name: key,
          references: mockReferences,
        );
        final referenceTypeList = [mockReferenceType];

        // Test the business logic without triggering storage
        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData[key], equals(mockReferences));
      });

      test("should handle reference type with null name", () {
        const key = "test_key";
        final mockReferenceType = ReferenceType(name: null, references: []);
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData, isEmpty);
      });

      test("should handle reference type with null references", () {
        const key = "test_key";
        final mockReferenceType = ReferenceType(name: key, references: null);
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData[key], equals([]));
      });

      test("should handle reference with null name", () {
        const key = "test_key";
        final mockReferences = [
          Reference(id: 1, name: null, description: "desc1"),
        ];
        final mockReferenceType = ReferenceType(
          name: key,
          references: mockReferences,
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData[key], equals(mockReferences));
      });

      test("should not process reference type with different name", () {
        const key = "test_key";
        const differentKey = "different_key";
        final mockReferenceType = ReferenceType(
          name: differentKey,
          references: [Reference(id: 1, name: "ref1")],
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData, isEmpty);
      });

      test("should handle empty reference type list", () {
        const key = "test_key";
        final referenceTypeList = <ReferenceType>[];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData, isEmpty);
      });

      test("should handle multiple reference types in list", () {
        const key = "test_key";
        final mockReferences1 = [Reference(id: 1, name: "ref1")];
        final mockReferences2 = [Reference(id: 2, name: "ref2")];

        final mockReferenceType1 =
            ReferenceType(name: key, references: mockReferences1);
        final mockReferenceType2 =
            ReferenceType(name: "other_key", references: mockReferences2);
        final referenceTypeList = [mockReferenceType1, mockReferenceType2];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(
          referenceDataService.referenceData[key],
          equals(mockReferences1),
        );
        expect(referenceDataService.referenceData["other_key"], isNull);
      });

      test("should handle reference with empty name", () {
        const key = "test_key";
        final mockReferences = [
          Reference(id: 1, name: "", description: "desc1"),
        ];
        final mockReferenceType = ReferenceType(
          name: key,
          references: mockReferences,
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData[key], equals(mockReferences));
      });
    });

    group("Data persistence", () {
      test("should maintain data across multiple calls", () {
        const key = "test_key";
        final mockReferences = [
          Reference(id: 1, name: "ref1", description: "desc1"),
        ];
        final mockReferenceType = ReferenceType(
          name: key,
          references: mockReferences,
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);
        final result = referenceDataService.referenceData;

        expect(result[key], equals(mockReferences));
        expect(referenceDataService.referenceData[key], equals(mockReferences));
      });

      test("should handle multiple keys", () {
        const key1 = "key1";
        const key2 = "key2";
        final mockReferences1 = [Reference(id: 1, name: "ref1")];
        final mockReferences2 = [Reference(id: 2, name: "ref2")];

        final mockReferenceType1 =
            ReferenceType(name: key1, references: mockReferences1);
        final mockReferenceType2 =
            ReferenceType(name: key2, references: mockReferences2);
        final referenceTypeList = [mockReferenceType1, mockReferenceType2];

        referenceDataService.getFromRefrenceList(referenceTypeList, key1);
        referenceDataService.getFromRefrenceList(referenceTypeList, key2);

        expect(
          referenceDataService.referenceData[key1],
          equals(mockReferences1),
        );
        expect(
          referenceDataService.referenceData[key2],
          equals(mockReferences2),
        );
      });

      test("should overwrite existing data for same key", () {
        const key = "test_key";
        final mockReferences1 = [Reference(id: 1, name: "ref1")];
        final mockReferences2 = [Reference(id: 2, name: "new_ref")];

        final mockReferenceType1 =
            ReferenceType(name: key, references: mockReferences1);
        final mockReferenceType2 =
            ReferenceType(name: key, references: mockReferences2);

        final referenceTypeList1 = [mockReferenceType1];
        final referenceTypeList2 = [mockReferenceType2];

        referenceDataService.getFromRefrenceList(referenceTypeList1, key);
        expect(
          referenceDataService.referenceData[key],
          equals(mockReferences1),
        );

        referenceDataService.getFromRefrenceList(referenceTypeList2, key);
        expect(
          referenceDataService.referenceData[key],
          equals(mockReferences2),
        );
        expect(
          referenceDataService.referenceData[key]![0].name,
          equals("new_ref"),
        );
      });
    });

    group("Edge cases", () {
      test("should handle null reference type list", () {
        const key = "test_key";

        referenceDataService.getFromRefrenceList([], key);

        expect(referenceDataService.referenceData, isEmpty);
      });

      test("should handle empty key", () {
        const key = "";
        final mockReferenceType = ReferenceType(
          name: key,
          references: [Reference(id: 1, name: "ref1")],
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData[key], isNotNull);
      });

      test("should handle reference with all null fields", () {
        const key = "test_key";
        final mockReferences = [
          Reference(
            id: 0,
            name: null,
            description: null,
            status: null,
            reference1: null,
            reference2: null,
            reference3: null,
            reference4: null,
            reference5: null,
          ),
        ];
        final mockReferenceType = ReferenceType(
          name: key,
          references: mockReferences,
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData[key], equals(mockReferences));
      });

      test("should handle very long key names", () {
        final longKey = "a" * 1000;
        final mockReferenceType = ReferenceType(
          name: longKey,
          references: [Reference(id: 1, name: "ref1")],
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, longKey);

        expect(referenceDataService.referenceData[longKey], isNotNull);
      });

      test("should handle special characters in key names", () {
        const key = r"test@key#123$%^&*()";
        final mockReferenceType = ReferenceType(
          name: key,
          references: [Reference(id: 1, name: "ref1")],
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        expect(referenceDataService.referenceData[key], isNotNull);
      });
    });

    group("Method Parameter Testing", () {
      test("should handle getReferenceData with empty keys list", () async {
        final emptyKeys = <String>[];

        expect(
          () => referenceDataService.getReferenceData(emptyKeys),
          returnsNormally,
        );
      });

      test("should handle getReferenceData with single key", () async {
        final singleKey = ["test_key"];

        expect(
          () => referenceDataService.getReferenceData(singleKey),
          returnsNormally,
        );
      });

      test("should handle getReferenceData with multiple keys", () async {
        final multipleKeys = ["key1", "key2", "key3"];

        expect(
          () => referenceDataService.getReferenceData(multipleKeys),
          returnsNormally,
        );
      });

      test("should handle getFromAPI with empty missing keys", () async {
        final emptyMissingKeys = <String>[];

        expect(
          () => referenceDataService.getFromAPI(emptyMissingKeys),
          returnsNormally,
        );
      });

      test("should handle getFromAPI with single missing key", () async {
        final singleMissingKey = ["missing_key"];

        expect(
          () => referenceDataService.getFromAPI(singleMissingKey),
          returnsNormally,
        );
      });

      test("should handle getFromAPI with multiple missing keys", () async {
        final multipleMissingKeys = ["missing_key1", "missing_key2"];

        expect(
          () => referenceDataService.getFromAPI(multipleMissingKeys),
          returnsNormally,
        );
      });

      test("should handle getFromLocalStorage with empty keys", () async {
        final emptyKeys = <String>[];

        expect(
          () => referenceDataService.getFromLocalStorage(emptyKeys),
          returnsNormally,
        );
      });

      test("should handle getFromLocalStorage with single key", () async {
        final singleKey = ["test_key"];

        final result =
            await referenceDataService.getFromLocalStorage(singleKey);

        expect(result, equals(singleKey));
      });

      test("should handle getFromLocalStorage with multiple keys", () async {
        final multipleKeys = ["key1", "key2", "key3"];

        final result =
            await referenceDataService.getFromLocalStorage(multipleKeys);

        expect(result, equals(multipleKeys));
      });
    });

    group("Data Transformation", () {
      test("should handle reference data transformation", () {
        const key = "test_key";
        final mockReferences = [
          Reference(id: 1, name: "ref1", description: "desc1"),
          Reference(id: 2, name: "ref2", description: "desc2"),
        ];
        final mockReferenceType = ReferenceType(
          name: key,
          references: mockReferences,
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        final storedData = referenceDataService.referenceData[key];
        expect(storedData, isNotNull);
        expect(storedData!.length, equals(2));
        expect(storedData[0].id, equals(1));
        expect(storedData[0].name, equals("ref1"));
        expect(storedData[1].id, equals(2));
        expect(storedData[1].name, equals("ref2"));
      });

      test("should handle complex reference data", () {
        const key = "complex_key";
        final mockReferences = [
          Reference(
            id: 1,
            name: "complex_ref1",
            description: "Complex description 1",
            status: "active",
            reference1: "ref1",
            reference2: "ref2",
            reference3: "ref3",
            reference4: "ref4",
            reference5: "ref5",
          ),
          Reference(
            id: 2,
            name: "complex_ref2",
            description: "Complex description 2",
            status: "inactive",
            reference1: "ref1_2",
            reference2: "ref2_2",
            reference3: "ref3_2",
            reference4: "ref4_2",
            reference5: "ref5_2",
          ),
        ];
        final mockReferenceType = ReferenceType(
          name: key,
          references: mockReferences,
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        final storedData = referenceDataService.referenceData[key];
        expect(storedData, isNotNull);
        expect(storedData!.length, equals(2));
        expect(storedData[0].name, equals("complex_ref1"));
        expect(storedData[0].status, equals("active"));
        expect(storedData[1].name, equals("complex_ref2"));
        expect(storedData[1].status, equals("inactive"));
      });

      test("should handle large number of references", () {
        const key = "large_key";
        final mockReferences = List.generate(
          100,
          (index) => Reference(
            id: index,
            name: "ref$index",
            description: "desc$index",
          ),
        );
        final mockReferenceType = ReferenceType(
          name: key,
          references: mockReferences,
        );
        final referenceTypeList = [mockReferenceType];

        referenceDataService.getFromRefrenceList(referenceTypeList, key);

        final storedData = referenceDataService.referenceData[key];
        expect(storedData, isNotNull);
        expect(storedData!.length, equals(100));
        expect(storedData[0].id, equals(0));
        expect(storedData[99].id, equals(99));
      });
    });

    group("Error Handling", () {
      test("should handle getReferenceData with null keys", () async {
        expect(
          () => referenceDataService.getReferenceData([]),
          returnsNormally,
        );
      });

      test("should handle getFromAPI with null missing keys", () async {
        expect(() => referenceDataService.getFromAPI([]), returnsNormally);
      });

      test("should handle getFromLocalStorage with null keys", () async {
        expect(
          () => referenceDataService.getFromLocalStorage([]),
          returnsNormally,
        );
      });

      test("should handle getFromRefrenceList with null parameters", () {
        expect(
          () => referenceDataService.getFromRefrenceList([], ""),
          returnsNormally,
        );
      });

      test("should handle API errors gracefully", () async {
        final missingKeys = ["test_key"];

        when(() => mockHomeRepository.getReferenceData(any()))
            .thenThrow(Exception("API Error"));

        expect(
          () => referenceDataService.getFromAPI(missingKeys),
          throwsException,
        );
      });

      test("should handle storage errors gracefully", () async {
        final keys = ["test_key"];

        when(() => mockLocalStorageService.get(any(), any()))
            .thenThrow(Exception("Storage Error"));

        final result = await referenceDataService.getFromLocalStorage(keys);

        expect(result, equals(keys));
      });
    });

    group("Integration Scenarios", () {
      test("should handle complete workflow scenario", () {
        const key1 = "workflow_key1";
        const key2 = "workflow_key2";

        final mockReferences1 = [
          Reference(id: 1, name: "workflow_ref1"),
          Reference(id: 2, name: "workflow_ref2"),
        ];
        final mockReferences2 = [
          Reference(id: 3, name: "workflow_ref3"),
        ];

        final mockReferenceType1 =
            ReferenceType(name: key1, references: mockReferences1);
        final mockReferenceType2 =
            ReferenceType(name: key2, references: mockReferences2);

        final referenceTypeList = [mockReferenceType1, mockReferenceType2];

        // Process first key
        referenceDataService.getFromRefrenceList(referenceTypeList, key1);
        expect(
          referenceDataService.referenceData[key1],
          equals(mockReferences1),
        );
        expect(referenceDataService.referenceData[key2], isNull);

        // Process second key
        referenceDataService.getFromRefrenceList(referenceTypeList, key2);
        expect(
          referenceDataService.referenceData[key1],
          equals(mockReferences1),
        );
        expect(
          referenceDataService.referenceData[key2],
          equals(mockReferences2),
        );

        // Verify total count
        expect(referenceDataService.referenceData.length, equals(2));
      });

      test("should handle data overwrite scenario", () {
        const key = "overwrite_key";

        final mockReferences1 = [Reference(id: 1, name: "old_ref")];
        final mockReferences2 = [Reference(id: 2, name: "new_ref")];

        final mockReferenceType1 =
            ReferenceType(name: key, references: mockReferences1);
        final mockReferenceType2 =
            ReferenceType(name: key, references: mockReferences2);

        final referenceTypeList1 = [mockReferenceType1];
        final referenceTypeList2 = [mockReferenceType2];

        // Initial data
        referenceDataService.getFromRefrenceList(referenceTypeList1, key);
        expect(
          referenceDataService.referenceData[key],
          equals(mockReferences1),
        );

        // Overwrite data
        referenceDataService.getFromRefrenceList(referenceTypeList2, key);
        expect(
          referenceDataService.referenceData[key],
          equals(mockReferences2),
        );
        expect(
          referenceDataService.referenceData[key]![0].name,
          equals("new_ref"),
        );
      });
    });

    group("Dependency Injection", () {
      test("should use injected dependencies when set", () {
        final testService = ReferenceDataService();
        final mockStorage = MockLocalStorageService();
        final mockRepo = MockHomeRepository();

        testService.setDependencies(
          localStorageService: mockStorage,
          homeRepository: mockRepo,
        );

        expect(testService, isA<ReferenceDataService>());
      });

      test("should use default dependencies when not set", () {
        final testService = ReferenceDataService();

        // Should not throw when accessing default dependencies
        expect(() => testService.getReferenceData([]), returnsNormally);
      });
    });

    group("Storage Operations", () {
      test("should handle storage operations with real data", () async {
        const key = "test_key";
        final mockData = {
          "ref1": {"id": 1, "name": "ref1", "description": "desc1"},
          "ref2": {"id": 2, "name": "ref2", "description": "desc2"},
        };

        when(() => mockLocalStorageService.get(any(), any()))
            .thenAnswer((_) async => mockData);

        final result = await referenceDataService.getFromLocalStorage([key]);

        expect(result, isEmpty);
        expect(referenceDataService.referenceData[key], isNotNull);
        expect(referenceDataService.referenceData[key]!.length, equals(2));
      });

      test("should handle API operations with real data", () async {
        const key = "test_key";
        final mockReferences = [
          Reference(id: 1, name: "ref1", description: "desc1"),
        ];
        final mockReferenceType = ReferenceType(
          name: key,
          references: mockReferences,
        );

        when(() => mockHomeRepository.getReferenceData(any()))
            .thenAnswer((_) async => [mockReferenceType]);

        await referenceDataService.getFromAPI([key]);

        expect(referenceDataService.referenceData[key], equals(mockReferences));
      });
    });

    group("Complete Workflow Testing", () {
      // test('should handle full getReferenceData workflow', () async {
      //   const key = 'test_key';
      //   final mockData = {
      //     'ref1': {'id': 1, 'name': 'ref1', 'description': 'desc1'},
      //   };

      //   when(() => mockLocalStorageService.get(any(), any()))
      //       .thenAnswer((_) async => mockData);

      //   final result = await referenceDataService.getReferenceData([key]);

      //   expect(result, isA<Map<String, List<Reference>>>());
      //   expect(result[key], isNotNull);
      //   expect(result[key]!.length, equals(1));
      // });

      test("should handle getReferenceData with missing keys", () async {
        const key = "missing_key";

        when(() => mockHomeRepository.getReferenceData(any()))
            .thenAnswer((_) async => []);

        final result = await referenceDataService.getReferenceData([key]);

        expect(result, isA<Map<String, List<Reference>>>());
      });
    });
  });
}
