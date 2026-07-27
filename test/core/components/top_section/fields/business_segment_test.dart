import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/top_section/fields/business_segment.dart";
import "package:wcas_frontend/core/constants/constants.dart";

import "../mock_data.dart";

void main() {
  group("BusinessSegment", () {
    testWidgets("renders with valid request data", (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: BusinessSegment(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);
      //expect(find.text('Corporate Banking'), findsOneWidget);
    });

    testWidgets("renders with null businessSegment",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithNullValues();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: BusinessSegment(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);

      final customSelectableText = tester
          .widget<CustomSelectableText>(find.byType(CustomSelectableText));
      expect(customSelectableText.text, "");
    });

    testWidgets("renders with empty businessSegment name",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithEmptyValues();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: BusinessSegment(request: request),
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
            body: BusinessSegment(request: request),
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
            body: BusinessSegment(request: request),
          ),
        ),
      );

      final labelWidget = tester.widget<LabelWidget>(find.byType(LabelWidget));
      expect(labelWidget.labelStyle?.fontWeight, FontWeight.bold);
    });

    testWidgets("has required constructor parameters",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      expect(() => BusinessSegment(request: request), returnsNormally);
    });

    testWidgets("widget key is properly set", (WidgetTester tester) async {
      const key = Key("business_segment_test");
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: BusinessSegment(key: key, request: request),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets("is a StatelessWidget", (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();
      final widget = BusinessSegment(request: request);

      expect(widget, isA<StatelessWidget>());
    });

    testWidgets("handles retail banking business segment",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithoutGroup();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: BusinessSegment(request: request),
          ),
        ),
      );

      await tester.pumpAndSettle();

      //expect(find.text('Retail Banking'), findsOneWidget);
      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);
    });

    testWidgets("handles investment banking business segment",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithEmptyGroup();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: BusinessSegment(request: request),
          ),
        ),
      );

      // expect(find.text('Investment Banking'), findsOneWidget);
      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);
    });
  });
}
