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

abstract class EventSubscription {
  /// Cancels this event subscriptions.
  void cancel();
}

class SyncEventSubscription<T> extends EventSubscription {
  final SyncEventLine<T> line;
  final SyncEventConsumer<T> consumer;
  final int priority;

  SyncEventSubscription(this.line, this.consumer, this.priority);

  @override
  void cancel() => line.unsubscribe(this);
}

class AsyncEventSubscription<T> extends EventSubscription {
  final AsyncEventLine<T> line;
  final AsyncEventConsumer<T> consumer;
  final int priority;

  AsyncEventSubscription(this.line, this.consumer, this.priority);

  @override
  void cancel() => line.unsubscribe(this);
}
