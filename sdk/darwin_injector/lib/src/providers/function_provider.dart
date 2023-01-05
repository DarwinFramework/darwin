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

class FunctionProvider extends DependencyProvider {

  final FutureOr<dynamic> Function() func;
  final LoadingStrategy strategy;

  bool hasCachedValue = false;
  dynamic cachedValue;

  FunctionProvider(this.func, this.strategy) {
    if (strategy == LoadingStrategy.eager) {
      setCacheValue(func());
    }
  }

  void setCacheValue(dynamic value) {
    hasCachedValue = true;
    cachedValue = value;
  }

  @override
  Future get(Injector injector) async {
    if (hasCachedValue) return cachedValue;
    var value = await func();
    if (strategy == LoadingStrategy.lazy) setCacheValue(value);
    return value;
  }

}