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
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_http/darwin_http.dart' as dh;
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

class HttpServiceDescriptorGenerator {
  static final String httpServerStrRef = "$genAlias.DarwinHttpServer";
  static final String pathUtilsStrRef = "$genAlias.PathUtils";
  static final String generatedRouteBaseStrRef =
      "$genAlias.DarwinHttpHandlerRoute";

  static Future<void> generateTo(
      SubjectGenContext genContext, SubjectCodeContext codeContext) async {
    var emitter = DartEmitter();
    AliasCounter aliasCounter = AliasCounter();
    CachedAliasCounter counter = CachedAliasCounter(aliasCounter);
    LibraryElement httpLibraryElement = await genContext.step.resolver
        .libraryFor(
            AssetId.resolve(Uri.parse("package:darwin_http/darwin_http.dart")));
    LibraryReader httpLibrary = LibraryReader(httpLibraryElement);
    DartType httpServer = httpLibrary.findType("DarwinHttpServer")!.thisType;

    var serviceClass = genContext.matches.first as ClassElement;
    var descriptorName = "${serviceClass.name}Descriptor";
    var srcDependencies =
        getDependencies(serviceClass.unnamedConstructor?.parameters, counter);
    var dependencies = srcDependencies.toList()
      ..add(CompiledInjectorKey(httpServer, null));
    var controllerMethods = serviceClass.methods;
    var builder = ClassBuilder();
    //region Generate Service Implementation
    ServiceGen.implementConstructor(builder, descriptorName);
    ServiceGen.implementDependencies(builder, dependencies, counter);
    ServiceGen.implementPublications(builder, [CompiledInjectorKey(serviceClass.thisType, null)], counter);
    ServiceGen.implementConditions(builder, serviceClass, counter);
    ServiceGen.implementBindings(builder, serviceClass, serviceClass.thisType, counter);
    ServiceGen.implementInstantiate(builder, serviceClass, srcDependencies, counter);
    //endregion
    //region Link Start Methods
    var startMethodCodeBuilder = StringBuffer();
    startMethodCodeBuilder.writeln(Handlers.enclosingClassVarDef(serviceClass, counter));
    startMethodCodeBuilder.writeln(
        "${counter.get(httpServer)} httpServer = await system.injector.get(${counter.get(httpServer)});");
    var pathSpecifierChecker = TypeChecker.fromRuntime(dh.RequestPathSpecifier);
    var requestRegistrations = (await Future.wait(controllerMethods
            .where((element) => pathSpecifierChecker.hasAnnotationOf(element))
            .map((e) => createHttpRegistration(
                genContext, codeContext, builder, serviceClass, e, counter))))
        .toList();
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
    //endregion
    var descriptorClass = builder.build();
    codeContext.additionalImports.addAll(counter.imports);
    codeContext.additionalImports.addAll([
      AliasImport.gen("package:darwin_sdk/darwin_sdk.dart"),
      AliasImport.gen("package:darwin_http/darwin_http.dart"),
      AliasImport.gen("package:darwin_injector/darwin_injector.dart"),
      AliasImport.gen("package:lyell/lyell.dart"),
      AliasImport.root("dart:async"),
      AliasImport.root("dart:core")
    ]);
    codeContext.additionalImports.where((element) => element.import.startsWith("dart:_http")).toList().forEach((element) {
      codeContext.additionalImports.remove(element);
      codeContext.additionalImports.add(AliasImport("dart:io", element.alias));
    });
    codeContext.codeBuffer.writeln(descriptorClass.accept(emitter));
  }

  static Future<String> createHttpRegistration(
      SubjectGenContext context,
      SubjectCodeContext code,
      ClassBuilder builder,
      ClassElement clazz,
      MethodElement element,
      CachedAliasCounter counter) async {
    var handler =
        Handlers.generate(clazz, element, builder, counter, useEnclosingVarDef: true);

    var appendedConditions = "";
    var conditionSourceArray = getConditionsSourceArray(element, counter);
    if (conditionSourceArray != null) {
      appendedConditions = "if (await $conditionSourceArray.match(system))";
    }

    return "$appendedConditions httpServer.registerRoute($generatedRouteBaseStrRef(system, obj, $handler));";
  }
}
