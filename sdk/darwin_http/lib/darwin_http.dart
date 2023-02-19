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

/// Support for doing something awesome.
///
/// More dartdocs go here.
library darwin_http;

import 'package:conduit_open_api/v3.dart';
import 'package:darwin_sdk/darwin_sdk.dart';

import 'darwin_http.dart';

export 'src/context.dart';
export 'src/events.dart';
export 'src/exceptions.dart';
export 'src/handler.dart';
export 'src/http_server.dart';
export 'src/parameters.dart';
export 'src/plugin.dart';
export 'src/route.dart';

class RestController {
  const RestController();
}

abstract class RequestMethodSpecifier {
  const RequestMethodSpecifier();

  Method? get method;
}

abstract class RequestPathSpecifier {
  const RequestPathSpecifier();

  String? get path;
}

class HttpHandlerVisitorArgs {
  final DarwinHttpHandlerRoute route;
  final HandlerRegistration registration;
  final HandlerParameter? parameter;

  HttpHandlerVisitorArgs(this.route, this.registration, this.parameter);
}

abstract class HttpParameterFactory<T> {
  const HttpParameterFactory();

  T createCacheEntry(HttpHandlerVisitorArgs args);

  dynamic createParameter(T cached, RequestContext context);
}

abstract class APIOperationVisitor {
  void visitOperation(
      HttpHandlerVisitorArgs args,
      APIOperation operation);
}

class GET extends HandlerAnnotation
    implements RequestMethodSpecifier, RequestPathSpecifier {
  @override
  final String? path;

  const GET([this.path]);

  @override
  Method? get method => Method.get;
}

class POST extends HandlerAnnotation
    implements RequestMethodSpecifier, RequestPathSpecifier {
  @override
  final String? path;

  const POST([this.path]);

  @override
  Method? get method => Method.post;
}

class PUT extends HandlerAnnotation
    implements RequestMethodSpecifier, RequestPathSpecifier {
  @override
  final String? path;

  const PUT([this.path]);

  @override
  Method? get method => Method.put;
}

class PATCH extends HandlerAnnotation
    implements RequestMethodSpecifier, RequestPathSpecifier {
  @override
  final String? path;

  const PATCH([this.path]);

  @override
  Method? get method => Method.patch;
}

class DELETE extends HandlerAnnotation
    implements RequestMethodSpecifier, RequestPathSpecifier {
  @override
  final String? path;

  const DELETE([this.path]);

  @override
  Method? get method => Method.delete;
}

class Path extends HandlerAnnotation
    implements RequestMethodSpecifier, RequestPathSpecifier {
  @override
  final Method? method;
  @override
  final String path;

  const Path(this.path, [this.method]);
}

enum Method {
  post("POST"),
  get("GET"),
  put("PUT"),
  delete("DELETE"),
  patch("PATCH");

  final String str;

  const Method(this.str);

  static Method parse(String src) =>
      Method.values.firstWhere((element) => element.str == src);
}
