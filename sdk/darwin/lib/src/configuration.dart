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

import 'dart:collection';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'system.dart';

typedef ConfigurationKey = List<String>;

/// Class-annotation for defining configuration classes.
///
/// Configuration classes must have zero-argument constructors or constructors
/// callable with zero arguments. All fields of the class must meet following
/// type constraints:
/// - String, int, double, bool
/// - List(String, int, double, bool)
class Configuration {
  /// Path of this configuration class.
  /// The path can be separated by using dots.
  final String? path;

  /// Defines a explicit type the configuration is bound to.
  final Type? boundType;

  const Configuration([this.path, this.boundType]);
}

/// String based asynchronous configuration source for.
abstract class ConfigurationSource {
  Future<String?> resolve(ConfigurationKey key);

  @nonVirtual
  Future<String?> getString(ConfigurationKey key) async {
    var value = await resolve(key);
    return value;
  }

  @nonVirtual
  Future<int?> getInt(ConfigurationKey key) async {
    var value = await resolve(key);
    if (value == null) return null;
    return int.parse(value);
  }

  @nonVirtual
  Future<double?> getDouble(ConfigurationKey key) async {
    var value = await resolve(key);
    if (value == null) return null;
    return double.parse(value);
  }

  @nonVirtual
  Future<bool?> getBool(ConfigurationKey key) async {
    var value = await resolve(key);
    if (value == null) return null;
    return value == "true";
  }

  @nonVirtual
  Future<List<String>?> getStrings(ConfigurationKey key) async {
    var value = await resolve(key);
    if (value == null) return null;
    return value.split(RegExp(", |,"));
  }

  @nonVirtual
  Future<List<int>?> getInts(ConfigurationKey key) async {
    var values = await getStrings(key);
    if (values == null) return null;
    return values.map((e) => int.parse(e)).toList();
  }

  @nonVirtual
  Future<List<double>?> getDoubles(ConfigurationKey key) async {
    var values = await getStrings(key);
    if (values == null) return null;
    return values.map((e) => double.parse(e)).toList();
  }

  @nonVirtual
  Future<List<bool>?> getBools(ConfigurationKey key) async {
    var values = await getStrings(key);
    if (values == null) return null;
    return values.map((e) => e == "true").toList();
  }
}

class CombinedConfigurationSource extends ConfigurationSource {
  List<ConfigurationSource> sources;

  CombinedConfigurationSource(this.sources);

  @override
  Future<String?> resolve(List<String> key) async {
    for (var source in sources) {
      var value = await source.resolve(key);
      if (value == null) continue;
      return value;
    }
    return null;
  }
}

class EnvConfigurationSource extends ConfigurationSource {
  @override
  Future<String?> resolve(List<String> key) async {
    var envKey = key.join("_");
    var env = Platform.environment.entries;
    return env
        .firstWhereOrNull(
            (element) => equalsIgnoreAsciiCase(element.key, envKey))
        ?.value;
  }
}

class RuntimeYamlConfigurationSource extends ConfigurationSource {
  YamlDocument? _cachedYaml;

  Future<YamlDocument?> load() async {
    if (_cachedYaml != null) return _cachedYaml;
    var currentDir = Directory.current;
    var file = File(path.join(currentDir.path, "config.yaml"));
    if (await file.exists()) {
      var map = loadYamlDocument(await file.readAsString());
      _cachedYaml = map;
      return map;
    }
    return null;
  }

  @override
  Future<String?> resolve(List<String> key) async {
    var document = await load();
    return YamlConfigurations.resolveFromYamlDocument(document, key);
  }
}

/// Utilities for implementing [ConfigurationSource]s using yaml.
class YamlConfigurations {
  static String? resolveFromYamlDocument(
      YamlDocument? document, List<String> key) {
    if (document == null) return null;
    if (document.contents is! YamlMap) return null;
    YamlMap cursor = document.contents as YamlMap;
    return resolveFromYamlMap(key, cursor);
  }

  static String? resolveFromYamlMap(List<String> key, YamlMap cursor) {
    for (var i = 0; i < key.length - 1; i++) {
      var part = key[i];
      var newCursorValue = cursor.nodes[part];
      if (newCursorValue == null) return null;
      if (newCursorValue is! YamlMap) return null;
      cursor = newCursorValue;
    }
    var node = cursor.nodes[key.last];
    if (node == null) return null;
    if (node is YamlList) {
      return node.nodes.map((e) => e.span.text).join(",");
    } else {
      return node.span.text;
    }
  }
}

class ApplicationArgsConfigSource extends ConfigurationSource {
  @override
  Future<String?> resolve(List<String> key) async {
    var joinedKey = key.join(".");
    var argSource = DarwinSystem.internalInstance.applicationArgs;
    var queue = Queue.of(argSource);
    while (queue.isNotEmpty) {
      var next = queue.removeFirst();
      if (next.startsWith("--$joinedKey=")) {
        var value = next.replaceFirst("--$joinedKey=", "");
        return value;
      } else if (queue.isNotEmpty && next == "--$joinedKey") {
        var value = queue.removeFirst();
        return value;
      } else if (next == "--$joinedKey") {
        return "true";
      } else if (next == "--no-$joinedKey") {
        return "false";
      }
    }
    return null;
  }
}

class DarwinSystemConfigurationMixin {
  static final List<ConfigurationSource> defaultSources = [
    ApplicationArgsConfigSource(),
    RuntimeYamlConfigurationSource(),
    EnvConfigurationSource(),
  ];

  List<String> applicationArgs = [];

  List<ConfigurationSource>? _configurationSources = defaultSources;
  ConfigurationSource configurationSource =
      CombinedConfigurationSource(defaultSources);

  List<ConfigurationSource>? get configurationSourceList =>
      _configurationSources;

  set configurationSourceList(List<ConfigurationSource>? value) {
    _configurationSources = value;
    configurationSource = CombinedConfigurationSource(value ?? []);
  }
}

class DarwinBaseConfiguration {
  String? profile;
  Level level;

  DarwinBaseConfiguration(this.profile, this.level);

  static Future<DarwinBaseConfiguration> load(DarwinSystem system) async {
    var source = system.configurationSource;
    var profile = (await system.configurationSource.getString(["profile"])) ?? system.profile;
    var levelInput = (await source.getString(["logging", "level"]));
    var level = levelInput == null
        ? Level.INFO
        : Level.LEVELS.firstWhere((element) => equalsIgnoreAsciiCase(element.name, levelInput));
    return DarwinBaseConfiguration(profile, level);
  }
}
