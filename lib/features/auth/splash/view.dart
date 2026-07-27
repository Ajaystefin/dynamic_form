import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/features/auth/splash/model.dart";

/// Splash screen responsible for initializing the application
/// and handling authentication redirects.
class SplashView extends StatelessWidget {
  /// Creates a [SplashView].
  const SplashView({super.key, this.queryParams});

  /// Query parameters received during navigation.
  final Map<String, String>? queryParams;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashViewModel>(
      lazy: false,
      create: (context) => SplashViewModel()..init(queryParams ?? {}),
      child: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
