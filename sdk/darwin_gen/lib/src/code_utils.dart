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

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

final namedChecker = TypeChecker.fromRuntime(Named);

List<CompiledInjectorKey> getDependencies(List<ParameterElement>? parameters, CachedAliasCounter counter) =>
    parameters?.map((e) => dependencyFromParameter(e, counter)).toList() ?? [];

String? getConditionsSourceArray(Element element, CachedAliasCounter counter) {
  var conditionChecker = TypeChecker.fromRuntime(Condition);
  var conditions = <String>[];
  for (var value in element.metadata.whereTypeChecker(conditionChecker)) {
    conditions.add(counter.toSource(value.computeConstantValue()!));
  }
  if (conditions.isEmpty) return null;
  return "[${conditions.join(", ")}]";
}

CompiledInjectorKey dependencyFromParameter(ParameterElement element, CachedAliasCounter counter) =>
    CompiledInjectorKey(
        element.type,
        namedChecker
            .firstAnnotationOf(element)
            ?.getField("name")
            ?.toStringValue());

CompiledBean parseBean(DartObject object) {
  var strategy = LoadingStrategy.values.firstWhere((element) =>
      element.name ==
      object.getField("strategy")?.getField("_name")?.toStringValue());
  return CompiledBean(
    name: object.getField("name")?.toStringValue(),
    strategy: strategy,
    isUnnamed: object.getField("isUnnamed")?.toBoolValue() ?? false,
    bindingType: object.getField("bindingType")?.toTypeValue(),
  );
}