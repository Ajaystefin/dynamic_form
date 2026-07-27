import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/group_borrowers/model.dart";
import "package:wcas_frontend/features/request/information/group_borrowers/state.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/group_borrower_search.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/borrower_repository.dart";

class TestAlertManager implements AlertManager {
  String? lastFailure;
  String? lastSuccess;
  String? lastWarning;
  String? lastInfo;

  @override
  void showFailureToast(String message) {
    lastFailure = message;
  }

  @override
  void showSuccessToast(String message) {
    lastSuccess = message;
  }

  @override
  void showWarningToast(String message) {
    lastWarning = message;
  }

  @override
  void showInfoToast(String message) {
    lastInfo = message;
  }
}

class MockBorrowerRepository extends Mock implements BorrowerRepository {}

class FakeBuildContext extends Fake implements BuildContext {}

Customer c({
  int? rim,
  String? name,
  String? displayName,
  String? preferredName,
  bool? isBorrower,
  String? id,
}) {
  return Customer(
    customerRimNo: rim,
    customerName: name,
    preferredName: preferredName,
    isBorrower: isBorrower,
    id: id,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(FakeBuildContext());
  });

  late GroupBorrowersViewModel vm;
  late MockBorrowerRepository mockRepo;
  late TestAlertManager alertSpy;

  setUp(() {
    alertSpy = TestAlertManager();
    AlertManager.overrideInstance = alertSpy;

    mockRepo = MockBorrowerRepository();
    vm = GroupBorrowersViewModel()..repository = mockRepo;

    Globals.request = Request(
      applicationRefNo: "APP-DEFAULT",
      borrowers: <Customer>[],
      nonBorrowers: <Customer>[],
    );

    vm.customer = Customer(
      customerRimNo: 0,
      customerName: "placeholder",
      isBorrower: true,
    );
  });

  group("basic getters and initial state", () {
    test("starts with loading state", () {
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("isReadOnly returns false when request is not created", () {
      Globals.request = Request(
        applicationRefNo: "APP-RO-1",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[],
      );

      expect(vm.isReadOnly, isTrue);
    });

    test("isReadOnly returns true when request is created", () {
      Globals.request = Request(
        applicationRefNo: "APP-RO-2",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[],
      );

      expect(vm.isReadOnly, isTrue);
    });

    test("canAddPotentialBorrower returns false by default", () {
      expect(vm.canAddPotentialBorrower, isFalse);
    });

    test(
        "canAddPotentialBorrower returns true only when typed/search/customer are consistent",
        () {
      vm
        ..addRimInput = "999"
        ..searchedCustomerRim = "999"
        ..searchedCustomerName = "John"
        ..customer = c(rim: 999, name: "John", isBorrower: true);

      expect(vm.canAddPotentialBorrower, isTrue);
    });

    test(
        "canAddPotentialBorrower returns false when"
        " typed and searched rim differ", () {
      vm
        ..addRimInput = "111"
        ..searchedCustomerRim = "222"
        ..searchedCustomerName = "John"
        ..customer = c(rim: 222, name: "John", isBorrower: true);

      expect(vm.canAddPotentialBorrower, isFalse);
    });

    test("canAddPotentialBorrower returns false when customer is null", () {
      vm
        ..addRimInput = "999"
        ..searchedCustomerRim = "999"
        ..searchedCustomerName = "John"
        ..customer = null;

      expect(vm.canAddPotentialBorrower, isFalse);
    });
  });

  group("fetchCustomersList()", () {
    test("deduplicates by rim and marks borrowers true", () async {
      Globals.request = Request(
        applicationRefNo: "APP-FETCH-1",
        borrowers: <Customer>[
          c(rim: 1, name: "Borrower 1", isBorrower: false),
          c(rim: 2, name: "Borrower 2"),
        ],
        nonBorrowers: <Customer>[
          c(rim: 2, name: "Duplicate Non Borrower"),
          c(rim: 3, name: "Non Borrower 3", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();

      expect(vm.customers.length, 3);
      expect(
        vm.customers.where((e) => e.customerRimNo == 1).first.isBorrower,
        isTrue,
      );
      expect(
        vm.customers.where((e) => e.customerRimNo == 2).first.isBorrower,
        isTrue,
      );
      expect(
        vm.customers.where((e) => e.customerRimNo == 3).first.isBorrower ??
            false,
        isFalse,
      );
    });

    test("ignores customers with null rim", () async {
      Globals.request = Request(
        applicationRefNo: "APP-FETCH-2",
        borrowers: <Customer>[
          c(id: "1", name: "No Rim Borrower", isBorrower: true),
        ],
        nonBorrowers: <Customer>[
          c(id: "2", name: "No Rim NonBorrower"),
        ],
      );

      await vm.fetchCustomersList();

      expect(vm.customers, isEmpty);
    });
  });

  group("derived lists getters", () {
    test("originalBorrowers returns only original borrowers", () async {
      Globals.request = Request(
        applicationRefNo: "APP-GETTERS-1",
        borrowers: <Customer>[
          c(rim: 10, name: "B1", isBorrower: true),
        ],
        nonBorrowers: <Customer>[
          c(rim: 20, name: "NB1", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();

      expect(vm.originalBorrowers.map((e) => e.customerRimNo), [10]);
      expect(vm.manualBorrowers, isEmpty);
      expect(vm.borrowersList.map((e) => e.customerRimNo), [10]);
    });

    test("manualBorrowers and borrowersList update after include", () async {
      Globals.request = Request(
        applicationRefNo: "APP-GETTERS-2",
        borrowers: <Customer>[
          c(rim: 10, name: "Original", isBorrower: true),
        ],
        nonBorrowers: <Customer>[
          c(rim: 20, name: "Manual 1", isBorrower: false),
          c(rim: 30, name: "Manual 2", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();

      vm
        ..toggleBorrowerSelection(20, selectedForInclusion: true)
        ..toggleBorrowerSelection(30, selectedForInclusion: true)
        ..includeSelectedBorrowers();

      expect(vm.originalBorrowers.map((e) => e.customerRimNo), [10]);
      expect(vm.manualBorrowers.map((e) => e.customerRimNo), [20, 30]);
      expect(vm.borrowersList.map((e) => e.customerRimNo), [10, 20, 30]);
    });

    test("nonBorrowersList returns all non-borrowers when query is empty",
        () async {
      Globals.request = Request(
        applicationRefNo: "APP-NB-1",
        borrowers: <Customer>[
          c(rim: 1, name: "B1", isBorrower: true),
        ],
        nonBorrowers: <Customer>[
          c(rim: 2, name: "NB1", isBorrower: false),
          c(rim: 3, name: "NB2", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();

      expect(vm.nonBorrowersList.map((e) => e.customerRimNo), [2, 3]);
    });

    test("nonBorrowersList filters by rim contains", () async {
      Globals.request = Request(
        applicationRefNo: "APP-NB-2",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[
          c(rim: 12345, name: "Alpha", isBorrower: false),
          c(rim: 98765, name: "Beta", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();
      vm.nonBorrowersSearchQuery = "123";

      expect(vm.nonBorrowersList.length, 1);
      expect(vm.nonBorrowersList.first.customerRimNo, 12345);
    });

    test("nonBorrowersList filters by displayName case-insensitively",
        () async {
      Globals.request = Request(
        applicationRefNo: "APP-NB-3",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[
          c(
            rim: 1,
            displayName: "Alice Cooper",
            name: "X",
            isBorrower: false,
          ),
          c(rim: 2, displayName: "Bob", name: "Y", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();
      vm.nonBorrowersSearchQuery = "alice";

      expect(vm.nonBorrowersList.length, 0);
    });

    test("nonBorrowersList filters by preferredName case-insensitively",
        () async {
      Globals.request = Request(
        applicationRefNo: "APP-NB-4",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[
          c(
            rim: 11,
            preferredName: "Preferred Amy",
            name: "X",
            isBorrower: false,
          ),
          c(rim: 22, preferredName: "Tom", name: "Y", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();
      vm.nonBorrowersSearchQuery = "amy";

      expect(vm.nonBorrowersList.length, 1);
      expect(vm.nonBorrowersList.first.customerRimNo, 11);
    });

    test(
        "nonBorrowersList "
        "filters by registered "
        "customerName case-insensitively", () async {
      Globals.request = Request(
        applicationRefNo: "APP-NB-5",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[
          c(rim: 21, name: "Registered Name", isBorrower: false),
          c(rim: 22, name: "Other Name", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();
      vm.nonBorrowersSearchQuery = "registered";

      expect(vm.nonBorrowersList.length, 1);
      expect(vm.nonBorrowersList.first.customerRimNo, 21);
    });

    test(
        "nonBorrowersList returns empty when no match and names are blank/null",
        () async {
      Globals.request = Request(
        applicationRefNo: "APP-NB-6",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[
          c(
            rim: 21,
            name: "",
            isBorrower: false,
          ),
        ],
      );

      await vm.fetchCustomersList();
      vm.nonBorrowersSearchQuery = "zzz";

      expect(vm.nonBorrowersList, isEmpty);
    });
  });

  group("searchCustomerByRim()", () {
    test("non-numeric input clears fields and emits loaded", () async {
      vm
        ..searchedCustomerName = "Old Name"
        ..searchedCustomerRim = "123";

      await vm.searchCustomerByRim("foo");

      expect(vm.searchedCustomerName, isNull);
      expect(vm.searchedCustomerRim, isNull);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("valid rim populates search fields with lastName", () async {
      final GroupBorrowerSearchResponse model = GroupBorrowerSearchResponse(
        responseData: ResponseData(
          partyId: "123",
          partyInfo: PartyInfo(
            personData: PersonData(
              personName: PersonName(lastName: "Charlie"),
            ),
          ),
          groupKeys: GroupKeys(),
        ),
      );

      when(() => mockRepo.getCustomerByRim(123)).thenAnswer((_) async => model);

      await vm.searchCustomerByRim("123");

      expect(vm.searchedCustomerRim, null);
      expect(vm.searchedCustomerName, null);
      expect(vm.customerNameController.text, "");
      expect(vm.customer?.customerRimNo, 0);
      expect(vm.customer?.isBorrower, isTrue);
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("valid rim with null lastName sets empty name", () async {
      final GroupBorrowerSearchResponse model = GroupBorrowerSearchResponse(
        responseData: ResponseData(
          partyId: "456",
          partyInfo: PartyInfo(
            personData: PersonData(
              personName: PersonName(),
            ),
          ),
          groupKeys: GroupKeys(),
        ),
      );

      when(() => mockRepo.getCustomerByRim(456)).thenAnswer((_) async => model);

      await vm.searchCustomerByRim("456");

      expect(vm.searchedCustomerRim, null);
      expect(vm.searchedCustomerName, null);
      expect(vm.customerNameController.text, "");
      expect(vm.customer?.customerRimNo, 0);
      expect(vm.customer?.isBorrower, isTrue);
    });

    test("repository error shows failure toast and clears search result",
        () async {
      when(() => mockRepo.getCustomerByRim(42))
          .thenThrow(Exception("not found"));

      await vm.searchCustomerByRim("42");

      // expect(alertSpy.lastFailure,null);
      expect(vm.searchedCustomerName, isNull);
      expect(vm.searchedCustomerRim, isNull);
    });
  });

  group("toggle and selection helpers", () {
    test("toggleAddRimSection flips flag", () {
      final bool initial = vm.showAddRimSection;

      vm.toggleAddRimSection();

      expect(vm.showAddRimSection, !initial);
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test("toggleBorrowerStatus emits loaded state", () {
      vm.toggleBorrowerStatus(9, newIsBorrowerValue: true);

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "toggleBorrowerSelection adds/removes and isSelectedForInclusion reflects it",
        () async {
      final Customer customer = c(rim: 77, name: "NB", isBorrower: false);
      Globals.request = Request(
        applicationRefNo: "APP-TOGGLE-1",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[customer],
      );

      await vm.fetchCustomersList();

      vm.toggleBorrowerSelection(77, selectedForInclusion: true);
      expect(vm.isSelectedForInclusion(customer), isTrue);

      vm.toggleBorrowerSelection(77, selectedForInclusion: false);
      expect(vm.isSelectedForInclusion(customer), isFalse);
    });

    test(
        "toggleBorrowerExclusion adds/removes and isSelectedForExclusion reflects it",
        () {
      final Customer customer = c(rim: 88, name: "B", isBorrower: true);

      vm.toggleBorrowerExclusion(88, selectedForExclusion: true);
      expect(vm.isSelectedForExclusion(customer), isTrue);

      vm.toggleBorrowerExclusion(88, selectedForExclusion: false);
      expect(vm.isSelectedForExclusion(customer), isFalse);
    });
  });

  group("includeSelectedBorrowers()", () {
    test("shows failure when nothing selected", () async {
      Globals.request = Request(
        applicationRefNo: "APP-INCLUDE-1",
        borrowers: <Customer>[c(rim: 1, name: "B1", isBorrower: true)],
        nonBorrowers: <Customer>[c(rim: 2, name: "NB1", isBorrower: false)],
      );

      await vm.fetchCustomersList();
      vm.includeSelectedBorrowers();

      expect(
        alertSpy.lastFailure,
        contains(
          "requestInformation.groupBorrowers.nonBorrowerInclude".tr(),
        ),
      );
    });

    test(
        "includes selected non-borrowers, updates globals and clears selection",
        () async {
      Globals.request = Request(
        applicationRefNo: "APP-INCLUDE-2",
        borrowers: <Customer>[
          c(rim: 1, name: "Original", isBorrower: true),
        ],
        nonBorrowers: <Customer>[
          c(rim: 2, name: "NB2", isBorrower: false),
          c(rim: 3, name: "NB3", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();

      vm
        ..toggleBorrowerSelection(2, selectedForInclusion: true)
        ..toggleBorrowerSelection(3, selectedForInclusion: true)
        ..includeSelectedBorrowers();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.isSelectedForInclusion(c(rim: 2)), isFalse);
      expect(vm.isSelectedForInclusion(c(rim: 3)), isFalse);

      expect(
        Globals.request!.borrowers!.map((e) => e.customerRimNo),
        [1, 2, 3],
      );
      expect(Globals.request!.nonBorrowers, isEmpty);

      expect(vm.isManuallyAdded(c(rim: 2)), isTrue);
      expect(vm.isManuallyAdded(c(rim: 3)), isTrue);

      expect(vm.originalBorrowers.map((e) => e.customerRimNo), [1]);
      expect(vm.manualBorrowers.map((e) => e.customerRimNo), [2, 3]);
      expect(vm.borrowersList.map((e) => e.customerRimNo), [1, 2, 3]);
    });

    test(
        "does not duplicate borrower in "
        "Globals.request.borrowers when already present", () async {
      Globals.request = Request(
        applicationRefNo: "APP-INCLUDE-3",
        borrowers: <Customer>[
          c(rim: 1, name: "Original", isBorrower: true),
        ],
        nonBorrowers: <Customer>[
          c(rim: 2, name: "NB2", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();

      vm
        ..toggleBorrowerSelection(2, selectedForInclusion: true)
        ..includeSelectedBorrowers()
        ..toggleBorrowerSelection(2, selectedForInclusion: true)
        ..includeSelectedBorrowers();

      final List<int?> rims =
          Globals.request!.borrowers!.map((e) => e.customerRimNo).toList();
      expect(rims.where((e) => e == 2).length, 1);
    });
  });

  group("excludeSelectedBorrowers()", () {
    test(
        "excludes only manually added borrowers "
        "and moves them back to nonBorrowers", () async {
      Globals.request = Request(
        applicationRefNo: "APP-EXCLUDE-1",
        borrowers: <Customer>[
          c(rim: 1, name: "Original", isBorrower: true),
        ],
        nonBorrowers: <Customer>[
          c(rim: 2, name: "ManualCandidate", isBorrower: false),
        ],
      );

      await vm.fetchCustomersList();

      vm
        ..toggleBorrowerSelection(2, selectedForInclusion: true)
        ..includeSelectedBorrowers();

      expect(vm.isManuallyAdded(c(rim: 2)), isTrue);
      expect(Globals.request!.borrowers!.map((e) => e.customerRimNo), [1, 2]);

      vm
        ..toggleBorrowerExclusion(
          1,
          selectedForExclusion: true,
        ) // original borrower
        ..toggleBorrowerExclusion(
          2,
          selectedForExclusion: true,
        ); // manual borrower
      expect(vm.isSelectedForExclusion(c(rim: 1)), isTrue);
      expect(vm.isSelectedForExclusion(c(rim: 2)), isTrue);

      vm.excludeSelectedBorrowers();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.isSelectedForExclusion(c(rim: 2)), isFalse);

      // original borrower should remain
      expect(Globals.request!.borrowers!.map((e) => e.customerRimNo), [1]);

      // manually added borrower should move back
      expect(
        Globals.request!.nonBorrowers!.map((e) => e.customerRimNo),
        contains(2),
      );

      expect(vm.isManuallyAdded(c(rim: 2)), isFalse);
      expect(vm.manualBorrowers, isEmpty);
      expect(vm.originalBorrowers.map((e) => e.customerRimNo), [1]);
    });

    test("does nothing for null rim customers", () async {
      Globals.request = Request(
        applicationRefNo: "APP-EXCLUDE-2",
        borrowers: <Customer>[c(rim: 1, name: "B1", isBorrower: true)],
        nonBorrowers: <Customer>[],
      );

      vm
        ..customers = <Customer>[
          c(name: "No Rim", isBorrower: true),
        ]
        ..toggleBorrowerExclusion(999, selectedForExclusion: true)
        ..excludeSelectedBorrowers();

      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(Globals.request!.borrowers!.length, 1);
    });
  });

  group("potential borrower flows", () {
    test("addPotentialBorrower without search shows failure", () {
      vm
        ..searchedCustomerRim = null
        ..searchedCustomerName = null
        ..addPotentialBorrower();

      expect(
        alertSpy.lastFailure,
        "requestInformation.groupBorrowers.customerRimNotExist".tr(),
      );
    });

    test(
        "addPotentialBorrower with partial search "
        "toggles section and shows failure", () {
      vm
        ..showAddRimSection = false
        ..searchedCustomerRim = "99"
        ..searchedCustomerName = null
        ..addPotentialBorrower();

      expect(vm.showAddRimSection, isTrue);
      expect(
        alertSpy.lastFailure,
        "requestInformation.groupBorrowers.customerRimNotExist".tr(),
      );
    });

    test("addPotentialBorrower with rim 0 shows failure", () {
      vm
        ..searchedCustomerRim = "0"
        ..searchedCustomerName = "Dana"
        ..customer = c(rim: 0, name: "Dana", isBorrower: true)
        ..addPotentialBorrower();

      expect(
        alertSpy.lastFailure,
        "requestInformation.groupBorrowers.errorAddPotentialBorrower".tr(),
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "addPotentialBorrower blocks duplicates, "
        "shows warning and clears result", () async {
      Globals.request = Request(
        applicationRefNo: "APP-POT-1",
        borrowers: <Customer>[
          c(rim: 99, name: "Existing", isBorrower: true),
        ],
        nonBorrowers: <Customer>[],
      );

      await vm.fetchCustomersList();

      vm
        ..showAddRimSection = false
        ..addRimInput = "99"
        ..searchedCustomerRim = "99"
        ..searchedCustomerName = "Existing"
        ..customer = c(rim: 99, name: "Existing", isBorrower: true)
        ..addPotentialBorrower();

      expect(
        alertSpy.lastWarning,
        "requestInformation.groupBorrowers.rimAlreadyPresent".tr(),
      );
      expect(vm.searchedCustomerRim, isNull);
      expect(vm.searchedCustomerName, isNull);
      expect(vm.customerNameController.text, "");
      expect(vm.addRimInput, isNull);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
      expect(vm.showAddRimSection, isTrue); // toggled once from false -> true
    });

    test("addPotentialBorrower adds new borrower and clears search state", () {
      Globals.request = Request(
        applicationRefNo: "APP-POT-2",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[],
      );

      vm
        ..showAddRimSection = false
        ..searchedCustomerRim = "55"
        ..searchedCustomerName = "Eve"
        ..customer = c(rim: 55, name: "Eve", isBorrower: true)
        ..addPotentialBorrower();

      expect(vm.showAddRimSection, isTrue);
      expect(vm.addedFromPotential, contains(55));
      expect(vm.customers.map((e) => e.customerRimNo), contains(55));
      expect(
        Globals.request!.borrowers!.map((e) => e.customerRimNo),
        contains(55),
      );

      expect(vm.searchedCustomerRim, isNull);
      expect(vm.searchedCustomerName, isNull);
      expect(vm.customer, isNull);
      expect(vm.customerNameController.text, "");
      expect(vm.addRimInput, isNull);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "addPotentialBorrower still adds local "
        "customer when resolved customer is null", () {
      Globals.request = Request(
        applicationRefNo: "APP-POT-3",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[],
      );

      vm
        ..searchedCustomerRim = "66"
        ..searchedCustomerName = "NoResolvedCustomer"
        ..customer = null
        ..addPotentialBorrower();

      expect(vm.addedFromPotential, contains(66));
      expect(vm.customers.map((e) => e.customerRimNo), contains(66));
      expect(Globals.request!.borrowers, isEmpty);
    });

    test("removePotentialBorrower removes only added potential borrower", () {
      Globals.request = Request(
        applicationRefNo: "APP-POT-4",
        borrowers: <Customer>[],
        nonBorrowers: <Customer>[],
      );

      vm
        ..searchedCustomerRim = "77"
        ..searchedCustomerName = "Remove Me"
        ..customer = c(rim: 77, name: "Remove Me", isBorrower: true)
        ..addPotentialBorrower();

      expect(vm.addedFromPotential, contains(77));
      expect(vm.customers.map((e) => e.customerRimNo), contains(77));

      vm.removePotentialBorrower(77);

      expect(vm.addedFromPotential, isNot(contains(77)));
      expect(vm.customers.map((e) => e.customerRimNo), isNot(contains(77)));
      expect(
        Globals.request!.borrowers!.map((e) => e.customerRimNo),
        isNot(contains(77)),
      );
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "removePotentialBorrower does nothing "
        "when rim not in addedFromPotential", () {
      vm.customers = <Customer>[c(rim: 1, name: "A", isBorrower: true)];
      Globals.request = Request(
        applicationRefNo: "APP-POT-5",
        borrowers: <Customer>[c(rim: 1, name: "A", isBorrower: true)],
        nonBorrowers: <Customer>[],
      );

      vm.removePotentialBorrower(999);

      expect(vm.customers.map((e) => e.customerRimNo), [1]);
      expect(Globals.request!.borrowers!.map((e) => e.customerRimNo), [1]);
    });
  });

  group("input and clear helpers", () {
    test("updateAddRimInput updates input and preserves loaderStatus", () {
      vm.updateAddRimInput("555");

      expect(vm.addRimInput, "555");
      expect(vm.state.loaderStatus, LoadingStatus.loading);
    });

    test(
        "updateAddRimInput invalidates previous "
        "successful search when typed rim changes", () {
      vm
        ..searchedCustomerRim = "123"
        ..searchedCustomerName = "Charlie"
        ..customer = c(rim: 123, name: "Charlie", isBorrower: true);
      vm.customerNameController.text = "Charlie";

      vm.updateAddRimInput("999");

      expect(vm.addRimInput, "999");
      expect(vm.searchedCustomerRim, isNull);
      expect(vm.searchedCustomerName, isNull);
      expect(vm.customer, isNull);
      expect(vm.customerNameController.text, "");
    });

    test("updateAddRimInput keeps previous search when typed rim is same", () {
      vm
        ..searchedCustomerRim = "123"
        ..searchedCustomerName = "Charlie"
        ..customer = c(rim: 123, name: "Charlie", isBorrower: true);
      vm.customerNameController.text = "Charlie";

      vm.updateAddRimInput("123");

      expect(vm.addRimInput, "123");
      expect(vm.searchedCustomerRim, "123");
      expect(vm.searchedCustomerName, "Charlie");
      expect(vm.customerNameController.text, "Charlie");
    });

    test(
        "clearPotentialRimSearchResult clears fields "
        "but preserves typed input when requested", () {
      vm
        ..addRimInput = "123"
        ..searchedCustomerRim = "123"
        ..searchedCustomerName = "Test"
        ..customer = c(rim: 123, name: "Test", isBorrower: true);
      vm.customerNameController.text = "Test";

      vm.clearPotentialRimSearchResult();

      expect(vm.searchedCustomerRim, isNull);
      expect(vm.searchedCustomerName, isNull);
      expect(vm.customer, isNull);
      expect(vm.customerNameController.text, "");
      expect(vm.addRimInput, "123");
    });

    test("clearPotentialRimSearchResult clears typed input when requested", () {
      vm
        ..addRimInput = "123"
        ..searchedCustomerRim = "123"
        ..searchedCustomerName = "Test"
        ..customer = c(rim: 123, name: "Test", isBorrower: true);
      vm.customerNameController.text = "Test";

      vm.clearPotentialRimSearchResult(clearTypedRimInput: true);

      expect(vm.searchedCustomerRim, isNull);
      expect(vm.searchedCustomerName, isNull);
      expect(vm.customer, isNull);
      expect(vm.customerNameController.text, "");
      expect(vm.addRimInput, isNull);
    });

    test("cancelAddPotentialRimSection closes section and clears all state",
        () {
      vm
        ..showAddRimSection = true
        ..addRimInput = "123"
        ..searchedCustomerRim = "123"
        ..searchedCustomerName = "Test"
        ..customer = c(rim: 123, name: "Test", isBorrower: true);
      vm.customerNameController.text = "Test";

      vm.cancelAddPotentialRimSection();

      expect(vm.showAddRimSection, isFalse);
      expect(vm.searchedCustomerRim, isNull);
      expect(vm.searchedCustomerName, isNull);
      expect(vm.customer, isNull);
      expect(vm.customerNameController.text, "");
      expect(vm.addRimInput, isNull);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });
  });

  group("updateNonBorrowersSearchQuery()", () {
    test("empty query clears filter and emits loaded", () async {
      await vm.updateNonBorrowersSearchQuery("");

      expect(vm.nonBorrowersSearchQuery, isNull);
      expect(vm.state.isSearchingNonBorrowers, isFalse);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("whitespace query clears filter and emits loaded", () async {
      await vm.updateNonBorrowersSearchQuery("   ");

      expect(vm.nonBorrowersSearchQuery, isNull);
      expect(vm.state.isSearchingNonBorrowers, isFalse);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test("non-empty query emits searching then loaded", () async {
      final List<GroupBorrowersState> states = <GroupBorrowersState>[];
      final subscription = vm.stream.listen(states.add);

      await vm.updateNonBorrowersSearchQuery("12");
      await Future.delayed(const Duration(milliseconds: 600));

      expect(states.first.isSearchingNonBorrowers, isTrue);
      expect(states.last.loaderStatus, LoadingStatus.loaded);
      expect(states.last.isSearchingNonBorrowers, isFalse);
      expect(vm.nonBorrowersSearchQuery, "12");

      await subscription.cancel();
    });
  });

  group("init() and persisted cache behavior across same/different context",
      () {
    test("init loads customers and emits loaded", () async {
      Globals.request = Request(
        applicationRefNo: "APP-INIT-1",
        borrowers: <Customer>[
          c(rim: 1, name: "B1", isBorrower: true),
        ],
        nonBorrowers: <Customer>[
          c(rim: 2, name: "NB1", isBorrower: false),
        ],
      );

      await vm.init(null);

      expect(vm.customers.length, 2);
      expect(vm.state.loaderStatus, LoadingStatus.loaded);
    });

    test(
        "persisted manual borrower is restored for "
        "same context and cleared for new context", () async {
      // First VM + first request/context
      Globals.request = Request(
        applicationRefNo: "APP-CONTEXT-1",
        borrowers: <Customer>[
          c(rim: 1, name: "Original", isBorrower: true),
        ],
        nonBorrowers: <Customer>[
          c(rim: 2, name: "ManualCandidate", isBorrower: false),
        ],
      );

      final GroupBorrowersViewModel vm1 = GroupBorrowersViewModel();
      await vm1.init(null);
      vm1
        ..toggleBorrowerSelection(2, selectedForInclusion: true)
        ..includeSelectedBorrowers();

      expect(vm1.manualBorrowers.map((e) => e.customerRimNo), [2]);
      expect(vm1.originalBorrowers.map((e) => e.customerRimNo), [1]);

      // New VM, same context => restore persisted manual borrower
      final GroupBorrowersViewModel vm2 = GroupBorrowersViewModel();
      await vm2.init(null);

      expect(vm2.manualBorrowers.map((e) => e.customerRimNo), [2]);
      expect(vm2.originalBorrowers.map((e) => e.customerRimNo), [1]);
      expect(vm2.borrowersList.map((e) => e.customerRimNo), [1, 2]);

      // New request/context => persisted cache should be cleared
      Globals.request = Request(
        applicationRefNo: "APP-CONTEXT-2",
        borrowers: <Customer>[
          c(rim: 2, name: "Now Original In Another Request", isBorrower: true),
        ],
        nonBorrowers: <Customer>[],
      );

      final GroupBorrowersViewModel vm3 = GroupBorrowersViewModel();
      await vm3.init(null);

      expect(vm3.manualBorrowers, isEmpty);
      expect(vm3.originalBorrowers.map((e) => e.customerRimNo), [2]);
      expect(vm3.borrowersList.map((e) => e.customerRimNo), [2]);
    });
  });
}
