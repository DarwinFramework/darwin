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
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_http_gen/service_generator.dart';
import 'package:lyell_gen/lyell_gen.dart';

class HttpBuilder extends ServiceAdapter<RestController> {
  HttpBuilder() : super(archetype: "http");

  @override
  FutureOr<void> generateSubject(SubjectGenContext genContext, SubjectCodeContext codeContext) async {
    await Handlers.initGenerator(genContext.step);
    await HttpServiceDescriptorGenerator.generateTo(genContext, codeContext);
  }

  @override
  FutureOr<SubjectDescriptor> generateDescriptor(SubjectGenContext<ClassElement> context) async {
    var binding = ServiceBinding(name: "${context.matches.first.displayName}Descriptor");
    var descriptor = context.defaultDescriptor();
    binding.store(descriptor);
    return descriptor;
  }
}
