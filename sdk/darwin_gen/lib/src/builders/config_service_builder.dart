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

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_sdk/darwin_sdk.dart' as darwin;
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

class ConfigServiceBuilder extends ServiceAdapter<darwin.Configuration> {
  ConfigServiceBuilder() : super(archetype: "conf");

  @override
  FutureOr<void> generateSubject(SubjectGenContext<ClassElement> genContext, SubjectCodeContext codeContext) async {
    var emitter = DartEmitter();
    AliasCounter aliasCounter = AliasCounter();
    CachedAliasCounter counter = CachedAliasCounter(aliasCounter);
    var configClass = genContext.matches.first;
    var descriptorName = "${configClass.name}Descriptor";
    var dependencies = getDependencies(configClass.unnamedConstructor?.parameters, counter);
    var configurationChecker = TypeChecker.fromRuntime(darwin.Configuration).firstAnnotationOf(configClass);
    var pathPrefix = configurationChecker
        ?.getField("path")
        ?.toStringValue()?.split(".") ?? <String>[];
    var boundType = configurationChecker
        ?.getField("boundType")
        ?.toTypeValue() ?? configClass.thisType;
    var published = <CompiledInjectorKey>[
      CompiledInjectorKey(boundType, null)
    ];
    var descriptorClass = Class((builder) {
      ServiceGen.implementConstructor(builder, descriptorName);
      ServiceGen.implementPublications(builder, published, counter);
      ServiceGen.implementDependencies(builder, dependencies, counter);
      ServiceGen.implementBindings(builder, configClass, boundType, counter);
      ServiceGen.implementInstantiate(builder, configClass, dependencies, counter);
      ServiceGen.implementConditions(builder, configClass, counter);
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
        ..body = Code(configClass.fields.map((e) {
          var fieldName = e.name;
          var actualName = "[${[...pathPrefix, e.name].map((e) => "'$e'").join(", ")}]";
          var suffix = "if ($fieldName != null) {obj.$fieldName = $fieldName;}";
          if (e.type.isDartCoreString) {
            return "var $fieldName = await system.configurationSource.getString($actualName);$suffix";
          } else if (e.type.isDartCoreInt) {
            return "var $fieldName = await system.configurationSource.getInt($actualName);$suffix";
          } else if (e.type.isDartCoreDouble) {
            return "var $fieldName = await system.configurationSource.getDouble($actualName);$suffix";
          } else if (e.type.isDartCoreBool) {
            return "var $fieldName = await system.configurationSource.getBool($actualName);$suffix";
          } else if (TypeChecker.fromRuntime(List<String>).isAssignableFromType(e.type)) {
            return "var $fieldName = await system.configurationSource.getStrings($actualName);$suffix";
          } else if (TypeChecker.fromRuntime(List<int>).isAssignableFromType(e.type)) {
            return "var $fieldName = await system.configurationSource.getInts($actualName);$suffix";
          } else if (TypeChecker.fromRuntime(List<double>).isAssignableFromType(e.type)) {
            return "var $fieldName = await system.configurationSource.getDoubles($actualName);$suffix";
          } else if (TypeChecker.fromRuntime(List<bool>).isAssignableFromType(e.type)) {
            return "var $fieldName = await system.configurationSource.getBools($actualName);$suffix";
          }
        }).join("\n"))));

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
        ..body = Code("")));
    });
    codeContext.additionalImports.addAll(counter.imports);
    codeContext.additionalImports.addAll([
      AliasImport.gen("package:darwin_sdk/darwin_sdk.dart"),
      AliasImport.gen("package:darwin_injector/darwin_injector.dart"),
      AliasImport.root("dart:async"),
      AliasImport.root("dart:core")
    ]);
    codeContext.codeBuffer.writeln(descriptorClass.accept(emitter));
  }

  @override
  FutureOr<SubjectDescriptor> generateDescriptor(SubjectGenContext<ClassElement> context) {
    var binding = ServiceBinding(name: "${context.matches.first.displayName}Descriptor");
    var descriptor = context.defaultDescriptor();
    binding.store(descriptor);
    return descriptor;
  }
}