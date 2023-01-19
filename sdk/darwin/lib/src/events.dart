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
import 'package:darwin_sdk/darwin_sdk.dart';

/// Event that gets triggered after the initial service startup completed for
/// all initially registered services.
class LateStartupEvent extends AsyncEvent {
  final DarwinSystem system;

  const LateStartupEvent(this.system);
}

/// Event that gets triggered after the darwin system is shut down.
class KillEvent extends AsyncEvent {
  final DarwinSystem system;
  const KillEvent(this.system);
}