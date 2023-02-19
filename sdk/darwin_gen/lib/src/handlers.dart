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

import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

class Handlers {
  static final annotationChecker = TypeChecker.fromRuntime(HandlerAnnotation);

  /// Checks if the given method element has at least one handler annotation.
  static bool isHandlerMethod(MethodElement element) {
    return annotationChecker.annotationsOf(element).isNotEmpty;
  }

  /// Generates only the reusable const variable definition for the enclosing class.
  static String enclosingClassVarDef(ClassElement classElement, CachedAliasCounter counter) {
    var classAnnotations = getHandlerAnnotationsSourceArray(classElement, counter);
    var enclosingClass =
        "$genAlias.HandlerEnclosingClass<${classElement.name}>('${classElement.name}', $classAnnotations)";
    return "const \$enclosingClass = $enclosingClass;";
  }

  /// Generates the source code of a handler registration. Can optionally
  /// [useEnclosingVarDef] to reference the variable $enclosingClass instead
  /// of inserting the enclosing class definition.
  static String generate(
      ClassElement classElement, MethodElement element, ClassBuilder builder, CachedAliasCounter counter,
      {bool useEnclosingVarDef = false}) {
    var proxyFuncName = "_\$${element.name}";
    builder.methods.add(Method((builder) => builder
      ..name = proxyFuncName
      ..static = true
      ..lambda = true
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "obj"
        ..type = Reference("dynamic")))
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "args"
        ..type = Reference("List<dynamic>")))
      ..body = Code(
          "(obj as ${counter.get(classElement.thisType)}).${element.name}(${element.parameters.mapIndexed((i, x) => "args[$i]").join(", ")})")));
    var proxy = "$genAlias.GeneratedHandlerProxy($proxyFuncName)";
    var parameters = "[${element.parameters.map((e) {
      var annotations = getHandlerAnnotationsSourceArray(e, counter);
      return "$genAlias.HandlerParameter<${counter.get(e.type)}>('${e.name}', ${e.isOptional}, $annotations)";
    }).join(", ")}]";
    var annotations = getHandlerAnnotationsSourceArray(element, counter);
    String returnType;
    try {
      returnType = "$genAlias.TypeToken<${counter.get(element.returnType)}>()";
    } catch(_) {
      returnType =  "$genAlias.TypeToken<${element.returnType.getDisplayString(withNullability: false)}>()";
    }
    var classAnnotations = getHandlerAnnotationsSourceArray(classElement, counter);
    var enclosingClass =
        "$genAlias.HandlerEnclosingClass<${counter.get(classElement.thisType)}>('${counter.get(classElement.thisType)}', $classAnnotations)";
    return "const $genAlias.HandlerRegistration('${element.name}', $parameters, $annotations, $returnType, $proxy, ${useEnclosingVarDef ? "\$enclosingClass" : enclosingClass})";
  }
}

String? getHandlerAnnotationsSourceArray(Element element, CachedAliasCounter counter) {
  var annotationChecker = TypeChecker.fromRuntime(HandlerAnnotation);
  var conditions = <String>[];
  for (var value in element.metadata.whereTypeChecker(annotationChecker)) {
    conditions.add(counter.toSource(value.computeConstantValue()!));
  }
  if (conditions.isEmpty) return "[]";
  return "[${conditions.join(", ")}]";
}
