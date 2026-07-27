import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/models/request/project/contract.dart";
import "package:wcas_frontend/repositories/project_repository.dart";

class MockRepo extends Mock implements ProjectRepository {}

void main() {
  late MockRepo mockRepository;

  setUp(() {
    mockRepository = MockRepo();
  });

  group("get contract details tests", () {
    test("getContractDetails success case", () async {
      //Handler
      when(() => mockRepository.getContractDetails())
          .thenAnswer((_) async => Contract());

      //Action
      final response = await mockRepository.getContractDetails();

      //Assert
      expect(response, isA<Contract>());
    });

    test("getContractDetails failure case", () async {
      //Handler
      when(() => mockRepository.getContractDetails()).thenThrow(Exception());

      //Assert
      expect(() => mockRepository.getContractDetails(), throwsException);
    });
  });

  group("get Link Commitment tests", () {
    test("getLinkCommitment success case", () async {
      //Handler
      when(() => mockRepository.getLinkContract()).thenAnswer((_) async => []);

      //Action
      final response = await mockRepository.getLinkContract();

      //Assert
      expect(response, []);
    });

    test("getLinkCommitment failure case", () async {
      //Handler
      when(() => mockRepository.getLinkContract()).thenThrow(Exception());

      //Assert
      expect(() => mockRepository.getLinkContract(), throwsException);
    });
  });
}
