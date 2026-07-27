import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Defines the application's theme configuration.
class CustomTheme {
  /// Light theme used throughout the application.
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    fontFamily: "Inter",
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    textTheme: const TextTheme(bodyLarge: TextStyle(fontSize: 13)),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: kIsWeb
          ? {
              // No animations for every OS if the app running on the web
              for (final platform in TargetPlatform.values)
                platform: const NoTransitionsBuilder(),
            }
          : {
              TargetPlatform.android: const SlidePageTransition(),
              TargetPlatform.iOS: const SlidePageTransition(),
              TargetPlatform.linux: const SlidePageTransition(),
              TargetPlatform.windows: const NoTransitionsBuilder(),
            },
    ),
  );
}

/// Custom page transition that slides pages in from the right.
class SlidePageTransition extends PageTransitionsBuilder {
  /// Creates a [SlidePageTransition].
  const SlidePageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

/// Page transition builder that disables route animations.
class NoTransitionsBuilder extends PageTransitionsBuilder {
  /// Creates a [NoTransitionsBuilder].
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    // only return the child without warping it with animations
    return child!;
  }
}
