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

import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_http/src/context.dart';
import 'package:shelf/shelf.dart';

abstract class DarwinHttpRequestHandler {

  Future<Response?> handle(RequestContext context);

}

abstract class HttpRequestInterceptor  {

  const HttpRequestInterceptor();

  Future<Response?> intercept(RequestContext context);

}

class HeaderEqualsInterceptor extends HttpRequestInterceptor {

  final String key;
  final String value;

  const HeaderEqualsInterceptor(this.key, this.value);

  @override
  Future<Response?> intercept(RequestContext context) async {
    if (context.request.headers[key] != value) {
      return Response.badRequest();
    }

    return null;
  }

}

extension InterceptorIterableExtension on Iterable<HttpRequestInterceptor> {

  Future<Response?> intercept(RequestContext context) async {
    for (var interceptor in this) {
      var value = await interceptor.intercept(context);
      if (value != null) return value;
    }
    return null;
  }

}
