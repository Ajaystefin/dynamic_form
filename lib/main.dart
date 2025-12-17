import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/env_config.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/local_storage_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/services/session/cubit.dart';
import 'package:wcas_frontend/core/components/listener_wrapper.dart';
import 'package:wcas_frontend/core/theme.dart';
import 'package:wcas_frontend/core/utils/semantics_provider.dart';
import 'package:toastification/toastification.dart';
import 'core/utils/scale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await EnvConfig.setEnvironment();
  usePathUrlStrategy();
  if (kReleaseMode) {
    await LocalStorageService().clearBox(LocalStorageBoxes.user);
    SessionCubit.instance.stopSession();
  }

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const App()),
  );
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// Controls whether the Semantics Debugger is enabled or disabled.
  /// When `true`, Flutter's Semantics Debugger will be displayed.
  bool showSemantics = false;

  /// Toggles the `showSemantics` state and triggers a UI rebuild.
  /// This function is called when the "Enable Semantics" button is pressed.
  void toggleSemantics() {
    setState(() {
      showSemantics = !showSemantics;
    });
  }

  @override
  Widget build(BuildContext context) {
    Scale.setup(context, const Size(1080, 1));
    Globals.deviceScreenType = context.deviceScreenType;
    return SemanticsProvider(
        showSemantics: showSemantics,
        toggleSemantics: toggleSemantics,
        child: AdaptiveTheme(
          light: CustomTheme.lightTheme,
          dark: CustomTheme.lightTheme,
          initial: AdaptiveThemeMode.light,
          builder: (theme, darkTheme) => ToastificationWrapper(
            child: MaterialApp.router(
              title: 'Corporate Lending',
              theme: theme,
              darkTheme: darkTheme,
              scaffoldMessengerKey: Globals.rootScaffoldMessengerKey,
              routerConfig: router,
              // navigatorObservers: [GoRouterObserver()],
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,

              /// Enables Semantics Debugger when `showSemantics` is true
              showSemanticsDebugger: showSemantics,
              builder: (context, child) {
                return BlocProvider(
                    create: (_) => SessionCubit.instance,
                    child: SessionWrapper(
                      child: child!,
                    ));
              },
            ),
          ),
        ));
  }
}
