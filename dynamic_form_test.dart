import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wcas_frontend/core/components/dynamic_form/dynamic_form.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/row_element.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';

void main() {
  group('DynamicForm', () {
    late List<Section> testSections;
    late Map<String, dynamic> testDocument;
    late GlobalKey formKey;

    setUp(() {
      formKey = GlobalKey<FormState>();
      testDocument = {};

      // Create test data
      final field1 = DynamicField(
        controlType: FieldType.textField,
        key: 'test_field_1',
        label: 'Test Field 1',
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      final field2 = DynamicField(
        controlType: FieldType.dropdown,
        key: 'test_field_2',
        label: 'Test Field 2',
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: 'Option 1', pairValue: 'value1'),
          Option(key: 'Option 2', pairValue: 'value2'),
        ],
      );

      final rowElement1 = RowElement(fields: [field1, field2]);
      final rowElement2 = RowElement(fields: []);
      final rowElement3 = RowElement(fields: null);

      testSections = [
        Section(rows: [rowElement1, rowElement2, rowElement3]),
        Section(rows: null),
      ];
    });

    testWidgets('renders DynamicForm with sections and fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicForm(
              key: formKey,
              sections: testSections,
              document: testDocument,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicForm), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('handles empty sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicForm(
              key: formKey,
              sections: const [],
              document: testDocument,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicForm), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('handles sections with null rows', (WidgetTester tester) async {
      final sectionsWithNullRows = [Section(rows: null)];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicForm(
              key: formKey,
              sections: sectionsWithNullRows,
              document: testDocument,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicForm), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('handles rows with null fields', (WidgetTester tester) async {
      final sectionsWithNullFields = [
        Section(rows: [RowElement(fields: null)])
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicForm(
              key: formKey,
              sections: sectionsWithNullFields,
              document: testDocument,
            ),
          ),
        ),
      );

      expect(find.byType(DynamicForm), findsOneWidget);
    });

    testWidgets('creates form with correct key', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicForm(
              key: formKey,
              sections: testSections,
              document: testDocument,
            ),
          ),
        ),
      );

      final form = tester.widget<Form>(find.byType(Form));
      expect(form.key, equals(formKey));
    });

    testWidgets('renders fields in rows with correct spacing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicForm(
              key: formKey,
              sections: testSections,
              document: testDocument,
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsAtLeastNWidgets(1));
      expect(find.byType(Expanded), findsNWidgets(2));
    });
  });
}
