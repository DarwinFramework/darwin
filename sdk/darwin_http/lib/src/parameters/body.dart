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

class Body extends HandlerAnnotation implements HttpParameterFactory<_BodyEntry>, APIOperationVisitor {

  final String? schemaReference;

  const Body({this.schemaReference});

  @override
  createCacheEntry(HttpHandlerVisitorArgs args) {
    return _BodyEntry(args.parameter!.typeArgument, args.route.inputContentType);
  }

  @override
  createParameter(_BodyEntry cached, RequestContext context) {
    return context.httpServer.deserializeBody(context, cached.type, cached.mime);
  }

  @override
  void visitOperation(HttpHandlerVisitorArgs args, APIOperation operation) {
    var event = ApiDocsResolveParameterTypeEvent(args);
    args.route.system.eventbus.getLine<ApiDocsResolveParameterTypeEvent>().dispatch(event);
    if (event.resolved == null) throw Exception("Can't resolve handler parameter ${args.parameter}");
    var mediaType = args.route.inputContentType ?? "application/json";
    if (schemaReference != null) {
      operation.requestBody = APIRequestBody({
        mediaType: APIMediaType(
            schema: APISchemaObject()
              ..referenceURI = Uri(path: schemaReference)
        )
      });
    } else {
      operation.requestBody = APIRequestBody({
        mediaType: APIMediaType(
            schema: event.resolved
        )
      });
    }
  }
}

class _BodyEntry {
  final Type type;
  final String? mime;

  _BodyEntry(this.type, this.mime);
}