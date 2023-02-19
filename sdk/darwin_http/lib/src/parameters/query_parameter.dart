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

class QueryParam extends HandlerAnnotation implements HttpParameterFactory<_QueryParamEntry>, APIOperationVisitor {
  final String? name;
  const QueryParam([this.name]);

  @override
  createParameter(_QueryParamEntry cached, RequestContext context) {
    var value = context.request.url.queryParameters[cached.name];
    if (value == null && !cached.nullable) throw RequestException.badRequest();
    return value;
  }

  @override
  void visitOperation(HttpHandlerVisitorArgs args, APIOperation operation) {
    var finalName = name ?? args.parameter!.name;
    var parameters = operation.parameters??<APIParameter>[];
    parameters.add(APIParameter.query(finalName, isRequired: args.parameter!.isRequired));
    operation.parameters = parameters;
  }

  @override
  _QueryParamEntry createCacheEntry(HttpHandlerVisitorArgs args) {
    var finalName = name ?? args.parameter!.name;
    return _QueryParamEntry(finalName, args.parameter!.nullable);
  }
}

class _QueryParamEntry {
  final String name;
  final bool nullable;
  _QueryParamEntry(this.name, this.nullable);
}