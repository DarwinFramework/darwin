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

import 'package:json2yaml/json2yaml.dart';

import '../darwin_starter.dart';

class PubspecFactory {
  static String getPubspec(
      ProjectType type,
      Map<String, String> packageVersions,
      List<String> dependenciesList,
      Map<String, Dependable> dependables,
      String name,
      String description) {
    var dependencies = <String, String>{};
    var devDependencies = <String, String>{};
    switch (type) {
      case ProjectType.console:
        dependencies.addAll({
          "logging": packageVersions["logging"]!,
          "darwin_sdk": packageVersions["darwin_sdk"]!,
          "darwin_eventbus": packageVersions["darwin_eventbus"]!,
          "darwin_injector": packageVersions["darwin_injector"]!,
        });
        devDependencies.addAll({
          "lints": packageVersions["lints"]!,
          "test": packageVersions["test"]!,
          "darwin_test": packageVersions["darwin_test"]!,
          "build_runner": packageVersions["build_runner"]!,
          "darwin_gen": packageVersions["darwin_gen"]!,
        });
        break;
      case ProjectType.rest:
        dependencies.addAll({
          "logging": packageVersions["logging"]!,
          "darwin_sdk": packageVersions["darwin_sdk"]!,
          "darwin_eventbus": packageVersions["darwin_eventbus"]!,
          "darwin_injector": packageVersions["darwin_injector"]!,
          "darwin_marshal": packageVersions["darwin_marshal"]!,
          "darwin_http": packageVersions["darwin_http"]!
        });
        devDependencies.addAll({
          "lints": packageVersions["lints"]!,
          "test": packageVersions["test"]!,
          "darwin_test": packageVersions["darwin_test"]!,
          "build_runner": packageVersions["build_runner"]!,
          "darwin_gen": packageVersions["darwin_gen"]!,
          "darwin_http_gen": packageVersions["darwin_http_gen"]!
        });
        break;
    }

    var catalogDependencies = <String>{};
    for (var value in dependenciesList) {
      catalogDependencies.add(value);
      var dependable = dependables[value]!;
      _addDependencyRecursive(dependables, dependable, catalogDependencies);
    }

    for (var value in catalogDependencies) {
      var dependable = dependables[value]!;
      dependencies.addAll(dependable.dependencies);
      devDependencies.addAll(dependable.devDependencies);
    }

    var pubspecContent = json2yaml({
      "name": name,
      "description": description,
      "version": "0.0.1",
      "environment": {"sdk": ">=2.18.6 <3.0.0"},
      "dependencies": dependencies,
      "dev_dependencies": devDependencies
    }, yamlStyle: YamlStyle.pubspecYaml);
    return pubspecContent;
  }
  
  static void _addDependencyRecursive(Map<String, Dependable> dependables,
      Dependable dependable, Set<String> set) {
    set.addAll(dependable.depends);
    for (var element in dependable.depends) {
      _addDependencyRecursive(dependables, dependables[element]!, set);
    }
  }
}