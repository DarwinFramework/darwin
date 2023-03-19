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
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:darwin_sdk/darwin_sdk.dart';

void _initMarshalNoop(DarwinMarshal marshal) {}

class MarshalPlugin extends DarwinPlugin {
  static late DarwinMarshal sharedMarshal;
  late DarwinMarshal marshal = DarwinMarshal();

  late Module module;

  MarshalPlugin([Function(DarwinMarshal) initMarshal = _initMarshalNoop]) {
    initMarshal(marshal);
  }

  @override
  int get loadOrder => -50;

  @override
  Future configure() async {
    // DarwinMarshalJson.register(marshal);
    DarwinMarshalSimple.register(marshal);

    module = Module();
    module.bind(DarwinMarshal).toConstant(marshal);
    sharedMarshal = marshal;
  }

  @override
  Stream<Module> collectModules() async* {
    yield module;
  }

  @override
  Stream<ServiceDescriptor> collectServices() async* {
    yield MarshalServiceDescriptor();
  }
}
