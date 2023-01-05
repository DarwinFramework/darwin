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

import 'package:darwin_injector/darwin_injector.dart';

class Injector {
  final List<Module> _modules = [];
  final Injector? parent;

  late InjectorMetadata metadata;

  Injector({this.parent}) {
    metadata = InjectorMetadata(parent?.metadata);
  }

  /// Returns all modules stores in this injector.
  List<Module> get modules => _modules;

  /// Performs a dependency provider lookup for the given [type], [name]
  /// and [data] and resolves the return provider.
  ///
  /// Throws an [Exception], if the providers returns null or no provider
  /// is found.
  Future<dynamic> get(Type type, {String? name, dynamic data}) async {
    var key = InjectorKey(type, name, data);
    return await getKey(key);
  }

  /// Performs a dependency provider lookup for the given [key]
  /// and resolves the return provider.
  ///
  /// Throws an [Exception], if the providers returns null or no provider
  /// is found.
  Future<dynamic> getKey(InjectorKey key) async {
    var parentState = parent;
    // Check own modules
    for (var module in modules) {
      if (module.check(key)) {
        var value = await module.get(this, key);
        if (value == null) throw Exception("Provided provided null");
        return value;
      }
    }

    // Check parent injector
    if (parentState != null) {
      var isProvidedByParent = parentState.checkKey(key);
      if (isProvidedByParent) return parentState.getKey(key);
    }
    throw Exception("No provider found");
  }

  /// Performs a dependency provider lookup for the given [type], [name]
  /// and [data] and returns whether or not a matching provider has been
  /// found.
  bool check(Type type, {String? name, dynamic data}) {
    var key = InjectorKey(type, name, data);
    return checkKey(key);
  }

  /// Performs a dependency provider lookup for the given [key]
  /// and returns whether or not a matching provider has been
  /// found.
  bool checkKey(InjectorKey key) {
    var parentState = parent;
    if (parentState != null) {
      if (parentState.checkKey(key)) return true;
    }
    return modules.any((element) => element.check(key));
  }

  /// Registers a new [module] into this injector.
  void registerModule(Module module) {
    modules.add(module);
  }

  /// Registers multiple new [modules] into this injector.
  void registerAllModules(Iterable<Module> iterable) {
    modules.addAll(iterable);
  }

  /// Unregisters a [module] in this injector.
  void unregisterModule(Module module, {bool recursive = false}) {
    modules.remove(module);
  }

  /// Returns all modules that contain a binding for the given [key].
  List<Module> where(InjectorKey key) => [
        ...modules.where((element) => element.check(key)).toList(),
        if (parent != null) ...parent!.where(key)
      ];

  /// Creates a new injector which has the this injector as its [parent].
  Injector createChildInjector() => Injector(parent: this);
}
