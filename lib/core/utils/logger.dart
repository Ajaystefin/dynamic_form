import 'package:logger/logger.dart';
import 'package:wcas_frontend/core/env_config.dart';

Logger logger = Logger(
  level: EnvConfig.enableLogging ? Level.fatal : Level.off,
  printer: PrettyPrinter(
    methodCount: 2, // Number of method calls to display
    errorMethodCount: 8, // Number of method calls if stack trace is provided
    lineLength: 120, // Width of the output
    colors: true, // Colorful log output
    printEmojis: true, // Print emojis for log levels
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
