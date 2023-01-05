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

part of 'http_server.dart';

class HttpServerServiceDescriptor extends ServiceDescriptor {
  @override
  Type get bindingType => DarwinHttpServer;

  @override
  Type get serviceType => DarwinHttpServer;

  @override
  List<InjectorKey> get dependencies => [InjectorKey.create(HttpPlugin)];

  @override
  List<InjectorKey> get publications =>
      [InjectorKey.create(HttpServerServiceDescriptor)];

  @override
  List<Condition> get conditions => [];

  @override
  Future instantiate(Injector injector) async => DarwinHttpServer(
      await injector.get(HttpPlugin), await injector.get(DarwinMarshal));

  @override
  Future<void> start(DarwinSystem system, obj) async =>
      await (obj as DarwinHttpServer).start(system);

  @override
  Future<void> stop(DarwinSystem system, obj) async =>
      await (obj as DarwinHttpServer).stop(system);
}
