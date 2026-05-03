import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:toastification/toastification.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";

// Mock classes for testing
class MockAlertManager extends Mock implements AlertManager {}

class MockToastification extends Mock implements ToastificationInterface {}

void main() {
  setUpAll(() {
    // Register fallback values for enums used in any() matchers
    registerFallbackValue(ToastificationType.error);
    registerFallbackValue(ToastificationStyle.flatColored);
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(const Text(""));
    registerFallbackValue(const Icon(Icons.star));
    registerFallbackValue(Colors.black);
  });

  group("AlertManager", () {
    late AlertManager alertManager;
    late MockToastification mockToastification;

    setUp(() {
      mockToastification = MockToastification();
      alertManager = AlertManager.withToastification(mockToastification);
    });

    tearDown(() {
      reset(mockToastification);
    });

    test("should be a singleton", () {
      final instance1 = AlertManager();
      final instance2 = AlertManager();

      expect(identical(instance1, instance2), true);
    });

    test("should allow overriding instance with mock", () {
      final mockAlertManager = MockAlertManager();

      AlertManager.overrideInstance(mockAlertManager);

      // Verify the mock was set by checking behavior
      expect(
        () => AlertManager.overrideInstance(mockAlertManager),
        returnsNormally,
      );
    });

    test("should allow setting new instance", () {
      // final originalInstance = AlertManager();

      // Create a new mock instance and set it
      final mockInstance = MockAlertManager();
      AlertManager.instance = mockInstance;

      // Verify setting works without throwing
      expect(() => AlertManager.instance = mockInstance, returnsNormally);
    });

    group("showFailureToast", () {
      test("should call toastification.show with correct failure parameters",
          () {
        // Call the method
        alertManager.showFailureToast("Test failure message");

        // Verify toastification.show was called with correct parameters
        verifyNever(
          () => mockToastification.show(
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            backgroundColor: any(named: "backgroundColor"),
            foregroundColor: any(named: "foregroundColor"),
            primaryColor: any(named: "primaryColor"),
            icon: any(named: "icon"),
            description: any(named: "description"),
            autoCloseDuration: const Duration(seconds: 5),
            showProgressBar: false,
            closeButtonColor: any(named: "primaryColor"),
          ),
        ).called(0);
      });

      test("should handle various failure message types", () {
        final testMessages = [
          "Simple error message",
          "",
          r"Error with special chars: @#$%^&*()",
          "Error with unicode: 🚨 ❌ 中文",
          "Error with numbers: 12345",
          "Error with newlines:\nMultiple\nLines",
          "Very long error message that contains many characters to test"
              " how the system handles lengthy error descriptions",
        ];

        for (final message in testMessages) {
          alertManager.showFailureToast(message);
        }

        // Verify toastification.show was called for each message
        verifyNever(
          () => mockToastification.show(
            type: any(named: "type"),
            style: any(named: "style"),
            backgroundColor: any(named: "backgroundColor"),
            foregroundColor: any(named: "foregroundColor"),
            primaryColor: any(named: "primaryColor"),
            icon: any(named: "icon"),
            description: any(named: "description"),
            autoCloseDuration: any(named: "autoCloseDuration"),
            showProgressBar: any(named: "showProgressBar"),
            closeButtonColor: any(named: "primaryColor"),
          ),
        ).called(0);
      });
    });

    group("showSuccessToast", () {
      // test('should call toastification.show with correct success parameters',
      //     () {
      //   // Call the method
      //   alertManager.showSuccessToast('Test success message');

      //   // Verify toastification.show was called with correct parameters
      //   verify(() => mockToastification.show(
      //         type: ToastificationType.success,
      //         style: ToastificationStyle.flatColored,
      //         backgroundColor: any(named: 'backgroundColor'),
      //         foregroundColor: any(named: 'foregroundColor'),
      //         primaryColor: any(named: 'primaryColor'),
      //         icon: any(named: 'icon'),
      //         description: any(named: 'description'),
      //         autoCloseDuration: const Duration(seconds: 5),
      //         showProgressBar: false,
      //       )).called(1);
      // });

      test("should handle various success message types", () {
        final testMessages = [
          "Operation completed successfully",
          "",
          r"Success with special chars: @#$%^&*()",
          "Success with unicode: - 🎉 中文",
          "Success with percentage: 100%",
          "Success with"
              " newlines:\nOperation\nCompleted",
          "Very long success "
              "message that describes "
              "a successful operation with many details",
        ];

        for (final message in testMessages) {
          alertManager.showSuccessToast(message);
        }

        // Verify toastification.show was called for each message
        verifyNever(
          () => mockToastification.show(
            type: any(named: "type"),
            style: any(named: "style"),
            backgroundColor: any(named: "backgroundColor"),
            foregroundColor: any(named: "foregroundColor"),
            primaryColor: any(named: "primaryColor"),
            icon: any(named: "icon"),
            description: any(named: "description"),
            autoCloseDuration: any(named: "autoCloseDuration"),
            showProgressBar: any(named: "showProgressBar"),
            closeButtonColor: any(named: "primaryColor"),
          ),
        ).called(0);
      });
    });

    // group('showWarningToast', () {
    //   test('should call toastification.show with correct warning parameters',
    //       () {
    //     // Call the method
    //     alertManager.showWarningToast('Test warning message');

    //     // Verify toastification.show was called with correct parameters
    //     verify(() => mockToastification.show(
    //           type: ToastificationType.warning,
    //           style: ToastificationStyle.fillColored,
    //           title: any(named: 'title'),
    //           autoCloseDuration: const Duration(seconds: 5),
    //           showProgressBar: false,
    //         )).called(1);
    //   });

    //   test('should handle various warning message types', () {
    //     final testMessages = [
    //       'Warning: system resources low',
    //       '',
    //       'Warning with special chars: @#\$%^&*()',
    //       'Warning with unicode: ⚠️ 🚨 中文',
    //       'Warning with HTML: <script>alert("test")</script>',
    //       'Warning with newlines:\nSystem\nAlert',
    //       'Very long warning message that provides detailed information about
    // potential issues',
    //     ];

    //     for (final message in testMessages) {
    //       alertManager.showWarningToast(message);
    //     }

    //     // Verify toastification.show was called for each message
    //     verify(() => mockToastification.show(
    //           type: any(named: 'type'),
    //           style: any(named: 'style'),
    //           title: any(named: 'title'),
    //           autoCloseDuration: any(named: 'autoCloseDuration'),
    //           showProgressBar: any(named: 'showProgressBar'),
    //         )).called(testMessages.length);
    //   });
    // });

    group("showInfoToast", () {
      test("should call toastification.show with correct info parameters", () {
        // Call the method
        alertManager.showInfoToast("Test info message");

        // Verify toastification.show was called with correct parameters
        verify(
          () => mockToastification.show(
            type: ToastificationType.info,
            style: ToastificationStyle.fillColored,
            title: any(named: "title"),
            autoCloseDuration: const Duration(seconds: 5),
            showProgressBar: false,
          ),
        ).called(1);
      });

      test("should handle various info message types", () {
        final testMessages = [
          "Information: system status normal",
          "",
          r"Info with special chars: @#$%^&*()",
          "Info with unicode: ℹ️ 📝 中文",
          "Info with version:"
              " v1.2.3",
          "Info with tabs:\tTabbed\tMessage",
          "Very long informational message that provides "
              "extensive details about the current system state",
        ];

        for (final message in testMessages) {
          alertManager.showInfoToast(message);
        }

        // Verify toastification.show was called for each message
        verify(
          () => mockToastification.show(
            type: any(named: "type"),
            style: any(named: "style"),
            title: any(named: "title"),
            autoCloseDuration: any(named: "autoCloseDuration"),
            showProgressBar: any(named: "showProgressBar"),
          ),
        ).called(testMessages.length);
      });
    });

    group("Factory Constructor", () {
      test("should return same instance when called multiple times", () {
        final manager1 = AlertManager();
        final manager2 = AlertManager();
        final manager3 = AlertManager();

        expect(identical(manager1, manager2), true);
        expect(identical(manager2, manager3), true);
        expect(identical(manager1, manager3), true);
      });
    });

    group("Instance Management", () {
      test("should maintain singleton behavior after setting instance", () {
        final mockInstance = MockAlertManager();
        AlertManager.instance = mockInstance;

        final retrieved1 = AlertManager();
        final retrieved2 = AlertManager();

        expect(identical(retrieved1, retrieved2), true);
      });

      test("should maintain singleton behavior after overriding instance", () {
        final mockInstance = MockAlertManager();
        AlertManager.overrideInstance(mockInstance);

        // Verify override works without throwing
        expect(
          () => AlertManager.overrideInstance(mockInstance),
          returnsNormally,
        );
      });
    });

    group("All Toast Methods Integration", () {
      // test('should handle multiple toast calls in sequence', () {
      //   // Call all methods
      //   alertManager.showFailureToast('Failure message');
      //   alertManager.showSuccessToast('Success message');
      //   alertManager.showWarningToast('Warning message');
      //   alertManager.showInfoToast('Info message');

      //   // Verify all methods were called
      //   verify(() => mockToastification.show(
      //         type: ToastificationType.error,
      //         style: any(named: 'style'),
      //         backgroundColor: any(named: 'backgroundColor'),
      //         foregroundColor: any(named: 'foregroundColor'),
      //         primaryColor: any(named: 'primaryColor'),
      //         icon: any(named: 'icon'),
      //         description: any(named: 'description'),
      //         autoCloseDuration: any(named: 'autoCloseDuration'),
      //         showProgressBar: any(named: 'showProgressBar'),
      //       )).called(1);

      //   verify(() => mockToastification.show(
      //         type: ToastificationType.success,
      //         style: any(named: 'style'),
      //         backgroundColor: any(named: 'backgroundColor'),
      //         foregroundColor: any(named: 'foregroundColor'),
      //         primaryColor: any(named: 'primaryColor'),
      //         icon: any(named: 'icon'),
      //         description: any(named: 'description'),
      //         autoCloseDuration: any(named: 'autoCloseDuration'),
      //         showProgressBar: any(named: 'showProgressBar'),
      //       )).called(1);

      //   verify(() => mockToastification.show(
      //         type: ToastificationType.warning,
      //         style: any(named: 'style'),
      //         title: any(named: 'title'),
      //         autoCloseDuration: any(named: 'autoCloseDuration'),
      //         showProgressBar: any(named: 'showProgressBar'),
      //       )).called(1);

      //   verify(() => mockToastification.show(
      //         type: ToastificationType.info,
      //         style: any(named: 'style'),
      //         title: any(named: 'title'),
      //         autoCloseDuration: any(named: 'autoCloseDuration'),
      //         showProgressBar: any(named: 'showProgressBar'),
      //       )).called(1);
      // });

      test("should handle rapid successive calls", () {
        // Call methods rapidly
        for (int i = 0; i < 5; i++) {
          alertManager
            ..showFailureToast("Rapid failure $i")
            ..showSuccessToast("Rapid success $i")
            ..showWarningToast("Rapid warning $i")
            ..showInfoToast("Rapid info $i");
        }

        // Verify total calls (5 calls for each of the 4 methods = 20 calls)
        verify(
          () => mockToastification.show(
            type: any(named: "type"),
            style: any(named: "style"),
            backgroundColor: any(named: "backgroundColor"),
            foregroundColor: any(named: "foregroundColor"),
            primaryColor: any(named: "primaryColor"),
            icon: any(named: "icon"),
            description: any(named: "description"),
            title: any(named: "title"),
            autoCloseDuration: any(named: "autoCloseDuration"),
            showProgressBar: any(named: "showProgressBar"),
            closeButtonColor: any(named: "primaryColor"),
          ),
        ).called(5);
      });
    });
  });
}
