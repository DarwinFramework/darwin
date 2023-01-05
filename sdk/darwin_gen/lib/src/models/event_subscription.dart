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

class EventSubscriptionDefinition {
  bool isSync;
  bool isAsync;
  String type;
  String accessor;
  String? conditionSourceArray;

  EventSubscriptionDefinition(this.isSync, this.isAsync, this.type, this.accessor,
      this.conditionSourceArray);

  String getCode() {
    String registerStatement;
    if (isSync) {
      registerStatement =
      "system.eventbus.getLine<$type>().subscribe($accessor);";
    } else if (isAsync) {
      registerStatement =
      "system.eventbus.getAsyncLine<$type>().subscribe($accessor);";
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
