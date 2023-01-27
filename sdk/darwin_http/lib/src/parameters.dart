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

import 'package:conduit_open_api/src/v3/operation.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_sdk/darwin_sdk.dart';

class Body extends HandlerAnnotation implements HttpParameterFactory, APIOperationVisitor {
  const Body();

  @override
  createParameter(HandlerRegistration registration, HandlerParameter parameter, RequestContext context) {
    return context.httpServer.deserializeBody(context, parameter.typeArgument);
  }

  @override
  void visitOperation(HandlerRegistration registration, HandlerParameter parameter, APIOperation operation) {
    DarwinSystem.internalInstance.injector.get(DarwinHttpServer)
    // TODO: implement visitOperation
  }
  
}

class Header extends HandlerAnnotation implements HttpParameterFactory {
  final String? name;
  const Header([this.name]);

  @override
  createParameter(HandlerRegistration registration, HandlerParameter parameter, RequestContext context) {
    var finalName = name ?? parameter.name;
    return context.request.headers[finalName];
  }
}

class Context extends HandlerAnnotation implements HttpParameterFactory {
  final String? key;
  const Context([this.key]);

  @override
  createParameter(HandlerRegistration registration, HandlerParameter parameter, RequestContext context) {
    var finalKey = key ?? parameter.name;
    return context[finalKey];
  }
}

class PathParameter extends HandlerAnnotation implements HttpParameterFactory {
  final String? name;
  const PathParameter([this.name]);

  @override
  createParameter(HandlerRegistration registration, HandlerParameter parameter, RequestContext context) {
    var finalName = name ?? parameter.name;
    return context.pathData[finalName];
  }
}

class QueryParameter extends HandlerAnnotation {
  final String? name;
  const QueryParameter([this.name]);
}

class Accepts extends HandlerAnnotation {
  final String contentType;
  const Accepts(this.contentType);
}

class Returns extends HandlerAnnotation {
  final String contentType;
  const Returns(this.contentType);
}
