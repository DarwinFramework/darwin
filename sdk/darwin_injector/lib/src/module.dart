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

import '../darwin_injector.dart';

class Module {
  final Map<InjectorKey, DependencyProvider> _providers = {};

  Map<InjectorKey, DependencyProvider> get providers => _providers;

  Future<dynamic> get(Injector injector, InjectorKey key) {
    var provider = providers[key];
    if (provider == null) {
      throw Exception("No dependency provider for $key found");
    }
    return provider.get(injector);
  }

  bool check(InjectorKey key) {
    return providers.containsKey(key);
  }

  void unbind(InjectorKey key) {
    _providers.remove(key);
  }

  BindingBuilder bind(Type type) => BindingBuilder(this, type);
}
