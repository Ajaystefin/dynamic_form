import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/section_background.dart";
import "package:wcas_frontend/core/components/top_section/fields/application_no.dart";
import "package:wcas_frontend/core/components/top_section/fields/business_segment.dart";
import "package:wcas_frontend/core/components/top_section/fields/customer_name.dart";
import "package:wcas_frontend/core/components/top_section/fields/group_name.dart";
import "package:wcas_frontend/core/components/top_section/fields/request_type.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";

import "mock_data.dart";

void main() {
  group("TopSectionDetails", () {
    testWidgets("renders SectionBackground wrapper",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopSectionDetails(request: request),
          ),
        ),
      );

      expect(find.byType(SectionBackground), findsOneWidget);
    });

    group("Mobile layout", () {
      // testWidgets('displays Column layout on mobile screen',
      //     (WidgetTester tester) async {
      //   final request = MockTopSectionData.createFullRequest();

      //   await tester.binding.setSurfaceSize(const Size(400, 800));
      //   await tester.pumpWidget(
      //     MaterialApp(
      //       home: Scaffold(
      //         body: TopSectionDetails(request: request),
      //       ),
      //     ),
      //   );

      //   // expect(find.byType(Column), findsOneWidget);
      //   expect(find.byType(Row), findsWidgets);

      //   final column = tester.widget<Column>(find.byType(Column));
      //   expect(column.crossAxisAlignment, CrossAxisAlignment.start);
      // });

      testWidgets("displays all field components on mobile when group exists",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopSectionDetails(request: request),
            ),
          ),
        );

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsOneWidget);
        expect(find.byType(BusinessSegment), findsOneWidget);
        expect(find.byType(RequestType), findsOneWidget);
      });

      testWidgets("excludes GroupName when groupName is null",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithoutGroup();

        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopSectionDetails(request: request),
            ),
          ),
        );

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsNothing);
        // expect(find.byType(BusinessSegment), findsNothing);
        expect(find.byType(RequestType), findsOneWidget);
      });

      testWidgets("excludes GroupName when groupName is empty",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithEmptyGroup();

        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopSectionDetails(request: request),
            ),
          ),
        );

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsNothing);
        // expect(find.byType(BusinessSegment), findsNothing);
        expect(find.byType(RequestType), findsOneWidget);
      });
    });

    group("Desktop/Tablet layout", () {
      testWidgets("displays Row layout on desktop screen",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopSectionDetails(request: request),
            ),
          ),
        );

        // Desktop layout should use Row for arranging field components
        final rows = find.byType(Row);
        expect(rows, findsAtLeastNWidgets(1));

        // Desktop layout should wrap fields in Expanded widgets
        expect(find.byType(Expanded), findsAtLeastNWidgets(3));
      });

      testWidgets("wraps field components in Expanded widgets on desktop",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopSectionDetails(request: request),
            ),
          ),
        );

        final expandedWidgets = find.byType(Expanded);
        expect(
          expandedWidgets,
          findsNWidgets(5),
        ); // All 4 components should be wrapped

        expect(
          find.descendant(
            of: expandedWidgets.at(0),
            matching: find.byType(ApplicationNo),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: expandedWidgets.at(1),
            matching: find.byType(CustomerName),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: expandedWidgets.at(2),
            matching: find.byType(GroupName),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: expandedWidgets.at(3),
            matching: find.byType(BusinessSegment),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: expandedWidgets.at(4),
            matching: find.byType(RequestType),
          ),
          findsOneWidget,
        );
      });

      testWidgets(
          "excludes GroupName Expanded wrapper when"
          " groupName is null on desktop", (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithoutGroup();

        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopSectionDetails(request: request),
            ),
          ),
        );

        final expandedWidgets = find.byType(Expanded);
        expect(expandedWidgets, findsNWidgets(4)); // Only 4 components

        expect(find.byType(GroupName), findsNothing);
      });
    });

    group("sectionFields method", () {
      testWidgets("returns correct widgets for mobile layout",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final topSection = TopSectionDetails(request: request);
                  final fields = topSection.sectionFields(context);

                  return Column(children: fields);
                },
              ),
            ),
          ),
        );

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsOneWidget);
        expect(find.byType(BusinessSegment), findsOneWidget);
        expect(find.byType(RequestType), findsOneWidget);
        // Mobile layout should have no Expanded widgets from field components
        // themselves
        // (Note: Other parts of the UI might still have Expanded widgets)
      });

      testWidgets("returns correct widgets for desktop layout",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final topSection = TopSectionDetails(request: request);
                  final fields = topSection.sectionFields(context);

                  return Row(children: fields);
                },
              ),
            ),
          ),
        );

        expect(find.byType(Expanded), findsNWidgets(5));
        expect(
          find.descendant(
            of: find.byType(Expanded),
            matching: find.byType(ApplicationNo),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(Expanded),
            matching: find.byType(CustomerName),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(Expanded),
            matching: find.byType(GroupName),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(Expanded),
            matching: find.byType(BusinessSegment),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(Expanded),
            matching: find.byType(RequestType),
          ),
          findsOneWidget,
        );
      });
    });

    testWidgets("handles null request gracefully", (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithNullValues();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopSectionDetails(request: request),
          ),
        ),
      );

      expect(find.byType(TopSectionDetails), findsOneWidget);
      expect(find.byType(SectionBackground), findsOneWidget);
    });
  });
}
