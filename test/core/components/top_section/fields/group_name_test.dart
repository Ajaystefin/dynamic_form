import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/top_section/fields/group_name.dart";
import "package:wcas_frontend/core/constants/constants.dart";

import "../mock_data.dart";

void main() {
  group("GroupName", () {
    testWidgets("renders with valid request data", (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: GroupName(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);
      expect(find.text("Test Group Holdings"), findsOneWidget);
    });

    testWidgets("renders with null groupName", (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithNullValues();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: GroupName(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);

      final customSelectableText = tester
          .widget<CustomSelectableText>(find.byType(CustomSelectableText));
      expect(customSelectableText.text, "");
    });

    testWidgets("renders with empty groupName", (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithEmptyValues();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: GroupName(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);

      final customSelectableText = tester
          .widget<CustomSelectableText>(find.byType(CustomSelectableText));
      expect(customSelectableText.text, "");
    });

    testWidgets("applies correct text style", (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: GroupName(request: request),
          ),
        ),
      );

      final customSelectableText = tester
          .widget<CustomSelectableText>(find.byType(CustomSelectableText));
      expect(customSelectableText.style?.color, AppColors.black);
    });

    testWidgets("applies bold font weight to label",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: GroupName(request: request),
          ),
        ),
      );

      final labelWidget = tester.widget<LabelWidget>(find.byType(LabelWidget));
      expect(labelWidget.labelStyle?.fontWeight, FontWeight.bold);
    });

    testWidgets("has required constructor parameters",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      expect(() => GroupName(request: request), returnsNormally);
    });

    testWidgets("widget key is properly set", (WidgetTester tester) async {
      const key = Key("group_name_test");
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: GroupName(key: key, request: request),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets("is a StatelessWidget", (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();
      final widget = GroupName(request: request);

      expect(widget, isA<StatelessWidget>());
    });

    testWidgets("handles request without group correctly",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithoutGroup();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: GroupName(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);

      final customSelectableText = tester
          .widget<CustomSelectableText>(find.byType(CustomSelectableText));
      expect(customSelectableText.text, "");
    });

    testWidgets("handles request with empty group name correctly",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithEmptyGroup();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: GroupName(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);

      final customSelectableText = tester
          .widget<CustomSelectableText>(find.byType(CustomSelectableText));
      expect(customSelectableText.text, "");
    });
  });
}
