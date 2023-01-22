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

import 'package:darwin_starter/darwin_starter.dart';
import 'package:dio/dio.dart';
import 'package:toml/toml.dart';

class StarterCatalog {
  static final String _catalogUrl =
      "https://raw.githubusercontent.com/DarwinFramework/starter_catalog/main";
  static final String _versionsUrl = "$_catalogUrl/versions.toml";
  static final String _packageVersionsUrl = "$_catalogUrl/packages.toml";
  static final String _dependablesUrl = "$_catalogUrl/dependables.toml";
  static final Dio _client = Dio();

  static Future<List<SdkVersion>> getVersions() async {
    var response = await _client.get(_versionsUrl);
    var document = TomlDocument.parse(response.data).toMap();
    return document.entries.map((e) {
      print(e);
      return SdkVersion(e.key, e.value["description"], e.value["description"]);
    }).toList();
  }

  static Future<Map<String, String>> getPackageVersions() async {
    var response = await _client.get(_packageVersionsUrl);
    var document = TomlDocument.parse(response.data).toMap();
    return document.cast<String, String>();
  }

  static Future<Map<String, Dependable>> getDependables() async {
    var response = await _client.get(_dependablesUrl);
    var document = TomlDocument.parse(response.data).toMap();
    return document.map((k,e) {
      return MapEntry(k, Dependable(
          e["name"],
          e["description"],
          e["category"],
          (e["depends"] as List).cast<String>(),
          (e["dependencies"] as Map).cast<String, String>(),
          (e["dev_dependencies"] as Map).cast<String, String>()));
    });
  }
}

class SdkVersion {
  String name;
  String description;
  String versionRange;

  SdkVersion(this.name, this.description, this.versionRange);

  @override
  String toString() {
    return 'SdkVersion{name: $name, description: $description, versionRange: $versionRange}';
  }
}

class Dependable {
  String name;
  String description;
  String category;
  List<String> depends;
  Map<String, String> dependencies;
  Map<String, String> devDependencies;

  Dependable(this.name, this.description, this.category, this.depends,
      this.dependencies, this.devDependencies);

  @override
  String toString() {
    return 'Dependable{name: $name, description: $description, category: $category, depends: $depends, dependencies: $dependencies, devDependencies: $devDependencies}';
  }
}
