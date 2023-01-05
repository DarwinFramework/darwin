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
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:darwin_gen/darwin_gen.dart';
import 'package:source_gen/source_gen.dart';

abstract class ServiceAdapter {
  final String archetype;
  final Type annotation;

  late Builder bindingBuilder;
  late Builder serviceBuilder;

  ServiceAdapter({
    required this.archetype,
    required this.annotation,
  }) {
    bindingBuilder = _ServiceAdapterBindingBuilder(this);
    serviceBuilder = _ServiceAdapterServiceBuilder(this);
  }

  Future<ServiceGenContext?> _createContext(BuildStep step) async {
    var library = await step.inputLibrary;
    var reader = LibraryReader(library);
    var foundServices = reader.annotatedWith(TypeChecker.fromRuntime(annotation));
    if (foundServices.isEmpty) return null;
    if (foundServices.length > 1) throw Exception("A dart file can only contain one service");
    var serviceClass = foundServices.first.element;
    if (serviceClass is! ClassElement) throw Exception("Only classes can be annotated with the service annotation $annotation");
    return ServiceGenContext(reader, serviceClass, step);
  }

  Future<void> generateService(ServiceGenContext genContext, ServiceCodeContext codeContext);

  Future<ServiceBinding> generateBinding(ServiceGenContext context);
}

class ServiceGenContext {
  final LibraryReader library;
  final ClassElement element;
  final BuildStep step;

  ServiceGenContext(this.library, this.element, this.step);

  ServiceBinding defaultBinding(ServiceAdapter adapter) => ServiceBinding(
      name: element.name,
      package: step.inputId.uri.toString(),
      descriptorName: "${element.name}Descriptor",
      descriptorPackage: step.inputId
          .changeExtension(".${adapter.archetype}.g.dart").uri.toString()
  );
}

class ServiceCodeContext {
  final List<AliasImport> additionalImports;
  final StringBuffer codeBuffer;

  ServiceCodeContext(this.additionalImports, this.codeBuffer);
}

class _ServiceAdapterBindingBuilder extends Builder {
  final ServiceAdapter adapter;

  _ServiceAdapterBindingBuilder(this.adapter);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var context = await adapter._createContext(buildStep);
    if (context == null) return;
    print("Generating Service Adapter Bindings for ${buildStep.inputId}");
    var binding = await adapter.generateBinding(context);
    await buildStep.writeAsString(
        buildStep.inputId.changeExtension(".${adapter.archetype}.service"),
        jsonEncode(binding.toMap()));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        ".dart": [".${adapter.archetype}.service"]
      };
}

class _ServiceAdapterServiceBuilder extends Builder {
  final ServiceAdapter adapter;

  _ServiceAdapterServiceBuilder(this.adapter);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var genContext = await adapter._createContext(buildStep);
    if (genContext == null) return;
    print("Generating Service Adapter Code for ${buildStep.inputId}");
    var passedCodeBuffer = StringBuffer();
    var additionalImports = List<AliasImport>.empty(growable: true);
    var codeContext = ServiceCodeContext(additionalImports, passedCodeBuffer);
    await adapter.generateService(genContext, codeContext);
    var codeBuffer = StringBuffer();
    codeBuffer.writeln(getImportString(genContext.library.element,
        genContext.step.inputId, additionalImports));
    codeBuffer.writeln(passedCodeBuffer.toString());
    await buildStep.writeAsString(
        buildStep.inputId.changeExtension(".${adapter.archetype}.g.dart"),
        DartFormatter(pageWidth: 200).format(codeBuffer.toString()));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        ".dart": [".${adapter.archetype}.g.dart"]
      };
}
