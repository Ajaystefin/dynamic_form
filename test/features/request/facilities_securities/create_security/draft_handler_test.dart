import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/draft_handler.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/country.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("CreateSecurityDraftHandler", () {
    late CreateSecurityViewModel viewModel;
    late CreateSecurityDraftHandler handler;

    setUp(() {
      viewModel = CreateSecurityViewModel();
      handler = CreateSecurityDraftHandler();
    });

    test("buildDraftData serializes state to JSON", () {
      // Arrange
      viewModel.security.securityGroup =
          Reference(id: 1, name: "Group 1", isActive: true);
      viewModel.security.securityProviderCategory = "Individual";
      viewModel.security.proposedSecurityAmount = 1000.50;
      viewModel.security.securityProvidedCountry =
          Country(code: "AE", description: "United Arab Emirates");
      viewModel.security.securityExpireDate = DateTime(2025, 12, 31);

      viewModel
        ..dynamicFormDocument = {"testKey": "testValue"}
        ..isEntityProvider = true
        ..proposedSecurityAmountController.text = "1000.50";

      // Act
      final draftData = handler.buildDraftData(viewModel);

      // Assert
      expect(draftData["securityGroup"]["id"], 1);
      expect(draftData["securityGroup"]["name"], "Group 1");
      expect(draftData["securityProviderCategory"], "Individual");
      expect(draftData["proposedSecurityAmount"], 1000.50);
      expect(draftData["securityProvidedCountry"]["code"], "AE");
      expect(
        draftData["securityExpireDate"],
        DateTime(2025, 12, 31).toIso8601String(),
      );
      expect(draftData["dynamicFormDocument"]["testKey"], "testValue");
      expect(draftData["isEntityProvider"], true);
      expect(draftData["proposedSecurityAmountControllerText"], "1000.50");
    });

    test("applyDraft restores draft values into live state", () {
      // Arrange
      final draftJson = {
        "securityGroup": {
          "id": 2,
          "name": "Group 2",
          "isActive": true,
        },
        "securityProviderCategory": "Corporate",
        "proposedSecurityAmount": 2000.75,
        "securityProvidedCountry": {
          "code": "US",
          "description": "United States",
        },
        "securityExpireDate": DateTime(2026, 1, 1).toIso8601String(),
        "dynamicFormDocument": {"restoredKey": "restoredValue"},
        "isEntityProvider": false,
        "proposedSecurityAmountControllerText": "2000.75",
      };

      // Act
      handler.applyDraft(viewModel, draftJson);

      // Assert
      expect(viewModel.security.securityGroup?.id, 2);
      expect(viewModel.security.securityGroup?.name, "Group 2");
      expect(viewModel.security.securityProviderCategory, "Corporate");
      expect(viewModel.security.proposedSecurityAmount, 2000.75);
      expect(viewModel.security.securityProvidedCountry?.code, "US");
      expect(viewModel.security.securityExpireDate, DateTime(2026, 1, 1));
      expect(viewModel.dynamicFormDocument["restoredKey"], "restoredValue");
      expect(viewModel.isEntityProvider, false);
      expect(viewModel.proposedSecurityAmountController.text, "2000.75");
    });

    test("applyDraft handles missing draft fields gracefully", () {
      // Arrange
      viewModel.security.securityGroup = Reference(id: 1, name: "Original");
      viewModel.security.proposedSecurityAmount = 500.0;
      viewModel.dynamicFormDocument = {"original": true};

      final Map<String, dynamic> emptyDraftJson = {};

      // Act
      handler.applyDraft(viewModel, emptyDraftJson);

      // Assert - Should remain unchanged
      expect(viewModel.security.securityGroup?.name, "Original");
      expect(viewModel.security.proposedSecurityAmount, 500.0);
      expect(viewModel.dynamicFormDocument["original"], true);
    });
  });
}
