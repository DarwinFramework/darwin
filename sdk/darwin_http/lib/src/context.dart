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

import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:shelf/shelf.dart';

class RequestContext with MetadataMixin {
  final DarwinSystem system;
  final DarwinHttpServer httpServer;
  final Injector injector;
  final Request request;
  final Method method;
  final HttpConnectionInfo connection;
  Map<String, String> pathData;

  @override
  InjectorMetadata get metadata => injector.metadata;

  RequestContext(this.system, this.httpServer, this.injector, this.request,
      this.method, this.connection, this.pathData);
}
