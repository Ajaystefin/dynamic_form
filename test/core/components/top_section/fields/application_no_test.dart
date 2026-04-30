import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/top_section/fields/application_no.dart";
import "package:wcas_frontend/core/constants/constants.dart";

import "../mock_data.dart";

void main() {
  group("ApplicationNo", () {
    testWidgets("renders with valid request data", (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: ApplicationNo(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);
      expect(find.text("APP-001-2024"), findsOneWidget);
    });

    testWidgets("renders with null applicationRefNo",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithNullValues();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: ApplicationNo(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);

      // Find CustomSelectableText widget and verify it displays empty string
      final customSelectableText = tester
          .widget<CustomSelectableText>(find.byType(CustomSelectableText));
      expect(customSelectableText.text, "");
    });

    testWidgets("renders with empty applicationRefNo",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithEmptyValues();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: ApplicationNo(request: request),
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
            body: ApplicationNo(request: request),
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
            body: ApplicationNo(request: request),
          ),
        ),
      );

      final labelWidget = tester.widget<LabelWidget>(find.byType(LabelWidget));
      expect(labelWidget.labelStyle?.fontWeight, FontWeight.bold);
    });

    testWidgets("has required constructor parameters",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      expect(() => ApplicationNo(request: request), returnsNormally);
    });

    testWidgets("widget key is properly set", (WidgetTester tester) async {
      const key = Key("application_no_test");
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: ApplicationNo(key: key, request: request),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets("is a StatelessWidget", (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();
      final widget = ApplicationNo(request: request);

      expect(widget, isA<StatelessWidget>());
    });
  });
}
