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

import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:lyell/lyell.dart';

/// Class-Annotation for defining services.
///
/// Services are modular components of the application which are independent
/// from other services which aren't marked as dependencies. Dependencies can
/// be declared via the constructor and further configured with annotations
/// like `@Named()`.
///
/// Example for declaring a Service:
/// ```dart
/// @Service()
/// class ServiceA {
///   Dependency dep;
///
///   ServiceA(this.dep)
/// }
/// ```
/// Services also have their own lifecycle consisting of a start and stop
/// signals. If the service extends [ServiceBase], both [ServiceBase.start]
/// and [ServiceBase.stop] will be bound to these signals. The [ServiceBase]
/// class can be used to further abstract services and create other abstract
/// base classes. The terminal implementation of the service can further
/// specify start and stop methods with the @[Start] and @[Stop] annotations.
/// These methods must have no arguments and can either be a void or a [Future].
///
/// Services can also define binding conditions, which must be met for the
/// service to be marked eligible for registration. Conditions can be specified
/// by annotating the implementing type with a const class implementing
/// condition. One example for this is the [Profile] annotation.
class Service extends RetainedAnnotation {
  final Type? type;

  const Service([this.type]);
}

/// Marks a service implementation as optional.
/// Optional services don't crash the dependency resolution if their dependencies
/// are not met and instead just get skipped.
class Optional extends RetainedAnnotation {
  const Optional();
}

/// Marks a service implementation as optional.
/// Optional services don't crash the dependency resolution if their dependencies
/// are not met and instead just get skipped.
const Optional optional = Optional();

/// Method annotation for declaring start methods for [Service]s.
/// Implementations must have no arguments and a return type of void or [Future].
class Start extends RetainedAnnotation {
  const Start();
}

/// Method annotation for declaring stop methods for [Service]s.
/// Implementations must have no arguments and a return type of void or [Future].
class Stop extends RetainedAnnotation {
  const Stop();
}

/// Abstract base for [Service]s, which can be used to hook into the service
/// lifecycle. Can also obtain the current instance of [DarwinSystem].
abstract class ServiceBase {
  FutureOr<void> start(DarwinSystem system);

  FutureOr<void> stop(DarwinSystem system);
}

/// Abstract factory-like service creator and information holder.
///
/// This class is mostly generated in end-user applications by darwin_gen or
/// the generators of other darwin packages. However this class can and should
/// also be manually implemented by plugins which intend to run custom services.
abstract class ServiceDescriptor implements Activator {
  const ServiceDescriptor();

  /// Actual type of the service that will be instantiated
  Type get serviceType;

  /// Type to which this service is going to get bound to.
  Type get bindingType;

  /// Defines if this service is optional and can be skipped.
  bool get optional => false;

  /// Dependencies required by this service.
  List<InjectorKey> get dependencies;

  /// Optional dependencies of this service.
  List<InjectorKey> get optionalDependencies => [];

  /// All dependencies which could be published by this service.
  List<InjectorKey> get publications;

  /// Conditions required by this service.
  List<Condition> get conditions;

  /// The start signal handler of this service.
  Future<void> start(DarwinSystem system, dynamic obj);

  /// The stop signal handler of this service.
  Future<void> stop(DarwinSystem system, dynamic obj);

  static ServiceDescriptor create(
    Type serviceType,
    FutureOr<dynamic> Function(Injector) instantiate, {
    Type? bindingType,
    bool optional = false,
    List<InjectorKey> publications = const [],
    List<InjectorKey> dependencies = const [],
    List<InjectorKey> optionalDependencies = const [],
    List<Condition> conditions = const [],
    FutureOr<void> Function(DarwinSystem, dynamic)? start,
    FutureOr<void> Function(DarwinSystem, dynamic)? stop,
  }) {
    var actualBindingType = bindingType ?? serviceType;
    var publicationList = publications.toList();
    if (!publicationList.any((element) => element.type == actualBindingType)) {
      publicationList.add(InjectorKey.create(actualBindingType));
    }
    return ServiceDescriptorImpl(
        bindingType: actualBindingType,
        serviceType: serviceType,
        optional: optional,
        conditions: conditions,
        dependencies: dependencies,
        optionalDependencies: optionalDependencies,
        publications: publicationList,
        instantiateFunc: instantiate,
        startFunc: start ?? _lifecycleNoop,
        stopFunc: stop ?? _lifecycleNoop);
  }
}

void _lifecycleNoop(DarwinSystem system, dynamic obj) {}

class ServiceDescriptorImpl extends ServiceDescriptor {
  @override
  Type bindingType;
  @override
  Type serviceType;
  @override
  List<Condition> conditions;
  @override
  List<InjectorKey> dependencies;
  @override
  List<InjectorKey> optionalDependencies;
  @override
  List<InjectorKey> publications;
  @override
  bool optional;
  FutureOr<dynamic> Function(Injector) instantiateFunc;
  FutureOr<void> Function(DarwinSystem, dynamic) startFunc;
  FutureOr<void> Function(DarwinSystem, dynamic) stopFunc;

  @override
  Future<dynamic> instantiate(Injector injector) async {
    return await instantiateFunc(injector);
  }

  @override
  Future<void> start(DarwinSystem system, dynamic obj) async {
    await startFunc(system, obj);
  }

  @override
  Future<void> stop(DarwinSystem system, dynamic obj) async {
    await stopFunc(system, obj);
  }

  ServiceDescriptorImpl({
    required this.bindingType,
    required this.serviceType,
    required this.optional,
    required this.conditions,
    required this.dependencies,
    required this.optionalDependencies,
    required this.publications,
    required this.instantiateFunc,
    required this.startFunc,
    required this.stopFunc,
  });

  @override
  String toString() {
    if (bindingType == serviceType) return "Descriptor [$bindingType]";
    return "Descriptor [$bindingType:$serviceType]";
  }
}

class RunningService {
  dynamic obj;
  ServiceDescriptor descriptor;

  RunningService(this.obj, this.descriptor);
}

mixin DarwinSystemServiceMixin on DarwinSystemBase {
  List<RunningService> runningServices = [];
  final List<ServiceDescriptor> serviceDescriptors = [];

  /// The current lifecycle start of this service system.
  /// Modifications to this systems state must be made at
  /// [SystemLifecycleState.initial] or after the startup
  /// at [SystemLifecycleState.started].
  SystemLifecycleState lifecycleState = SystemLifecycleState.initial;

  /// Starts all services described by [serviceDescriptors],
  /// solving dependencies by recursively starting only satisfied services
  /// until all descriptors have either declined registration or have been started.
  ///
  /// If a dependency resolution cycle elapses without any emitted services,
  /// the service graph is considered broken and an [UnsatisfiedServiceDependenciesException]
  /// will be thrown.
  Future<void> startServices() async {
    var logging = (this as DarwinSystemLoggingMixin);
    lifecycleState = SystemLifecycleState.starting;
    var resolver = ServiceMixinResolver(this);
    await resolver.solve(serviceDescriptors).forEach((element) {
      if (logging.level.value <= element.type.level.value) {
        logging.handler(element.type.createLog(element));
      }
      if (element.type == ResolveEventType.failed) throw Exception();
    });
    lifecycleState = SystemLifecycleState.started;
  }

  /// Constructs and starts the service described by [descriptor] and returns
  /// if the service has been started and registered successfully.
  ///
  /// Service dependencies aren't checked or validated by this method, when
  /// calling manually, make sure to check [ServiceDescriptor.isSatisfied]
  /// before invoking this method.
  Future<bool> startService(ServiceDescriptor descriptor) async {
    var logger = (this as DarwinSystemLoggingMixin).logger;
    logger
        .finer("Trying to start service ${descriptor.serviceType}...");
    if (!serviceDescriptors.contains(descriptor)) {
      serviceDescriptors.add(descriptor);
    }
    var matchesConditions = await descriptor.conditions.match(this as DarwinSystem);
    if (!matchesConditions) {
      logger.finer(
          "Service conditions aren't met, skipping service registration");
      return false;
    }
    var obj = await descriptor.instantiate(injector);
    await descriptor.start(this as DarwinSystem, obj);
    darwinSystemModule.bind(descriptor.bindingType).toConstant(obj);
    runningServices.add(RunningService(obj, descriptor));
    logger.fine("Started service ${descriptor.serviceType}");
    return true;
  }

  Future<void> stopServices() async {
    // Stop services in reversed order so children shut down before their parents do
    for (var service in runningServices.reversed) {
      var obj = service.obj;
      var descriptor = service.descriptor;
      await descriptor.stop(this as DarwinSystem, obj);
    }
    runningServices.clear();
  }

  /// Returns all service descriptors which bind to [type].
  List<ServiceDescriptor> findDescriptors(Type type) => serviceDescriptors
      .where((element) => element.bindingType == type)
      .toList();

  /// Returns all service descriptors which have the implementation class [type].
  List<ServiceDescriptor> findDescriptorsExact(Type type) => serviceDescriptors
      .where((element) => element.serviceType == type)
      .toList();

  /// Returns all running services which are bound to [type].
  List<RunningService> findServices(Type type) => runningServices
      .where((element) => element.descriptor.bindingType == type)
      .toList();

  /// Returns all running services which have the implementation class [type].
  List<RunningService> findServicesExact(Type type) => runningServices
      .where((element) => element.obj.runtimeType == type)
      .toList();

  /// Returns all running services which have the associated [descriptor].
  List<RunningService> findServicesWithDescriptor(
          ServiceDescriptor descriptor) =>
      runningServices
          .where((element) => element.descriptor == descriptor)
          .toList();
}

enum SystemLifecycleState { initial, starting, started }
