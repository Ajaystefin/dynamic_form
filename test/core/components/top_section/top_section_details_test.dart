import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/section_background.dart";
import "package:wcas_frontend/core/components/top_section/fields/application_no.dart";
import "package:wcas_frontend/core/components/top_section/fields/business_segment.dart";
import "package:wcas_frontend/core/components/top_section/fields/customer_name.dart";
import "package:wcas_frontend/core/components/top_section/fields/group_name.dart";
import "package:wcas_frontend/core/components/top_section/fields/request_type.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/models/request/request.dart";

import "mock_data.dart";

Future<void> pumpTopSectionDetails(
  WidgetTester tester, {
  required Request request,
  required Size size,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
        ),
        child: Scaffold(
          body: TopSectionDetails(request: request),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> pumpSectionFieldsOnly(
  WidgetTester tester, {
  required Request request,
  required Size size,
  required Widget Function(List<Widget> fields) builder,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
        ),
        child: Scaffold(
          body: Builder(
            builder: (context) {
              final topSection = TopSectionDetails(request: request);
              final fields = topSection.sectionFields(context);

              return builder(fields);
            },
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group("TopSectionDetails", () {
    testWidgets("renders SectionBackground wrapper",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createFullRequest();

      await pumpTopSectionDetails(
        tester,
        request: request,
        size: const Size(1200, 800),
      );

      expect(find.byType(TopSectionDetails), findsOneWidget);
      expect(find.byType(SectionBackground), findsOneWidget);
    });

    group("Mobile layout", () {
      testWidgets("uses SizedBox and Column layout on mobile screen",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(400, 800),
        );

        final sectionBackground = tester.widget<SectionBackground>(
          find.byType(SectionBackground),
        );

        expect(sectionBackground.child, isA<SizedBox>());

        final sizedBox = sectionBackground.child as SizedBox;

        expect(sizedBox.width, double.infinity);
        expect(sizedBox.child, isA<Column>());

        final column = sizedBox.child! as Column;

        expect(column.spacing, 10);
        expect(column.crossAxisAlignment, CrossAxisAlignment.start);
        expect(column.children.length, 5);
      });

      testWidgets("displays all field components on mobile when values exist",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(400, 800),
        );

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsOneWidget);
        expect(find.byType(BusinessSegment), findsOneWidget);
        expect(find.byType(RequestType), findsOneWidget);
      });

      testWidgets("does not wrap mobile field widgets with Expanded",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(400, 800),
        );

        final sectionBackground = tester.widget<SectionBackground>(
          find.byType(SectionBackground),
        );

        final sizedBox = sectionBackground.child as SizedBox;
        final column = sizedBox.child! as Column;

        expect(column.children.whereType<Expanded>(), isEmpty);
        expect(column.children.whereType<ApplicationNo>(), hasLength(1));
        expect(column.children.whereType<CustomerName>(), hasLength(1));
        expect(column.children.whereType<GroupName>(), hasLength(1));
        expect(column.children.whereType<BusinessSegment>(), hasLength(1));
        expect(column.children.whereType<RequestType>(), hasLength(1));
      });

      testWidgets("excludes GroupName on mobile when groupName is null",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithoutGroup();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(400, 800),
        );

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsNothing);
        expect(find.byType(BusinessSegment), findsOneWidget);
        expect(find.byType(RequestType), findsOneWidget);
      });

      testWidgets("excludes GroupName on mobile when groupName is empty",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithEmptyGroup();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(400, 800),
        );

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsNothing);
        expect(find.byType(BusinessSegment), findsOneWidget);
        expect(find.byType(RequestType), findsOneWidget);
      });

      testWidgets("renders only RequestType on mobile when optional values are null",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithNullValues();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(400, 800),
        );

        expect(find.byType(ApplicationNo), findsNothing);
        expect(find.byType(CustomerName), findsNothing);
        expect(find.byType(GroupName), findsNothing);
        expect(find.byType(BusinessSegment), findsNothing);
        expect(find.byType(RequestType), findsOneWidget);

        final sectionBackground = tester.widget<SectionBackground>(
          find.byType(SectionBackground),
        );

        final sizedBox = sectionBackground.child as SizedBox;
        final column = sizedBox.child! as Column;

        expect(column.children.length, 1);
        expect(column.children.first, isA<RequestType>());
      });
    });

    group("Desktop and tablet layout", () {
      testWidgets("uses Row layout on desktop screen",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(1200, 800),
        );

        final sectionBackground = tester.widget<SectionBackground>(
          find.byType(SectionBackground),
        );

        expect(sectionBackground.child, isA<Row>());

        final row = sectionBackground.child as Row;

        expect(row.spacing, 10);
        expect(row.crossAxisAlignment, CrossAxisAlignment.start);
        expect(row.children.length, 5);
        expect(row.children.every((child) => child is Expanded), isTrue);
      });

      testWidgets("wraps all field components in Expanded widgets on desktop",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(1200, 800),
        );

        final expandedWidgets = find.byType(Expanded);

        expect(expandedWidgets, findsNWidgets(5));

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

      testWidgets("excludes GroupName Expanded wrapper when groupName is null",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithoutGroup();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(1200, 800),
        );

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsNothing);
        expect(find.byType(BusinessSegment), findsOneWidget);
        expect(find.byType(RequestType), findsOneWidget);

        expect(find.byType(Expanded), findsNWidgets(4));
      });

      testWidgets("excludes GroupName Expanded wrapper when groupName is empty",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithEmptyGroup();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(1200, 800),
        );

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsNothing);
        expect(find.byType(BusinessSegment), findsOneWidget);
        expect(find.byType(RequestType), findsOneWidget);

        expect(find.byType(Expanded), findsNWidgets(4));
      });

      testWidgets("renders only RequestType Expanded when optional values are null",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithNullValues();

        await pumpTopSectionDetails(
          tester,
          request: request,
          size: const Size(1200, 800),
        );

        expect(find.byType(ApplicationNo), findsNothing);
        expect(find.byType(CustomerName), findsNothing);
        expect(find.byType(GroupName), findsNothing);
        expect(find.byType(BusinessSegment), findsNothing);
        expect(find.byType(RequestType), findsOneWidget);

        expect(find.byType(Expanded), findsOneWidget);

        expect(
          find.descendant(
            of: find.byType(Expanded),
            matching: find.byType(RequestType),
          ),
          findsOneWidget,
        );
      });
    });

    group("sectionFields method", () {
      testWidgets("returns direct field widgets for mobile layout",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();
        late List<Widget> capturedFields;

        await pumpSectionFieldsOnly(
          tester,
          request: request,
          size: const Size(400, 800),
          builder: (fields) {
            capturedFields = fields;

            return Column(
              children: fields,
            );
          },
        );

        expect(capturedFields.length, 5);
        expect(capturedFields.whereType<Expanded>(), isEmpty);
        expect(capturedFields.whereType<ApplicationNo>(), hasLength(1));
        expect(capturedFields.whereType<CustomerName>(), hasLength(1));
        expect(capturedFields.whereType<GroupName>(), hasLength(1));
        expect(capturedFields.whereType<BusinessSegment>(), hasLength(1));
        expect(capturedFields.whereType<RequestType>(), hasLength(1));

        expect(find.byType(ApplicationNo), findsOneWidget);
        expect(find.byType(CustomerName), findsOneWidget);
        expect(find.byType(GroupName), findsOneWidget);
        expect(find.byType(BusinessSegment), findsOneWidget);
        expect(find.byType(RequestType), findsOneWidget);
      });

      testWidgets("returns Expanded field widgets for desktop layout",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createFullRequest();
        late List<Widget> capturedFields;

        await pumpSectionFieldsOnly(
          tester,
          request: request,
          size: const Size(1200, 800),
          builder: (fields) {
            capturedFields = fields;

            return Row(
              children: fields,
            );
          },
        );

        expect(capturedFields.length, 5);
        expect(capturedFields.whereType<Expanded>(), hasLength(5));

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

      testWidgets("sectionFields returns only RequestType on mobile for null values",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithNullValues();
        late List<Widget> capturedFields;

        await pumpSectionFieldsOnly(
          tester,
          request: request,
          size: const Size(400, 800),
          builder: (fields) {
            capturedFields = fields;

            return Column(
              children: fields,
            );
          },
        );

        expect(capturedFields.length, 1);
        expect(capturedFields.first, isA<RequestType>());
        expect(capturedFields.whereType<Expanded>(), isEmpty);

        expect(find.byType(ApplicationNo), findsNothing);
        expect(find.byType(CustomerName), findsNothing);
        expect(find.byType(GroupName), findsNothing);
        expect(find.byType(BusinessSegment), findsNothing);
        expect(find.byType(RequestType), findsOneWidget);
      });

      testWidgets("sectionFields returns only RequestType Expanded on desktop for null values",
          (WidgetTester tester) async {
        final request = MockTopSectionData.createRequestWithNullValues();
        late List<Widget> capturedFields;

        await pumpSectionFieldsOnly(
          tester,
          request: request,
          size: const Size(1200, 800),
          builder: (fields) {
            capturedFields = fields;

            return Row(
              children: fields,
            );
          },
        );

        expect(capturedFields.length, 1);
        expect(capturedFields.first, isA<Expanded>());

        expect(find.byType(ApplicationNo), findsNothing);
        expect(find.byType(CustomerName), findsNothing);
        expect(find.byType(GroupName), findsNothing);
        expect(find.byType(BusinessSegment), findsNothing);
        expect(find.byType(RequestType), findsOneWidget);
        expect(find.byType(Expanded), findsOneWidget);

        expect(
          find.descendant(
            of: find.byType(Expanded),
            matching: find.byType(RequestType),
          ),
          findsOneWidget,
        );
      });
    });

    testWidgets("handles request with null values gracefully",
        (WidgetTester tester) async {
      final request = MockTopSectionData.createRequestWithNullValues();

      await pumpTopSectionDetails(
        tester,
        request: request,
        size: const Size(1200, 800),
      );

      expect(find.byType(TopSectionDetails), findsOneWidget);
      expect(find.byType(SectionBackground), findsOneWidget);
      expect(find.byType(RequestType), findsOneWidget);
    });
  });
}
