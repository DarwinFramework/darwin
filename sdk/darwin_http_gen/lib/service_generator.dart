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
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_http_gen/darwin_http_gen.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:source_gen/source_gen.dart';

import 'introspect.dart';

class HttpServiceDescriptorGenerator {
  static final String httpServerStrRef = "$genAlias.DarwinHttpServer";
  static final String pathUtilsStrRef = "$genAlias.PathUtils";
  static final String generatedRouteBaseStrRef =
      "$genAlias.DarwinGeneratedHttpRoute";

  static Future<void> generateTo(
      ServiceGenContext genContext, ServiceCodeContext codeContext) async {
    var emitter = DartEmitter();
    var serviceClass = genContext.element;
    var descriptorName = "${serviceClass.name}Descriptor";
    var srcDependencies =
        getDependencies(serviceClass.unnamedConstructor?.parameters);
    var dependencies = srcDependencies.toList()
      ..add(CompiledInjectorKey.fromString(httpServerStrRef, null));

    var controllerMethods = genContext.element.methods;
    var requestMap = Map<MethodElement, RequestMapping>.fromEntries(
        controllerMethods
            .where((element) => requestMappingChecker.hasAnnotationOf(element))
            .map((e) => MapEntry<MethodElement, RequestMapping>(
                e,
                parseRequestMapper(
                    requestMappingChecker.firstAnnotationOf(e)!))));

    _addSpecificMapping(
        controllerMethods, requestMap, getMappingChecker, HttpMethods.get);
    _addSpecificMapping(
        controllerMethods, requestMap, postMappingChecker, HttpMethods.post);
    _addSpecificMapping(
        controllerMethods, requestMap, putMappingChecker, HttpMethods.put);
    _addSpecificMapping(controllerMethods, requestMap, deleteMappingChecker,
        HttpMethods.delete);
    _addSpecificMapping(
        controllerMethods, requestMap, patchMappingChecker, HttpMethods.patch);

    print(requestMap);

    var builder = ClassBuilder();
    var requestRegistrations = await Future.wait(requestMap.entries
        .map((e) =>
        createHttpRegistration(genContext, codeContext, builder, serviceClass, e.value, e.key))
        .toList());

    ServiceGen.implementConstructor(builder, descriptorName);
    ServiceGen.implementDependencies(builder, dependencies);
    ServiceGen.implementPublications(builder,
        [CompiledInjectorKey.fromString(serviceClass.displayName, null)]);
    ServiceGen.implementConditions(builder, serviceClass);
    ServiceGen.implementBindings(
        builder, serviceClass, serviceClass.displayName);
    ServiceGen.implementInstantiate(builder, serviceClass, srcDependencies);

    //region Link Start Methods
    var startMethodCodeBuilder = StringBuffer();
    startMethodCodeBuilder.writeln(
        "$httpServerStrRef httpServer = await system.injector.get($httpServerStrRef);");
    for (var registration in requestRegistrations) {
      startMethodCodeBuilder.writeln(registration);
    }

    builder.methods.add(Method((builder) => builder
      ..returns = Reference("Future<void>")
      ..modifier = MethodModifier.async
      ..name = "start"
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "system"
        ..type = ServiceGen.darwinSystemRef))
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "obj"
        ..type = Reference("dynamic")))
      ..annotations.add(CodeExpression(Code("override")))
      ..body = Code(startMethodCodeBuilder.toString())));
    //endregion
    //region Link Stop Methods
    var stopMethodCodeBuilder = StringBuffer();
    builder.methods.add(Method((builder) => builder
      ..returns = Reference("Future<void>")
      ..modifier = MethodModifier.async
      ..name = "stop"
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "system"
        ..type = ServiceGen.darwinSystemRef))
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "obj"
        ..type = Reference("dynamic")))
      ..annotations.add(CodeExpression(Code("override")))
      ..body = Code(stopMethodCodeBuilder.toString())));

    var descriptorClass = builder.build();
    codeContext.additionalImports.addAll([
      AliasImport.gen("package:darwin_sdk/darwin_sdk.dart"),
      AliasImport.gen("package:darwin_http/darwin_http.dart"),
      AliasImport.gen("package:darwin_injector/darwin_injector.dart"),
      AliasImport.root("dart:async"),
      AliasImport.root("dart:core")
    ]);
    codeContext.codeBuffer.writeln(descriptorClass.accept(emitter));
  }

  static void _addSpecificMapping(
      List<MethodElement> controllerMethods,
      Map<MethodElement, RequestMapping> requestMap,
      TypeChecker checker,
      HttpMethods method) {
    controllerMethods
        .where((element) => checker.hasAnnotationOf(element))
        .forEach((element) {
      requestMap[element] = RequestMapping(
          parseMappingPath(checker.annotationsOf(element).first), method);
    });
  }

  static Future<String> createHttpRegistration(
      ServiceGenContext context,
      ServiceCodeContext codeContext,
      ClassBuilder builder,
      ClassElement classElement,
      RequestMapping mapping,
      MethodElement element) async {

    var handler = AnnotatedHandlers.generateAndGet(classElement, element, builder, context, codeContext);


    var matcherStr = mapping.path;

    var classRequestMapping =
        requestMappingChecker.firstAnnotationOf(classElement);
    if (classRequestMapping != null) {
      var classPath = parseRequestMapper(classRequestMapping).path;
      matcherStr = PathUtils.combinePath(classPath, matcherStr);
    }
    matcherStr = PathUtils.sanitizePath(matcherStr);

    var acceptContentType = acceptsChecker
        .annotationsOf(element)
        .firstOrNull
        ?.getField("contentType")
        ?.toStringValue();
    var returnContentType = returnsChecker
        .annotationsOf(element)
        .firstOrNull
        ?.getField("contentType")
        ?.toStringValue();

    if (acceptContentType != null) acceptContentType = "'$acceptContentType'";
    if (returnContentType != null) returnContentType = "'$returnContentType'";

    var paramFactories = element.parameters
        .map(createParameterFactory)
        .where((element) => element != null)
        .join(", ");

    var responseMarshalType = (await getSerialType(element.returnType, context))
        .getDisplayString(withNullability: false);
    if (responseMarshalType == "void") responseMarshalType = "dynamic";

    var appendedConditions = "";
    var conditionSourceArray = getConditionsSourceArray(element);
    if (conditionSourceArray != null) {
      appendedConditions = "if (await $conditionSourceArray.match(system))";
    }

    var classLevelInterceptors = getInterceptorSourceArray(classElement);

    return """
    $handler;
    
    $appendedConditions
httpServer.registerRoute($generatedRouteBaseStrRef(
  $pathUtilsStrRef.parseMatcher("$matcherStr"),
  $genAlias.${mapping.method},
  (context) async => obj.${element.name}($paramFactories),
   $responseMarshalType, $acceptContentType, $returnContentType,
   const [...$classLevelInterceptors, ...${getInterceptorSourceArray(element)}]
));
""";
  }

  static String? createParameterFactory(ParameterElement element) {
    if (bodyChecker.hasAnnotationOf(element)) {
      var outType = element.type.getDisplayString(withNullability: false);
      return "await httpServer.deserializeBody(context, $outType)";
    }

    if (queryParamChecker.hasAnnotationOf(element)) {
      var queryParam =
          parseQueryParameter(queryParamChecker.firstAnnotationOf(element)!);
      var parameterName = queryParam.name ?? element.name;
      return "context.request.url.queryParameters['$parameterName']";
    }

    if (pathParamChecker.hasAnnotationOf(element)) {
      var pathParam =
          parseQueryParameter(pathParamChecker.firstAnnotationOf(element)!);
      var parameterName = pathParam.name ?? element.name;
      return "context.pathData['$parameterName']";
    }

    if (contextChecker.hasAnnotationOf(element)) {
      var context = parseContext(contextChecker.firstAnnotationOf(element)!);
      var key = context.key ?? element.name;
      return "context['$key']";
    }

    if (headerChecker.hasAnnotationOf(element)) {
      var header = parseHeader(headerChecker.firstAnnotationOf(element)!);
      var name = header.name ?? element.name;
      return "context.request.headers['$name']";
    }

    return "await context.injector.getKey(const ${dependencyFromParameter(element).genInjectorKey})";
  }
}

RequestMapping parseRequestMapper(DartObject object) {
  var method = HttpMethods.values
      .where((element) =>
          element.name ==
          object.getField("method")?.getField("_name")?.toStringValue())
      .firstOrNull;
  var path = object.getField("path")!.toStringValue()!;
  return RequestMapping(path, method);
}

String parseMappingPath(DartObject object) {
  return object.getField("path")?.toStringValue() ?? "";
}

PathParameter parsePathParameter(DartObject object) {
  var name = object.getField("name")?.toStringValue();
  return PathParameter(name);
}

QueryParameter parseQueryParameter(DartObject object) {
  var name = object.getField("name")?.toStringValue();
  return QueryParameter(name);
}

Header parseHeader(DartObject object) {
  var name = object.getField("name")?.toStringValue();
  return Header(name);
}

Context parseContext(DartObject object) {
  var name = object.getField("key")?.toStringValue();
  return Context(name);
}
