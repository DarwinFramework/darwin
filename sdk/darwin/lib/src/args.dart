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

import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin_sdk.dart';

import 'plugin.dart';
import 'service.dart';

/// Arguments supplied by the code generator to the [DarwinSystem].
class DarwinSystemGeneratedArgs {
  final List<ServiceDescriptor> services;

  const DarwinSystemGeneratedArgs(this.services);
}

/// User specified arguments to the [DarwinSystem].
class DarwinSystemUserArgs {
  final Module appModule;
  final List<DarwinPlugin> plugins;

  const DarwinSystemUserArgs({
    required this.appModule,
    required this.plugins,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DarwinSystemUserArgs &&
          runtimeType == other.runtimeType &&
          appModule == other.appModule &&
          plugins == other.plugins);

  @override
  int get hashCode => appModule.hashCode ^ plugins.hashCode;

  @override
  String toString() {
    return 'DarwinSystemUserArgs{appModule: $appModule, plugins: $plugins}';
  }

  DarwinSystemUserArgs copyWith({
    Module? appModule,
    List<DarwinPlugin>? plugins,
  }) {
    return DarwinSystemUserArgs(
      appModule: appModule ?? this.appModule,
      plugins: plugins ?? this.plugins,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appModule': appModule,
      'plugins': plugins,
    };
  }

  factory DarwinSystemUserArgs.fromMap(Map<String, dynamic> map) {
    return DarwinSystemUserArgs(
      appModule: map['appModule'] as Module,
      plugins: map['plugins'] as List<DarwinPlugin>,
    );
  }
}
