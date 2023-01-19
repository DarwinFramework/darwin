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
import 'package:logging/logging.dart';

DarwinSystem createInfantSystem(
    {Module? appModule,
    List<DarwinPlugin> plugins = const [],
    List<ServiceDescriptor>? services}) {
  var system = DefaultDarwinSystemImpl();
  system.loggingMixin.handler = (log) => print(log);
  system.loggingMixin.level = Level.ALL;
  system.loggingMixin.enableLogging();
  DefaultDarwinSystem.initSystem(system,
      DarwinSystemUserArgs(appModule: appModule ?? Module(), plugins: plugins));
  if (services != null) system.serviceMixin.serviceDescriptors.addAll(services);
  return system;
}

Future<DarwinSystem> startSystem(List<ServiceDescriptor> services,
    {Module? appModule, List<DarwinPlugin> plugins = const []}) async {
  var generated = DarwinSystemGeneratedArgs(services);
  var userArgs =
      DarwinSystemUserArgs(appModule: appModule ?? Module(), plugins: plugins);
  var system = DefaultDarwinSystemImpl();
  system.loggingMixin.handler = (log) => print(log);
  system.loggingMixin.level = Level.ALL;
  await system.prepare(generated, userArgs);
  await system.start(generated, userArgs);
  return system;
}
