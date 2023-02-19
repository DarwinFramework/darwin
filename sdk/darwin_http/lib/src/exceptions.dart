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

import 'package:shelf/shelf.dart';

/// Interrupts a request handler with a response.
class RequestException implements Exception {
  Response response;
  RequestException(this.response);

  factory RequestException.notFound([Object? body]) =>
      RequestException(Response.notFound(body));
  factory RequestException.badRequest([Object? body]) =>
      RequestException(Response.badRequest(body: body));
  factory RequestException.forbidden([Object? body]) =>
      RequestException(Response.forbidden(body));
  factory RequestException.unauthorized([Object? body]) =>
      RequestException(Response.unauthorized(body));
  factory RequestException.conflict([Object? body]) =>
      RequestException(Response(409, body: body ?? "Conflict"));
  factory RequestException.gone([Object? body]) =>
      RequestException(Response(410, body: body ?? "Gone"));
  factory RequestException.status(int code, [Object? body]) =>
      RequestException(Response(code, body: body));

  @override
  String toString() {
    return 'RequestException ${response.statusCode}';
  }
}
