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

import 'package:darwin_injector/darwin_injector.dart';

class BindingBuilder {
  Module module;
  Type type;
  String? name;
  dynamic data;

  BindingBuilder(this.module, this.type);

  InjectorKey get key => InjectorKey(type, name, data);

  BindingBuilder withName(String? name) {
    this.name = name;
    return this;
  }

  InjectorKey to(DependencyProvider provider) {
    module.providers[key] = provider;
    return key;
  }

  InjectorKey toConstant(dynamic constant) {
    module.providers[key] = ConstantProvider(constant);
    return key;
  }

  InjectorKey toFunction(FutureOr<dynamic> Function() func,
      {LoadingStrategy strategy = LoadingStrategy.direct}) {
    module.providers[key] = FunctionProvider(func, strategy);
    return key;
  }

  InjectorKey toContextFunction(
      FutureOr<dynamic> Function(Injector injector) func) {
    module.providers[key] = ContextFunctionProvider(func);
    return key;
  }
}
