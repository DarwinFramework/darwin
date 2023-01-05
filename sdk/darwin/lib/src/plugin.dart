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

import 'dart:developer';

import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin.dart';

/// Extensions for darwin applications.
///
/// This is the base class for any plugin extensions. Each plugin can publish
/// dependency injection modules by yielding them via [collectModules] and
/// Services by yielding their [ServiceDescriptor] via [collectServices].
///
/// All plugin instances are being directly bound to their respective type via
/// a [ConstantProvider], making them available via dependency injection for all
/// services.
///
/// Plugins are loaded sorted naturally by their [loadOrder] value, although
/// this just influences the order in which [configure] is called. Services
/// published by the plugin still follow the usual service lifecycle.
abstract class DarwinPlugin {
  int loadOrder = 0;

  /// Configures and prepares the plugin before services are loaded.
  ///
  /// Please note, that this method is intended just for configuration,
  /// initialisation and validation, not for actually starting services,
  /// which should be achieved via  service publication using [collectServices].
  Future configure();

  /// Returns additional dependency injection modules for the application.
  Stream<Module> collectModules() async* {}

  /// Returns services defined by this plugin.
  Stream<ServiceDescriptor> collectServices() async* {}
}

mixin DarwinSystemPluginMixin on DarwinSystem {
  final List<DarwinPlugin> plugins = [];

  Stream<ServiceDescriptor> configurePlugins() async* {
    for (var plugin in plugins) {
      darwinSystemModule
          .bind(plugin.runtimeType)
          .toConstant(plugin); // Bind plugin
      await plugin.configure();
      await plugin.collectModules().forEach((element) {
        injector.registerModule(element);
        log("Registered module $element by $plugin", name: "Darwin System");
      });
      var services = await plugin.collectServices().toList();
      for (var service in services) {
        yield service;
        log("Registered service binding $service by $plugin",
            name: "Darwin System");
      }
    }
  }
}
