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
import 'package:darwin_eventbus/darwin_eventbus.dart';
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:source_gen/source_gen.dart';

class BaseServiceResults {
  String descriptorName;
  List<CompiledInjectorKey> dependencies;

  BaseServiceResults(this.descriptorName, this.dependencies);
}

class ServiceGen {
  static final Reference serviceDescriptorRef =
      Reference("$genAlias.ServiceDescriptor");
  static final Reference darwinSystemRef = Reference("$genAlias.DarwinSystem");
  static final Reference injectorRef = Reference("$genAlias.Injector");
  static final Reference injectorKeyRef = Reference("$genAlias.InjectorKey");
  static final Reference injectorKeyListRef =
      Reference("List<$genAlias.InjectorKey>");
  static final Reference conditionRef = Reference("$genAlias.Condition");
  static final Reference conditionListRef =
      Reference("List<$genAlias.Condition>");

  static final String serviceBaseStrRef = "$genAlias.ServiceBase";

  static final serviceChecker = TypeChecker.fromRuntime(Service);
  static final startChecker = TypeChecker.fromRuntime(Start);
  static final stopChecker = TypeChecker.fromRuntime(Stop);
  static final beanChecker = TypeChecker.fromRuntime(Bean);
  static final subscriptionChecker = TypeChecker.fromRuntime(Subscribe);
  static final syncEventChecker = TypeChecker.fromRuntime(SyncEvent);
  static final asyncEventChecker = TypeChecker.fromRuntime(AsyncEvent);

  static Future<BaseServiceResults> generateTo(
      ServiceGenContext genContext, ServiceCodeContext codeContext) async {
    var emitter = DartEmitter();
    var serviceClass = genContext.element;
    var descriptorName = "${serviceClass.name}Descriptor";
    var dependencies =
        getDependencies(serviceClass.unnamedConstructor?.parameters);

    List<GeneratedBeanDefinition> beans = getBeanDefinitions(genContext);
    List<EventSubscriptionDefinition> eventSubscriptions =
        getEventSubscriptions(genContext);

    var serviceAnnotation = serviceChecker.firstAnnotationOf(serviceClass);
    var boundType = serviceAnnotation
            ?.getField("type")
            ?.toTypeValue()
            ?.getDisplayString(withNullability: false) ??
        serviceClass.name;
    var published = <CompiledInjectorKey>[
      CompiledInjectorKey.fromString(boundType, null),
      ...beans.where((element) => element.conditionSourceArray == null).map(
          (e) => e.bean
              .getInjectorKey(e.accessor.sourceType, e.accessor.sourceName))
    ];

    var descriptorClass = Class((builder) {
      implementConstructor(builder, descriptorName);
      implementPublications(builder, published);
      implementDependencies(builder, dependencies);
      implementConditions(builder, serviceClass);
      implementBindings(builder, serviceClass, boundType);
      implementInstantiate(builder, serviceClass, dependencies);
      implementStartMethod(serviceClass, beans, eventSubscriptions, builder);
      implementStopMethod(serviceClass, builder);
    });
    codeContext.additionalImports.addAll([
      AliasImport.gen("package:darwin_sdk/darwin_sdk.dart"),
      AliasImport.gen("package:darwin_injector/darwin_injector.dart"),
      AliasImport.root("dart:async"),
      AliasImport.root("dart:core")
    ]);
    codeContext.codeBuffer.writeln(descriptorClass.accept(emitter));
    return BaseServiceResults(descriptorName, dependencies);
  }

  static List<GeneratedBeanDefinition> getBeanDefinitions(
      ServiceGenContext genContext) {
    var beans = <GeneratedBeanDefinition>[];
    genContext.element.methods
        .where((element) => beanChecker.hasAnnotationOf(element))
        .forEach((element) {
      var accessor = BeanGenAccessor(
          element.displayName,
          element.returnType.getDisplayString(withNullability: false),
          "obj.${element.name}");
      var bean = parseBean(beanChecker.firstAnnotationOf(element)!);
      var conditions = getConditionsSourceArray(element);
      beans.add(GeneratedBeanDefinition(accessor, bean, conditions));
    });
    genContext.element.fields
        .where((element) => beanChecker.hasAnnotationOf(element))
        .forEach((element) {
      var accessor = BeanGenAccessor(
          element.displayName,
          element.type.getDisplayString(withNullability: false),
          "() => obj.${element.name}");
      var bean = parseBean(beanChecker.firstAnnotationOf(element)!);
      var conditions = getConditionsSourceArray(element);
      beans.add(GeneratedBeanDefinition(accessor, bean, conditions));
    });
    return beans;
  }

  static List<EventSubscriptionDefinition> getEventSubscriptions(
      ServiceGenContext genContext) {
    var eventSubscriptions = genContext.element.methods
        .where((element) => subscriptionChecker.hasAnnotationOf(element))
        .map((element) {
      if (element.parameters.isEmpty) {
        throw Exception("Subscribed methods must have an event argument.");
      }
      var type = element.parameters.first.type;
      return EventSubscriptionDefinition(
          syncEventChecker.isSuperTypeOf(type),
          asyncEventChecker.isSuperTypeOf(type),
          type.getDisplayString(withNullability: false),
          "(evt) async => await (obj.${element.name}(evt) as FutureOr<dynamic>)",
          getConditionsSourceArray(element));
    }).toList();
    return eventSubscriptions;
  }

  static void implementConstructor(
      ClassBuilder builder, String descriptorName) {
    builder
      ..name = descriptorName
      ..extend = serviceDescriptorRef
      ..constructors.add(Constructor((builder) => builder..constant = true));
  }

  static void implementInstantiate(ClassBuilder builder,
      ClassElement serviceClass, List<CompiledInjectorKey> dependencies) {
    builder.methods.add(Method((builder) => builder
      ..name = "instantiate"
      ..returns = Reference("Future<dynamic>")
      ..annotations.add(CodeExpression(Code("override")))
      ..modifier = MethodModifier.async
      ..requiredParameters.add(Parameter((builder) => builder
        ..type = injectorRef
        ..name = "injector"))
      ..body = Code(
          "return ${serviceClass.name}(${dependencies.map((e) => "await injector.getKey(${e.genInjectorKey})").join(", ")});")));
  }

  static void implementBindings(
      ClassBuilder builder, ClassElement serviceClass, String boundType) {
    builder.methods.add(Method((builder) => builder
      ..name = "serviceType"
      ..type = MethodType.getter
      ..returns = Reference("Type")
      ..annotations.add(CodeExpression(Code("override")))
      ..lambda = true
      ..body = Code(serviceClass.name)));
    builder.methods.add(Method((builder) => builder
      ..name = "bindingType"
      ..type = MethodType.getter
      ..returns = Reference("Type")
      ..annotations.add(CodeExpression(Code("override")))
      ..lambda = true
      ..body = Code(boundType)));
  }

  static void implementDependencies(
      ClassBuilder builder, List<CompiledInjectorKey> dependencies) {
    builder.methods.add(Method((builder) => builder
      ..name = "dependencies"
      ..type = MethodType.getter
      ..returns = injectorKeyListRef
      ..annotations.add(CodeExpression(Code("override")))
      ..lambda = true
      ..body = Code(
          "const [${dependencies.map((e) => e.genInjectorKey).join(",")}]")));
  }

  static void implementPublications(
      ClassBuilder builder, List<CompiledInjectorKey> publications) {
    builder.methods.add(Method((builder) => builder
      ..name = "publications"
      ..type = MethodType.getter
      ..returns = injectorKeyListRef
      ..annotations.add(CodeExpression(Code("override")))
      ..lambda = true
      ..body = Code(
          "const [${publications.map((e) => e.genInjectorKey).join(",")}]")));
  }

  static void implementConditions(ClassBuilder builder, Element element) {
    var source = getConditionsSourceArray(element) ?? "[]";
    builder.methods.add(Method((builder) => builder
      ..name = "conditions"
      ..type = MethodType.getter
      ..returns = conditionListRef
      ..annotations.add(CodeExpression(Code("override")))
      ..lambda = true
      ..body = Code("const $source")));
  }

  static void implementStartMethod(
      ClassElement serviceClass,
      List<GeneratedBeanDefinition> beans,
      List<EventSubscriptionDefinition> subscriptions,
      ClassBuilder builder) {
    var startMethod = serviceClass.methods
        .firstWhereOrNull((element) => startChecker.hasAnnotationOf(element));
    var startMethodCodeBuilder = StringBuffer();
    if (startMethod != null) {
      startMethodCodeBuilder.writeln(
          "if (obj is $serviceBaseStrRef) await (obj as $serviceBaseStrRef).start(system);await ((obj as ${serviceClass.name}).${startMethod.name}() as FutureOr<void>);");
    } else {
      startMethodCodeBuilder.writeln(
          "if (obj is $serviceBaseStrRef) await (obj as $serviceBaseStrRef).start(system);");
    }

    for (var element in beans) {
      startMethodCodeBuilder.writeln(element.getCode());
    }

    for (var element in subscriptions) {
      startMethodCodeBuilder.writeln(element.getCode());
    }

    builder.methods.add(Method((builder) => builder
      ..returns = Reference("Future<void>")
      ..modifier = MethodModifier.async
      ..name = "start"
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "system"
        ..type = darwinSystemRef))
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "obj"
        ..type = Reference("dynamic")))
      ..annotations.add(CodeExpression(Code("override")))
      ..body = Code(startMethodCodeBuilder.toString())));
  }

  static void implementStopMethod(
      ClassElement serviceClass, ClassBuilder builder) {
    var stopMethod = serviceClass.methods
        .firstWhereOrNull((element) => stopChecker.hasAnnotationOf(element));
    var stopMethodCodeBuilder = StringBuffer();

    if (stopMethod != null) {
      stopMethodCodeBuilder.writeln(
          "await ((obj as ${serviceClass.name}).${stopMethod.name}() as FutureOr<void>);if (obj is $serviceBaseStrRef) await (obj as $serviceBaseStrRef).stop(system);");
    } else {
      stopMethodCodeBuilder.writeln(
          "if (obj is $serviceBaseStrRef) await (obj as $serviceBaseStrRef).stop(system);");
    }

    builder.methods.add(Method((builder) => builder
      ..returns = Reference("Future<void>")
      ..modifier = MethodModifier.async
      ..name = "stop"
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "system"
        ..type = darwinSystemRef))
      ..requiredParameters.add(Parameter((builder) => builder
        ..name = "obj"
        ..type = Reference("dynamic")))
      ..annotations.add(CodeExpression(Code("override")))
      ..body = Code(stopMethodCodeBuilder.toString())));
  }
}
