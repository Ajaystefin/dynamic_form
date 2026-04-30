import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/components/comment_history/comments_table.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/layout/state.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// ------------------------------------------------------
/// MOCKS
/// ------------------------------------------------------
class MockLayoutViewModel extends Mock implements LayoutViewModel {}

class FakeBuildContext extends Fake implements BuildContext {}

/// ------------------------------------------------------
/// MOCK EasyLocalization
/// ------------------------------------------------------
extension MockTranslationExtension on String {
  String tr() => this;
}

/// ------------------------------------------------------
/// HELPERS
/// ------------------------------------------------------
Widget buildTestWidget({
  required Widget child,
  required LayoutViewModel viewModel,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(2000, 2000),
      ),
      child: BlocProvider<LayoutViewModel>.value(
        value: viewModel,
        child: Material(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: 1800,
                height: 1200,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Comment buildComment({
  DateTime? createdDate,
  String? user,
  String? comment,
}) {
  return Comment(
    createdDate: createdDate,
    userId: user,
    comment: comment,
  );
}

void main() {
  late MockLayoutViewModel layoutViewModel;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    layoutViewModel = MockLayoutViewModel();

    /// REQUIRED for BlocProvider
    when(() => layoutViewModel.stream)
        .thenAnswer((_) => const Stream<LayoutState>.empty());

    when(() => layoutViewModel.state).thenReturn(
      LayoutState(
        currentRoute: "/",
        hideSideMenu: false,
      ),
    );
  });

  /// ======================================================
  /// BASIC CONSTRUCTOR TESTS
  /// ======================================================
  group("CommentsTableWidget – constructor tests", () {
    test("creates widget instance", () {
      const widget = CommentsTableWidget(comments: []);
      expect(widget, isA<CommentsTableWidget>());
      expect(widget.comments, isEmpty);
    });

    test("handles null fields safely", () {
      final comment = buildComment(
        createdDate: null,
        user: null,
        comment: null,
      );

      expect(() => CommentsTableWidget(comments: [comment]), returnsNormally);
    });

    test("handles large comment list", () {
      final comments = List.generate(
        20,
        (i) => buildComment(
          createdDate: DateTime.now(),
          user: "User $i",
          comment: "Comment $i",
        ),
      );

      expect(() => CommentsTableWidget(comments: comments), returnsNormally);
    });
  });

  /// ======================================================
  /// WIDGET RENDERING TESTS
  /// ======================================================
  group("CommentsTableWidget – widget rendering", () {
    testWidgets("renders table headers", (tester) async {
      await tester.binding.setSurfaceSize(const Size(2000, 2000));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          viewModel: layoutViewModel,
          child: const CommentsTableWidget(comments: []),
        ),
      );

      expect(
        find.text("covenantsConditions.covenantsSummary.timeStamp"),
        findsOneWidget,
      );
      expect(
        find.text("covenantsConditions.covenantsSummary.user"),
        findsOneWidget,
      );
      expect(
        find.text("covenantsConditions.covenantsSummary.comment"),
        findsOneWidget,
      );
    });

    testWidgets("renders short plain text comment", (tester) async {
      const text = "Short comment";

      await tester.binding.setSurfaceSize(const Size(2000, 2000));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          viewModel: layoutViewModel,
          child: CommentsTableWidget(
            comments: [
              buildComment(
                createdDate: DateTime(2023, 1, 1),
                user: "User1",
                comment: text,
              ),
            ],
          ),
        ),
      );

      expect(find.text(text), findsOneWidget);
      expect(find.text("common.viewMore"), findsNothing);
    });

    testWidgets("renders long comment with View More", (tester) async {
      final longText = "A" * 100;

      await tester.binding.setSurfaceSize(const Size(2000, 2000));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          viewModel: layoutViewModel,
          child: CommentsTableWidget(
            comments: [buildComment(comment: longText)],
          ),
        ),
      );

      expect(find.textContaining("…"), findsOneWidget);
      expect(find.text("common.viewMore"), findsOneWidget);
    });

    testWidgets("tapping View More calls corporate dialog", (tester) async {
      final longText = "A" * 100;

      when(() => layoutViewModel.showCommentCorporateDialog(any(), any()))
          .thenAnswer((_) async => true);

      await tester.binding.setSurfaceSize(const Size(2000, 2000));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          viewModel: layoutViewModel,
          child: CommentsTableWidget(
            comments: [buildComment(comment: longText)],
          ),
        ),
      );

      await tester.tap(find.text("common.viewMore"));
      await tester.pump();

      verify(
        () => layoutViewModel.showCommentCorporateDialog(any(), longText),
      ).called(1);
    });
  });

  /// ======================================================
  /// HTML COMMENTS TESTS
  /// ======================================================
  group("CommentsTableWidget – html comments", () {
    testWidgets("shows View Comment button", (tester) async {
      await tester.binding.setSurfaceSize(const Size(2000, 2000));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          viewModel: layoutViewModel,
          child: CommentsTableWidget(
            comments: [buildComment(comment: "<p>Hello</p>")],
            ishtmlComment: true,
          ),
        ),
      );

      expect(find.text("common.viewComment"), findsOneWidget);
    });

    testWidgets("tapping View Comment opens html dialog", (tester) async {
      const html = "<p>Hello</p>";

      when(() => layoutViewModel.showCommentDialog(any(), any()))
          .thenAnswer((_) async => true);

      await tester.binding.setSurfaceSize(const Size(2000, 2000));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          viewModel: layoutViewModel,
          child: CommentsTableWidget(
            comments: [buildComment(comment: html)],
            ishtmlComment: true,
          ),
        ),
      );

      await tester.tap(find.text("common.viewComment"));
      await tester.pump();

      verify(() => layoutViewModel.showCommentDialog(any(), html)).called(1);
    });
  });
}
