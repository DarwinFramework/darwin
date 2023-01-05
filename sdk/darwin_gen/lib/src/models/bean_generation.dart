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

import 'package:darwin_gen/darwin_gen.dart';

class BeanGenAccessor {
  String sourceName;
  String sourceType;
  String accessor; // The service object will always have the name 'obj'

  BeanGenAccessor(this.sourceName, this.sourceType, this.accessor);
}

class GeneratedBeanDefinition {
  final BeanGenAccessor accessor;
  final CompiledBean bean;
  final String? conditionSourceArray;

  GeneratedBeanDefinition(this.accessor, this.bean, this.conditionSourceArray);

  String getCode() {
    var manuallyRevivedBean =
    bean.getCode(accessor.sourceName, accessor.sourceType);
    var registerStatement =
        "system.beanMixin.registerBean($manuallyRevivedBean, ${accessor.accessor});";
    if (conditionSourceArray == null) {
      return registerStatement;
    } else {
      return "if (await $conditionSourceArray.match(system)) $registerStatement";
    }
  }
}