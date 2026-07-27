import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Holds processed comment data for display and editing.
class ProcessCommentResult {
  /// Creates a processed comment result.
  const ProcessCommentResult({
    required this.comments,
    required this.isCommentVisible,
    required this.reviewCommentId,
    required this.initialText,
  });

  /// Comments remaining after processing the current user's editable comment.
  final List<Comment> comments;

  /// Indicates whether comment history should be visible.
  final bool isCommentVisible;

  /// Review comment identifier for the current user's comment.
  final String reviewCommentId;

  /// Initial text to populate in the comment editor.
  final String initialText;
}

/// Utility class for processing comments based on the current user and role.
class ProcessComments {
  /// Processes the given comments and separates current user's editable comment.
  static ProcessCommentResult process(
    List<Comment> comments,
  ) {
    if (comments.isEmpty || comments.firstOrNull == null) {
      return const ProcessCommentResult(
        comments: [],
        isCommentVisible: false,
        reviewCommentId: "0",
        initialText: "",
      );
    }

    bool isCommentVisible = false;
    if (comments.length == 1) {
      isCommentVisible = comments.first.userId != Globals.user?.id ||
          comments.first.userRole != Globals.user?.currentRole?.roleId;
    } else {
      isCommentVisible = true;
    }

    final Comment comment = comments.first;
    String reviewCommentId = "0";
    String initialText = "";

    if (comment.userId == Globals.user?.id &&
        comment.userRole == Globals.user?.currentRole?.roleId) {
      reviewCommentId = comment.reviewCommentId ?? "0";
      initialText = comment.comment ?? "";

      comments = List.of(comments)
        ..removeWhere(
          (c) => c.reviewCommentId == comment.reviewCommentId,
        );
    }

    return ProcessCommentResult(
      comments: comments,
      isCommentVisible: isCommentVisible,
      reviewCommentId: reviewCommentId,
      initialText: initialText,
    );
  }
}
