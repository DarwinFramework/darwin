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

import 'package:darwin_eventbus/darwin_eventbus.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

part 'http_server_descriptor.dart';
part 'http_server_handler.dart';
part 'http_server_serialize.dart';

class DarwinHttpServer extends ServiceBase {

  static const String requestDrainedKey = "request.drained";

  final HttpPlugin plugin;
  final DarwinMarshal marshal;

  DarwinHttpServer(this.plugin, this.marshal);

  late Logger logger;
  late HttpServer server;
  late DarwinSystem system;
  late AsyncEventLine<HttpRequestRespondEvent> onHttpRequestRespond;
  late AsyncEventLine<IncomingHttpRequestEvent> onIncomingHttpRequest;

  List<Module> requestModules = [DefaultHttpRequestModule()];
  List<DarwinHttpRoute> routes = [];

  void registerRoute(DarwinHttpRoute route) {
    routes.add(route);
    routes.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    logger.finer("Registered http route: $route");
  }

  @override
  FutureOr<void> start(DarwinSystem system) async {
    this.system = system;
    logger = system.loggingMixin.createLogger("Darwin Http");
    onIncomingHttpRequest =
        system.eventbus.getAsyncLine<IncomingHttpRequestEvent>();
    onHttpRequestRespond =
        system.eventbus.getAsyncLine<HttpRequestRespondEvent>();
    var pipeline = Pipeline();
    for (var middleware in plugin.shelfMiddlewares) {
      pipeline = pipeline.addMiddleware(middleware);
    }
    var handler = pipeline.addHandler(handleRequest);
    server = await shelf_io.serve(handler, plugin.address, plugin.port,
        securityContext: plugin.securityContext,
        poweredByHeader: "darwin/shelf");
    var completer = Completer();
    /*
    // Never complete until I find a way to link it to the isolate
    server.listen((event) { }, onDone: () {
      completer.complete();
    });
    */
    system.daemons.add(completer.future);
  }

  @override
  FutureOr<void> stop(DarwinSystem system) async {
    await server.close();
    logger.fine("Shelf server closed");
  }
}

class DefaultHttpRequestModule extends Module {
  DefaultHttpRequestModule() {
    bind(HttpConnectionInfo).toContextFunction((injector) async {
      RequestContext context = await injector.get(RequestContext);
      return context.connection;
    });
    bind(Request).toContextFunction((injector) async {
      RequestContext context = await injector.get(RequestContext);
      return context.request;
    });
    // Return the request scoped injector
    bind(Injector).toContextFunction((injector) => injector);
  }
}
