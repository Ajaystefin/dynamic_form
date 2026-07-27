import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/repositories/customer_respository.dart";

class MockCustomerRepositoryy extends Mock implements CustomerRepository {}

void main() {
  // late MockAdvancedSearchViewModel viewModel;
  late MockCustomerRepositoryy mockRepository;

  setUpAll(() {
    mockRepository = MockCustomerRepositoryy();
    // viewModel = MockConditionEditDialogViewModel();
  });

  test("get customer details", () async {
    const String customerRimNo = "12";
    const String customerName = "rtrt";
    const String groupId = "67";
    const String groupName = "name";
    final Customer customer = Customer();
//Handler
    when(
      () => mockRepository.searchUserDetails(
        customerRimNo,
        customerName,
        groupId,
        groupName,
      ),
    ).thenAnswer((_) async => customer);
//Action
    final response = await mockRepository.searchUserDetails(
      customerRimNo,
      customerName,
      groupId,
      groupName,
    );

    expect(response, isA<Customer>());
  });

  test("Failure case", () async {
    const String customerRimNo = "12";
    const String customerName = "rtrt";
    const String groupId = "67";
    const String groupName = "name";
    when(
      () => mockRepository.searchUserDetails(
        customerRimNo,
        customerName,
        groupId,
        groupName,
      ),
    ).thenThrow(Exception("Failed to load"));

    expect(
      () => mockRepository.searchUserDetails(
        customerRimNo,
        customerName,
        groupId,
        groupName,
      ),
      throwsException,
    );
  });
}
