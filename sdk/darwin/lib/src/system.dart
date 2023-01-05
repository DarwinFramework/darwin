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

import 'package:darwin_eventbus/darwin_eventbus.dart';
import 'package:darwin_injector/darwin_injector.dart';

import '../darwin_sdk.dart';

abstract class DarwinSystem {
  static late DarwinSystem internalInstance;

  List<Future> daemons = [];
  late Module darwinSystemModule;
  late Injector injector;
  late EventBus eventbus;

  Future<void> start(
      DarwinSystemGeneratedArgs generated, DarwinSystemUserArgs user);

  Future<void> stop();
}

extension DarwinSystemExtensions on DarwinSystem {
  DarwinSystemBeanMixin get beanMixin => this as DarwinSystemBeanMixin;

  DarwinSystemPluginMixin get pluginMixin => this as DarwinSystemPluginMixin;

  DarwinSystemServiceMixin get serviceMixin => this as DarwinSystemServiceMixin;

  DarwinSystemLoggingMixin get loggingMixin => this as DarwinSystemLoggingMixin;

  DarwinSystemProfileMixin get profileMixin => this as DarwinSystemProfileMixin;
}

abstract class DefaultDarwinSystem extends DarwinSystem
    with
        DarwinSystemServiceMixin,
        DarwinSystemPluginMixin,
        DarwinSystemBeanMixin,
        DarwinSystemLoggingMixin,
        DarwinSystemProfileMixin {
  @override
  Future<void> start(
      DarwinSystemGeneratedArgs generated, DarwinSystemUserArgs user) async {
    enableLogging();
    loggingMixin.logger.info("Starting darwin application...");
    var stopwatch = Stopwatch();
    stopwatch.start();
    await initSystem(this, user);
    await prepareServices(this, generated, user);
    await runLateStartup(this);
    stopwatch.stop();
    loggingMixin.logger.info(
        "Started darwin application in ${stopwatch.elapsedMilliseconds}ms!");
  }

  static Future<void> runLateStartup(DarwinSystem system) async {
    var lateStartupEvent = LateStartupEvent(system);
    await system.eventbus
        .getAsyncLine<LateStartupEvent>()
        .dispatch(lateStartupEvent);
  }

  static Future<void> prepareServices(DarwinSystem system,
      DarwinSystemGeneratedArgs generated, DarwinSystemUserArgs user) async {
    if (system is! DarwinSystemServiceMixin) throw Exception();
    var services = generated.services.toList();
    if (system is DarwinSystemPluginMixin) {
      system.pluginMixin.plugins.addAll(user.plugins);
      await system.pluginMixin.configurePlugins().forEach((element) {
        services.add(element);
      });
    }
    system.serviceDescriptors.addAll(services);
    await system.startServices();
  }

  static Future initSystem(
      DarwinSystem system, DarwinSystemUserArgs user) async {
    system.eventbus = EventBus();
    system.injector = Injector();
    system.darwinSystemModule = Module();
    system.injector.registerModule(user.appModule);
    system.injector.registerModule(system.darwinSystemModule);
    system.darwinSystemModule.bind(DarwinSystem).toConstant(system);
  }

  @override
  Future<void> stop() async {
    loggingMixin.logger.info("Stopping darwin application...");
    var stopwatch = Stopwatch();
    // Stop services in reversed order so children shut down before their parents do
    for (var service in runningServices.reversed) {
      var obj = service.obj;
      var descriptor = service.descriptor;
      await descriptor.stop(this, obj);
    }
    runningServices.clear();
    loggingMixin.logger.info(
        "Stopped darwin application in ${stopwatch.elapsedMilliseconds}ms. Goodbye!");
  }
}

class DefaultDarwinSystemImpl extends DefaultDarwinSystem {}
