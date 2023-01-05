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
import 'package:darwin_sdk/darwin.dart';
import 'package:source_gen/source_gen.dart';

const String genAlias = "gen";

class AliasImport {
  final String import;
  final String? alias;

  const AliasImport(this.import, this.alias);

  factory AliasImport.root(String import) => AliasImport(import, null);
  factory AliasImport.gen(String import) => AliasImport(import, genAlias);

  String get code => "import '$import'${alias == null ? "" : " as $alias"};";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AliasImport &&
          runtimeType == other.runtimeType &&
          import == other.import &&
          alias == other.alias;

  @override
  int get hashCode => import.hashCode ^ alias.hashCode;
}

String getImportString(LibraryElement library, AssetId id,
    [List<AliasImport> additional = const []]) {
  Set<AliasImport> importValues = <AliasImport>{};
  importValues.addAll(additional);
  importValues.add(AliasImport.root(id.uri.toString()));
  for (var element in library.libraryImports) {
    importValues.add(AliasImport(element.importedLibrary!.identifier,
        element.prefix?.element.displayName));
  }
  return importValues.map((e) => e.code).join("\n");
}

final namedChecker = TypeChecker.fromRuntime(Named);

List<CompiledInjectorKey> getDependencies(List<ParameterElement>? parameters) =>
    parameters?.map(dependencyFromParameter).toList() ?? [];

String? getConditionsSourceArray(Element element) {
  var conditionChecker = TypeChecker.fromRuntime(Condition);
  var conditions = <String>[];
  for (var value in element.metadata.whereTypeChecker(conditionChecker)) {
    conditions.add(value.toSource().substring(1));
  }
  if (conditions.isEmpty) return null;
  return "[${conditions.join(", ")}]";
}

CompiledInjectorKey dependencyFromParameter(ParameterElement element) =>
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

String trimAsyncType(String src) {
  if (src.startsWith("Future<") || src.startsWith("Stream<")) {
    return removeOutermostGenerics(src);
  }
  if (src == "Future" || src == "Stream") return "dynamic";
  return src;
}

String removeOutermostGenerics(String src) {
  var dls = src.split("<");
  var drs = src.split(">");
  if (dls.length == 1 || drs.length == 1) return src;
  var left = dls.skip(1).join("<");
  var right = drs.skip(1).take(drs.length - 1).join(">");
  return left.substring(0, left.length - drs.length + 1) + right;
}

extension MetadataExtension on List<ElementAnnotation> {
  List<ElementAnnotation> whereTypeChecker(TypeChecker checker) =>
      where((element) => checker.isAssignableFrom(
          element.computeConstantValue()!.type!.element2!)).toList();
}
