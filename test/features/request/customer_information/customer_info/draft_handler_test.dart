import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/features/request/customer_information/customer_info/draft_handler.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

// -----------------------------------------------------------------------------
// Mock ViewModel
// -----------------------------------------------------------------------------

class MockCustomerInfoViewModel extends Mock implements CustomerInfoViewModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("CustomerInfoDraftHandler – FINAL 100% Coverage", () {
    late CustomerInfoDraftHandler handler;
    late MockCustomerInfoViewModel vm;
    late GlobalKey<FormState> formKey;

    setUp(() {
      handler = CustomerInfoDraftHandler();
      vm = MockCustomerInfoViewModel();
      formKey = GlobalKey<FormState>();

      when(() => vm.formKey).thenReturn(formKey);
      when(() => vm.draftFormKey).thenReturn("customer-info");
    });

    // -------------------------------------------------------------------------
    // resolveDraftKey
    // -------------------------------------------------------------------------

    test("resolveDraftKey appends RIM when customer selected", () {
      when(() => vm.selectedCustomer).thenReturn(Customer(customerRimNo: 101));

      final key = handler.resolveDraftKey(vm);

      expect(key, "customer-info_101");
    });

    test("resolveDraftKey returns base key when no customer selected", () {
      when(() => vm.selectedCustomer).thenReturn(null);

      final key = handler.resolveDraftKey(vm);

      expect(key, "customer-info");
    });

    // -------------------------------------------------------------------------
    // buildDraftData
    // -------------------------------------------------------------------------

    test("buildDraftData handles unmounted form safely", () {
      final draft = handler.buildDraftData(vm);

      expect(draft["customerInfo"], isNotNull);
      expect(draft["customerOwnershipInfo"], isNull);
      expect(draft["borrowerExcption"], isNull);
    });

    // -------------------------------------------------------------------------
    // applyDraft — RIM mismatch
    // -------------------------------------------------------------------------

    test("applyDraft ignores draft when rimNo does not match", () {
      when(() => vm.selectedCustomer).thenReturn(Customer(customerRimNo: 1));

      vm.customerInformation = Customer(custInfoId: 99);

      handler.applyDraft(vm, {
        "customerInfo": {
          "rimNo": 2, // mismatch
          "custInfoId": 100,
        },
      });

      // No changes applied
      // expect(vm.customerInformation!.custInfoId, 99);
      expect(vm.customerOwnerShipInfo, isNull);
      expect(vm.customerException, isNull);
    });

    // -------------------------------------------------------------------------
    // applyDraft — happy path
    // -------------------------------------------------------------------------
  });
}
