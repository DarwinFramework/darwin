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
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:source_gen/source_gen.dart';

class DarwinHttpServiceBindingBuilder extends Builder {

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var library = await buildStep.inputLibrary;
    var reader = LibraryReader(library);
    var foundServices = reader.annotatedWith(TypeChecker.fromRuntime(RestController));
    if (foundServices.isEmpty) return;
    if (foundServices.length > 1) throw Exception("A dart file can only have one service");
    var serviceClass = foundServices.first.element;
    if (serviceClass is! ClassElement) throw Exception("Only classes can be annotated with @RestController");
    var package = buildStep.inputId.uri.toString();
    var descriptorId = buildStep.inputId.changeExtension(".http.g.dart");
    var descriptorName = "${serviceClass.name}Descriptor";
    var binding = ServiceBinding(
        name: serviceClass.name,
        package: package,
        descriptorName: descriptorName,
        descriptorPackage: descriptorId.uri.toString()
    );
    await buildStep.writeAsString(buildStep.inputId.changeExtension(".http.service"), jsonEncode(binding.toMap()));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    ".dart": [".http.service"]
  };

}