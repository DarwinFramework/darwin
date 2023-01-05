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
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_injector/darwin_injector.dart';

class CompiledBean {

  final String? name;
  final LoadingStrategy strategy;
  final bool isUnnamed;
  final DartType? bindingType;

  const CompiledBean({
    required this.name,
    required this.strategy,
    required this.isUnnamed,
    required this.bindingType,
  });

  String getCode(String methodName, String returnType, {bool aliased = true}) {
    var nameArg = name ?? methodName;
    var typeArg = bindingType?.getDisplayString(withNullability: false) ?? returnType;
    return "${aliased ? "$genAlias." : ""}Bean(name: '$nameArg', strategy: ${aliased ? "$genAlias." : ""}$strategy, isUnnamed: $isUnnamed, bindingType: $typeArg)";
  }

  CompiledInjectorKey getInjectorKey(String returnType, String methodName) {
    return CompiledInjectorKey.fromString(bindingType?.getDisplayString(withNullability: false) ?? returnType, isUnnamed ? null : (name ?? methodName));
  }

}