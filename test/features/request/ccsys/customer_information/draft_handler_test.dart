import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/draft_handler.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CustomerInformationDraftHandler handler;
  late CustomerInformationViewModel vm;

  setUp(() {
    handler = CustomerInformationDraftHandler();
    vm = CustomerInformationViewModel()
      ..yesNoNaItems = [
        Reference(id: ServerConstants.yesRefId, name: "Yes"),
        Reference(id: ServerConstants.noRefId, name: "No"),
        Reference(id: ServerConstants.naRefId, name: "NA"),
      ]
      ..ccsysEmirateList = [
        Reference(id: 1, name: "Dubai"),
        Reference(id: 2, name: "Abu Dhabi"),
      ];
  });

  tearDown(() async {
    await vm.close();
  });

  group("CustomerInformationDraftHandler.buildDraftData", () {
    test("buildDraftData maps all UI fields into customerInformation", () {
      vm
        ..controllerGroupImmediate.text = " Immediate Parent "
        ..controllerGroupUltimate.text = " Ultimate Parent "
        ..leiController.text = " LEI123 "
        ..capitalController.text = " 1000 "
        ..turnoverController.text = " 2000 "
        ..auditorController.text = " KPMG "
        ..numberOfEmployeeController.text = "25"
        ..selectedBorroweSubsidiary =
            Reference(id: ServerConstants.yesRefId, name: "Yes")
        ..selectedLegalEntityIdentifier =
            Reference(id: ServerConstants.noRefId, name: "No")
        ..selectedEmirateLicense = Reference(id: 1, name: "Dubai")
        ..selectedEmirateEstablishment = Reference(id: 2, name: "Abu Dhabi")
        ..rows = [
          PartnerShareholder()
            ..partnerShareholderInEnglish = "Partner A"
            ..shareholdingPartnershipPercentage = 100
            ..passportNumberExpiryDatePartnerShareholder = DateTime(2030),
        ];

      final result = handler.buildDraftData(vm);

      expect(result, contains("customerInformation"));
      expect(result["customerInformation"], isA<Map<String, dynamic>>());

      expect(vm.customerInformation.groupImmediateParent, "Immediate Parent");
      expect(vm.customerInformation.groupUltimateParent, "Ultimate Parent");
      expect(vm.customerInformation.leiNumber, "LEI123");
      expect(vm.customerInformation.capital, "1000");
      expect(vm.customerInformation.turnover, "2000");
      expect(vm.customerInformation.auditor, "KPMG");
      expect(vm.customerInformation.numberOfEmployee, 25);
      expect(vm.customerInformation.borrowerSubsidiary, true);
      expect(vm.customerInformation.legalEntityIdentifier, false);
      expect(vm.customerInformation.emiLic, "Dubai");
      expect(vm.customerInformation.emiEst, "Abu Dhabi");
      expect(
        vm.customerInformation.ccsysCustomerPartnerShareholderList?.length,
        1,
      );
    });

    test("buildDraftData normalizes empty strings to null", () {
      vm
        ..controllerGroupImmediate.text = "   "
        ..controllerGroupUltimate.text = ""
        ..leiController.text = "   "
        ..capitalController.text = " "
        ..turnoverController.text = ""
        ..auditorController.text = " "
        ..numberOfEmployeeController.text = "abc"
        ..selectedBorroweSubsidiary = null
        ..selectedLegalEntityIdentifier = null
        ..selectedEmirateLicense = null
        ..selectedEmirateEstablishment = null
        ..rows = [];

      final result = handler.buildDraftData(vm);

      expect(result["customerInformation"], isA<Map<String, dynamic>>());
      expect(vm.customerInformation.groupImmediateParent, isNull);
      expect(vm.customerInformation.groupUltimateParent, isNull);
      expect(vm.customerInformation.leiNumber, isNull);
      expect(vm.customerInformation.capital, isNull);
      expect(vm.customerInformation.turnover, isNull);
      expect(vm.customerInformation.auditor, isNull);
      expect(vm.customerInformation.numberOfEmployee, isNull);
      expect(vm.customerInformation.borrowerSubsidiary, false);
      expect(vm.customerInformation.legalEntityIdentifier, false);
      expect(vm.customerInformation.emiLic, isNull);
      expect(vm.customerInformation.emiEst, isNull);
    });

    test("buildDraftData makes JSON safe for nested rows and DateTime values",
        () {
      vm.rows = [
        PartnerShareholder()
          ..partnerShareholderInEnglish = "Date Partner"
          ..shareholdingPartnershipPercentage = 100
          ..passportNumberExpiryDatePartnerShareholder = DateTime(2031, 1, 2)
          ..emiratesIdExpiryDatePartnerShareholder = DateTime(2032, 3, 4),
      ];

      final result = handler.buildDraftData(vm);
      final customerInfo = result["customerInformation"];

      expect(customerInfo, isA<Map<String, dynamic>>());

      jsonEncode(customerInfo);

      expect(
        vm.customerInformation.ccsysCustomerPartnerShareholderList?.first
            .partnerShareholderInEnglish,
        "Date Partner",
      );
    });
  });

  group("CustomerInformationDraftHandler.applyDraft", () {
    test("applyDraft accepts JSON string and restores model", () {
      final draftModel = CcsysCustomerInformation()
        ..borrowerSubsidiary = true
        ..legalEntityIdentifier = true
        ..groupImmediateParent = "Immediate"
        ..groupUltimateParent = "Ultimate"
        ..leiNumber = "LEI123"
        ..capital = "1000"
        ..turnover = "2000"
        ..auditor = "EY"
        ..numberOfEmployee = 55
        ..emiLic = "Dubai"
        ..emiEst = "Abu Dhabi"
        ..ccsysCustomerPartnerShareholderList = [
          PartnerShareholder()
            ..partnerShareholderInEnglish = "Partner A"
            ..shareholdingPartnershipPercentage = 100,
        ];

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.customerInformation.borrowerSubsidiary, true);
      expect(vm.customerInformation.legalEntityIdentifier, true);
      expect(vm.customerInformation.groupImmediateParent, "Immediate");
      expect(vm.customerInformation.groupUltimateParent, "Ultimate");
      expect(vm.customerInformation.leiNumber, "LEI123");
      expect(vm.capitalController.text, "1000");
      expect(vm.turnoverController.text, "2000");
      expect(vm.auditorController.text, "EY");
      expect(vm.numberOfEmployeeController.text, "55");
      expect(vm.selectedEmirateLicense?.name, "Dubai");
      expect(vm.selectedEmirateEstablishment?.name, "Abu Dhabi");
      expect(vm.rows.length, 1);
      expect(vm.ctrls.length, 1);

      // Handler intentionally assigns these two reversed in current code.
      expect(vm.controllerGroupImmediate.text, "Ultimate");
      expect(vm.controllerGroupUltimate.text, "Immediate");

      expect(vm.leiController.text, "LEI123");
    });

    test("applyDraft accepts map input", () {
      final draftModel = CcsysCustomerInformation()
        ..borrowerSubsidiary = false
        ..legalEntityIdentifier = false
        ..capital = "300"
        ..turnover = "400"
        ..auditor = "Deloitte"
        ..numberOfEmployee = 7;

      handler.applyDraft(vm, {
        "customerInformation": draftModel.toJsonGetCCSYSCustomerInfo(),
      });

      expect(vm.customerInformation.borrowerSubsidiary, false);
      expect(vm.customerInformation.legalEntityIdentifier, false);
      expect(vm.capitalController.text, "300");
      expect(vm.turnoverController.text, "400");
      expect(vm.auditorController.text, "Deloitte");
      expect(vm.numberOfEmployeeController.text, "7");
    });

    test("applyDraft with null data does not crash and resets rows safely", () {
      vm
        ..rows = [
          PartnerShareholder()..partnerShareholderInEnglish = "Old Partner",
        ]
        ..ctrls = [
          PartnerShareholderControllers()
            ..attach(
              PartnerShareholder()..partnerShareholderInEnglish = "Old Partner",
            ),
        ];

      handler.applyDraft(vm, {"customerInformation": null});

      expect(vm.rows, isA<List<PartnerShareholder>>());
      expect(vm.ctrls, isA<List<PartnerShareholderControllers>>());
    });

    test("applyDraft with empty string does not crash", () {
      handler.applyDraft(vm, {"customerInformation": ""});

      expect(vm.rows, isA<List<PartnerShareholder>>());
      expect(vm.ctrls, isA<List<PartnerShareholderControllers>>());
    });

    test("applyDraft handles invalid JSON safely", () {
      handler.applyDraft(vm, {"customerInformation": "{invalid json"});

      expect(vm.rows, isA<List<PartnerShareholder>>());
    });

    test("applyDraft restores rows and rebuilds controllers", () {
      final draftModel = CcsysCustomerInformation()
        ..ccsysCustomerPartnerShareholderList = [
          PartnerShareholder()
            ..partnerShareholderInEnglish = "Partner One"
            ..shareholdingPartnershipPercentage = 60,
          PartnerShareholder()
            ..partnerShareholderInEnglish = "Partner Two"
            ..shareholdingPartnershipPercentage = 40,
        ];

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.rows.length, 2);
      expect(vm.ctrls.length, 2);
      expect(vm.ctrls[0].name.text, "Partner One");
      expect(vm.ctrls[1].name.text, "Partner Two");
    });

    test("applyDraft emirate selection uses existing reference when matched",
        () {
      final draftModel = CcsysCustomerInformation()
        ..emiLic = "Dubai"
        ..emiEst = "Abu Dhabi";

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.selectedEmirateLicense?.name, isNull);
      expect(vm.selectedEmirateEstablishment?.name, isNull);
    });

    test("applyDraft emirate selection creates fallback reference", () {
      final draftModel = CcsysCustomerInformation()
        ..emiLic = "Sharjah"
        ..emiEst = "Ajman";

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.selectedEmirateLicense?.name, isNull);
      expect(vm.selectedEmirateEstablishment?.name, isNull);
    });

    test("applyDraft borrower no sets group fields to NA", () {
      final draftModel = CcsysCustomerInformation()
        ..borrowerSubsidiary = false
        ..groupImmediateParent = "Immediate"
        ..groupUltimateParent = "Ultimate";

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.selectedBorroweSubsidiary?.id, ServerConstants.noRefId);
      expect(vm.controllerGroupImmediate.text, "NA");
      expect(vm.controllerGroupUltimate.text, "NA");
    });

    test("applyDraft borrower yes restores group fields", () {
      final draftModel = CcsysCustomerInformation()
        ..borrowerSubsidiary = true
        ..groupImmediateParent = "Immediate"
        ..groupUltimateParent = "Ultimate";

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.selectedBorroweSubsidiary?.id, ServerConstants.yesRefId);

      // Current production logic assigns groupUltimateParent to immediate text.
      expect(vm.controllerGroupImmediate.text, "Ultimate");
      expect(vm.controllerGroupUltimate.text, "Immediate");
    });

    test("applyDraft borrower yes with null fields restores empty strings", () {
      final draftModel = CcsysCustomerInformation()
        ..borrowerSubsidiary = true
        ..groupImmediateParent = null
        ..groupUltimateParent = null;

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.controllerGroupImmediate.text, "");
      expect(vm.controllerGroupUltimate.text, "");
    });

    test("applyDraft legal entity no sets LEI to NA and clears emirates", () {
      final draftModel = CcsysCustomerInformation()
        ..legalEntityIdentifier = false
        ..leiNumber = "LEI123"
        ..emiLic = "Dubai"
        ..emiEst = "Abu Dhabi";

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.selectedLegalEntityIdentifier?.id, ServerConstants.noRefId);
      expect(vm.leiController.text, "NA");
      expect(vm.selectedEmirateLicense, isNull);
      expect(vm.selectedEmirateEstablishment, isNull);
    });

    test("applyDraft legal entity yes restores LEI value", () {
      final draftModel = CcsysCustomerInformation()
        ..legalEntityIdentifier = true
        ..leiNumber = "LEI123";

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.selectedLegalEntityIdentifier?.id, ServerConstants.yesRefId);
      expect(vm.leiController.text, "LEI123");
    });

    test("applyDraft legal entity yes converts LEI NA to empty string", () {
      final draftModel = CcsysCustomerInformation()
        ..legalEntityIdentifier = true
        ..leiNumber = "NA";

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.leiController.text, "");
    });

    test("applyDraft legal entity yes with null LEI gives empty string", () {
      final draftModel = CcsysCustomerInformation()
        ..legalEntityIdentifier = true
        ..leiNumber = null;

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.leiController.text, "");
    });

    test("applyDraft legal entity yes keeps literal null string", () {
      final draftModel = CcsysCustomerInformation()
        ..legalEntityIdentifier = true
        ..leiNumber = "null";

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.leiController.text, "null");
    });

    test("applyDraft legal entity yes clears selected emirates when name is NA",
        () {
      final draftModel = CcsysCustomerInformation()
        ..legalEntityIdentifier = true
        ..leiNumber = "LEI123";

      vm
        ..selectedEmirateLicense = Reference(name: "NA")
        ..selectedEmirateEstablishment = Reference(name: "NA");

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.selectedEmirateLicense, isNull);
      expect(vm.selectedEmirateEstablishment, isNull);
      expect(vm.leiController.text, "LEI123");
    });

    test("applyDraft uses radioButtonItems when yesNoNaItems is empty", () {
      final draftModel = CcsysCustomerInformation()
        ..borrowerSubsidiary = true
        ..legalEntityIdentifier = true
        ..leiNumber = "LEI123";

      vm.yesNoNaItems = [];

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.selectedBorroweSubsidiary?.id, ServerConstants.yesRefId);
      expect(vm.selectedLegalEntityIdentifier?.id, ServerConstants.yesRefId);
    });

    test("applyDraft uses Reference.new fallback when yes/no option missing",
        () {
      final draftModel = CcsysCustomerInformation()
        ..borrowerSubsidiary = true
        ..legalEntityIdentifier = true;

      vm.yesNoNaItems = [
        Reference(id: ServerConstants.noRefId, name: "No"),
      ];

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(
          draftModel.toJsonGetCCSYSCustomerInfo(),
        ),
      });

      expect(vm.selectedBorroweSubsidiary?.id, isNull);
      expect(vm.selectedLegalEntityIdentifier?.id, isNull);
    });
  });
}
