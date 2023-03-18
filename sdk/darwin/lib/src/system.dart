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
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../darwin_sdk.dart';
import 'configuration.dart';

@sealed
abstract class DarwinSystemBase {
  static late DarwinSystem internalInstance;

  List<Future> daemons = [];
  late Module darwinSystemModule;
  late Injector injector;
  late EventBus eventbus;

  Future<void> prepare(
      DarwinSystemGeneratedArgs generated, DarwinSystemUserArgs user);
  Future<void> start(
      DarwinSystemGeneratedArgs generated, DarwinSystemUserArgs user);

  Future<void> stop();
}

extension DarwinSystemExtensions on DarwinSystemBase {
  @Deprecated("Use mixin methods directly")
  DarwinSystemBeanMixin get beanMixin => this as DarwinSystemBeanMixin;
  @Deprecated("Use mixin methods directly")
  DarwinSystemPluginMixin get pluginMixin => this as DarwinSystemPluginMixin;
  @Deprecated("Use mixin methods directly")
  DarwinSystemServiceMixin get serviceMixin => this as DarwinSystemServiceMixin;
  @Deprecated("Use mixin methods directly")
  DarwinSystemLoggingMixin get loggingMixin => this as DarwinSystemLoggingMixin;
  @Deprecated("Use mixin methods directly")
  DarwinSystemProfileMixin get profileMixin => this as DarwinSystemProfileMixin;
}

/// Default [DarwinSystem] base class containing all common mixins.
@reopen
abstract class DarwinSystem extends DarwinSystemBase
    with
        DarwinSystemServiceMixin,
        DarwinSystemPluginMixin,
        DarwinSystemBeanMixin,
        DarwinSystemLoggingMixin,
        DarwinSystemProfileMixin,
        DarwinSystemConfigurationMixin {


  static DarwinSystem get internalInstance => DarwinSystemBase.internalInstance;
  static set internalInstance(DarwinSystem system) => DarwinSystemBase.internalInstance = system;

  @override
  Future<void> prepare(
      DarwinSystemGeneratedArgs generated, DarwinSystemUserArgs user) async {
    initSystem(this, user);
  }

  @override
  Future<void> start(
      DarwinSystemGeneratedArgs generated, DarwinSystemUserArgs user) async {
    enableLogging();
    logger.info("Starting darwin application...");
    var stopwatch = Stopwatch();
    stopwatch.start();
    await prepareAndStartServices(this, generated, user);
    await runLateStartup(this);
    stopwatch.stop();
    logger.info(
        "Started darwin application in ${stopwatch.elapsedMilliseconds}ms!");
  }

  static Future<void> runLateStartup(DarwinSystem system) async {
    var lateStartupEvent = LateStartupEvent(system);
    await system.eventbus
        .getAsyncLine<LateStartupEvent>()
        .dispatch(lateStartupEvent);
  }

  /// Prepares all collected service descriptions and starts them via
  /// [DarwinSystemServiceMixin.startServices].
  static Future<void> prepareAndStartServices(DarwinSystem system,
      DarwinSystemGeneratedArgs generated, DarwinSystemUserArgs user) async {
    var services = generated.services.toList();
    system.plugins.addAll(user.plugins);
    await system.configurePlugins().forEach((element) {
      services.add(element);
    });
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
    system.darwinSystemModule.bind(Logger).toContextFunction((injector) {
      return system.createLogger("Application");
    });
    var baseConfiguration = await DarwinBaseConfiguration.load(system);
    system.profile = baseConfiguration.profile;
    system.level = baseConfiguration.level;
    system.checkDebug(); // Check and potentially enable debug mode
  }

  @override
  Future<void> stop() async {
    logger.info("Stopping darwin application...");
    var stopwatch = Stopwatch();
    await stopServices();
    logger.info(
        "Stopped darwin application in ${stopwatch.elapsedMilliseconds}ms. Goodbye!");

    await eventbus.getAsyncLine<KillEvent>().dispatch(KillEvent(this));
  }
}

@Deprecated("Extend DarwinSystem instead")
class DefaultDarwinSystem extends DarwinSystem {}


class DefaultDarwinSystemImpl extends DarwinSystem {}