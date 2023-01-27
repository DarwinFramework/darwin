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
import 'package:source_gen/source_gen.dart';

class AnnotatedHandlers {

  static final annotationChecker = TypeChecker.fromRuntime(HandlerAnnotation);

  static bool isHandlerMethod(MethodElement element) {
    return annotationChecker.annotationsOf(element).isNotEmpty;
  }

  static String generateAndGet(ClassElement classElement, MethodElement element, ClassBuilder builder,
      ServiceGenContext genContext, ServiceCodeContext codeContext) {
    var proxyFuncName = "_\$${element.name}";
    builder.methods.add(Method((builder) => builder
        ..name = proxyFuncName
        ..static = true
        ..lambda = true
        ..requiredParameters.add(Parameter((builder) => builder
            ..name = "obj"
            ..type = Reference("dynamic")
        ))
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "args"
        ..type = Reference("List<dynamic>")
      ))
        ..body = Code("(obj as ${classElement.name}).${element.name}(${element.parameters.mapIndexed((i,x) => "args[$i]").join(", ")})")
    ));
    var proxy = "$genAlias.GeneratedHandlerProxy($proxyFuncName)";
    var parameters = "[${element.parameters.map((e) {
      var annotations = getHandlerAnnotationsSourceArray(e);
      return "$genAlias.HandlerParameter<${e.type.getDisplayString(withNullability: false)}>('${e.name}', $annotations)";
    }).join(", ")}]";
    var annotations = getHandlerAnnotationsSourceArray(element);
    var returnType = "$genAlias.HandlerReturnType<${element.returnType.getDisplayString(withNullability: false)}>()";
    return "const $genAlias.HandlerRegistration('${classElement.name}.${element.name}', $parameters, $annotations, $returnType, $proxy)";
  }

}

String? getHandlerAnnotationsSourceArray(Element element) {
  var annotationChecker = TypeChecker.fromRuntime(HandlerAnnotation);
  var conditions = <String>[];
  for (var value in element.metadata.whereTypeChecker(annotationChecker)) {
    conditions.add(value.toSource().substring(1));
  }
  if (conditions.isEmpty) return "[]";
  return "[${conditions.join(", ")}]";
}
