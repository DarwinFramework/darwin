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

extension ResolutionExtension on ServiceDescriptor {
  /// Verifies if the [injector] provides all required dependencies.
  bool isSatisfied(Injector injector) =>
      collectDependencies().every((element) => injector.checkKey(element));

  /// Verifies if all required dependencies are either already provided
  /// by the [injector] or could still become available as
  /// promised by [futurePromises].
  bool isSolvable(Injector injector, List<InjectorKey> futurePromises) =>
      isSatisfied(injector) ||
      collectDependencies().any((element) => futurePromises.contains(element));

  /// Returns if the [DarwinSystemServiceMixin] should wait another dependency
  /// cycle before trying to create this service, either because it is currently
  /// lacking required dependencies, or optional dependencies are still being
  /// possibly promised by [futurePromises].
  bool skipDependencyCycle(
          Injector injector, List<InjectorKey> futurePromises) =>
      !isSatisfied(injector) ||
      collectOptionalDependencies()
          .any((element) => futurePromises.contains(element));

  /// Collects all required dependencies of this service and its conditions.
  Iterable<InjectorKey> collectDependencies() sync* {
    yield* dependencies;
    for (var condition in conditions) {
      yield* condition.dependencies;
    }
  }

  /// Collects all optional dependencies of this service and its conditions.
  Iterable<InjectorKey> collectOptionalDependencies() sync* {
    yield* optionalDependencies;
    for (var condition in conditions) {
      yield* condition.optionalDependencies;
    }
  }
}

class ServiceMixinResolver extends ServiceResolver {
  DarwinSystemServiceMixin serviceMixin;
  ServiceMixinResolver(this.serviceMixin);

  @override
  Future activate(ServiceDescriptor descriptor) =>
      serviceMixin.startService(descriptor);

  @override
  Injector get injector => serviceMixin.injector;
}

/// Dependency resolver for [ServiceDescriptor]s.
abstract class ServiceResolver {
  Injector get injector;

  /// Starts the [descriptor] asynchronously.
  Future activate(ServiceDescriptor descriptor);

  /// Starts all given [descriptors] respecting dependency constraints.
  /// The cyclic service resolution is carried out by performing following
  /// checks on each unsolved service until either no unsolved services are left
  /// or no new changes can be made:
  /// 1. Is this service optional and is it still unsolvable?<br>
  /// true => Skip the service and remove it from the list
  ///
  /// 2. Is this still missing required dependencies or are missing optional
  /// dependencies still possibly obtainable from other unsolved services?<br>
  /// true => Skip this resolution cycle
  ///
  /// 3. (indirect) Are all required dependencies provided?<br>
  /// true => Start the service<br>
  /// false => Throw an exception
  ///
  /// In this algorithm, step 3 is indirectly performed as the resolution cycle
  /// will be skipped indefinitely in the case of an missing required dependency,
  /// which will result in the cancellation of the resolution loop since no
  /// further changes have been made in the last cycle.
  ///
  Stream<ResolveEvent> solve(List<ServiceDescriptor> descriptors) async* {
    yield ResolveEvent(ResolveEventType.started, null);
    var unsolved = descriptors.toList();
    while (true) {
      var lenBefore = unsolved.length; // Remember length before cycle
      // Collect injector keys which could possibly become available
      var futurePromises =
          unsolved.expand((element) => element.publications).toList();
      for (var descriptor in unsolved.toList()) {
        // If the service is optional and not solvable in this context, skip it
        if (descriptor.optional &&
            !descriptor.isSolvable(injector, futurePromises)) {
          unsolved.remove(descriptor);
          yield ResolveEvent(
              ResolveEventType.serviceSkipped,
              descriptor,
              descriptor.dependencies
                  .where((element) => !injector.checkKey(element))
                  .toList());
          continue;
        }
        // If the service has unfulfilled dependencies or optional dependencies
        // could still become available, wait another dependency cycle
        if (descriptor.skipDependencyCycle(injector, futurePromises)) {
          continue;
        }
        // All dependencies are met and no more optional dependencies can
        // be fulfilled anymore -> start the service now.
        unsolved.remove(descriptor);
        await activate(descriptor);
        yield ResolveEvent(ResolveEventType.serviceStarted, descriptor);
      }
      var lenAfter = unsolved.length;
      if (lenAfter == 0) {
        yield ResolveEvent(ResolveEventType.finished, null);
        break;
      }
      if (lenBefore != lenAfter) continue; // At least one declined
      for (var descriptor in unsolved) {
        yield ResolveEvent(
            ResolveEventType.serviceError,
            descriptor,
            descriptor.dependencies
                .where((element) => !injector.checkKey(element))
                .toList());
      }
      yield ResolveEvent(ResolveEventType.failed, null);
      break;
    }
  }
}

class ResolveEvent {
  ResolveEventType type;
  ServiceDescriptor? descriptor;
  List<InjectorKey>? offendingKeys;

  ResolveEvent(this.type, [this.descriptor, this.offendingKeys]);
}

enum ResolveEventType {
  started(Level.FINER, _logStarted),
  finished(Level.FINER, _logFinished),
  failed(Level.SEVERE, _logFailed),
  serviceStarted(Level.FINER, _logServiceStarted),
  serviceSkipped(Level.FINE, _logServiceSkipped),
  serviceError(Level.WARNING, _logServiceError);

  final LogRecord Function(ResolveEvent) logConverter;
  final Level level;
  const ResolveEventType(this.level, this.logConverter);

  LogRecord createLog(ResolveEvent event) => logConverter(event);

  static LogRecord _logStarted(ResolveEvent event) =>
      LogRecord(started.level, "Resolution started", "Service Resolution");
  static LogRecord _logFinished(ResolveEvent event) =>
      LogRecord(finished.level, "Resolution finished", "Service Resolution");
  static LogRecord _logFailed(ResolveEvent event) =>
      LogRecord(failed.level, "Resolution failed!", "Service Resolution");

  static LogRecord _logServiceStarted(ResolveEvent event) => LogRecord(
      serviceStarted.level,
      "Service ${event.descriptor} resolved",
      "Service Resolution");
  static LogRecord _logServiceSkipped(ResolveEvent event) => LogRecord(
      serviceSkipped.level,
      "Service ${event.descriptor} skipped! Missing ${event.offendingKeys}",
      "Service Resolution");
  static LogRecord _logServiceError(ResolveEvent event) => LogRecord(
      serviceError.level,
      "Service ${event.descriptor} can't be started! Missing ${event.offendingKeys}",
      "Service Resolution");
}
