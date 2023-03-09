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

import 'dart:io';

import 'package:darwin_http/src/http_server.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:shelf/shelf.dart';

class HttpPlugin extends DarwinPlugin {
  List<Middleware> shelfMiddlewares = [];
  SecurityContext? securityContext;
  Object address = InternetAddress.anyIPv4;
  int port = 8080;
  bool generateOpenApiModel = true;
  bool runUnbound = false;

  @override
  int get loadOrder => -10;

  @override
  Future configure() async {}

  @override
  Stream<ServiceDescriptor> collectServices() async* {
    yield HttpServerServiceDescriptor();
  }
}
