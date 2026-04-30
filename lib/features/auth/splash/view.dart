import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/features/auth/splash/model.dart";

class SplashView extends StatelessWidget {
  const SplashView({super.key, this.queryParams});
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
