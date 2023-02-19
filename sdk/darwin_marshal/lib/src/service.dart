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

import 'package:darwin_eventbus/darwin_eventbus.dart';
import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:darwin_sdk/darwin_sdk.dart';

class MarshalService {
  final DarwinMarshal marshal;
  final DarwinSystem system;

  MarshalService(this.system, this.marshal);

  late SyncEventLine<MarshalConfigureEvent> onMarshalConfigure;

  void start() {
    system.eventbus.getAsyncLine<LateStartupEvent>()
        .subscribe(doLateStartup, priority: EventPriority.high);
    onMarshalConfigure = system.eventbus.getLine<MarshalConfigureEvent>();
  }

  void doLateStartup(LateStartupEvent event) {
    onMarshalConfigure.dispatch(MarshalConfigureEvent(marshal));
  }
}

class MarshalConfigureEvent extends SyncEvent {
  final DarwinMarshal marshal;

  MarshalConfigureEvent(this.marshal);
}

class MarshalServiceDescriptor extends ServiceDescriptor {
  @override
  Type get bindingType => MarshalService;

  @override
  List<Condition> get conditions => [];

  @override
  List<InjectorKey> get dependencies => [];

  @override
  List<InjectorKey> get publications => [InjectorKey.create(MarshalService)];

  @override
  Type get serviceType => MarshalService;

  @override
  Future instantiate(Injector injector) async {
    DarwinSystem system = await injector.get(DarwinSystem);
    DarwinMarshal marshal = await injector.get(DarwinMarshal);
    return MarshalService(system, marshal);
  }

  @override
  Future<void> start(DarwinSystem system, obj) async {
    (obj as MarshalService).start();
  }

  @override
  Future<void> stop(DarwinSystem system, obj) async {}
}
