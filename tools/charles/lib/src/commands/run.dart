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

import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:charles/src/execution.dart';
import 'package:cli_util/cli_util.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:darwin_starter/darwin_starter.dart';

class RunCommand extends Command<void> {

  @override
  String get description => "Runs the darwin application";

  @override
  String get name => "run";

  RunCommand() {}

  @override
  Future<void> run() async {
    var working = Directory.current;
    var logger = Logger.standard();
    var ansi = logger.ansi;

    var progress = logger.progress("Running build_runner build");
    await runCmd(Platform.resolvedExecutable, ["run", "build_runner", "build", "--delete-conflicting-outputs"]);
    progress.finish(message: "Done");
    await runWrappedCmd(Platform.resolvedExecutable, ["run"]);
  }
}
