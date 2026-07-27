import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/features/request/customer_information/customer_info/draft_handler.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

class MockCustomerInfoViewModel extends Mock implements CustomerInfoViewModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("CustomerInfoDraftHandler", () {
    late CustomerInfoDraftHandler handler;
    late MockCustomerInfoViewModel vm;
    late GlobalKey<FormState> formKey;

    Customer? selectedCustomer;
    Customer? customerInformation;
    List<CustomerOwnerShipInfo>? customerOwnerShipInfo;
    List<CustomerException>? customerException;

    setUp(() {
      handler = CustomerInfoDraftHandler();
      vm = MockCustomerInfoViewModel();
      formKey = GlobalKey<FormState>();

      selectedCustomer = null;
      customerInformation = null;
      customerOwnerShipInfo = null;
      customerException = null;

      when(() => vm.formKey).thenReturn(formKey);
      when(() => vm.draftFormKey).thenReturn("customer-info");

      when(() => vm.selectedCustomer).thenAnswer((_) => selectedCustomer);

      when(() => vm.customerInformation).thenAnswer(
        (_) => customerInformation,
      );

      when(() => vm.customerInformation = any()).thenAnswer((invocation) {
        return customerInformation =
            invocation.positionalArguments.first as Customer?;
      });

      when(() => vm.customerOwnerShipInfo).thenAnswer(
        (_) => customerOwnerShipInfo,
      );

      when(() => vm.customerOwnerShipInfo = any()).thenAnswer((invocation) {
        return customerOwnerShipInfo = invocation.positionalArguments.first
            as List<CustomerOwnerShipInfo>?;
      });

      when(() => vm.customerException).thenAnswer(
        (_) => customerException,
      );

      when(() => vm.customerException = any()).thenAnswer((invocation) {
        return customerException =
            invocation.positionalArguments.first as List<CustomerException>?;
      });
    });

    Customer createCustomer({
      required int rimNo,
      required int custInfoId,
    }) {
      return Customer(
        customerRimNo: rimNo,
        custInfoId: custInfoId,
      )
        ..tlExpiryDate = "2026-12-31"
        ..relatnStartDate = "2026-01-01"
        ..establishmentDate = "2025-05-05"
        ..borrowRelationShipDate = "2026-06-06"
        ..tlExpiryDateLong = 111
        ..relatnStartDateLong = 222
        ..establishmentDateLong = 333
        ..borrowRelationShipDateLong = 444;
    }

    Map<String, dynamic> createSafeCustomerJson({
      required int rimNo,
      required int custInfoId,
    }) {
      return <String, dynamic>{
        "rimNo": rimNo,
        "customerRimNo": rimNo,
        "custInfoId": custInfoId,
        "tlExpiryDate": "2026-12-31",
        "relatnStartDate": "2026-01-01",
        "establishmentDate": "2025-05-05",
        "borrowRelationShipDate": "2026-06-06",
      };
    }

    CustomerOwnerShipInfo createOwnershipInfo() {
      return CustomerOwnerShipInfo();
    }

    Map<String, dynamic> createSafeOwnershipJson() {
      return createOwnershipInfo().toJson();
    }

    CustomerException createException() {
      return CustomerException()
        ..dueDate = "2026-10-20"
        ..dueDateLong = 999999;
    }

    Map<String, dynamic> createSafeExceptionJson() {
      final Map<String, dynamic> json = createException().toJson();
      json["dueDate"] = "2026-10-20";
      json.remove("dueDateLong");
      return json;
    }

    test(
        "resolveDraftKey returns key with rim number when selected customer exists",
        () {
      selectedCustomer = Customer(customerRimNo: 101);

      final String result = handler.resolveDraftKey(vm);

      expect(result, "customer-info_101");
    });

    test("resolveDraftKey returns base key when selected customer is null", () {
      selectedCustomer = null;

      final String result = handler.resolveDraftKey(vm);

      expect(result, "customer-info");
    });

    test("buildDraftData handles null form state and null model values safely",
        () {
      customerInformation = null;
      customerOwnerShipInfo = null;
      customerException = null;

      final Map<String, dynamic> result = handler.buildDraftData(vm);

      expect(result["customerInfo"], isA<Map<String, dynamic>>());
      expect(result["customerOwnershipInfo"], isNull);
      expect(result["borrowerExcption"], isNull);
    });

    testWidgets(
        "buildDraftData saves mounted form and builds complete draft data",
        (WidgetTester tester) async {
      bool isSaved = false;

      customerInformation = createCustomer(
        rimNo: 101,
        custInfoId: 50,
      );

      customerOwnerShipInfo = <CustomerOwnerShipInfo>[
        createOwnershipInfo(),
      ];

      customerException = <CustomerException>[
        createException(),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                initialValue: "test",
                onSaved: (_) {
                  isSaved = true;
                },
              ),
            ),
          ),
        ),
      );

      final Map<String, dynamic> result = handler.buildDraftData(vm);

      expect(isSaved, isTrue);

      final Map<String, dynamic> customerInfo =
          result["customerInfo"] as Map<String, dynamic>;

      expect(customerInfo["tlExpiryDate"], "2026-12-31");
      expect(customerInfo["relatnStartDate"], "2026-01-01");
      expect(customerInfo["establishmentDate"], "2025-05-05");
      expect(customerInfo["borrowRelationShipDate"], "2026-06-06");

      final List<dynamic> ownership =
          result["customerOwnershipInfo"] as List<dynamic>;

      expect(ownership, hasLength(1));

      final List<dynamic> exceptions =
          result["borrowerExcption"] as List<dynamic>;

      expect(exceptions, hasLength(1));

      final Map<String, dynamic> exceptionJson =
          exceptions.first as Map<String, dynamic>;

      expect(exceptionJson["dueDate"], "2026-10-20");
      expect(exceptionJson.containsKey("dueDateLong"), isFalse);
    });

    test("applyDraft does nothing when customerInfo is null", () {
      selectedCustomer = Customer(customerRimNo: 101);
      customerInformation = createCustomer(
        rimNo: 101,
        custInfoId: 10,
      );

      handler.applyDraft(
        vm,
        <String, dynamic>{
          "customerInfo": null,
        },
      );

      expect(customerInformation?.custInfoId, 10);
      expect(customerOwnerShipInfo, isNull);
      expect(customerException, isNull);
    });

    test(
        "applyDraft ignores draft when rimNo does not match selected customer rim",
        () {
      selectedCustomer = Customer(customerRimNo: 101);
      customerInformation = createCustomer(
        rimNo: 101,
        custInfoId: 10,
      );

      handler.applyDraft(
        vm,
        <String, dynamic>{
          "customerInfo": createSafeCustomerJson(
            rimNo: 999,
            custInfoId: 999,
          ),
          "customerOwnershipInfo": <Map<String, dynamic>>[
            createSafeOwnershipJson(),
          ],
          "borrowerExcption": <Map<String, dynamic>>[
            createSafeExceptionJson(),
          ],
        },
      );

      expect(customerInformation?.custInfoId, 10);
      expect(customerOwnerShipInfo, isNull);
      expect(customerException, isNull);
    });

    test(
        "applyDraft applies matching customer draft with ownership and exceptions",
        () {
      selectedCustomer = Customer(customerRimNo: 101);
      customerInformation = null;
      customerOwnerShipInfo = null;
      customerException = null;

      handler.applyDraft(
        vm,
        <String, dynamic>{
          "customerInfo": createSafeCustomerJson(
            rimNo: 101,
            custInfoId: 500,
          ),
          "customerOwnershipInfo": <Map<String, dynamic>>[
            createSafeOwnershipJson(),
          ],
          "borrowerExcption": <Map<String, dynamic>>[
            createSafeExceptionJson(),
          ],
        },
      );

      expect(customerInformation, isNotNull);
      expect(customerInformation?.tlExpiryDateLong, isNull);
      expect(customerInformation?.relatnStartDateLong, isNull);
      expect(customerInformation?.establishmentDateLong, isNull);
      expect(customerInformation?.borrowRelationShipDateLong, isNull);

      expect(customerOwnerShipInfo, isNotNull);
      expect(customerOwnerShipInfo, hasLength(1));

      expect(customerException, isNotNull);
      expect(customerException, hasLength(1));
      expect(customerException?.first.dueDateLong, isNull);
    });

    test(
        "applyDraft applies matching customer draft when optional lists are null",
        () {
      selectedCustomer = Customer(customerRimNo: 202);
      customerInformation = createCustomer(
        rimNo: 202,
        custInfoId: 20,
      );
      customerOwnerShipInfo = null;
      customerException = null;

      handler.applyDraft(
        vm,
        <String, dynamic>{
          "customerInfo": createSafeCustomerJson(
            rimNo: 202,
            custInfoId: 600,
          ),
          "customerOwnershipInfo": null,
          "borrowerExcption": null,
        },
      );

      expect(customerInformation, isNotNull);
      expect(customerInformation?.tlExpiryDateLong, isNull);
      expect(customerInformation?.relatnStartDateLong, isNull);
      expect(customerInformation?.establishmentDateLong, isNull);
      expect(customerInformation?.borrowRelationShipDateLong, isNull);

      expect(customerOwnerShipInfo, isNull);
      expect(customerException, isNull);
    });

    test(
        "applyDraft applies draft when selected rim and draft rim are both null",
        () {
      selectedCustomer = null;
      customerInformation = null;
      customerOwnerShipInfo = null;
      customerException = null;

      final Map<String, dynamic> customerJson = createSafeCustomerJson(
        rimNo: 303,
        custInfoId: 700,
      );

      customerJson["rimNo"] = null;

      handler.applyDraft(
        vm,
        <String, dynamic>{
          "customerInfo": customerJson,
          "customerOwnershipInfo": null,
          "borrowerExcption": null,
        },
      );

      expect(customerInformation, isNotNull);
      expect(customerInformation?.tlExpiryDateLong, isNull);
      expect(customerInformation?.relatnStartDateLong, isNull);
      expect(customerInformation?.establishmentDateLong, isNull);
      expect(customerInformation?.borrowRelationShipDateLong, isNull);
    });
  });
}
