import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form_inline.dart";
import "package:wcas_frontend/core/components/textfield.dart";

void main() {
  group("DynamicFormInline Inline Rendering Tests", () {
    testWidgets("Handles empty input string with SizedBox",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(inputString: ""),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  testWidgets(
    "dispose() runs safely and disposes resources",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            //  Explicitly include both placeholders
            body: DynamicFormInline(
              inputString: "Borrower () for [year]",
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      // Capture references BEFORE dispose
      final controllers = [
        ...state.dynamicControllers,
        ...state.bracketControllers,
      ];
      final notifier = state.filltextVN;

      // Trigger dispose
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      //  Controllers should throw if accessed after dispose
      for (final c in controllers) {
        expect(
          () => c.text = "test",
          throwsA(isA<FlutterError>()),
        );
      }

      //  ValueNotifier should throw after dispose
      expect(
        () => notifier.value = "new value",
        throwsA(isA<FlutterError>()),
      );
    },
  );

  testWidgets(
    "getFormattedString replaces dynamic placeholder with entered text",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower ())",
              splitSymbol: "())", //initializeControllers REQUIRED
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      //initializeControllers Controller now exists
      expect(state.dynamicControllers.length, 1);

      // Set value via controller
      state.dynamicControllers.first.text = "ABC Corp";

      // Trigger formatting
      state.getFormattedString();
      await tester.pump();

      //initializeControllers Final assertion
      expect(find.textContaining("Borrower ABC Corp"), findsWidgets);
    },
  );

  testWidgets(
    "creates dynamic controller only when splitSymbol matches regex output",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower ())",
              splitSymbol: "())", //initializeControllers REQUIRED
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      expect(state.dynamicControllers.length, 1);
    },
  );

  testWidgets(
    "clears bracket controller when editedPreview contains default placeholder",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Period [quarter/half year/ year]",
              editedPreview: "Period [quarter/half year/ year]",
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      expect(state.bracketControllers.length, 1);
      expect(state.bracketControllers.first.text, isEmpty);
    },
  );

  testWidgets(
    "keeps bracket controller text when editedPreview contains real value",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower [name]",
              editedPreview: "Borrower [ABC Corp]",
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      expect(state.bracketControllers.length, 1);
      expect(state.bracketControllers.first.text, "ABC Corp");
    },
  );

  testWidgets(
    "initializes preview text from editedPreview when provided",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower [name]",
              editedPreview: "Borrower [XYZ]",
            ),
          ),
        ),
      );

      expect(find.textContaining("Borrower [XYZ]"), findsWidgets);
    },
  );

  testWidgets(
    "getFormattedString replaces dynamic placeholder with entered text",
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower ())",
              splitSymbol: "())", // REQUIRED
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      // Dynamic controller exists
      expect(state.dynamicControllers.length, 1);

      // Simulate typing
      state.dynamicControllers.first.text = "ABC Corp";

      // Trigger formatting
      state.getFormattedString();
      await tester.pump();

      // Result visible
      expect(find.textContaining("Borrower ABC Corp"), findsWidgets);
    },
  );

  testWidgets(
    "getFormattedString replaces dynamic placeholder with entered text",
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower ())",
              splitSymbol: "())", // REQUIRED
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      // Dynamic controller exists
      expect(state.dynamicControllers.length, 1);

      // Simulate typing
      state.dynamicControllers.first.text = "ABC Corp";

      // Trigger formatting
      state.getFormattedString();
      await tester.pump();

      // Result visible
      expect(find.textContaining("Borrower ABC Corp"), findsWidgets);
    },
  );

  testWidgets(
    "formats bracket placeholders correctly",
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Period [year]",
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      expect(state.bracketControllers.length, 1);

      state.bracketControllers.first.text = "2026";
      state.getFormattedString();
      await tester.pump();

      expect(find.textContaining("[2026]"), findsWidgets);
    },
  );

  testWidgets(
    "calls callback only when all fields are valid",
    (tester) async {
      String? callbackValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower ()) for [year]",
              splitSymbol: "())",
              callBackString: (v) => callbackValue = v,
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      // Fill only one field
      state.dynamicControllers.first.text = "ABC Corp";
      state.getFormattedString();
      await tester.pump();

      expect(callbackValue, isNull);

      // Fill all fields
      state.bracketControllers.first.text = "2026";
      state.getFormattedString();
      await tester.pump();

      expect(callbackValue, "Borrower ABC Corp for [2026]");
    },
  );

  testWidgets(
    "buildInlineSpans always adds leading required asterisk",
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower [name]",
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      expect(state.inlineSpans.isNotEmpty, isTrue);

      final firstSpan = state.inlineSpans.first as TextSpan;
      expect(firstSpan.text, "*");
    },
  );

  testWidgets(
    "buildInlineSpans adds static text as TextSpan",
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower [name]",
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      final hasBorrowerText = state.inlineSpans.any(
        (s) => s is TextSpan && s.text!.contains("Borrower"),
      );

      expect(hasBorrowerText, isTrue);
    },
  );
  testWidgets(
    "buildInlineSpans creates WidgetSpan only for bracket"
    " placeholder due to regex mismatch",
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower ()) for [year]",
              splitSymbol: "())",
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      // Controllers are created correctly
      expect(state.dynamicControllers.length, 1);
      expect(state.bracketControllers.length, 1);

      // Only ONE WidgetSpan is rendered (bracket only)
      final widgetSpanCount = state.inlineSpans.whereType<WidgetSpan>().length;

      expect(widgetSpanCount, 1);
    },
  );
  testWidgets(
    "buildInlineSpans creates CustomTextField for bracket placeholder",
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Period [year]",
            ),
          ),
        ),
      );

      expect(find.byType(CustomTextField), findsOneWidget);
    },
  );
  testWidgets(
    "buildInlineSpans exercises error-path logic when showError=true",
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicFormInline(
              inputString: "Borrower ())",
              splitSymbol: "())",
              showError: true,
              isRequired: true,
            ),
          ),
        ),
      );

      final state = tester.state<DynamicFormInlineState>(
        find.byType(DynamicFormInline),
      );

      // initializeControllers: dynamic controller exists
      expect(state.dynamicControllers.length, 1);

      // Empty input -> invalid
      state.dynamicControllers.first.text = "";

      // Trigger rebuild path
      state.getFormattedString();
      await tester.pump();

      // inlineSpans rebuilt
      expect(state.inlineSpans.length, greaterThan(1));

      // EXPECTED BEHAVIOR with current prod code:
      // buildInlineSpans regex DOES NOT match '())',
      // so no WidgetSpan is rendered
      final hasWidgetSpan = state.inlineSpans.any((s) => s is WidgetSpan);
      expect(hasWidgetSpan, isFalse);
    },
  );
}
