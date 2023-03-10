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

import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:lyell/lyell.dart';

/// Field and method annotation for defining service beans.
///
/// Beans are a lightweight and easy-to-use form of dependency providers, which
/// are published by services. Instance methods of services can be  annotated
/// with this annotation to create a bean. Static methods and methods with
/// arguments can't be registered as beans.
class Bean extends RetainedAnnotation {
  /// Defines the name of the bean. This value will be ignored when [isUnnamed]
  /// is true.
  final String? name;

  /// Defines the loading strategy for this bean, influencing when and if the
  /// result of this method invocation will be cached.
  final LoadingStrategy strategy;

  /// Disables name binding making the bean injectable just by its type.
  final bool isUnnamed;

  /// Sets the type to which this bean is bound. The type specified must be
  /// of the same type as or a supertype of the returned object.
  final Type? bindingType;

  const Bean({
    this.name,
    this.strategy = LoadingStrategy.direct,
    this.isUnnamed = false,
    this.bindingType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bean &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          strategy == other.strategy &&
          isUnnamed == other.isUnnamed &&
          bindingType == other.bindingType;

  @override
  int get hashCode =>
      name.hashCode ^
      strategy.hashCode ^
      isUnnamed.hashCode ^
      bindingType.hashCode;
}

mixin DarwinSystemBeanMixin on DarwinSystemBase {
  /// Registers a [bean] at runtime with its supplier function [func].
  void registerBean(Bean bean, FutureOr<dynamic> Function() func) {
    darwinSystemModule
        .bind(bean.bindingType!) // Must be set
        .withName(bean.isUnnamed ? null : bean.name) // Must be set
        .toFunction(func);
  }

  /// Unregisters a [bean] at runtime if present.
  void unregisterBean(Bean bean) {
    darwinSystemModule.unbind(InjectorKey.create(bean.bindingType!,
        name: bean.isUnnamed ? null : bean.name));
  }
}
