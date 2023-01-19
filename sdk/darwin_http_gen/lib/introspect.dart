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
import 'package:darwin_gen/darwin_gen.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:source_gen/source_gen.dart';

bool _isInitialized = false;
late LibraryReader coreLibraryReader;

late InterfaceElement iterableType;
final iterableChecker = TypeChecker.fromRuntime(Iterable);

late InterfaceElement listType;
final listChecker = TypeChecker.fromRuntime(List);

late InterfaceElement setType;
final setChecker = TypeChecker.fromRuntime(Set);

late InterfaceElement streamType;
final streamChecker = TypeChecker.fromRuntime(Stream);

late InterfaceElement futureType;
final futureChecker = TypeChecker.fromRuntime(Future);

final bodyChecker = TypeChecker.fromRuntime(Body);
final queryParamChecker = TypeChecker.fromRuntime(QueryParameter);
final pathParamChecker = TypeChecker.fromRuntime(PathParameter);
final contextChecker = TypeChecker.fromRuntime(Context);
final headerChecker = TypeChecker.fromRuntime(Header);
final requestMappingChecker = TypeChecker.fromRuntime(RequestMapping);
final acceptsChecker = TypeChecker.fromRuntime(Accepts);
final returnsChecker = TypeChecker.fromRuntime(Returns);

final getMappingChecker = TypeChecker.fromRuntime(GetMapping);
final postMappingChecker = TypeChecker.fromRuntime(PostMapping);
final putMappingChecker = TypeChecker.fromRuntime(PutMapping);
final deleteMappingChecker = TypeChecker.fromRuntime(DeleteMapping);
final patchMappingChecker = TypeChecker.fromRuntime(PatchMapping);

Future _tryInitialize(ServiceGenContext context) async {
  if (_isInitialized) return;

  var coreLibrary = await context.step.resolver.findLibraryByName("dart.core");
  coreLibraryReader = LibraryReader(coreLibrary!);
  iterableType = coreLibraryReader.findType("Iterable") as InterfaceElement;
  listType = coreLibraryReader.findType("List") as InterfaceElement;
  setType = coreLibraryReader.findType("Set") as InterfaceElement;
  streamType = coreLibraryReader.findType("Stream") as InterfaceElement;
  futureType = coreLibraryReader.findType("Future") as InterfaceElement;

  _isInitialized = true;
}

Future<DartType> getSerialType(DartType target, ServiceGenContext context) async {
  await _tryInitialize(context);
  if (target.isVoid || target.isDynamic) return target;
  if (target.isDartCoreIterable) {
    return target.asInstanceOf(iterableType)!.typeArguments.first;
  }
  if (target.isDartAsyncStream) {
    return target.asInstanceOf(streamType)!.typeArguments.first;
  }
  if (target.isDartAsyncFuture) {
    return target.asInstanceOf(futureType)!.typeArguments.first;
  }
  return target;
}
