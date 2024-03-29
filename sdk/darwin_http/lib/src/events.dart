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

import 'package:conduit_open_api/v3.dart';
import 'package:darwin_eventbus/darwin_eventbus.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:shelf/shelf.dart';

class IncomingHttpRequestEvent extends AsyncEvent {
  final RequestContext context;
  bool _isCancelled = false;
  Response? _response;

  bool get isCancelled => _isCancelled;
  Response? get response => _response;

  void setCancelled(bool isCancelled, Response? response) {
    if (isCancelled) {
      _isCancelled = true;
      _response = response;
    } else {
      _isCancelled = false;
      _response = null;
    }
  }

  IncomingHttpRequestEvent(this.context, this._isCancelled);
}

class HttpRequestRespondEvent extends AsyncEvent {
  final RequestContext context;
  final bool hasBeenHandled;
  Response response;

  HttpRequestRespondEvent(this.context, this.response, this.hasBeenHandled);
}

class HttpExceptionResolveEvent extends SyncEvent {
  final dynamic exception;
  final StackTrace stackTrace;
  Response? response;

  HttpExceptionResolveEvent(this.exception, this.stackTrace);
}

class ApiDocsResolveParameterTypeEvent extends SyncEvent {
  final HttpHandlerVisitorArgs args;

  APISchemaObject? resolved;

  void update(APISchemaObject object) {
    resolved = object;
  }

  ApiDocsResolveParameterTypeEvent(this.args);
}

class ApiDocsResolveReturnTypeEvent extends SyncEvent {
  final HttpHandlerVisitorArgs args;

  APISchemaObject? resolved;

  void update(APISchemaObject object) {
    resolved = object;
  }

  ApiDocsResolveReturnTypeEvent(this.args);
}

class ApiDocsPopulateEvent extends SyncEvent {
  final APIDocument document;
  ApiDocsPopulateEvent(this.document);
}