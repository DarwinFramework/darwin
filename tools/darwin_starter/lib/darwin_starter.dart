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

/// A project generator for darwin framework applications
library darwin_starter;

import 'package:archive/archive.dart';
import 'package:darwin_starter/src/archiver.dart';
import 'package:darwin_starter/src/main.dart';
import 'package:darwin_starter/src/pubspec.dart';
import 'package:darwin_starter/templates/dummy_generated.dart';
import 'package:darwin_starter/templates/misc.dart';

import 'darwin_starter.dart';

export 'src/catalog.dart';
export 'src/project_type.dart';

class DarwinStarter {
  static Future<Archive> initialize(
      {required String name,
      String description = "A sample darwin framework application",
      ProjectType type = ProjectType.console,
      List<String> dependencies = const []}) async {
    var dependables = await StarterCatalog.getDependables();
    var packageVersions = await StarterCatalog.getPackageVersions();

    var files = <String, String>{};
    String pubspecContent = PubspecFactory.getPubspec(type, packageVersions,
        dependencies, dependables, name, description);
    String mainContent = MainFactory.getMain(type, name);

    return package({
      ".gitignore": MiscFiles.gitignore,
      "analysis_options.yaml": MiscFiles.analysisOptions,
      "CHANGELOG.md": MiscFiles.changelog,
      "pubspec.yaml": pubspecContent,
      "README.md": MiscFiles.readme,
      "bin/$name.dart": mainContent,
      "lib/darwin.g.dart": DummyGeneratedTemplates.darwin
    });
  }
}
