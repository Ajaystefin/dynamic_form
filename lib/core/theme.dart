import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class CustomTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    fontFamily: 'Inter',
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
              TargetPlatform.windows: const NoTransitionsBuilder()
            },
    ),
  );
}

class SlidePageTransition extends PageTransitionsBuilder {
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

class NoTransitionsBuilder extends PageTransitionsBuilder {
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
