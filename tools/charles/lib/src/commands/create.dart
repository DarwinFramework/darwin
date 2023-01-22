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

class CreateCommand extends Command<void> {

  @override
  String get description => "Create a new darwin project";

  @override
  String get name => "create";


  CreateCommand() {
    argParser.addOption("type", defaultsTo: "rest", allowed: ["console", "rest"], mandatory: false);
  }

  @override
  Future<void> run() async {
    var type = argResults!["type"]!;
    var left = argResults!.rest.toList();
    var name = left.removeAt(0);

    var working = Directory.current;
    var logger = Logger.standard();
    var ansi = logger.ansi;

    var progress = logger.progress("Generating project files");
    var archive = await DarwinStarter.initialize(name: name, type: ProjectType.values.firstWhere((element) => element.name == type));
    var path = "${working.path}/$name/";
    extractArchiveToDisk(archive, path);
    progress.finish(message: "Done");

    progress = logger.progress("Running pub get");
    await runCmd(Platform.resolvedExecutable, ["pub", "get"], workingDirectory: path);
    progress.finish(message: "Done");

    progress = logger.progress("Running build_runner build");
    await runCmd(Platform.resolvedExecutable, ["run", "build_runner", "build", "--delete-conflicting-outputs"], workingDirectory: path);
    progress.finish(message: "Done");
    logger.write("Created project ${ansi.emphasized(name)}!\n");
  }
}
