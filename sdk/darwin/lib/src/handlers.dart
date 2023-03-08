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

import 'package:lyell/lyell.dart';

/// Base class for handler annotations. Handler annotations will be retained
/// at runtime and are store in [HandlerRegistration] and [HandlerParameter].
class HandlerAnnotation extends RetainedAnnotation{
  const HandlerAnnotation();
}

/// A singular handler registration.
class HandlerRegistration extends RetainedAnnotationHolder {
  final String name;
  final TypeCapture returnType;
  final HandlerProxy proxy;
  @override
  final List<HandlerAnnotation> annotations;
  final List<HandlerParameter> parameters;
  final HandlerEnclosingClass enclosingClass;
  const HandlerRegistration(this.name, this.parameters, this.annotations,
      this.returnType, this.proxy, this.enclosingClass);

  String get fullName => "${enclosingClass.name}.$name";

  Iterable<T> expandedAnnotationsOf<T>() => [
    ...enclosingClass.annotationsOf<T>(),
    ...annotationsOf<T>()
  ];

}

class HandlerEnclosingClass<T> extends RetainedAnnotationHolder {
  final String name;
  @override
  final List<HandlerAnnotation> annotations;
  const HandlerEnclosingClass(this.name, this.annotations);

  Type get typeArgument => T;
}

/// Method proxy for handler methods.
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

/// Descriptor for parameters of handler methods.
class HandlerParameter<T> extends RetainedAnnotationHolder with TypeCaptureMixin<T> {
  final String name;

  final bool nullable;
  @override
  final List<HandlerAnnotation> annotations;

  const HandlerParameter(this.name, this.nullable, this.annotations);

  bool get isRequired => !nullable;
}
