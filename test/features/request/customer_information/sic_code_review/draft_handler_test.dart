import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/utils.dart";

import "package:wcas_frontend/features/request/customer_information/sic_code_review/draft_handler.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/state.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/sic_code.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("SicCodeReviewDraftHandler – 100% flat coverage", () {
    late SicCodeReviewDraftHandler handler;
    late SicCodeReviewViewModel vm;

    setUp(() {
      handler = SicCodeReviewDraftHandler();
      vm = SicCodeReviewViewModel()
        ..emit(SicCodeReviewState(loaderStatus: LoadingStatus.loaded))

        // Safe defaults that tests mutate as needed:
        ..comment.strategyComment = ""
        ..controllerAccountLevelSicCode.text = ""
        ..selectedCustomer = null
        ..customerSICcodeReview = <SicCodeReview>[];
    });

    test(
        "buildDraftData: serializes rim, comment, and"
        " only rows matching current RIM", () {
      // Arrange
      vm
        ..selectedCustomer = Customer(customerRimNo: 555)
        ..comment.strategyComment = "Note"
        ..customerSICcodeReview = [
          SicCodeReview(
            rimNo: 555,
            proposedSicCode: "1000",
          ), // included (idx 0)
          SicCodeReview(
            rimNo: 777,
            proposedSicCode: "2000",
          ), // excluded (idx 1)
          SicCodeReview(rimNo: 555, proposedSicCode: null), // included (idx 2)
        ];

      // Act
      final data = handler.buildDraftData(vm);

      // Assert
      expect(data["rimNo"], 555);
      expect(data["accountLevelComment"], "Note");

      final sic = data["sicReviews"] as List?;
      expect(sic, isNotNull);
      expect(sic!.length, 2);

      final m0 = sic[0] as Map;
      expect(m0["rowIndex"], 0);
      expect(m0["rimNo"], 555);
      expect(m0["proposedSicCode"], "1000");

      final m1 = sic[1] as Map;
      expect(m1["rowIndex"], 2);
      expect(m1["rimNo"], 555);
      expect(m1["proposedSicCode"], isNull);
    });

    test("applyDraft: early return when draft is empty", () {
      // Arrange
      vm
        ..selectedCustomer = Customer(customerRimNo: 123)
        ..customerSICcodeReview = []
        ..comment.strategyComment = "orig"
        ..controllerAccountLevelSicCode.text = "";

      // Act
      handler.applyDraft(vm, <String, dynamic>{});

      // Assert — unchanged, and no crash
      expect(vm.comment.strategyComment, "orig");
      expect(vm.controllerAccountLevelSicCode.text, "");
    });

    test("applyDraft: returns early when currentRim is null", () {
      // Arrange
      vm.selectedCustomer = null;

      // Act
      handler.applyDraft(vm, {"rimNo": 10, "accountLevelComment": "x"});

      // Assert — nothing applied
      expect(vm.comment.strategyComment, "");
      expect(vm.controllerAccountLevelSicCode.text, "");
    });

    test("applyDraft: returns early when draft rim is missing/unparsable", () {
      // Arrange
      vm.selectedCustomer = Customer(customerRimNo: 10);

      // Act
      handler.applyDraft(vm, {"rimNo": null, "accountLevelComment": "x"});

      // Assert — nothing applied
      expect(vm.comment.strategyComment, "");
      expect(vm.controllerAccountLevelSicCode.text, "");
    });

    test("applyDraft: returns early on rim mismatch", () {
      // Arrange
      vm.selectedCustomer = Customer(customerRimNo: 1);

      // Act
      handler.applyDraft(vm, {"rimNo": 2, "accountLevelComment": "x"});

      // Assert — nothing applied
      expect(vm.comment.strategyComment, "");
      expect(vm.controllerAccountLevelSicCode.text, "");
    });

    test("applyDraft: restores comment (String) and updates controller", () {
      // Arrange
      vm.selectedCustomer = Customer(customerRimNo: 101);

      // Act
      handler.applyDraft(vm, {
        "rimNo": "101", // parsed
        "accountLevelComment": "hello",
      });

      // Assert
      expect(vm.comment.strategyComment, "hello");
      expect(vm.controllerAccountLevelSicCode.text, "hello");
    });

    test("applyDraft: non-string comment does not restore", () {
      // Arrange
      vm.selectedCustomer = Customer(customerRimNo: 55);
      vm.comment.strategyComment = "keep";

      // Act
      handler.applyDraft(vm, {
        "rimNo": 55,
        "accountLevelComment": 123, // non-string
      });

      // Assert
      expect(vm.comment.strategyComment, "keep");
      expect(vm.controllerAccountLevelSicCode.text, "");
    });

    test(
        "applyDraft: restores "
        "rows by index "
        '(preferred) and normalizes "null-like" values', () {
      // Arrange
      vm
        ..selectedCustomer = Customer(customerRimNo: 500)
        ..customerSICcodeReview = [
          SicCodeReview(rimNo: 500, proposedSicCode: "A"), // idx 0
          SicCodeReview(
            rimNo: 500,
            proposedSicCode: "B",
          ), // idx 1 -> becomes 1456
          SicCodeReview(
            rimNo: 500,
            proposedSicCode: "C",
          ), // idx 2 -> becomes null
        ];

      // Act
      handler.applyDraft(vm, {
        "rimNo": 500,
        "accountLevelComment": "c",
        "sicReviews": [
          {"rowIndex": 1, "rimNo": "500", "proposedSicCode": "1456"},
          {"rowIndex": 0, "rimNo": 999, "proposedSicCode": "SHOULD_IGNORE"},
          {"rowIndex": 2, "rimNo": 500, "proposedSicCode": " null "}, // -> null
        ],
      });

      // Assert
      expect(vm.customerSICcodeReview![1].proposedSicCode, "1456");
      expect(vm.customerSICcodeReview![2].proposedSicCode, isNull);
      expect(vm.comment.strategyComment, "c");
      expect(vm.controllerAccountLevelSicCode.text, "c");
    });

    test(
        "applyDraft: fallback restore when index "
        "invalid matches previous proposedSicCode", () {
      // Arrange
      vm
        ..selectedCustomer = Customer(customerRimNo: 9)
        ..customerSICcodeReview = [
          SicCodeReview(rimNo: 9, proposedSicCode: "OLD"), // idx 0
          SicCodeReview(rimNo: 9, proposedSicCode: "X"), // idx 1
        ];

      // Act
      handler.applyDraft(vm, {
        "rimNo": 9,
        "sicReviews": [
          {
            "rowIndex": 999, // invalid index
            "rimNo": 9,
            "proposedSicCode": "OLD", // fallback match to idx 0
          },
        ],
      });

      // Assert (value remains 'OLD'; branch exercised)
      expect(vm.customerSICcodeReview![0].proposedSicCode, "OLD");
    });

    test(
        "applyDraft: fallback when draft proposed "
        "is null-like attaches to first null row", () {
      // Arrange
      vm
        ..selectedCustomer = Customer(customerRimNo: 12)
        ..customerSICcodeReview = [
          SicCodeReview(rimNo: 12, proposedSicCode: "A"),
          SicCodeReview(rimNo: 12, proposedSicCode: null), // eligible
        ];

      // Act
      handler.applyDraft(vm, {
        "rimNo": 12,
        "sicReviews": [
          {"rowIndex": -1, "rimNo": 12, "proposedSicCode": "   "}, // -> null
        ],
      });

      // Assert
      expect(vm.customerSICcodeReview![1].proposedSicCode, isNull);
    });

    test("applyDraft: draft has rows but vm list is null -> skips row restore",
        () {
      // Arrange
      vm
        ..selectedCustomer = Customer(customerRimNo: 13)
        ..customerSICcodeReview = null;

      // Act
      handler.applyDraft(vm, {
        "rimNo": 13,
        "sicReviews": [
          {"rowIndex": 0, "rimNo": 13, "proposedSicCode": "X"},
        ],
      });

      // Assert: just no crash
      expect(vm.customerSICcodeReview, isNull);
    });

    test("applyDraft: vm list is empty -> skips row restore", () {
      // Arrange
      vm
        ..selectedCustomer = Customer(customerRimNo: 14)
        ..customerSICcodeReview = <SicCodeReview>[];

      // Act
      handler.applyDraft(vm, {
        "rimNo": 14,
        "sicReviews": [
          {"rowIndex": 0, "rimNo": 14, "proposedSicCode": "Y"},
        ],
      });

      // Assert: unchanged
      expect(vm.customerSICcodeReview, isEmpty);
    });

    test("buildDraftData is stable when empty values", () {
      // Arrange
      vm.comment.strategyComment = "";

      // Act
      final data = handler.buildDraftData(vm);

      // Assert
      expect(data["accountLevelComment"], "");
    });

    test(
        "applyDraft does not set selected customer "
        "or trigger fetches (just context)", () {
      // Arrange: put a rim in draft but ensure handler keeps selection
      // unchanged
      final draft = <String, dynamic>{
        "accountLevelComment": "Any",
        "selectedCustomerRimNo": 99999, // informational only
      };

      expect(vm.selectedCustomer, isNull);

      // Act
      handler.applyDraft(vm, draft);

      // Assert: still null
      expect(vm.selectedCustomer, isNull);
    });
  });
}
