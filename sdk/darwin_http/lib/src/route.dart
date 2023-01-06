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
import 'dart:io';

import 'package:darwin_http/darwin_http.dart';
import 'package:shelf/shelf.dart';

abstract class DarwinHttpRoute implements DarwinHttpRequestHandler {
  int get sortIndex => 0;
  Future<bool> checkRequest(RequestContext context);
}

class DarwinGeneratedHttpRoute extends DarwinHttpRoute {
  final PathMatcher path;
  final HttpMethods method;
  final FutureOr<dynamic> Function(RequestContext context) proxyFunc;
  final Type resultType;
  final String? acceptContentType;
  final String? returnContentType;
  final List<HttpRequestInterceptor> interceptors;

  @override
  int get sortIndex => path.sortIndex;

  DarwinGeneratedHttpRoute(
      this.path,
      this.method,
      this.proxyFunc,
      this.resultType,
      this.acceptContentType,
      this.returnContentType,
      this.interceptors);

  @override
  Future<bool> checkRequest(RequestContext context) async {
    if (context.method != method) return false;
    if (!path.match(context.request.url).result) return false;
    if (acceptContentType != null) {
      var headerValue = context.request.headers["Content-Type"];
      if (headerValue == null) return false;
      var argType = ContentType.parse(headerValue);
      var srcType = ContentType.parse(acceptContentType!);
      if (argType.mimeType != srcType.mimeType) return false;
    }
    return true;
  }

  @override
  Future<Response?> handle(RequestContext context) async {
    var match = path.match(context.request.url);
    context.pathData = match.data;
    var interceptedResponse = await interceptors.intercept(context);
    if (interceptedResponse != null) return interceptedResponse;
    var methodOutput = await proxyFunc(context);
    if (methodOutput == null) return Response(204);
    var response = await context.httpServer
        .serializeResponse(methodOutput, resultType, returnContentType);
    return response;
  }

  @override
  String toString() {
    return 'generated route for ${method.str} $path';
  }
}
