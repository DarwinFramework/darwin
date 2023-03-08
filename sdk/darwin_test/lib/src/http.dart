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
import 'dart:convert';
import 'dart:io';

import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:shelf/shelf.dart';
import 'package:collection/collection.dart';
import 'package:test/expect.dart';

void expectResponse(DarwinSystem system, Matcher matcher, {
  required String path,
  Method method = Method.get,
  String? body,
  Map<String, dynamic> query = const {},
  Map<String, String> headers = const {}
}) {
  Future<ReadResponse> response = () async {
    var headerBuffer = {
      "User-Agent": "DarwinTest"
    };
    headerBuffer.addAll(headers);
    DarwinHttpServer server = await system.injector.get(DarwinHttpServer);
    var request = Request(method.str, Uri.http("localhost", path, query), headers: headerBuffer, body: body, context: {
      "shelf.io.connection_info": DummyHttpConnectionInfo()
    });
    var response = await server.handleRequest(request);
    var readBody = await response.read().expand((element) => element).toList();
    var readResponse = ReadResponse(response, readBody);
    return readResponse;
  }();
  expect(response, completion(matcher));
}

@Deprecated("use hasStatus()")
Matcher isStatus(int code) => ResponseStatusMatcher(code);
@Deprecated("use hasBody()")
Matcher isBody(String body) => ResponseBodyStringMatcher(body);

Matcher hasStatus(int code) => ResponseStatusMatcher(code);
Matcher hasBody(String body) => ResponseBodyStringMatcher(body);
Matcher hasHeader(String key, String? value) => ResponseHeaderStringMatcher(key, value);

class DummyHttpConnectionInfo extends HttpConnectionInfo {

  @override
  int get localPort => 1337;

  @override
  InternetAddress get remoteAddress => InternetAddress("127.0.0.1");

  @override
  int get remotePort => 1337;

}

class ResponseBodyMatcher extends Matcher {

  List<int> body;

  ResponseBodyMatcher(this.body);

  @override
  Description describe(Description description) {
    return description.add("has body $body");
  }

  @override
  bool matches(item, Map matchState) {
    if (item is! ReadResponse) throw ArgumentError("Must be a ReadResponse");
    return ListEquality().equals(item.body, body);
  }
}

class ResponseBodyStringMatcher extends Matcher {

  String body;

  ResponseBodyStringMatcher(this.body);

  @override
  Description describe(Description description) {
    return description.add("has body $body");
  }

  @override
  bool matches(item, Map matchState) {
    if (item is! ReadResponse) throw ArgumentError("Must be a ReadResponse");
    return utf8.decode(item.body) == body;
  }
}

class ResponseHeaderStringMatcher extends Matcher {

  String key;
  String? value;

  ResponseHeaderStringMatcher(this.key, this.value);

  @override
  Description describe(Description description) {
    return description.add("has a header $key with value $value");
  }

  @override
  bool matches(item, Map matchState) {
    if (item is! ReadResponse) throw ArgumentError("Must be a ReadResponse");
    item.showHeader = true;
    return item.response.headers[key] == value;
  }
}

class ResponseStatusMatcher extends Matcher {
  int code;

  ResponseStatusMatcher(this.code);

  @override
  Description describe(Description description) {
    return description.add("has status code $code");
  }

  @override
  bool matches(item, Map matchState) {
    if (item is! ReadResponse) throw ArgumentError("Must be a ReadResponse");
    return item.response.statusCode == code;
  }
}

class ReadResponse {
  Response response;
  List<int> body;

  ReadResponse(this.response, this.body);

  bool showHeader = false;

  @override
  String toString() {
    return "${response.statusCode}: ${utf8.decode(body)}"
        "${showHeader == false ? "" : response.headers}";
  }
}
