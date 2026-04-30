import "package:dropdown_search/dropdown_search.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/button_dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";

Future<void> pumpDropdown(
  WidgetTester tester, {
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

CustomDropdownItem item({
  required String label,
  required String value,
  VoidCallback? onPressed,
}) {
  return CustomDropdownItem(
    label: label,
    value: value,
    onPressed: onPressed,
  );
}

void main() {
  group("CustomDropdownButton constructor and defaults", () {
    test("assigns default values correctly", () {
      const widget = CustomDropdownButton(
        label: "Return",
      );

      expect(widget.label, "Return");
      expect(widget.isLoading, isNull);
      expect(widget.tooltip, isNull);
      expect(widget.backgroundColor, isNull);
      expect(widget.disabledColor, isNull);
      expect(widget.textColor, isNull);
      expect(widget.width, isNull);
      expect(widget.height, isNull);
      expect(widget.borderRadius, isNull);
      expect(widget.textStyle, isNull);
      expect(widget.initialOption, isNull);
      expect(widget.options, isNull);
      expect(widget.isSearchable, true);
      expect(widget.showValueWithLabel, true);
      expect(widget.callBack, isNull);
      expect(widget.validation, isNull);
      expect(widget.callBackWithHeader, isNull);
      expect(widget.onButtonPressed, isNull);
    });

    test("accepts all optional parameters", () {
      final option = item(label: "Approve", value: "approve");

      final widget = CustomDropdownButton(
        label: "Return",
        isLoading: true,
        tooltip: "tooltip",
        backgroundColor: Colors.red,
        disabledColor: Colors.grey,
        textColor: Colors.white,
        width: 120,
        height: 40,
        borderRadius: 8,
        textStyle: const TextStyle(fontSize: 14),
        initialOption: option,
        options: <CustomDropdownItem>[option],
        isSearchable: false,
        showValueWithLabel: false,
        callBack: (_) {},
        validation: (_) {},
        callBackWithHeader: (_, __) {},
        onButtonPressed: () {},
      );

      expect(widget.isLoading, true);
      expect(widget.tooltip, "tooltip");
      expect(widget.backgroundColor, Colors.red);
      expect(widget.disabledColor, Colors.grey);
      expect(widget.textColor, Colors.white);
      expect(widget.width, 120);
      expect(widget.height, 40);
      expect(widget.borderRadius, 8);
      expect(widget.textStyle, isNotNull);
      expect(widget.initialOption, same(option));
      expect(widget.options, hasLength(1));
      expect(widget.isSearchable, false);
      expect(widget.showValueWithLabel, false);
      expect(widget.callBack, isNotNull);
      expect(widget.validation, isNotNull);
      expect(widget.callBackWithHeader, isNotNull);
      expect(widget.onButtonPressed, isNotNull);
    });
  });

  group("CustomDropdownButton build / label behavior", () {
    testWidgets("shows base label only when there is no selection",
        (tester) async {
      await pumpDropdown(
        tester,
        child: const CustomDropdownButton(
          label: "Return",
        ),
      );

      final customButton =
          tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Return");
    });

    testWidgets(
        "uses initialOption when it has non-empty value"
        " and showValueWithLabel=true", (tester) async {
      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          initialOption: item(label: "Approve", value: "approve"),
        ),
      );

      final customButton =
          tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Return Approve");
    });

    testWidgets(
        "uses selected "
        "label only when "
        "showValueWithLabel=false and selection exists", (tester) async {
      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          showValueWithLabel: false,
          initialOption: item(label: "Approve", value: "approve"),
        ),
      );

      final customButton =
          tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Approve");
    });

    testWidgets("does not preselect initialOption if value is empty",
        (tester) async {
      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          initialOption: item(label: "Approve", value: ""),
        ),
      );

      final customButton =
          tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Return");
    });
  });

  group("DropdownSearch enabled logic", () {
    testWidgets("DropdownSearch is disabled when options are null",
        (tester) async {
      await pumpDropdown(
        tester,
        child: const CustomDropdownButton(
          label: "Return",
          callBack: null,
          callBackWithHeader: null,
        ),
      );

      final dropdown =
          tester.widget<DropdownSearch<(String?, dynamic, Function()?)>>(
        find.byType(DropdownSearch<(String?, dynamic, Function()?)>),
      );

      expect(dropdown.enabled, false);
    });

    testWidgets("DropdownSearch is disabled when options are empty",
        (tester) async {
      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          options: const <CustomDropdownItem>[],
          callBack: (_) {},
        ),
      );

      final dropdown =
          tester.widget<DropdownSearch<(String?, dynamic, Function()?)>>(
        find.byType(DropdownSearch<(String?, dynamic, Function()?)>),
      );

      expect(dropdown.enabled, false);
    });

    testWidgets("DropdownSearch is disabled when callbacks are null",
        (tester) async {
      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          options: <CustomDropdownItem>[
            item(label: "Approve", value: "approve"),
          ],
        ),
      );

      final dropdown =
          tester.widget<DropdownSearch<(String?, dynamic, Function()?)>>(
        find.byType(DropdownSearch<(String?, dynamic, Function()?)>),
      );

      expect(dropdown.enabled, false);
    });

    testWidgets(
        "DropdownSearch is enabled when options exist and callback exists",
        (tester) async {
      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          options: <CustomDropdownItem>[
            item(label: "Approve", value: "approve"),
          ],
          callBack: (_) {},
        ),
      );

      final dropdown =
          tester.widget<DropdownSearch<(String?, dynamic, Function()?)>>(
        find.byType(DropdownSearch<(String?, dynamic, Function()?)>),
      );

      expect(dropdown.enabled, true);
    });
  });

  group("Button press behavior", () {
    testWidgets("pressing button with selection calls onButtonPressed",
        (tester) async {
      int pressedCount = 0;

      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          initialOption: item(label: "Approve", value: "approve"),
          onButtonPressed: () {
            pressedCount++;
          },
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();

      expect(pressedCount, 1);
    });
  });

  group("Selection / callbacks / header mapping", () {
    testWidgets("selecting an item triggers callBack and updates label",
        (tester) async {
      String? selectedValue;

      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          options: <CustomDropdownItem>[
            item(label: "Approve", value: "approve"),
            item(label: "Reject", value: "reject"),
          ],
          callBack: (value) {
            selectedValue = value;
          },
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Approve").last);
      await tester.pumpAndSettle();

      expect(selectedValue, "approve");

      final customButton =
          tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Return Approve");
    });

    testWidgets(
        "selecting an item triggers callBackWithHeader with mapped header",
        (tester) async {
      String? selectedValue;
      String? selectedHeader;

      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          options: <CustomDropdownItem>[
            item(label: "BPM Role", value: "__header__:bpm"),
            item(label: "Manager", value: "manager"),
            item(label: "Ops Role", value: "__header__:ops"),
            item(label: "Operations", value: "operations"),
          ],
          callBackWithHeader: (value, header) {
            selectedValue = value;
            selectedHeader = header;
          },
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Manager").last);
      await tester.pumpAndSettle();

      expect(selectedValue, "manager");
      expect(selectedHeader, "BPM Role");

      final customButton =
          tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Return Manager");
    });

    testWidgets("tapping a header row does not trigger callbacks or selection",
        (tester) async {
      String? selectedValue;
      String? selectedHeader;

      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          options: <CustomDropdownItem>[
            item(label: "BPM Role", value: "__header__:bpm"),
            item(label: "Manager", value: "manager"),
          ],
          callBack: (value) {
            selectedValue = value;
          },
          callBackWithHeader: (value, header) {
            selectedHeader = header;
          },
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("BPM Role").last);
      await tester.pumpAndSettle();

      expect(selectedValue, isNull);
      expect(selectedHeader, isNull);

      final customButton =
          tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Return");
    });

    testWidgets(
        "header map uses latest encountered header for following values",
        (tester) async {
      String? selectedHeader;

      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          label: "Return",
          options: <CustomDropdownItem>[
            item(label: "Header A", value: "__header__:a"),
            item(label: "Item A1", value: "a1"),
            item(label: "Header B", value: "__header__:b"),
            item(label: "Item B1", value: "b1"),
          ],
          callBackWithHeader: (_, header) {
            selectedHeader = header;
          },
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Item B1").last);
      await tester.pumpAndSettle();

      expect(selectedHeader, "Header B");
    });
  });

  group("didUpdateWidget coverage", () {
    testWidgets("late arriving initialOption gets applied when previously null",
        (tester) async {
      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          key: const ValueKey("dropdown"),
          label: "Return",
          options: <CustomDropdownItem>[
            item(label: "Approve", value: "approve"),
          ],
          callBack: (_) {},
        ),
      );

      var customButton = tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Return");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdownButton(
              key: const ValueKey("dropdown"),
              label: "Return",
              initialOption: item(label: "Approve", value: "approve"),
              options: <CustomDropdownItem>[
                item(label: "Approve", value: "approve"),
              ],
              callBack: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      customButton = tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Return Approve");
    });

    testWidgets(
        "keeps current selection when didUpdateWidget "
        "runs and selection already exists", (tester) async {
      await pumpDropdown(
        tester,
        child: CustomDropdownButton(
          key: const ValueKey("dropdown-2"),
          label: "Return",
          initialOption: item(label: "Approve", value: "approve"),
          options: <CustomDropdownItem>[
            item(label: "Approve", value: "approve"),
            item(label: "Reject", value: "reject"),
          ],
          callBack: (_) {},
        ),
      );

      var customButton = tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.label, "Return Approve");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdownButton(
              key: const ValueKey("dropdown-2"),
              label: "Return",
              initialOption: item(label: "Reject", value: "reject"),
              options: <CustomDropdownItem>[
                item(label: "Approve", value: "approve"),
                item(label: "Reject", value: "reject"),
              ],
              callBack: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      customButton = tester.widget<CustomButton>(find.byType(CustomButton));
      // Existing selected state should remain
      expect(customButton.label, "Return Approve");
    });
  });
}
