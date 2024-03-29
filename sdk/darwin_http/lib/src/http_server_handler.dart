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

part of 'http_server.dart';

extension HttpServerHandler on DarwinHttpServer {
  Future<Response> handleRequest(Request request) async {
    var completer = Completer<Response>();
    Zone? requestZone;
    runZonedGuarded(() {
      requestZone = Zone.current;
      _handleRequestInternal(request).then(completer.complete);
    }, (error, stack) {
      logger.log(
          Level.SEVERE,
          "Caught exception while processing an http request",
          error,
          stack,
          requestZone);
      completer.complete(Response.internalServerError());
    });
    return completer.future;
  }

  Future<Response> _handleRequestInternal(Request request) async {
    var method = Method.parse(request.method);
    var childInjector = system.injector.createChildInjector();
    var connectionInfo =
        request.context["shelf.io.connection_info"] as HttpConnectionInfo;
    var context = RequestContext(
        system, this, childInjector, request, method, connectionInfo, {});
    var childModule = Module();
    childInjector.registerModule(childModule);
    childInjector.registerAllModules(requestModules);
    childModule.bind(RequestContext).toConstant(context);
    logger.finest(
        "${request.method} ${request.url} from ${connectionInfo.remoteAddress.address}:${connectionInfo.remotePort}");

    // Dispatch incoming request event before handling the request
    var requestEvent = IncomingHttpRequestEvent(context, false);
    await onIncomingHttpRequest.dispatch(requestEvent);
    if (requestEvent.isCancelled) {
      return requestEvent.response ?? Response.notFound("");
    }

    // Handle request normally
    var response = Response.notFound("");
    var hasBeenHandled = false;
    for (var entry in routes) {
      if (!await entry.checkRequest(context)) continue;
      hasBeenHandled = true;
      Response? handledResponse;
      try {
        handledResponse = await entry.handle(context);
        handledResponse =
            handledResponse?.change(context: {"darwin.original": true});
      } on RequestException catch (exception, _) { // Handle expected exceptions.
        logger.log(Level.FINE,
            "Request handler '$entry' threw a request exception", exception);
        handledResponse = exception.response;
      } catch(exception, stacktrace) { // Handle unexpected exceptions.
        var defaultResponse = Response.internalServerError();
        var event = HttpExceptionResolveEvent(exception, stacktrace);
        onExceptionResolve.dispatch(event);
        if (event.response == null) {
          logger.log(Level.SEVERE, "Request handler '$entry' threw an unexpected exception", exception, stacktrace);
        }
        handledResponse = event.response ?? defaultResponse;
      }
      if (context[DarwinHttpServer.requestDrainedKey] != true) {
        await context.request.read().drain(); // Drain body
        context[DarwinHttpServer.requestDrainedKey] = true;
      }
      if (handledResponse == null) {
        response = Response.internalServerError();
        break;
      }
      response = handledResponse;
      break;
    }

    // Dispatch response event before sending the response
    var responseEvent =
        HttpRequestRespondEvent(context, response, hasBeenHandled);
    await onHttpRequestRespond.dispatch(responseEvent);
    return responseEvent.response;
  }
}

extension DarwinHttpServiceResponseExtension on Response {
  /// Returns if this response is derived from the initially return response.
  /// Returns false, if the response has been replaced or an error response
  /// has been emitted.
  bool get isOriginal => context["darwin.original"] == true;
}
