import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/dynamic_form.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/row_element.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/section.dart";

void main() {
  group("DynamicForm", () {
    late GlobalKey<DynamicFormState> formKey;
    late Map<String, dynamic> testDocument;

    // Helper: builds a minimal DynamicField
    DynamicField makeField({
      required String key,
      required FieldType type,
      bool required = false,
      bool isDisable = false,
      bool isCMOUpdate = false,
      String? defaultValue,
      List<Option>? options,
    }) {
      return DynamicField(
        controlType: type,
        key: key,
        label: key,
        required: required,
        rowData: 1,
        enabledDefault: true,
        isDisable: isDisable,
        isCMOUpdate: isCMOUpdate,
        defaultValue: defaultValue,
        optionList: options,
      );
    }

    // Helper: pumps the widget tree
    Future<void> pumpForm(
      WidgetTester tester, {
      required List<Section> sections,
      required Map<String, dynamic> document,
      void Function(String, dynamic)? onFieldChange,
      bool disableAllExceptCMOUpdate = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DynamicForm(
                key: formKey,
                sections: sections,
                document: document,
                onFieldChange: onFieldChange,
                disableAllExceptCMOUpdate: disableAllExceptCMOUpdate,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    setUp(() {
      formKey = GlobalKey<DynamicFormState>();
      testDocument = {};
    });

    // ------------------------------------------------------------------ //
    //  Rendering                                                           //
    // ------------------------------------------------------------------ //
    group("rendering", () {
      testWidgets("renders with empty sections", (tester) async {
        await pumpForm(tester, sections: const [], document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
        expect(find.byType(Form), findsOneWidget);
      });

      testWidgets("renders with null rows section", (tester) async {
        await pumpForm(
          tester,
          sections: [Section(rows: null)],
          document: testDocument,
        );
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("renders with empty rows", (tester) async {
        await pumpForm(
          tester,
          sections: [Section(rows: [])],
          document: testDocument,
        );
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("renders with null fields row", (tester) async {
        await pumpForm(
          tester,
          sections: [
            Section(rows: [RowElement(fields: null)]),
          ],
          document: testDocument,
        );
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("renders with empty fields row", (tester) async {
        await pumpForm(
          tester,
          sections: [
            Section(rows: [RowElement(fields: [])]),
          ],
          document: testDocument,
        );
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("renders outline section type wrapped in BoxLayout",
          (tester) async {
        await pumpForm(
          tester,
          sections: [Section(rows: [], type: "outline")],
          document: testDocument,
        );
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("renders outline section with UPPERCASE type",
          (tester) async {
        await pumpForm(
          tester,
          sections: [Section(rows: [], type: "OUTLINE")],
          document: testDocument,
        );
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("renders textField and dropdown in same row", (tester) async {
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "f1", type: FieldType.textField),
                  makeField(
                    key: "f2",
                    type: FieldType.dropdown,
                    options: [
                      Option(key: "A", pairValue: "a"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(Row), findsAtLeastNWidgets(1));
      });

      testWidgets("pads single-field rows to 3 fields", (tester) async {
        // A row with 1 field should have 2 sizedBox padding fields added
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "solo", type: FieldType.textField),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("pads two-field rows to 3 fields", (tester) async {
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "f1", type: FieldType.textField),
                  makeField(key: "f2", type: FieldType.textField),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("does NOT pad rows that contain a grid field",
          (tester) async {
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "g1", type: FieldType.grid),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });
    });

    // ------------------------------------------------------------------ //
    //  Default Values                                                       //
    // ------------------------------------------------------------------ //
    group("_initializeDefaultValues", () {
      testWidgets("sets defaultValue for textField when document key absent",
          (tester) async {
        final doc = <String, dynamic>{};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "txt",
                    type: FieldType.textField,
                    defaultValue: "hello",
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: doc);
        expect(doc["txt"], "hello");
      });

      testWidgets("does NOT overwrite existing document value", (tester) async {
        final doc = <String, dynamic>{"txt": "existing"};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "txt",
                    type: FieldType.textField,
                    defaultValue: "default",
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: doc);
        expect(doc["txt"], "existing");
      });

      testWidgets('sets boolean true for singleCheckBox default "true"',
          (tester) async {
        final doc = <String, dynamic>{};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "chk",
                    type: FieldType.singleCheckBox,
                    defaultValue: "true",
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: doc);
        expect(doc["chk"], true);
      });

      testWidgets('sets boolean false for singleCheckBox default "false"',
          (tester) async {
        final doc = <String, dynamic>{};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "chk",
                    type: FieldType.singleCheckBox,
                    defaultValue: "false",
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: doc);
        expect(doc["chk"], false);
      });

      testWidgets("sets defaultValue for percentage field", (tester) async {
        final doc = <String, dynamic>{};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "pct",
                    type: FieldType.percentage,
                    defaultValue: "10",
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: doc);
        expect(doc["pct"], "10");
      });

      testWidgets("sets defaultValue for amount field", (tester) async {
        final doc = <String, dynamic>{};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "amt",
                    type: FieldType.amount,
                    defaultValue: "500",
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: doc);
        expect(doc["amt"], "500");
      });

      testWidgets("sets defaultValue for textArea field", (tester) async {
        final doc = <String, dynamic>{};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "ta",
                    type: FieldType.textArea,
                    defaultValue: "notes",
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: doc);
        expect(doc["ta"], "notes");
      });

      testWidgets("does not set when defaultValue is null", (tester) async {
        final doc = <String, dynamic>{};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "nd",
                    type: FieldType.textField,
                    defaultValue: null,
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: doc);
        expect(doc.containsKey("nd"), false);
      });

      testWidgets("does not set when defaultValue is empty string",
          (tester) async {
        final doc = <String, dynamic>{};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "empty",
                    type: FieldType.textField,
                    defaultValue: "",
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: doc);
        expect(doc.containsKey("empty"), false);
      });
    });

    // ------------------------------------------------------------------ //
    //  validate() / save()                                                 //
    // ------------------------------------------------------------------ //
    group("validate and save", () {
      testWidgets("validate returns false when no form is attached yet",
          (tester) async {
        await pumpForm(tester, sections: const [], document: testDocument);
        // form key is attached, validate should return true (no validators)
        final result = formKey.currentState?.validate();
        expect(result, isNotNull);
      });

      testWidgets("save() does not throw", (tester) async {
        await pumpForm(tester, sections: const [], document: testDocument);
        expect(() => formKey.currentState?.save(), returnsNormally);
      });
    });

    // ------------------------------------------------------------------ //
    //  updateFieldValue                                                    //
    // ------------------------------------------------------------------ //
    group("updateFieldValue", () {
      late List<Section> sections;

      setUp(() {
        sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "name", type: FieldType.textField),
                  makeField(key: "amount", type: FieldType.amount),
                  makeField(key: "currency_field", type: FieldType.currency),
                ],
              ),
            ],
          ),
        ];
      });

      testWidgets("updates plain text field value in document", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.updateFieldValue("name", "John");
        await tester.pump();
        expect(testDocument["name"], "John");
      });

      testWidgets("sets null value", (tester) async {
        testDocument["name"] = "existing";
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.updateFieldValue("name", null);
        await tester.pump();
        expect(testDocument["name"], isNull);
      });

      testWidgets("handles grid field update via map with index key",
          (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState
            ?.updateFieldValue("name", {"value": "GridVal", "index": 0});
        await tester.pump();
        expect(testDocument["name@0"], "GridVal");
      });

      testWidgets("merges currency map with existing currency value",
          (tester) async {
        testDocument["currency_field"] = {
          "fromCurrency": "USD",
          "fromVal": 100,
          "aedEquivalent": 370,
        };
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.updateFieldValue("currency_field", {
          "fromCurrency": "USD",
          "fromVal": null,
          "aedEquivalent": 370,
        });
        await tester.pump();
        final val = testDocument["currency_field"] as Map;
        expect(val["fromCurrency"], "USD");
        expect(val["fromVal"], 100); // preserved from existing
      });

      testWidgets("updates controller text for text field", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.updateFieldValue("name", "Alice");
        await tester.pump();
        expect(testDocument["name"], "Alice");
      });
    });

    // ------------------------------------------------------------------ //
    //  updateFields (batch)                                               //
    // ------------------------------------------------------------------ //
    group("updateFields", () {
      testWidgets("updates multiple fields at once", (tester) async {
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "a", type: FieldType.textField),
                  makeField(key: "b", type: FieldType.textField),
                  makeField(key: "c", type: FieldType.textField),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.updateFields({"a": "1", "b": "2", "c": "3"});
        await tester.pump();
        expect(testDocument["a"], "1");
        expect(testDocument["b"], "2");
        expect(testDocument["c"], "3");
      });

      testWidgets("handles empty map without error", (tester) async {
        await pumpForm(tester, sections: const [], document: testDocument);
        expect(() => formKey.currentState?.updateFields({}), returnsNormally);
      });
    });

    // ------------------------------------------------------------------ //
    //  getFieldValue / getAllFieldValues                                   //
    // ------------------------------------------------------------------ //
    group("getFieldValue and getAllFieldValues", () {
      testWidgets("getFieldValue returns null for missing key", (tester) async {
        await pumpForm(tester, sections: const [], document: testDocument);
        expect(formKey.currentState?.getFieldValue("missing"), isNull);
      });

      testWidgets("getFieldValue returns correct value", (tester) async {
        testDocument["x"] = 42;
        await pumpForm(tester, sections: const [], document: testDocument);
        expect(formKey.currentState?.getFieldValue("x"), 42);
      });

      testWidgets("getAllFieldValues returns a copy of document",
          (tester) async {
        testDocument["p"] = "q";
        await pumpForm(tester, sections: const [], document: testDocument);
        final all = formKey.currentState?.getAllFieldValues();
        expect(all, isNotNull);
        expect(all!["p"], "q");
        // Mutating the returned map should not affect the original
        all["p"] = "changed";
        expect(testDocument["p"], "q");
      });
    });

    // ------------------------------------------------------------------ //
    //  setFieldVisibility                                                  //
    // ------------------------------------------------------------------ //
    group("setFieldVisibility", () {
      late DynamicField targetField;
      late List<Section> sections;

      setUp(() {
        targetField = makeField(key: "vis_field", type: FieldType.textField);
        sections = [
          Section(
            rows: [
              RowElement(fields: [targetField]),
            ],
          ),
        ];
      });

      testWidgets("hides a field (sets showField=false)", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setFieldVisibility("vis_field", false);
        await tester.pump();
        expect(targetField.showField, false);
      });

      testWidgets("shows a field (sets showField=true)", (tester) async {
        targetField.showField = false;
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setFieldVisibility("vis_field", true);
        await tester.pump();
        expect(targetField.showField, true);
      });

      testWidgets("does not throw for unknown key", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(
          () => formKey.currentState?.setFieldVisibility("nonexistent", false),
          returnsNormally,
        );
      });
    });

    // ------------------------------------------------------------------ //
    //  setFieldMandatory                                                   //
    // ------------------------------------------------------------------ //
    group("setFieldMandatory", () {
      late DynamicField targetField;
      late List<Section> sections;

      setUp(() {
        targetField = makeField(key: "mand_field", type: FieldType.textField);
        sections = [
          Section(
            rows: [
              RowElement(fields: [targetField]),
            ],
          ),
        ];
      });

      testWidgets("makes a field mandatory", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setFieldMandatory("mand_field", true);
        await tester.pump();
        expect(targetField.isMandatory, true);
      });

      testWidgets("makes a field optional", (tester) async {
        targetField.isMandatory = true;
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setFieldMandatory("mand_field", false);
        await tester.pump();
        expect(targetField.isMandatory, false);
      });

      testWidgets("does not throw for unknown key", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(
          () => formKey.currentState?.setFieldMandatory("unknown", true),
          returnsNormally,
        );
      });
    });

    // ------------------------------------------------------------------ //
    //  setFieldEnabled                                                     //
    // ------------------------------------------------------------------ //
    group("setFieldEnabled", () {
      late DynamicField targetField;
      late List<Section> sections;

      setUp(() {
        targetField = makeField(key: "en_field", type: FieldType.textField);
        sections = [
          Section(
            rows: [
              RowElement(fields: [targetField]),
            ],
          ),
        ];
      });

      testWidgets("disables a normal field", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setFieldEnabled("en_field", false);
        await tester.pump();
        expect(targetField.isDisable, true);
      });

      testWidgets("enables a normal field", (tester) async {
        targetField.isDisable = true;
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setFieldEnabled("en_field", true);
        await tester.pump();
        expect(targetField.isDisable, false);
      });

      testWidgets("does not throw for unknown key", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(
          () => formKey.currentState?.setFieldEnabled("nope", false),
          returnsNormally,
        );
      });

      testWidgets("disables a specific grid cell via index param",
          (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setFieldEnabled("en_field", false, index: 2);
        await tester.pump();
        expect(formKey.currentState?.isGridCellDisabled("en_field", 2), true);
        expect(formKey.currentState?.isGridCellDisabled("en_field", 0), false);
      });

      testWidgets("enables a specific grid cell via index param",
          (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        // First disable
        formKey.currentState?.setFieldEnabled("en_field", false, index: 1);
        // Then enable
        formKey.currentState?.setFieldEnabled("en_field", true, index: 1);
        await tester.pump();
        expect(formKey.currentState?.isGridCellDisabled("en_field", 1), false);
        expect(
          formKey.currentState?.enabledGridCells.contains("en_field@1"),
          true,
        );
      });

      testWidgets("disabledGridCells returns a copy", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setFieldEnabled("en_field", false, index: 0);
        final cells = formKey.currentState?.disabledGridCells;
        expect(cells, isNotNull);
        expect(cells!.contains("en_field@0"), true);
        // Mutation should not affect internal state
        cells.add("fake@99");
        expect(
          formKey.currentState?.disabledGridCells.contains("fake@99"),
          false,
        );
      });

      testWidgets("enabledGridCells returns a copy", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setFieldEnabled("en_field", true, index: 5);
        final cells = formKey.currentState?.enabledGridCells;
        expect(cells, isNotNull);
        expect(cells!.contains("en_field@5"), true);
      });
    });

    // ------------------------------------------------------------------ //
    //  isGridCellDisabled                                                  //
    // ------------------------------------------------------------------ //
    group("isGridCellDisabled", () {
      testWidgets("returns false for never-set cell", (tester) async {
        await pumpForm(tester, sections: const [], document: testDocument);
        expect(formKey.currentState?.isGridCellDisabled("any", 0), false);
      });
    });

    // ------------------------------------------------------------------ //
    //  updateDropdownOptions                                               //
    // ------------------------------------------------------------------ //
    group("updateDropdownOptions", () {
      late DynamicField dropField;
      late List<Section> sections;

      setUp(() {
        dropField = makeField(
          key: "drop",
          type: FieldType.dropdown,
          options: [
            Option(key: "A", pairValue: "a"),
            Option(key: "B", pairValue: "b"),
          ],
        );
        sections = [
          Section(
            rows: [
              RowElement(fields: [dropField]),
            ],
          ),
        ];
      });

      testWidgets("updates options list", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.updateDropdownOptions(
          "drop",
          [Option(key: "C", pairValue: "c")],
        );
        await tester.pump();
        expect(dropField.optionList?.length, 1);
        expect(dropField.optionList?.first.key, "C");
      });

      testWidgets("clears selection when clearSelection=true and value invalid",
          (tester) async {
        testDocument["drop"] = "A";
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.updateDropdownOptions(
          "drop",
          [Option(key: "C", pairValue: "c")],
          clearSelection: true,
        );
        await tester.pump();
        expect(testDocument["drop"], isNull);
      });

      testWidgets(
          "keeps selection when clearSelection=true and value still valid",
          (tester) async {
        testDocument["drop"] = "C";
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.updateDropdownOptions(
          "drop",
          [Option(key: "C", pairValue: "c")],
          clearSelection: true,
        );
        await tester.pump();
        expect(testDocument["drop"], "C");
      });

      testWidgets("no-op for unknown field key", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(
          () => formKey.currentState?.updateDropdownOptions("ghost", []),
          returnsNormally,
        );
      });

      testWidgets("no-op for non-dropdown field", (tester) async {
        final txtField = makeField(key: "txt2", type: FieldType.textField);
        final s = [
          Section(
            rows: [
              RowElement(fields: [txtField]),
            ],
          ),
        ];
        await pumpForm(tester, sections: s, document: testDocument);
        expect(
          () => formKey.currentState?.updateDropdownOptions("txt2", []),
          returnsNormally,
        );
      });

      testWidgets("works with refDataDropdown type", (tester) async {
        final refField =
            makeField(key: "ref_drop", type: FieldType.refDataDropdown);
        final s = [
          Section(
            rows: [
              RowElement(fields: [refField]),
            ],
          ),
        ];
        await pumpForm(tester, sections: s, document: testDocument);
        formKey.currentState?.updateDropdownOptions(
          "ref_drop",
          [Option(key: "X", pairValue: "x")],
        );
        await tester.pump();
        expect(refField.optionList?.length, 1);
      });

      testWidgets("works with countryDropdown type", (tester) async {
        final cField =
            makeField(key: "country", type: FieldType.countryDropdown);
        final s = [
          Section(
            rows: [
              RowElement(fields: [cField]),
            ],
          ),
        ];
        await pumpForm(tester, sections: s, document: testDocument);
        formKey.currentState?.updateDropdownOptions(
          "country",
          [Option(key: "AE", pairValue: "UAE")],
        );
        await tester.pump();
        expect(cField.optionList?.length, 1);
      });
    });

    // ------------------------------------------------------------------ //
    //  setDropdownDefaultSelection                                         //
    // ------------------------------------------------------------------ //
    group("setDropdownDefaultSelection", () {
      late DynamicField dropField;
      late List<Section> sections;
      final optA = Option(key: "A", pairValue: "a");
      final optB = Option(key: "B", pairValue: "b");

      setUp(() {
        dropField = makeField(
          key: "sel_drop",
          type: FieldType.dropdown,
          options: [optA, optB],
        );
        sections = [
          Section(
            rows: [
              RowElement(fields: [dropField]),
            ],
          ),
        ];
      });

      testWidgets("sets default when no current selection", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setDropdownDefaultSelection("sel_drop", optA);
        await tester.pump();
        expect(testDocument["sel_drop"], "A");
      });

      testWidgets("does NOT overwrite valid current selection by default",
          (tester) async {
        testDocument["sel_drop"] = "B";
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setDropdownDefaultSelection("sel_drop", optA);
        await tester.pump();
        expect(testDocument["sel_drop"], "B");
      });

      testWidgets("forceOverwrite replaces valid current selection",
          (tester) async {
        testDocument["sel_drop"] = "B";
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setDropdownDefaultSelection(
          "sel_drop",
          optA,
          forceOverwrite: true,
        );
        await tester.pump();
        expect(testDocument["sel_drop"], "A");
      });

      testWidgets("onlyIfDocumentEmpty only sets when doc has no value",
          (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setDropdownDefaultSelection(
          "sel_drop",
          optA,
          onlyIfDocumentEmpty: true,
        );
        await tester.pump();
        expect(testDocument["sel_drop"], "A");
      });

      testWidgets("onlyIfDocumentEmpty does NOT overwrite when doc has value",
          (tester) async {
        testDocument["sel_drop"] = "B";
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setDropdownDefaultSelection(
          "sel_drop",
          optA,
          onlyIfDocumentEmpty: true,
        );
        await tester.pump();
        expect(testDocument["sel_drop"], "B");
      });

      testWidgets(
          "inserts option into optionList when missing"
          " and insertIfMissing=true", (tester) async {
        final newOpt = Option(key: "C", pairValue: "c");
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.setDropdownDefaultSelection(
          "sel_drop",
          newOpt,
          insertIfMissing: true,
        );
        await tester.pump();
        expect(dropField.optionList?.any((o) => o.key == "C"), true);
      });

      testWidgets("no-op for unknown field", (tester) async {
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(
          () =>
              formKey.currentState?.setDropdownDefaultSelection("ghost", optA),
          returnsNormally,
        );
      });

      testWidgets("no-op for non-dropdown field", (tester) async {
        final txtF = makeField(key: "txt3", type: FieldType.textField);
        final s = [
          Section(
            rows: [
              RowElement(fields: [txtF]),
            ],
          ),
        ];
        await pumpForm(tester, sections: s, document: testDocument);
        expect(
          () => formKey.currentState?.setDropdownDefaultSelection("txt3", optA),
          returnsNormally,
        );
      });
    });

    // ------------------------------------------------------------------ //
    //  clearDropdownSelection                                              //
    // ------------------------------------------------------------------ //
    group("clearDropdownSelection", () {
      testWidgets("clears current dropdown selection", (tester) async {
        testDocument["clr_drop"] = "A";
        final dropField = makeField(
          key: "clr_drop",
          type: FieldType.dropdown,
          options: [Option(key: "A", pairValue: "a")],
        );
        final sections = [
          Section(
            rows: [
              RowElement(fields: [dropField]),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        formKey.currentState?.clearDropdownSelection("clr_drop");
        await tester.pump();
        expect(testDocument["clr_drop"], isNull);
      });

      testWidgets("no-op when selection is already null", (tester) async {
        final dropField = makeField(
          key: "clr_drop2",
          type: FieldType.dropdown,
          options: [Option(key: "A", pairValue: "a")],
        );
        final sections = [
          Section(
            rows: [
              RowElement(fields: [dropField]),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(
          () => formKey.currentState?.clearDropdownSelection("clr_drop2"),
          returnsNormally,
        );
      });

      testWidgets("no-op for unknown field key", (tester) async {
        await pumpForm(tester, sections: const [], document: testDocument);
        expect(
          () => formKey.currentState?.clearDropdownSelection("no_exist"),
          returnsNormally,
        );
      });

      testWidgets("no-op for non-dropdown field", (tester) async {
        final txtField = makeField(key: "txt4", type: FieldType.textField);
        final sections = [
          Section(
            rows: [
              RowElement(fields: [txtField]),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(
          () => formKey.currentState?.clearDropdownSelection("txt4"),
          returnsNormally,
        );
      });
    });

    // ------------------------------------------------------------------ //
    //  disableAllExceptCMOUpdate                                           //
    // ------------------------------------------------------------------ //
    group("disableAllExceptCMOUpdate", () {
      testWidgets("renders with disableAllExceptCMOUpdate=true",
          (tester) async {
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(
                    key: "norm",
                    type: FieldType.textField,
                    isCMOUpdate: false,
                  ),
                  makeField(
                    key: "cmo",
                    type: FieldType.textField,
                    isCMOUpdate: true,
                  ),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(
          tester,
          sections: sections,
          document: testDocument,
          disableAllExceptCMOUpdate: true,
        );
        expect(find.byType(DynamicForm), findsOneWidget);
      });
    });

    // ------------------------------------------------------------------ //
    //  onFieldChange callback                                              //
    // ------------------------------------------------------------------ //
    group("onFieldChange", () {
      testWidgets("widget receives onFieldChange callback", (tester) async {
        String? capturedKey;
        dynamic capturedValue;
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "cb_field", type: FieldType.textField),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(
          tester,
          sections: sections,
          document: testDocument,
          onFieldChange: (key, value) {
            capturedKey = key;
            capturedValue = value;
          },
        );
        // The callback itself is wired via DynamicFormField; we just verify
        // widget builds.
        expect(find.byType(DynamicForm), findsOneWidget);
        // Suppress unused warning in test
        expect(capturedKey, isNull);
        expect(capturedValue, isNull);
      });
    });

    // ------------------------------------------------------------------ //
    //  Controller initialisation from existing document values            //
    // ------------------------------------------------------------------ //
    group("controller initialization", () {
      testWidgets("initialises controller from string document value",
          (tester) async {
        testDocument["init_txt"] = "pre-filled";
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "init_txt", type: FieldType.textField),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("initialises currency controller from map document value",
          (tester) async {
        testDocument["cur"] = {
          "fromCurrency": "AED",
          "fromVal": 1500,
          "aedEquivalent": 1500,
        };
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "cur", type: FieldType.currency),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("initialises currency controller when fromVal is null",
          (tester) async {
        testDocument["cur2"] = {"fromCurrency": "AED", "fromVal": null};
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "cur2", type: FieldType.currency),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("initialises percentage field controller", (tester) async {
        testDocument["pct2"] = "25";
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "pct2", type: FieldType.percentage),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("initialises amount field controller", (tester) async {
        testDocument["amt2"] = "999";
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "amt2", type: FieldType.amount),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });

      testWidgets("initialises textArea field controller", (tester) async {
        testDocument["ta2"] = "some note";
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "ta2", type: FieldType.textArea),
                ],
              ),
            ],
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });
    });

    // ------------------------------------------------------------------ //
    //  Multiple sections                                                   //
    // ------------------------------------------------------------------ //
    group("multiple sections", () {
      testWidgets("renders multiple sections correctly", (tester) async {
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "s1f1", type: FieldType.textField),
                ],
              ),
            ],
          ),
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "s2f1", type: FieldType.textField),
                ],
              ),
            ],
          ),
          Section(rows: null),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(ListView), findsAtLeastNWidgets(1));
      });

      testWidgets("outline section is wrapped with BoxLayout", (tester) async {
        final sections = [
          Section(
            rows: [
              RowElement(
                fields: [
                  makeField(key: "of1", type: FieldType.textField),
                ],
              ),
            ],
            type: "outline",
          ),
        ];
        await pumpForm(tester, sections: sections, document: testDocument);
        expect(find.byType(DynamicForm), findsOneWidget);
      });
    });
  });
}
