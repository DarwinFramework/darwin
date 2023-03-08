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

import 'package:conduit_open_api/v3.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:shelf/shelf.dart';

abstract class DarwinHttpRoute implements DarwinHttpRequestHandler {
  int get sortIndex => 0;

  Future<bool> checkRequest(RequestContext context);

  Map<String, MapEntry<Method, APIOperation>> get outputs => {};
}

class DarwinHttpHandlerRoute implements DarwinHttpRoute {
  final DarwinSystem system;
  final HandlerRegistration registration;
  final dynamic obj;
  late PathMatcher path;
  late Method method;
  late List<HttpRequestInterceptor> interceptors;
  late String? inputContentType;
  late String? outputContentType;
  late HttpHandlerVisitorArgs handlerArgs;
  late List<dynamic Function(RequestContext)> cachedParameterFactories;

  DarwinHttpHandlerRoute(this.system, this.obj, this.registration) {
    // Determine the final route path definition
    var parentPath = registration.enclosingClass
        .firstAnnotationOf<RequestPathSpecifier>()
        ?.path;
    var ownPath = registration.firstAnnotationOf<RequestPathSpecifier>()?.path;
    var uri = (ownPath ?? parentPath)!;
    if (parentPath != null && ownPath != null) {
      uri = PathUtils.combinePath(parentPath, ownPath);
    }
    uri = PathUtils.sanitizePath(uri);
    path = PathUtils.parseMatcher(uri);
    method = registration.firstAnnotationOf<RequestMethodSpecifier>()!.method!;

    // Collect all request interceptors
    interceptors = [
      ...(registration.enclosingClass.annotationsOf<HttpRequestInterceptor>()),
      ...(registration.annotationsOf<HttpRequestInterceptor>())
    ];

    // Determine content types
    inputContentType = registration.firstAnnotationOf<Accepts>()?.contentType ??
        registration.enclosingClass.firstAnnotationOf<Accepts>()?.contentType;

    outputContentType = registration
            .firstAnnotationOf<Returns>()
            ?.contentType ??
        registration.enclosingClass.firstAnnotationOf<Returns>()?.contentType;

    handlerArgs = HttpHandlerVisitorArgs(this, registration, null);

    cachedParameterFactories = registration.parameters.map((parameter) {
      var factory = parameter.firstAnnotationOf<HttpParameterFactory>() ??
          DIParameterFactory();
      var args = HttpHandlerVisitorArgs(this, registration, parameter);
      var cacheEntry = factory.createCacheEntry(args);
      return (RequestContext context) =>
          factory.createParameter(cacheEntry, context);
    }).toList();
  }

  @override
  Future<Response?> handle(RequestContext context) async {
    var match = path.match(context.request.url);
    context.pathData = match.data;
    var interceptedResponse = await interceptors.intercept(context);
    if (interceptedResponse != null) return interceptedResponse;
    var data = [];
    for (var value in cachedParameterFactories) {
      data.add(await value.call(context));
    }
    var methodOutput =
        await (registration.proxy.invoke(obj, data) as FutureOr<dynamic>);
    if (methodOutput == null) return Response(204);
    var response = await context.httpServer.serializeResponse(
        methodOutput, registration.returnType, outputContentType);
    return response;
  }

  @override
  Future<bool> checkRequest(RequestContext context) async {
    return context.method == method && path.match(context.request.url).result;
  }

  @override
  Map<String, MapEntry<Method, APIOperation>> get outputs {
    var evt = ApiDocsResolveReturnTypeEvent(handlerArgs);
    system.eventbus.getLine<ApiDocsResolveReturnTypeEvent>().dispatch(evt);
    evt.resolved ??= APISchemaObject.empty();
    var operation = APIOperation("${method.name}-${path.sourcePath.replaceAll("/", "-")}", {
      "200": APIResponse.schema("default response", evt.resolved!,
          contentTypes: [outputContentType ?? "application/json"])
    });
    operation.parameters = [];
    path.fragments.whereType<VariablePathMatcherFragment>().forEach((element) {
      operation.parameters!.add(APIParameter.path(element.variableName));
    });

    return {"/${path.sourcePath}": MapEntry(method, operation)};
  }

  @override
  int get sortIndex => path.sortIndex;

  @override
  String toString() {
    return "${method.name}-${path.sourcePath.replaceAll("/", "-")}";
  }
}
