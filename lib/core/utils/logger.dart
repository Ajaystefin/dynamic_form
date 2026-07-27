import "dart:convert";

import "package:file_saver/file_saver.dart";
import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:wcas_frontend/core/env_config.dart";

// Buffers recent log lines in memory (bounded, oldest dropped first) in
// addition to printing them to the console. This is what makes
// `downloadLogs()` below possible, since prod consoles/network tabs aren't
// reachable after the fact. Capped via `EnvConfig.logBufferSize` so memory
// can't grow unbounded over a long session.
final MemoryOutput _memoryOutput = MemoryOutput(
  bufferSize: EnvConfig.logBufferSize,
  secondOutput: kDebugMode ? ConsoleOutput() : null,
);

/// Custom log filter that checks [EnvConfig.enableLogging] dynamically.
class _DynamicLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (!EnvConfig.enableLogging) {
      return false;
    }
    // `Level.info` lets `.i`/`.w`/`.e`/`.f` calls through (the levels
    // repositories actually log at) while dropping noisy `.d` debug calls.
    return event.level >= Level.info;
  }
}

/// Application logger instance.
Logger logger = Logger(
  filter: _DynamicLogFilter(),
  // SimplePrinter over PrettyPrinter: PrettyPrinter's ANSI color codes and
  // box-drawing borders are terminal-only — opened in a plain-text file
  // (the whole point of `downloadLogs()`) they show up as garbled noise
  // instead of formatting. SimplePrinter emits one plain line per call.
  printer: SimplePrinter(printTime: true, colors: false),
  output: _memoryOutput,
);

/// Saves the buffered logs as a downloadable text file.
///
/// Only ever has content when `EnvConfig.enableLogging` is true, since
/// `_memoryOutput` is fed by the `logger` instance above.
Future<void> downloadLogs() async {
  final String content =
      _memoryOutput.buffer.expand((event) => event.lines).join("\n");
  final Uint8List bytes = Uint8List.fromList(utf8.encode(content));
  // ":" is sanitized out since it isn't a safe filename character on some
  // OSes / browser download targets.
  final String fileName =
      "logs_${DateTime.now().toIso8601String().replaceAll(RegExp("[:.]"), "-")}.txt";
  await FileSaver.instance.saveFile(name: fileName, bytes: bytes);
}
