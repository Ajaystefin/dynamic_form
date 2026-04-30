import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/draft_handler.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("CommonTabsDraftHandler", () {
    late CommonTabsViewModel viewModel;
    late CommonTabsDraftHandler handler;

    setUp(() {
      viewModel = CommonTabsViewModel();
      handler = CommonTabsDraftHandler();
    });

    test("buildDraftData serializes state to JSON", () {
      // Arrange
      viewModel.rteController.setInternalText("Test Strategy Comment");

      // Act
      final draftData = handler.buildDraftData(viewModel);

      // Assert
      expect(draftData["strategyComment"], "Test Strategy Comment");
    });

    test("applyDraft restores draft values when commentData exists", () {
      // Arrange
      viewModel.commentData = Comment(strategyComment: "Old Comment");

      final draftJson = {
        "strategyComment": "New Comment",
      };

      // Act
      handler.applyDraft(viewModel, draftJson);

      // Assert
      expect(viewModel.commentData!.strategyComment, "New Comment");
    });

    test("applyDraft restores draft values when commentData is null", () {
      // Arrange
      viewModel.commentData = null;

      final draftJson = {
        "strategyComment": "New Comment",
      };

      // Act
      handler.applyDraft(viewModel, draftJson);

      // Assert
      expect(viewModel.commentData!.strategyComment, "New Comment");
    });

    test("applyDraft handles missing draft fields gracefully", () {
      // Arrange
      viewModel.commentData = Comment(strategyComment: "Original Comment");

      final Map<String, dynamic> emptyDraftJson = {};

      // Act
      handler.applyDraft(viewModel, emptyDraftJson);

      // Assert - Should remain unchanged
      expect(viewModel.commentData!.strategyComment, "Original Comment");
    });
  });
}
