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
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:test/expect.dart';

/// Asserts that a service that is injectable by [T] is running in a [DarwinSystem].
Matcher isRunning<T>() => IsRunning(T);

/// Asserts that a service that is injectable by [T] is not running in a [DarwinSystem].
Matcher isNotRunning<T>() => IsNotRunning(T);

/// Asserts that a [key] is bound in the given [DarwinSystem] or [Injector].
Matcher isBound(InjectorKey key) => IsBound(key);

/// Asserts that a [key] is not bound in the given [DarwinSystem] or [Injector].
Matcher isUnbound(InjectorKey key) => IsUnbound(key);

/// Matcher that checks if an [InjectorKey] is bound.
class IsBound extends Matcher {
  InjectorKey key;
  IsBound(this.key);

  @override
  Description describe(Description description) {
    return description.add("has binding for $key");
  }

  @override
  bool matches(item, Map matchState) {
    if (item is Injector) {
      return item.checkKey(key);
    } else if (item is DarwinSystem) {
      return item.injector.checkKey(key);
    }
    throw ArgumentError("Must be DarwinSystem or Injector");
  }
}

/// Matcher that checks if an [InjectorKey] is not bound.
class IsUnbound extends Matcher {
  InjectorKey key;
  IsUnbound(this.key);

  @override
  Description describe(Description description) {
    return description.add("has no binding for $key");
  }

  @override
  bool matches(item, Map matchState) {
    if (item is Injector) {
      return !item.checkKey(key);
    } else if (item is DarwinSystem) {
      return !item.injector.checkKey(key);
    }
    throw ArgumentError("Must be DarwinSystem or Injector");
  }
}

/// Matcher that checks if a service is running.
class IsRunning extends Matcher {
  Type type;

  IsRunning(this.type);

  @override
  Description describe(Description description) {
    return description.add("has running service $type");
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is! DarwinSystem) throw ArgumentError("Must be DarwinSystem");
    return item.serviceMixin.findServices(type).isNotEmpty;
  }
}

/// Matcher that checks if a service is not running.
class IsNotRunning extends Matcher {
  Type type;

  IsNotRunning(this.type);

  @override
  Description describe(Description description) {
    return description.add("has no running service $type");
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is! DarwinSystem) throw ArgumentError("Must be DarwinSystem");
    return item.serviceMixin.findServices(type).isEmpty;
  }
}
