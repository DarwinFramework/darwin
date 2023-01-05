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
import 'package:darwin_sdk/darwin.dart';

abstract class Condition {

  const Condition();

  /// Additional service dependencies which are required to perform this
  /// condition check.
  List<InjectorKey> get dependencies => [];

  /// Validates the conditions for the given [DarwinSystem].
  FutureOr<bool> match(DarwinSystem system);
}

extension ConditionIterableExtension on Iterable<Condition> {

  Future<bool> match(DarwinSystem system) async {
    var conditionValues = await Future.wait(
        map((x) async => await x.match(system))
    );
    return conditionValues.every((element) => element == true);
  }

}

class AlwaysCondition extends Condition {

  const AlwaysCondition();

  @override
  FutureOr<bool> match(DarwinSystem system) {
    return true;
  }
}

class NeverCondition extends Condition {

  const NeverCondition();

  @override
  FutureOr<bool> match(DarwinSystem system) {
    return false;
  }
}