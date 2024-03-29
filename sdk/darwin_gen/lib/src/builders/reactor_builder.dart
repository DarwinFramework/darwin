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

import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:darwin_gen/src/models/service_binding.dart';
import 'package:glob/glob.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:pubspec/pubspec.dart';
import 'package:recase/recase.dart';

class ServiceReactorBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var isLibrary = false;
    try {
      var pubspecString = await buildStep
          .readAsString(AssetId(buildStep.inputId.package, "pubspec.yaml"));
      var pubspec = PubSpec.fromYamlString(pubspecString);
      var darwinRegion = pubspec.unParsedYaml?["darwin"];
      if (darwinRegion != null) {
        log.info("Using darwin generator options specified in the pubspec.yaml");
        var map = darwinRegion as Map;
        isLibrary = map["library"] as bool? ?? false;
        log.info("isLibrary: $isLibrary");
      }
    } catch (ex) {
      log.warning(
          "Can't resolve package pubspec.yaml with error: $ex. Using default values.");
    }

    StringBuffer buffer = StringBuffer();
    var componentIds = await buildStep.findAssets(Glob("**.service")).toList();
    List<String> importValues = List.empty(growable: true);
    List<String> descriptorNames = List.empty(growable: true);
    importValues.add("package:darwin_sdk/darwin_sdk.dart");
    for (var value in componentIds) {
      var bindingString = await buildStep.readAsString(value);
      var descriptor = SubjectDescriptor.fromMap(jsonDecode(bindingString));
      var binding = ServiceBinding.load(descriptor);
      var sourcePath = binding.package;
      if (!importValues.contains(sourcePath)) importValues.add(sourcePath);
      descriptorNames.add(binding.name);
    }
    buffer.writeln(importValues.map((e) => "import '$e';").join("\n"));
    if (isLibrary) {
      buffer.writeln("""
const ${buildStep.inputId.package.camelCase}GeneratedArgs = DarwinSystemGeneratedArgs([${descriptorNames.map((e) => "$e()").join(",\n")}]);
""");
    } else {
      buffer.writeln("""
const darwinSystemGeneratedArgs = DarwinSystemGeneratedArgs([${descriptorNames.map((e) => "$e()").join(",\n")}]);

late DarwinApplication application;

Future<DarwinApplication> initialiseDarwin() async {
  var instance = DarwinApplication();
  instance.generatedArgs = darwinSystemGeneratedArgs;
  instance.system = DefaultDarwinSystemImpl();
  application = instance;
  return instance;
}
""");
    }

    buildStep.writeAsString(
        AssetId(buildStep.inputId.package, "lib/darwin.g.dart"),
        DartFormatter().format(buffer.toString()));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r"$lib$": ["darwin.g.dart"]
      };
}
