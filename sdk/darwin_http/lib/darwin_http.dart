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
  HttpMethods? get method;
}

abstract class HttpParameterFactory {
  const HttpParameterFactory();
  dynamic createParameter(HandlerRegistration registration, HandlerParameter parameter, RequestContext context);
}

abstract class APIOperationVisitor {
  void visitOperation(HandlerRegistration registration, HandlerParameter parameter, APIOperation operation);
}

class GetMapping extends HandlerAnnotation implements RequestMethodSpecifier {
  final String? path;
  const GetMapping([this.path]);
  @override
  HttpMethods? get method => HttpMethods.get;
}

class PostMapping extends HandlerAnnotation implements RequestMethodSpecifier {
  final String? path;
  const PostMapping([this.path]);
  @override
  HttpMethods? get method => HttpMethods.post;
}

class PutMapping extends HandlerAnnotation implements RequestMethodSpecifier {
  final String? path;
  const PutMapping([this.path]);
  @override
  HttpMethods? get method => HttpMethods.put;
}

class PatchMapping extends HandlerAnnotation implements RequestMethodSpecifier {
  final String? path;
  const PatchMapping([this.path]);
  @override
  HttpMethods? get method => HttpMethods.patch;
}

class DeleteMapping extends HandlerAnnotation implements RequestMethodSpecifier {
  final String? path;
  const DeleteMapping([this.path]);

  @override
  HttpMethods? get method => HttpMethods.delete;
}

class RequestMapping extends HandlerAnnotation implements RequestMethodSpecifier {
  @override
  final HttpMethods? method;
  final String path;
  const RequestMapping(this.path, [this.method]);
}

enum HttpMethods {
  post("POST"),
  get("GET"),
  put("PUT"),
  delete("DELETE"),
  patch("PATCH");

  final String str;
  const HttpMethods(this.str);

  static HttpMethods parse(String src) =>
      HttpMethods.values.firstWhere((element) => element.str == src);
}
