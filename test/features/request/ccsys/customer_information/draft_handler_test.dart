import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/draft_handler.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/ccsys/customer_information.dart";

class MockCustomerVM extends Mock implements CustomerInformationViewModel {}

class FakeCustomerInformationState extends Fake
    implements CustomerInformationState {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeCustomerInformationState());

    // Add these if Mocktail asks for fallback values for setters:
    registerFallbackValue(CcsysCustomerInformation());
    registerFallbackValue(Reference());
  });

  group("CustomerInformationDraftHandler", () {
    late MockCustomerVM vm;
    late CustomerInformationDraftHandler handler;

    late TextEditingController lei;
    late TextEditingController groupImmediate;
    late TextEditingController groupUltimate;
    late TextEditingController capital;
    late TextEditingController turnover;
    late TextEditingController auditor;
    late TextEditingController employees;

    setUp(() {
      vm = MockCustomerVM();
      handler = CustomerInformationDraftHandler();

      lei = TextEditingController();
      groupImmediate = TextEditingController();
      groupUltimate = TextEditingController();
      capital = TextEditingController();
      turnover = TextEditingController();
      auditor = TextEditingController();
      employees = TextEditingController();

      final state = CustomerInformationState(
        loaderStatus: LoadingStatus.loaded,
        borrowerSubsidiary: false,
        legalEntityIdentifier: true,
      );

      when(() => vm.state).thenReturn(state);
      when(() => vm.emit(any<CustomerInformationState>())).thenAnswer((_) {});

      when(() => vm.formKey).thenReturn(GlobalKey<FormState>());

      // -----------------------------
      // Mutable backing fields
      // -----------------------------
      CcsysCustomerInformation customerInfo = CcsysCustomerInformation();
      List<PartnerShareholder> rows = <PartnerShareholder>[];
      final List<PartnerShareholderControllers> ctrls =
          <PartnerShareholderControllers>[];

      Reference? selectedBorrowerSubsidiary;
      Reference? selectedLegalEntityIdentifier;
      Reference? selectedEmirateLicense;
      Reference? selectedEmirateEstablishment;

      // customerInformation getter + setter

      when(() => vm.customerInformation).thenAnswer((_) => customerInfo);

      when(() => vm.customerInformation = any()).thenAnswer((invocation) {
        final value =
            invocation.positionalArguments[0] as CcsysCustomerInformation;
        customerInfo = value;
        return value;
      });

      when(() => vm.rows).thenAnswer((_) => rows);

      when(() => vm.rows = any()).thenAnswer((invocation) {
        final value = List<PartnerShareholder>.from(
          invocation.positionalArguments[0] as List,
        );
        rows = value;
        return value;
      });

      // ctrls getter only (list itself is mutable)
      when(() => vm.ctrls).thenAnswer((_) => ctrls);

      when(() => vm.leiController).thenReturn(lei);
      when(() => vm.controllerGroupImmediate).thenReturn(groupImmediate);
      when(() => vm.controllerGroupUltimate).thenReturn(groupUltimate);
      when(() => vm.capitalController).thenReturn(capital);
      when(() => vm.turnoverController).thenReturn(turnover);
      when(() => vm.auditorController).thenReturn(auditor);
      when(() => vm.numberOfEmployeeController).thenReturn(employees);

      when(() => vm.ccsysEmirateList).thenReturn([
        Reference(id: 26, name: "Dubai Studio City"),
        Reference(id: 27, name: "Dubai Techno Park"),
        Reference(name: "NA"),
      ]);

      when(() => vm.yesNoNaItems).thenReturn([
        Reference(id: ServerConstants.yesRefId, name: "Yes"),
        Reference(id: ServerConstants.noRefId, name: "No"),
      ]);

      when(() => vm.defaultField).thenReturn(Reference(name: "NA"));

      when(() => vm.draftFormKey).thenReturn("customer-information");
      when(() => vm.draftModuleKey).thenReturn("ccsys");
      when(() => vm.ccsysCustomerInformationId).thenReturn(123);

      // selectedBorroweSubsidiary getter + setter
      when(() => vm.selectedBorroweSubsidiary)
          .thenAnswer((_) => selectedBorrowerSubsidiary);
      when(() => vm.selectedBorroweSubsidiary = any()).thenAnswer((invocation) {
        selectedBorrowerSubsidiary =
            invocation.positionalArguments[0] as Reference?;
        return null;
      });

      // selectedLegalEntityIdentifier getter + setter
      when(() => vm.selectedLegalEntityIdentifier)
          .thenAnswer((_) => selectedLegalEntityIdentifier);
      when(() => vm.selectedLegalEntityIdentifier = any())
          .thenAnswer((invocation) {
        selectedLegalEntityIdentifier =
            invocation.positionalArguments[0] as Reference?;
        return null;
      });

      // selectedEmirateLicense getter + setter
      when(() => vm.selectedEmirateLicense)
          .thenAnswer((_) => selectedEmirateLicense);
      when(() => vm.selectedEmirateLicense = any()).thenAnswer((invocation) {
        selectedEmirateLicense =
            invocation.positionalArguments[0] as Reference?;
        return null;
      });

      // selectedEmirateEstablishment getter + setter
      when(() => vm.selectedEmirateEstablishment)
          .thenAnswer((_) => selectedEmirateEstablishment);
      when(() => vm.selectedEmirateEstablishment = any())
          .thenAnswer((invocation) {
        selectedEmirateEstablishment =
            invocation.positionalArguments[0] as Reference?;
        return null;
      });
    });
    //

    test(
        "buildDraftData saves normalized values, booleans,"
        " emirates and row controller data", () {
      lei.text = "  LEI999  ";
      groupImmediate.text = "  Parent 1  ";
      groupUltimate.text = "  Parent 2  ";
      capital.text = " 100000 ";
      turnover.text = " 250000 ";
      auditor.text = "  KPMG  ";
      employees.text = "42";

      when(() => vm.selectedBorroweSubsidiary)
          .thenReturn(Reference(id: ServerConstants.yesRefId, name: "Yes"));
      when(() => vm.selectedLegalEntityIdentifier)
          .thenReturn(Reference(id: ServerConstants.yesRefId, name: "Yes"));
      when(() => vm.selectedEmirateLicense)
          .thenReturn(Reference(id: 26, name: "Dubai Studio City"));
      when(() => vm.selectedEmirateEstablishment)
          .thenReturn(Reference(id: 27, name: "Dubai Techno Park"));

      final ctrl = PartnerShareholderControllers();
      ctrl.name.text = "Alice";
      ctrl.sharePercent.text = "55";
      ctrl.netWorth.text = "1000000";
      ctrl.emiratesId.text = "EID123";
      ctrl.passport.text = "P123";
      ctrl.tradeLicense.text = "TL123";
      ctrl.leiNumber.text = "LEI-P1";

      when(() => vm.ctrls).thenReturn([ctrl]);
      when(() => vm.rows).thenReturn([]);

      final draft = handler.buildDraftData(vm);

      final info = vm.customerInformation;

      expect(info.groupImmediateParent, "Parent 1");
      expect(info.groupUltimateParent, "Parent 2");
      expect(info.leiNumber, "LEI999");
      expect(info.capital, "100000");
      expect(info.turnover, "250000");
      expect(info.auditor, "KPMG");
      expect(info.numberOfEmployee, 42);
      expect(info.borrowerSubsidiary, true);
      expect(info.legalEntityIdentifier, true);
      expect(info.emiLic, "26-Dubai Studio City");
      expect(info.emiEst, "27-Dubai Techno Park");

      expect(draft["formKey"], "customer-information");
      expect(draft["moduleKey"], "ccsys");
      expect(draft["selectedBorroweSubsidiaryId"], ServerConstants.yesRefId);
      expect(
        draft["selectedLegalEntityIdentifierId"],
        ServerConstants.yesRefId,
      );
      expect(draft["ccsysCustomerInformationId"], 123);

      expect(draft["rowControllers"], isA<List>());
      final rowCtrls = draft["rowControllers"] as List;
      expect(rowCtrls, hasLength(1));
      expect(rowCtrls.first["name"], "Alice");
      expect(rowCtrls.first["sharePercent"], "55");
      expect(rowCtrls.first["netWorth"], "1000000");
      expect(rowCtrls.first["emiratesId"], "EID123");
      expect(rowCtrls.first["passport"], "P123");
      expect(rowCtrls.first["tradeLicense"], "TL123");
      expect(rowCtrls.first["leiNumber"], "LEI-P1");

      expect(draft["customerInformation"], isA<Map<String, dynamic>>());
    });

    test(
        "buildDraftData converts "
        "blank strings to "
        "null and invalid employee count to null", () {
      lei.text = "   ";
      groupImmediate.text = "";
      groupUltimate.text = " ";
      capital.text = "";
      turnover.text = " ";
      auditor.text = "";
      employees.text = "abc";

      when(() => vm.selectedBorroweSubsidiary).thenReturn(null);
      when(() => vm.selectedLegalEntityIdentifier).thenReturn(null);
      when(() => vm.selectedEmirateLicense).thenReturn(null);
      when(() => vm.selectedEmirateEstablishment).thenReturn(null);

      final draft = handler.buildDraftData(vm);
      final info = vm.customerInformation;

      expect(info.groupImmediateParent, isNull);
      expect(info.groupUltimateParent, isNull);
      expect(info.leiNumber, isNull);
      expect(info.capital, isNull);
      expect(info.turnover, isNull);
      expect(info.auditor, isNull);
      expect(info.numberOfEmployee, isNull);

      expect(info.borrowerSubsidiary, false);
      expect(info.legalEntityIdentifier, false);
      expect(info.emiLic, isNull);
      expect(info.emiEst, isNull);

      expect(draft["selectedBorroweSubsidiaryId"], isNull);
      expect(draft["selectedLegalEntityIdentifierId"], isNull);
    });

    test(
        "applyDraft with LEI=YES restores emirate references "
        "from id-name code and sets controller texts", () {
      final source = CcsysCustomerInformation()
        ..emiLic = "26-Dubai Studio City"
        ..emiEst = "27-Dubai Techno Park"
        ..leiNumber = "OLD-LEI"
        ..groupImmediateParent = "Old Parent 1"
        ..groupUltimateParent = "Old Parent 2"
        ..capital = "50000"
        ..turnover = "99999"
        ..auditor = "Old Auditor"
        ..numberOfEmployee = 8;

      handler.applyDraft(vm, {
        "customerInformation": jsonEncode(source.toJsonGetCCSYSCustomerInfo()),
        "selectedBorroweSubsidiaryId": ServerConstants.yesRefId,
        "selectedLegalEntityIdentifierId": ServerConstants.yesRefId,
        "leiText": "LEI-NEW",
        "groupImmediateText": "Parent 1",
        "groupUltimateText": "Parent 2",
        "capital": "100000",
        "turnoverText": "200000",
        "auditorText": "KPMG",
        "numberOfEmployeeText": "88",
        "rows": [],
        "rowControllers": [],
      });

      expect(vm.leiController.text, "LEI-NEW");
      expect(vm.controllerGroupImmediate.text, "Parent 1");
      expect(vm.controllerGroupUltimate.text, "Parent 2");
      expect(vm.capitalController.text, "100000");
      expect(vm.turnoverController.text, "200000");
      expect(vm.auditorController.text, "KPMG");
      expect(vm.numberOfEmployeeController.text, "88");

      expect(vm.selectedBorroweSubsidiary?.id, ServerConstants.yesRefId);
      expect(vm.selectedLegalEntityIdentifier?.id, ServerConstants.yesRefId);

      expect(vm.selectedEmirateLicense?.id, 26);
      expect(vm.selectedEmirateLicense?.name, "Dubai Studio City");
      expect(vm.selectedEmirateEstablishment?.id, 27);
      expect(vm.selectedEmirateEstablishment?.name, "Dubai Techno Park");

      expect(vm.customerInformation.emiLic, "Dubai Studio City");
      expect(vm.customerInformation.emiEst, "Dubai Techno Park");
      expect(vm.customerInformation.legalEntityIdentifier, true);

      verify(() => vm.emit(any<CustomerInformationState>()))
          .called(greaterThan(0));
    });

    test("applyDraft restores LEI", () {
      handler.applyDraft(vm, {
        "leiText": "LEI999",
      });

      expect(
        lei.text,
        "LEI999",
      );
    });

    test(
        "applyDraft with LEI=NO forces default "
        "NA emirates and updates model flags", () {
      handler.applyDraft(vm, {
        "customerInformation": {},
        "selectedLegalEntityIdentifierId": ServerConstants.noRefId,
        "rows": [],
        "rowControllers": [],
      });

      expect(vm.selectedLegalEntityIdentifier?.id, ServerConstants.noRefId);
      expect(vm.selectedEmirateLicense?.name, "NA");
      expect(vm.selectedEmirateEstablishment?.name, "NA");
      expect(vm.customerInformation.emiLic, "NA");
      expect(vm.customerInformation.emiEst, "NA");
      expect(vm.customerInformation.legalEntityIdentifier, false);

      verify(() => vm.emit(any<CustomerInformationState>()))
          .called(greaterThan(0));
    });

    test(
        "applyDraft recreates row controllers and prefers "
        "saved rowControllers values over model values", () {
      handler.applyDraft(vm, {
        "rows": [
          {
            "partnerShareholderInEnglish": "Model Name",
            "shareholdingPartnershipPercentage": 10,
            "networthPartnerShareholderAed": "5000",
            "emiratesIdPartnerShareholder": "E-MODEL",
            "passportNumberPartnerShareholder": "P-MODEL",
            "tradeLicenseNumberPartnerShareholder": "TL-MODEL",
            "leiNumberPartnerShareholder": "LEI-MODEL",
          }
        ],
        "rowControllers": [
          {
            "name": "Saved Name",
            "sharePercent": "55",
            "netWorth": "999999",
            "emiratesId": "E-SAVED",
            "passport": "P-SAVED",
            "tradeLicense": "TL-SAVED",
            "leiNumber": "LEI-SAVED",
          }
        ],
      });

      expect(vm.rows, hasLength(1));
      expect(vm.ctrls, hasLength(1));

      final ctrl = vm.ctrls.first;
      expect(ctrl.name.text, "Model Name");
      expect(ctrl.sharePercent.text, "10");
      expect(ctrl.netWorth.text, "5000");
      expect(ctrl.emiratesId.text, "E-MODEL");
      expect(ctrl.passport.text, "P-MODEL");
      expect(ctrl.tradeLicense.text, "TL-MODEL");
      expect(ctrl.leiNumber.text, "LEI-MODEL");

      verify(() => vm.emit(any<CustomerInformationState>()))
          .called(greaterThan(0));
    });

    test(
        "applyDraft falls back to row model values "
        "when rowControllers entry is missing", () {
      handler.applyDraft(vm, {
        "rows": [
          {
            "partnerShareholderInEnglish": "Fallback Name",
            "shareholdingPartnershipPercentage": 15,
            "networthPartnerShareholderAed": "7000",
            "emiratesIdPartnerShareholder": "E-FALLBACK",
            "passportNumberPartnerShareholder": "P-FALLBACK",
            "tradeLicenseNumberPartnerShareholder": "TL-FALLBACK",
            "leiNumberPartnerShareholder": "LEI-FALLBACK",
          }
        ],
        "rowControllers": [],
      });

      expect(vm.rows, hasLength(1));
      expect(vm.ctrls, hasLength(1));

      final ctrl = vm.ctrls.first;
      expect(ctrl.name.text, "Fallback Name");
      expect(ctrl.sharePercent.text, "15");
      expect(ctrl.netWorth.text, "7000");
      expect(ctrl.emiratesId.text, "E-FALLBACK");
      expect(ctrl.passport.text, "P-FALLBACK");
      expect(ctrl.tradeLicense.text, "TL-FALLBACK");
      expect(ctrl.leiNumber.text, "LEI-FALLBACK");
    });

    test("applyDraft restores rows when rows is a JSON string", () {
      final rowsJson = jsonEncode([
        {
          "partnerShareholderInEnglish": "Json Name",
          "shareholdingPartnershipPercentage": 33,
        }
      ]);

      handler.applyDraft(vm, {
        "rows": rowsJson,
        "rowControllers": [],
      });

      expect(vm.rows, hasLength(1));
      expect(vm.ctrls, hasLength(1));
    });

    test(
        "applyDraft handles invalid customerInformation "
        "JSON safely and still emits loaded", () {
      expect(
        () => handler.applyDraft(vm, {
          "customerInformation": "{invalid-json",
          "rows": [],
          "rowControllers": [],
        }),
        returnsNormally,
      );

      verify(() => vm.emit(any<CustomerInformationState>()))
          .called(greaterThan(0));
    });

    test("LEI = NO forces NA", () {
      handler.applyDraft(vm, {
        "selectedLegalEntityIdentifierId": ServerConstants.noRefId,
      });

      expect(vm.selectedEmirateLicense?.name, "NA");
      expect(vm.selectedEmirateEstablishment?.name, "NA");
    });

    test("Partner restore safe", () {
      expect(
        () => handler.applyDraft(vm, {
          "rows": [],
          "rowControllers": [],
        }),
        returnsNormally,
      );
    });
  });
}
