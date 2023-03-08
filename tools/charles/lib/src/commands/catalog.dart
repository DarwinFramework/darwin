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

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:darwin_starter/darwin_starter.dart';
import 'package:pub_api_client/pub_api_client.dart';
import 'package:toml/toml.dart';

class CatalogCommand extends Command<void> {
  @override
  String get description => "Utility for maintaining darwin starter catalogs";

  @override
  String get name => "catalog";

  CatalogCommand() {}

  @override
  Future<void> run() async {
    var working = Directory.current;
    var logger = Logger.standard();
    var ansi = logger.ansi;
    var pubClient = PubClient();

    await updatePackageVersions(pubClient, logger, ansi, working);
    await updateDependableVersions(pubClient, logger, ansi, working);

    logger.stdout("Finished!");
    pubClient.close();
  }

  Future<void> updatePackageVersions(
      PubClient pubClient, Logger logger, Ansi ansi, Directory working) async {
    var currentPackageVersion = await StarterCatalog.getPackageVersions();
    var newPackageVersions = <String, String>{};
    for (var entry in currentPackageVersion.entries) {
      await _updateVersion(
          pubClient, entry.key, entry.value, logger, ansi, newPackageVersions);
    }
    await File("${working.path}/packages.toml")
        .writeAsString(TomlDocument.fromMap(newPackageVersions).toString());
  }

  Future<void> updateDependableVersions(
      PubClient pubClient, Logger logger, Ansi ansi, Directory working) async {
    var currentPackageVersion = await StarterCatalog.getDependables();
    var newDependables = <String, Dependable>{};
    for (var dep in currentPackageVersion.entries) {
      var newMainVersion = <String, String>{};
      var newDevVersion = <String, String>{};
      logger.stdout("Selecting dependable ${ansi.emphasized(dep.value.name)}");
      for (var entry in dep.value.dependencies.entries) {
        await _updateVersion(
            pubClient, entry.key, entry.value, logger, ansi, newMainVersion);
      }
      for (var entry in dep.value.devDependencies.entries) {
        await _updateVersion(
            pubClient, entry.key, entry.value, logger, ansi, newDevVersion);
      }
      newDependables[dep.key] = Dependable(
          dep.value.name,
          dep.value.description,
          dep.value.category,
          dep.value.depends,
          newMainVersion,
          newDevVersion);
    }
    await File("${working.path}/dependables.toml").writeAsString(
        TomlDocument.fromMap(newDependables
            .map((key, value) => MapEntry(key, value.toMap()))).toString());
  }

  Future<void> _updateVersion(
      PubClient pubClient,
      String packageName,
      String packageVersion,
      Logger logger,
      Ansi ansi,
      Map<String, String> newPackageVersions) async {
    var versions = await pubClient.packageVersions(packageName);
    var originVersion = packageVersion.replaceFirst("^", "").split(".");
    var targetVersion = packageVersion;
    for (var newVersion in versions) {
      var spliced = newVersion.split(".");
      if (spliced[0] == originVersion[0] && spliced[1] == originVersion[1]) {
        targetVersion = "^$newVersion";
        break;
      }
      logger.stdout(
          "Update ${ansi.emphasized(packageName)} from ${packageVersion} to "
          "${"${ansi.green}${ansi.bold}^$newVersion${ansi.none}}"}?\n"
          "(y = Yes, n = No, k = Keep)");
      var choice = stdin.readLineSync()!;
      if (choice == "y" || choice == "yes") {
        targetVersion = "^$newVersion";
        break;
      } else if (choice == "k" || choice == "keep") {
        targetVersion = packageVersion;
        break;
      }
    }
    newPackageVersions[packageName] = targetVersion;
    if (targetVersion != packageVersion) {
      logger.write(
          "Updated package ${ansi.emphasized(packageName)} from $packageVersion "
          "to ${ansi.emphasized(targetVersion)}\n");
    } else {
      logger.write("Keeping version ${ansi.emphasized(packageVersion)} for "
          "package ${ansi.emphasized(packageName)}\n");
    }
  }
}
