/*
 *    Copyright 2022, the Darwin Framework authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import 'package:ansi_styles/ansi_styles.dart';
import 'package:ansi_styles/extension.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:logging/logging.dart';

typedef LogHandler = Function(LogRecord);

mixin DarwinSystemLoggingMixin on DarwinSystem {
  Logger logger = Logger.detached("Darwin");
  LogHandler handler = DarwinDefaultLogger.log;
  Level level = Level.CONFIG;

  void enableLogging() {
    // Initialise system logger
    logger.level = level;
    logger.onRecord.listen(handler);

    // Override global log consumer
    Logger.root.level = level;
    Logger.root.clearListeners();
    Logger.root.onRecord.listen(handler);
  }

  /// Creates a detached [Logger] with the specified [name], that is linked
  /// to the [handler] and has configured sound [Level] of [level].
  Logger createLogger(String name) => Logger.detached(name)
    ..level = level
    ..onRecord.listen(handler);
}

class DarwinDefaultLogger {

  /// Disables the ansi formatting for the default logger.
  static bool noAnsi = false;

  /// Sets the box width for the name group.
  static const int groupWidth = 15;

  static void log(LogRecord record) {
    var localTime = record.time.toLocal();
    var hour = localTime.hour.toString().padLeft(2, "0");
    var minute = localTime.minute.toString().padLeft(2, "0");
    var second = localTime.second.toString().padLeft(2, "0");
    var millisecond = localTime.millisecond.toString().padLeft(3, "0");
    var formattedTime = AnsiStyles.gray("$hour:$minute:$second.$millisecond");
    var level = record.level.coloredName;
    var group =
        "[".gray + record.loggerName.padLeft(groupWidth).gray + "]".gray;
    var message = StringBuffer(record.message);
    var colon = AnsiStyles.gray(":");
    if (record.object != null &&
        record.error != null &&
        record.error is StackTrace) {
      message.write("\n${record.error}");
    } else {
      if (record.error != null) message.write(": ${record.error}");
      if (record.stackTrace != null) message.write("\n${record.stackTrace}");
    }
    var finalMessage = "$formattedTime $level $group$colon $message";
    if (noAnsi) finalMessage = AnsiStyles.strip(finalMessage);
    print(finalMessage);
  }
}

extension LogLevelColorExtension on Level {

  /// Returns the formatted name of the log level
  /// for the [DarwinDefaultLogger].
  String get coloredName {
    if (value <= Level.FINEST.value) {
      return "TRACE   ".cyan;
    } else if (value <= Level.FINER.value) {
      return "DEBUG   ".blue;
    } else if (value <= Level.FINE.value) {
      return "VERBOSE ".magenta;
    } else if (value <= Level.CONFIG.value) {
      return "CONFIG  ".green;
    } else if (value <= Level.INFO.value) {
      return "INFO    ".whiteBright;
    } else if (value <= Level.WARNING.value) {
      return "WARNING ".yellow;
    } else if (value <= Level.SEVERE.value) {
      return "SEVERE  ".red;
    }
    return "CRITICAL".red.bold;
  }
}
