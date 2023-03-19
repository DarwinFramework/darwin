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

import 'package:analyzer/dart/element/type.dart';
import 'package:lyell_gen/lyell_gen.dart';

class EventSubscriptionDefinition {
  bool isSync;
  bool isAsync;
  DartType type;
  String accessor;
  int priority;
  String? conditionSourceArray;

  EventSubscriptionDefinition(this.isSync, this.isAsync, this.type,
      this.accessor, this.conditionSourceArray, this.priority);

  String getCode(CachedAliasCounter counter) {
    String registerStatement;
    if (isSync) {
      registerStatement =
          "system.eventbus.getLine<${counter.get(type)}>().subscribe($accessor, priority: $priority);";
    } else if (isAsync) {
      registerStatement =
          "system.eventbus.getAsyncLine<${counter.get(type)}>().subscribe($accessor, priority: $priority);";
    } else {
      throw Exception("Can't determine event type");
    }

    if (conditionSourceArray == null) {
      return registerStatement;
    } else {
      return "if (await $conditionSourceArray.match(system)) $registerStatement";
    }
  }
}
