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

export 'src/context.dart';
export 'src/events.dart';
export 'src/handler.dart';
export 'src/http_server.dart';
export 'src/path.dart';
export 'src/plugin.dart';
export 'src/route.dart';

class RestController {
  const RestController();
}

class GetMapping {
  final String? path;
  const GetMapping([this.path]);
}

class PostMapping {
  final String? path;
  const PostMapping([this.path]);
}

class PutMapping {
  final String? path;
  const PutMapping([this.path]);
}

class PatchMapping {
  final String? path;
  const PatchMapping([this.path]);
}

class DeleteMapping {
  final String? path;
  const DeleteMapping([this.path]);
}

class RequestMapping {
  final HttpMethods? method;
  final String path;
  const RequestMapping(this.path, [this.method]);
}

class Body {
  const Body();
}

class Header {
  final String? name;
  const Header([this.name]);
}

class Context {
  final String? key;
  const Context([this.key]);
}

class PathParameter {
  final String? name;
  const PathParameter([this.name]);
}

class QueryParameter {
  final String? name;
  const QueryParameter([this.name]);
}

class Accepts {
  final String contentType;
  const Accepts(this.contentType);
}

class Returns {
  final String contentType;
  const Returns(this.contentType);
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
