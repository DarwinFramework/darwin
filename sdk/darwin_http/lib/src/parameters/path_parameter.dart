// ignore_for_file: library_private_types_in_public_api

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

part of '../parameters.dart';

class PathParam extends HandlerAnnotation implements HttpParameterFactory<_PathParamEntry>, APIOperationVisitor {
  final String? name;
  const PathParam([this.name]);

  @override
  createParameter(_PathParamEntry cached, RequestContext context) {
    return context.pathData[cached.name];
  }

  @override
  void visitOperation(HttpHandlerVisitorArgs args, APIOperation operation) {
    var finalName = name ?? args.parameter!.name;
    var parameters = operation.parameters??<APIParameter>[];
    parameters.add(APIParameter.path(finalName));
    operation.parameters = parameters;
  }

  @override
  _PathParamEntry createCacheEntry(HttpHandlerVisitorArgs args) {
    var finalName = name ?? args.parameter!.name;
    return _PathParamEntry(finalName);
  }
}

class _PathParamEntry {
  final String name;
  _PathParamEntry(this.name);
}
