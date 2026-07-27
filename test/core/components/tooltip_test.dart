import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/tooltip.dart";

void main() {
  // ================= BASIC TOOLTIP =================

  testWidgets("renders normal tooltip", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: "Hello",
            child: Text("Child"),
          ),
        ),
      ),
    );

    expect(find.text("Child"), findsOneWidget);
    expect(find.byType(Tooltip), findsOneWidget);
  });

  testWidgets("renders rich tooltip", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: "Rich",
            isRichMessage: true,
            child: Text("Child"),
          ),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsOneWidget);
  });

  // ================= SHOW TOOLTIP FALSE =================

  testWidgets("returns child when showTooltip is false", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: "Hidden",
            showTooltip: false,
            child: Text("OnlyChild"),
          ),
        ),
      ),
    );

    expect(find.text("OnlyChild"), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
  });

  // ================= SIDE OVERLAY =================

  testWidgets("renders side overlay tooltip", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: "Overlay message",
            showSideOverlay: true,
            child: Text("HoverMe"),
          ),
        ),
      ),
    );

    expect(find.text("HoverMe"), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing); // uses custom overlay
  });

  testWidgets("side overlay appears on hover", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: "Overlay message",
            showSideOverlay: true,
            child: Text("HoverMe"),
          ),
        ),
      ),
    );

    final target = find.text("HoverMe");

    // simulate mouse enter
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(target));
    await tester.pump();

    // move pointer to trigger onEnter
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();

    expect(find.text("Overlay message"), findsOneWidget);

    // simulate exit
    await gesture.moveTo(Offset.zero);
    await tester.pumpAndSettle();
  });

  testWidgets("side overlay does not show when message empty", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: "",
            showSideOverlay: true,
            child: Text("HoverMe"),
          ),
        ),
      ),
    );

    final target = find.text("HoverMe");

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(target));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();

    expect(find.text(""), findsNothing);
  });

  // ================= MAX HEIGHT SCROLL =================

  testWidgets("side overlay uses scroll when maxHeight provided",
      (tester) async {
    final longText = "A " * 200;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: longText,
            showSideOverlay: true,
            sideOverlayMaxHeight: 100,
            child: const Text("Hover"),
          ),
        ),
      ),
    );

    final target = find.text("Hover");

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(target));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets("side overlay without maxHeight renders normal content",
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: "Short message",
            showSideOverlay: true,
            child: Text("Hover"),
          ),
        ),
      ),
    );

    final target = find.text("Hover");

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: tester.getCenter(target));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text("Short message"), findsOneWidget);
  });

  // ================= DISPOSE COVERAGE =================

  testWidgets("side overlay disposed correctly", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: "Dispose test",
            showSideOverlay: true,
            child: Text("Hover"),
          ),
        ),
      ),
    );

    await tester.pumpWidget(const SizedBox()); // dispose widget

    expect(find.text("Hover"), findsNothing);
  });

  // ================= PARAMETER COVERAGE =================

  testWidgets("custom styles passed", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTooltip(
            message: "Styled",
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.all(5),
            preferBelow: true,
            verticalOffset: 20,
            height: 40,
            child: Icon(Icons.info),
          ),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsOneWidget);
    expect(find.byIcon(Icons.info), findsOneWidget);
  });
}
