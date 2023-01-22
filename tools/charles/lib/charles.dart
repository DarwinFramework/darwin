import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:charles/src/commands/create.dart';
import 'package:charles/src/commands/run.dart';

class CharlesCommandRunner extends CommandRunner<void> {

  CharlesCommandRunner() : super(
      'charles',
      'A command cline utility for working with the darwin framework',
      usageLineLength: terminalWidth
  ) {
    addCommand(CreateCommand());
    addCommand(RunCommand());
  }

}

int get terminalWidth {
  if (stdout.hasTerminal) {
    return stdout.terminalColumns;
  }
  return 80;
}