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

class SyncEventLine<T> {
  List<SyncEventSubscription<T>> subscriptions = [];

  /// Subscribes a [SyncEventConsumer] function to this [SyncEventLine] with
  /// a [priority] which defaults to [EventPriority.normal].
  SyncEventSubscription<T> subscribe(SyncEventConsumer<T> consumer,
      {int priority = EventPriority.normal}) {
    var subscription = SyncEventSubscription(this, consumer, priority);
    subscriptions.add(subscription);
    subscriptions.sort((a, b) => a.priority.compareTo(b.priority));
    return subscription;
  }

  /// Subscribes to this [SyncEventLine] with a [priority] which defaults to
  /// [EventPriority.normal] and returns all events as a [Stream].
  EventLineStream<T> subscribeStream({int priority = EventPriority.normal}) {
    var controller = StreamController<T>.broadcast();
    var subscription =
        subscribe((p0) => controller.add(p0), priority: priority);
    return EventLineStream<T>(subscription, controller.stream);
  }

  /// Subscribes to this [SyncEventLine] with a [priority] which defaults to
  /// [EventPriority.normal] for one event.
  Future<T> subscribeNext({int priority = EventPriority.normal}) async {
    var completer = Completer<T>();
    var subscription =
        subscribe((p0) => completer.complete(p0), priority: priority);
    var result = await completer.future;
    unsubscribe(subscription);
    return result;
  }

  /// Unsubscribes an already registered [subscription].
  void unsubscribe(SyncEventSubscription<T> subscription) {
    subscriptions.remove(subscription);
  }

  /// Invokes the event chain with an [event].
  void dispatch(T event) {
    for (var value in subscriptions) {
      value.consumer(event);
    }
  }
}

class AsyncEventLine<T> {
  /// The dispatch mode for this [AsyncEventLine].
  ///
  /// **Sequential**: All subscribers are notified in a chain-like manner, sorted
  /// by priority. It is guaranteed, that higher priorities will be executed
  /// later than lower priorities.
  ///
  /// **Parallel**: All listeners start their handling of the event at the
  /// same time. It is not guaranteed, that higher changes made by higher
  /// priority subscribers won't get overridden by lower priority subscribers.
  AsyncLineMode mode = AsyncLineMode.sequential;

  List<AsyncEventSubscription<T>> subscriptions = [];

  /// Subscribes a [AsyncEventConsumer] function to this [AsyncEventLine] with
  /// a [priority] which defaults to [EventPriority.normal].
  AsyncEventSubscription<T> subscribe(AsyncEventConsumer<T> consumer,
      {int priority = EventPriority.normal}) {
    var subscription = AsyncEventSubscription(this, consumer, priority);
    subscriptions.add(subscription);
    subscriptions.sort((a, b) => a.priority.compareTo(b.priority));
    return subscription;
  }

  /// Subscribes to this [AsyncEventLine] with a [priority] which defaults to
  /// [EventPriority.normal] and returns all events as a [Stream].
  EventLineStream<T> subscribeStream({int priority = EventPriority.normal}) {
    var controller = StreamController<T>.broadcast();
    var subscription =
        subscribe((p0) => controller.add(p0), priority: priority);
    return EventLineStream<T>(subscription, controller.stream);
  }

  /// Subscribes to this [AsyncEventLine] with a [priority] which defaults to
  /// [EventPriority.normal] for one event.
  Future<T> subscribeNext({int priority = EventPriority.normal}) async {
    var completer = Completer<T>();
    var subscription =
        subscribe((p0) => completer.complete(p0), priority: priority);
    var result = await completer.future;
    unsubscribe(subscription);
    return result;
  }

  /// Unsubscribes an already registered [subscription].
  void unsubscribe(AsyncEventSubscription<T> subscription) {
    subscriptions.remove(subscription);
  }

  /// Invokes and awaits the event chain with an [event].
  Future dispatch(T event) async {
    switch (mode) {
      case AsyncLineMode.parallel:
        _dispatchParallel(event);
        break;
      case AsyncLineMode.sequential:
        _dispatchSequential(event);
        break;
    }
  }

  Future _dispatchSequential(T event) async {
    for (var value in subscriptions.toList()) {
      await value.consumer(event);
    }
  }

  Future _dispatchParallel(T event) async {
    await Future.wait(subscriptions.toList().map((e) => _toFuture(e.consumer(event))));
  }

  Future _toFuture(FutureOr<void> futureOr) async => await futureOr;
}

enum AsyncLineMode {
  /// All subscribers are notified in a chain-like manner, sorted
  /// by priority. It is guaranteed, that higher priorities will be executed
  /// later than lower priorities.
  parallel,

  /// All listeners start their handling of the event at the
  /// same time. It is not guaranteed, that higher changes made by higher
  /// priority subscribers won't get overridden by lower priority subscribers.
  sequential
}

class EventPriority {
  EventPriority._();

  static const int highest = 200;
  static const int high = 100;
  static const int normal = 0;
  static const int low = -100;
  static const int lower = -200;
}
