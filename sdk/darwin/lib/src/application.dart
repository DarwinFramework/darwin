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
import 'dart:io';

import 'package:darwin_eventbus/darwin_eventbus.dart';
import 'package:darwin_injector/darwin_injector.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../darwin_sdk.dart';

/// Builder for [DarwinSystem].
/// Combines generated [DarwinSystemGeneratedArgs] and creates the
/// [DarwinSystemUserArgs]. Also has options for configuring the created
/// [DarwinSystem].
class DarwinApplication {
  List<DarwinPlugin> plugins = [];
  Module module = Module();

  DarwinSystemGeneratedArgs? _generatedArgs;
  DarwinSystem? _system;
  set generatedArgs(DarwinSystemGeneratedArgs args) => _generatedArgs = args;
  set system(DarwinSystem system) => _system = system;
  DarwinSystem get system => _system!;

  /// Forces the process to exit when the application is stopped.
  bool exitProcessOnStop = false;

  /// Configures if the application should watch process signals.
  bool watchProcessSignals = true;

  /// Returns true if the system received a shutdown signal.
  bool get isShuttingDown => _isShuttingDown;
  bool _isShuttingDown = false;

  /// Manually overrides [DarwinSystemLoggingMixin.level].
  void setLogLevel(Level level) => system.loggingMixin.level = level;

  /// Manually overrides [DarwinSystemLoggingMixin.handler].
  void setLogHandler(LogHandler handler) =>
      system.loggingMixin.handler = handler;

  /// Sets the [DarwinSystemProfileMixin.profile] for this application.
  /// Can be used to define logical execute environments.
  void setProfile(String profile) => system.profileMixin.profile = profile;

  /// Installs a [DarwinPlugin] onto this application.
  ///
  /// Plugins are not loaded directly after being installed. They are instead
  /// being configured after calling [execute].
  void install(DarwinPlugin plugin) => plugins.add(plugin);

  /// Starts the [DarwinSystem] with the current configuration and statically
  /// links [DarwinSystem.internalInstance] as well as [system].
  @mustCallSuper
  Future execute() async {
    var currentSystem = _system;
    currentSystem ??= DarwinSystem.internalInstance;
    _system = currentSystem;
    DarwinSystem.internalInstance = currentSystem;
    plugins.sort((a, b) =>
        a.loadOrder.compareTo(b.loadOrder)); // Sort plugins by priority
    var userArgs = DarwinSystemUserArgs(appModule: module, plugins: plugins);
    await currentSystem.prepare(_generatedArgs!, userArgs);
    if (exitProcessOnStop) {
      currentSystem.eventbus
          .getAsyncLine<KillEvent>()
          .subscribeNext(priority: EventPriority.highest)
          .then((value) => exit(0));
    }
    await currentSystem.start(_generatedArgs!, userArgs);
    _hookDaemons();
    if (watchProcessSignals) _watchSignals();
  }

  /// Stops the [DarwinSystem] and exits the process if [exitProcessOnStop]
  /// is set to true.
  void stop() async {
    if (isShuttingDown) return;
    _isShuttingDown = true;
    await _system!.stop();
  }

  void _hookDaemons() async {
    await Future.wait(_system!.daemons);
    stop();
  }

  void _watchSignals() async {
    await ProcessSignal.sigterm.watch().first.then((value) => stop());
    await ProcessSignal.sigint.watch().first.then((value) => stop());
  }
}
