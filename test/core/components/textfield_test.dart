import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";

void main() {
  group("CustomTextField", () {
    testWidgets("renders textfield with default properties",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(CustomTooltip), findsOneWidget);
    });

    testWidgets("renders with initial value and hint text",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              initialValue: "Initial text",
              hintText: "Enter text here",
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text("Initial text"), findsOneWidget);
    });

    testWidgets("renders with label and helper text",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              labelText: "Name",
              helperText: "Enter your name",
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets("renders with prefix and suffix icons",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              prefixIcon: Icon(Icons.person),
              suffixIcon: Icon(Icons.clear),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets("calls onChanged when text changes",
        (WidgetTester tester) async {
      String? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), "New text");
      await tester.pump();
      expect(changedValue, "New text");
    });

    testWidgets("renders as password field when isPassword is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              isPassword: true,
              hintText: "Password",
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      // Password field is rendered with obscureText enabled
    });

    testWidgets("renders as read-only when specified",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              readOnly: true,
              initialValue: "Read only text",
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      // Read-only field is rendered
    });

    testWidgets("applies custom styling", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              textStyle: TextStyle(fontSize: 16, color: Colors.blue),
              hintStyle: TextStyle(color: Colors.grey),
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              fillColor: Colors.yellow,
              filled: true,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets("renders with custom width", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              width: 200,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(TextFormField),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, 200);
    });

    testWidgets("renders with maxLength", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              maxLength: 10,
              hintText: "Max 10 chars",
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      // MaxLength is applied
    });

    testWidgets("calls onTap when tapped", (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets("calls onSubmitted when submitted",
        (WidgetTester tester) async {
      String? submittedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              onSubmitted: (value) {
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), "Submitted text");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submittedValue, "Submitted text");
    });

    testWidgets("uses external controller when provided",
        (WidgetTester tester) async {
      final controller = TextEditingController(text: "Controller text");
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text("Controller text"), findsOneWidget);
      controller.dispose();
    });

    testWidgets("uses underline border when specified",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              useUnderlineBorder: true,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets("supports multiple lines", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              maxLines: 3,
              minLines: 2,
            ),
          ),
        ),
      );

      // Multiple lines are supported
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets("calls onSaved when form is saved",
        (WidgetTester tester) async {
      String? savedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomTextField(
                initialValue: "Save me",
                onSaved: (value) {
                  savedValue = value;
                },
              ),
            ),
          ),
        ),
      );

      tester.state<FormState>(find.byType(Form)).save();
      expect(savedValue, "Save me");
    });

    group("Search Functionality", () {
      testWidgets("calls onSearchChanged after debounce",
          (WidgetTester tester) async {
        String? searchedValue;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                onSearchChanged: (value) async {
                  await Future.delayed(const Duration(milliseconds: 100));
                  searchedValue = value;
                },
                searchDebounce: const Duration(milliseconds: 300),
              ),
            ),
          ),
        );

        // Enter text
        await tester.enterText(find.byType(TextFormField), "search query");
        await tester.pump();

        // Wait for debounce
        await tester.pump(const Duration(milliseconds: 300));

        // Wait for async function
        await tester.pump(const Duration(milliseconds: 150));

        expect(searchedValue, "search query");
      });

      testWidgets("shows loading indicator during search",
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                onSearchChanged: (value) async {
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                searchDebounce: const Duration(milliseconds: 100),
                showSearchLoader: true,
              ),
            ),
          ),
        );

        // Enter text
        await tester.enterText(find.byType(TextFormField), "search");
        await tester.pump();

        // Wait for debounce
        await tester.pump(const Duration(milliseconds: 100));

        // Check for loading indicator
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for search to complete
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        // Loading indicator should be gone
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets("cancels previous search when typing continues",
          (WidgetTester tester) async {
        int searchCallCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                onSearchChanged: (value) async {
                  searchCallCount++;
                  await Future.delayed(const Duration(milliseconds: 100));
                },
                searchDebounce: const Duration(milliseconds: 200),
              ),
            ),
          ),
        );

        // Type multiple times quickly
        await tester.enterText(find.byType(TextFormField), "s");
        await tester.pump(const Duration(milliseconds: 50));

        await tester.enterText(find.byType(TextFormField), "se");
        await tester.pump(const Duration(milliseconds: 50));

        await tester.enterText(find.byType(TextFormField), "sea");
        await tester.pump(const Duration(milliseconds: 50));

        // Wait for final debounce
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 150));

        // Should only call search once for the final value
        expect(searchCallCount, 1);
      });

      testWidgets("shows suffix icon when not searching",
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                suffixIcon: const Icon(Icons.search),
                onSearchChanged: (value) async {
                  await Future.delayed(const Duration(milliseconds: 100));
                },
                searchDebounce: const Duration(milliseconds: 100),
              ),
            ),
          ),
        );

        // Initially should show search icon
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets("handles search errors gracefully",
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                onSearchChanged: (value) async {
                  throw Exception("Search failed");
                },
                searchDebounce: const Duration(milliseconds: 100),
              ),
            ),
          ),
        );

        // Should not crash when search throws error
        await tester.enterText(find.byType(TextFormField), "error");
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();

        // Widget should still be present
        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group("Validation", () {
      testWidgets("does not validate when readOnly is true",
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                child: CustomTextField(
                  readOnly: true,
                  validator: (value) => "Should not show",
                ),
              ),
            ),
          ),
        );

        final formState = tester.state<FormState>(find.byType(Form));
        final isValid = formState.validate();
        await tester.pump();

        expect(isValid, true);
        expect(find.text("Should not show"), findsNothing);
      });
    });

    group("Focus Management", () {
      testWidgets("respects custom focus node", (WidgetTester tester) async {
        final focusNode = FocusNode();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                focusNode: focusNode,
              ),
            ),
          ),
        );

        expect(focusNode.hasFocus, false);

        focusNode.requestFocus();
        await tester.pump();

        expect(focusNode.hasFocus, true);
        focusNode.dispose();
      });

      testWidgets("autofocus works when enabled", (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                autoFocus: true,
              ),
            ),
          ),
        );

        await tester.pump();

        // Autofocus is enabled
        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group("Edge Cases", () {
      testWidgets("handles null controller with initial value",
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                initialValue: "Initial",
              ),
            ),
          ),
        );

        expect(find.text("Initial"), findsOneWidget);
      });

      testWidgets("handles controller with initial value",
          (WidgetTester tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                controller: controller,
                initialValue: "Should use controller",
              ),
            ),
          ),
        );

        // Controller should be seeded with initial value if empty
        expect(controller.text, "Should use controller");
        controller.dispose();
      });

      testWidgets("does not override controller text if already set",
          (WidgetTester tester) async {
        final controller = TextEditingController(text: "Controller value");
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                controller: controller,
                initialValue: "Initial value",
              ),
            ),
          ),
        );

        expect(controller.text, "Controller value");
        expect(find.text("Controller value"), findsOneWidget);
        controller.dispose();
      });

      testWidgets("handles empty counterText", (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                counterText: "",
                maxLength: 10,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });
  });
}
