import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/draft_handler.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/model.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/profitability/business_volume.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("BusinessVolumeDraftHandler", () {
    late BusinessVolumeViewModel viewModel;
    late BusinessVolumeDraftHandler handler;

    setUp(() {
      viewModel = BusinessVolumeViewModel();
      handler = BusinessVolumeDraftHandler();
    });

    test("buildDraftData serializes state to JSON", () {
      // Arrange
      viewModel.comments = "Test comment";

      final customer1 = Customer(customerRimNo: 12345);
      final customer2 = Customer(customerRimNo: 67890);

      final bv1 = BusinessVolume(estimatesForNextYear: "1000");
      final bv2 = BusinessVolume(estimatesForNextYear: "2000");
      final bv3 = BusinessVolume(estimatesForNextYear: "3000");

      viewModel.customerWiseBusinessVolume = {
        customer1: [bv1, bv2],
        customer2: [bv3],
      };

      // Act
      final draftData = handler.buildDraftData(viewModel);

      // Assert
      expect(draftData["comments"], "Test comment");

      final volumesByCustomer =
          draftData["businessVolumesByCustomer"] as Map<String, dynamic>;
      expect(volumesByCustomer.length, 2);

      final customer1Volumes = volumesByCustomer["12345"] as List<dynamic>;
      expect(customer1Volumes.length, 2);
      expect(customer1Volumes[0]["estimatesForNextYear"], "1000");
      expect(customer1Volumes[1]["estimatesForNextYear"], "2000");

      final customer2Volumes = volumesByCustomer["67890"] as List<dynamic>;
      expect(customer2Volumes.length, 1);
      expect(customer2Volumes[0]["estimatesForNextYear"], "3000");
    });

    test("applyDraft restores draft values into live map", () {
      // Arrange
      // Setup live map first (applyDraft expects live structure to exist)
      final customer1 = Customer(customerRimNo: 12345);
      final customer2 = Customer(customerRimNo: 67890);

      final bv1 = BusinessVolume(estimatesForNextYear: "old_1");
      final bv2 = BusinessVolume(estimatesForNextYear: "old_2");
      final bv3 = BusinessVolume(estimatesForNextYear: "old_3");

      viewModel.customerWiseBusinessVolume = {
        customer1: [bv1, bv2],
        customer2: [bv3],
      };

      final draftJson = {
        "comments": "Restored comment",
        "businessVolumesByCustomer": {
          "12345": [
            {"estimatesForNextYear": "new_1"},
            {"estimatesForNextYear": "new_2"},
          ],
          "67890": [
            {"estimatesForNextYear": "new_3"},
          ],
        },
      };

      // Act
      handler.applyDraft(viewModel, draftJson);

      // Assert
      expect(viewModel.comments, "Restored comment");

      // Verify the objects *inside* the map were mutated
      expect(
        viewModel
            .customerWiseBusinessVolume[customer1]![0].estimatesForNextYear,
        "new_1",
      );
      expect(
        viewModel
            .customerWiseBusinessVolume[customer1]![1].estimatesForNextYear,
        "new_2",
      );
      expect(
        viewModel
            .customerWiseBusinessVolume[customer2]![0].estimatesForNextYear,
        "new_3",
      );
    });

    test("applyDraft handles missing draft fields gracefully", () {
      // Arrange
      viewModel.comments = "Original comment";
      final customer = Customer(customerRimNo: 111);
      final bv = BusinessVolume(estimatesForNextYear: "Original estimate");

      viewModel.customerWiseBusinessVolume = {
        customer: [bv],
      };

      final Map<String, dynamic> emptyDraftJson = {};

      // Act
      handler.applyDraft(viewModel, emptyDraftJson);

      // Assert - Should remain unchanged
      expect(viewModel.comments, "Original comment");
      expect(
        viewModel.customerWiseBusinessVolume[customer]![0].estimatesForNextYear,
        "Original estimate",
      );
    });

    test("applyDraft only updates if list lengths match", () {
      // Arrange
      final customer = Customer(customerRimNo: 222);
      final bv = BusinessVolume(estimatesForNextYear: "Original estimate");

      viewModel.customerWiseBusinessVolume = {
        customer: [bv], // Live data has 1 item
      };

      final draftJson = {
        "businessVolumesByCustomer": {
          "222": [
            {"estimatesForNextYear": "Draft 1"},
            {"estimatesForNextYear": "Draft 2"}, // Draft has 2 items
          ],
        },
      };

      // Act
      handler.applyDraft(viewModel, draftJson);

      // Assert - Should not have updated the estimates since lengths mismatch
      expect(
        viewModel.customerWiseBusinessVolume[customer]![0].estimatesForNextYear,
        "Original estimate",
      );
    });
  });
}
