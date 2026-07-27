import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/top_section/fields/request_type.dart";
import "package:wcas_frontend/core/constants/constants.dart";

import "../mock_data.dart";

void main() {
  group("RequestType", () {
    testWidgets("renders with valid request data", (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: RequestType(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);
    });

    testWidgets("renders with null requestType", (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithNullValues();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: RequestType(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);

      final customSelectableText = tester
          .widget<CustomSelectableText>(find.byType(CustomSelectableText));
      expect(customSelectableText.text, "");
    });

    testWidgets("renders with empty requestType name",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithEmptyValues();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: RequestType(request: request),
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
            body: RequestType(request: request),
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
            body: RequestType(request: request),
          ),
        ),
      );

      final labelWidget = tester.widget<LabelWidget>(find.byType(LabelWidget));
      expect(labelWidget.labelStyle?.fontWeight, FontWeight.bold);
    });

    testWidgets("has required constructor parameters",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      expect(() => RequestType(request: request), returnsNormally);
    });

    testWidgets("widget key is properly set", (WidgetTester tester) async {
      const key = Key("request_type_test");
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: RequestType(key: key, request: request),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
    });

    testWidgets("is a StatelessWidget", (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();
      final widget = RequestType(request: request);

      expect(widget, isA<StatelessWidget>());
    });

    testWidgets("handles loan application request type",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithoutGroup();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: RequestType(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);
    });

    testWidgets("handles investment advisory request type",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithEmptyGroup();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: RequestType(request: request),
          ),
        ),
      );

      expect(find.byType(LabelWidget), findsOneWidget);
      expect(find.byType(CustomSelectableText), findsOneWidget);
    });
  });
}
