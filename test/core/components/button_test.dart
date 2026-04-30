import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("CustomButton", () {
    testWidgets("renders button with label and calls onPressed when tapped",
        (WidgetTester tester) async {
      bool buttonPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Test Button",
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text("Test Button"), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(buttonPressed, isTrue);
    });

    testWidgets("shows CircularProgressIndicator when isLoading is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Test Button",
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text("Test Button"), findsNothing);
    });

    testWidgets("shows CircularProgressIndicator when internal loading is true",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Test Button",
              onPressed: () async {
                await Future.delayed(const Duration(milliseconds: 100));
              },
            ),
          ),
        ),
      );

      expect(find.text("Test Button"), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Start the loading animation
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text("Test Button"), findsNothing);
      await tester.pumpAndSettle(); // Finish the loading animation
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text("Test Button"), findsOneWidget);
    });

    testWidgets("button is disabled when onPressed is null",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Disabled Button",
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets(
        "button is disabled when isLoading is true,"
        " even if onPressed is provided", (WidgetTester tester) async {
      bool buttonPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Loading Button",
              onPressed: () {
                buttonPressed = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      await tester.tap(
        find.byType(ElevatedButton),
        warnIfMissed: false,
      ); // Try tapping, but it should be disabled
      expect(buttonPressed, isFalse);
    });

    testWidgets("displays tooltip when provided", (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Button",
              onPressed: null,
              tooltip: "This is a tooltip",
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
      expect(find.byTooltip("This is a tooltip"), findsOneWidget);
    });

    testWidgets("applies custom background color", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Button",
              onPressed: () {},
              backgroundColor: Colors.red,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(
        button.style?.backgroundColor?.resolve({WidgetState.pressed}),
        Colors.red,
      );
    });

    testWidgets("applies custom text color", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Button",
              onPressed: () {},
              textColor: Colors.blue,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text("Button"));
      expect(text.style?.color, Colors.blue);
    });

    testWidgets("applies custom width and height", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Button",
              onPressed: () {},
              width: 200,
              height: 50,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 200);
      expect(sizedBox.height, 50);
    });

    testWidgets("applies custom text style", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Button",
              onPressed: () {},
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text("Button"));
      expect(text.style?.fontSize, 20);
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets("displays leading icon", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Button",
              onPressed: () {},
              leadingIcon: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets("displays trailing icon", (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Button",
              onPressed: () {},
              trailingIcon: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets("displays both leading and trailing icons",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Button",
              onPressed: () {},
              leadingIcon: const Icon(Icons.add),
              trailingIcon: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets("uses default colors when not provided",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Button",
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(
        button.style?.backgroundColor?.resolve({WidgetState.pressed}),
        AppColors.buttonBackground,
      );

      final text = tester.widget<Text>(find.text("Button"));
      expect(text.style?.color, Colors.white);
    });

    testWidgets(
        "CircularProgressIndicator uses default text color if not provided",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Test Button",
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(
        (indicator.valueColor! as AlwaysStoppedAnimation<Color>).value,
        Colors.white,
      );
    });

    testWidgets("CircularProgressIndicator uses provided text color",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: "Test Button",
              onPressed: null,
              isLoading: true,
              textColor: Colors.purple,
            ),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(
        (indicator.valueColor! as AlwaysStoppedAnimation<Color>).value,
        Colors.purple,
      );
    });
  });
}
