import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/draft_handler.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/certification_data.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("OtherCertificationsDraftHandler", () {
    late OtherCertificationsViewModel viewModel;
    late OtherCertificationsDraftHandler handler;

    setUp(() {
      viewModel = OtherCertificationsViewModel();
      handler = OtherCertificationsDraftHandler();
    });

    test("buildDraftData serializes state to JSON", () {
      // Arrange
      final certInfo1 = Reference(id: 111, name: "Cert 1");
      final certInfo2 = Reference(id: 222, name: "Cert 2");
      final optionYes = Reference(id: 1, name: "YES", reference1: "YES");
      final optionNo = Reference(id: 2, name: "NO", reference1: "NO");

      final certData1 = CertificationData(
        appCertificationId: 1,
        certificateInformation: certInfo1,
        selectedOption: optionYes,
        remarks: "Test remarks 1",
      );

      final certData2 = CertificationData(
        appCertificationId: 2,
        certificateInformation: certInfo2,
        selectedOption: optionNo,
        remarks: "Test remarks 2",
      );

      viewModel.certificationDataMap = {
        111: certData1,
        222: certData2,
      };

      // Act
      final draftData = handler.buildDraftData(viewModel);

      // Assert
      expect(draftData.length, 2);

      final data1 = draftData["111"] as Map<String, dynamic>;
      expect(data1["selectedOptionId"], 1);
      expect(data1["remarks"], "Test remarks 1");

      final data2 = draftData["222"] as Map<String, dynamic>;
      expect(data2["selectedOptionId"], 2);
      expect(data2["remarks"], "Test remarks 2");
    });

    test("applyDraft restores draft values into live map", () {
      // Arrange
      final optionYes = Reference(id: 1, name: "YES");
      final optionNo = Reference(id: 2, name: "NO");

      viewModel.yesNoNaOptions = [optionYes, optionNo];

      final certData1 = CertificationData(
        appCertificationId: 1,
        certificateInformation: Reference(id: 111),
        selectedOption: optionYes,
        remarks: "Original 1",
      );

      final certData2 = CertificationData(
        appCertificationId: 2,
        certificateInformation: Reference(id: 222),
        selectedOption: optionYes,
        remarks: "Original 2",
      );

      certData1.isUpdated = false;
      certData2.isUpdated = false;

      viewModel.certificationDataMap = {
        111: certData1,
        222: certData2,
      };

      final draftJson = {
        "111": {
          "selectedOptionId": 2,
          "remarks": "New Remarks 1",
        },
        "222": {
          "selectedOptionId": 1,
          "remarks": "New Remarks 2",
        },
      };

      // Act
      handler.applyDraft(viewModel, draftJson);

      // Assert
      expect(viewModel.certificationDataMap[111]!.selectedOption?.id, 2);
      expect(viewModel.certificationDataMap[111]!.selectedOption, optionNo);
      expect(viewModel.certificationDataMap[111]!.remarks, "New Remarks 1");
      expect(viewModel.certificationDataMap[111]!.isUpdated, true);

      expect(viewModel.certificationDataMap[222]!.selectedOption?.id, 1);
      expect(viewModel.certificationDataMap[222]!.selectedOption, optionYes);
      expect(viewModel.certificationDataMap[222]!.remarks, "New Remarks 2");
      expect(viewModel.certificationDataMap[222]!.isUpdated, true);
    });

    test("applyDraft handles missing draft fields gracefully", () {
      // Arrange
      final optionYes = Reference(id: 1, name: "YES");
      viewModel.yesNoNaOptions = [optionYes];

      final certData = CertificationData(
        appCertificationId: 1,
        certificateInformation: Reference(id: 333),
        selectedOption: optionYes,
        remarks: "Original",
      );

      viewModel.certificationDataMap = {
        333: certData,
      };

      // Empty or unmapped data
      final draftJson = {
        "999": {
          "selectedOptionId": 2,
          "remarks": "Unmatched",
        },
      };

      // Act
      handler.applyDraft(viewModel, draftJson);

      // Assert - should remain unchanged
      expect(viewModel.certificationDataMap[333]!.selectedOption?.id, 1);
      expect(viewModel.certificationDataMap[333]!.remarks, "Original");
      expect(viewModel.certificationDataMap[333]!.isUpdated, false);
    });
  });
}
