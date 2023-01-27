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

import 'package:darwin_sdk/darwin_sdk.dart';

/// Base class for handler annotations. Handler annotations will be retained
/// at runtime and are store in [HandlerRegistration] and [HandlerParameter].
class HandlerAnnotation {
  const HandlerAnnotation();
}

abstract class HandlerAnnotationHolder {
  const HandlerAnnotationHolder();

  List<HandlerAnnotation> get annotations;

  Iterable<T> annotationsOf<T>() => annotations.whereType<T>();

  Iterable<T> annotationsOfExact<T>() => annotations
      .where((element) => element.runtimeType == T)
      .map((e) => e as T);
}

/// A singular handler registration.
class HandlerRegistration extends HandlerAnnotationHolder {
  final String name;
  final HandlerReturnType returnType;
  final HandlerProxy proxy;
  @override
  final List<HandlerAnnotation> annotations;
  final List<HandlerParameter> parameters;

  const HandlerRegistration(this.name, this.parameters, this.annotations,
      this.returnType, this.proxy);
}

abstract class HandlerProxy {
  const HandlerProxy();

  /// Invokes the handler method
  dynamic invoke(dynamic obj, List<dynamic> args);
}

typedef GeneratedHandlerProxyFun = dynamic Function(dynamic, List<dynamic>);

class GeneratedHandlerProxy extends HandlerProxy {
  final GeneratedHandlerProxyFun func;

  const GeneratedHandlerProxy(this.func);

  @override
  invoke(obj, List<dynamic> args) {
    return func(obj, args);
  }
}

class HandlerReturnType<T> {
  const HandlerReturnType();

  Type get typeArgument => T;
}

class HandlerParameter<T> extends HandlerAnnotationHolder {
  final String name;

  @override
  final List<HandlerAnnotation> annotations;

  const HandlerParameter(this.name, this.annotations);

  Type get typeArgument => T;
}
