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

/// Synchronous and asynchronous eventbus implementations used by the drawin framework.
library darwin_eventbus;

import 'dart:async';

export 'src/bus.dart';
export 'src/events.dart';
export 'src/line.dart';
export 'src/subscription.dart';

export 'src/bus.dart';
export 'src/events.dart';
export 'src/line.dart';
export 'src/subscription.dart';

typedef SyncEventConsumer<T> = Function(T);
typedef AsyncEventConsumer<T> = FutureOr<void> Function(T);

class Subscribe {
  const Subscribe();
}

const Subscribe subscribe = Subscribe();