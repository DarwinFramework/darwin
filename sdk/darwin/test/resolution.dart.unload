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
import 'package:darwin_test/darwin_test.dart';
import 'package:test/test.dart';

class A {}

class B {}

class C {}

class D {}

class E {}

class Z {}

void main() {
  test("Resolution order", () async {
    var a = ServiceDescriptor.create(A, (p0) => null);
    var b = ServiceDescriptor.create(B, (p0) => null,
        optionalDependencies: [InjectorKey.create(A)]);
    var c = ServiceDescriptor.create(C, (p0) => null,
        dependencies: [InjectorKey.create(A), InjectorKey.create(B)]);
    var d = ServiceDescriptor.create(D, (p0) => null,
        dependencies: [InjectorKey.create(A)],
        optionalDependencies: [InjectorKey.create(C)],
        publications: [InjectorKey.create(Z)]);
    var e = ServiceDescriptor.create(E, (p0) => null,
        dependencies: [InjectorKey.create(B)],
        optionalDependencies: [InjectorKey.create(D), InjectorKey.create(Z)]);

    var unsolved = [e, d, c, b, a];
    var system = createInfantSystem(services: unsolved);
    await system.serviceMixin.startServices();
    var expectedOrder = [a, b, c, d, e];
    for (var i = 0; i < expectedOrder.length; i++) {
      var expected = expectedOrder[i];
      var actual = system.serviceMixin.runningServices[i].descriptor;
      expect(actual, expected);
    }
  });

  test("Optional service", () async {
    var a = ServiceDescriptor.create(A, (p0) => null);
    var b = ServiceDescriptor.create(B, (p0) => null,
        dependencies: [InjectorKey.create(Z)], optional: true);
    var c = ServiceDescriptor.create(C, (p0) => null,
        optionalDependencies: [InjectorKey.create(B)]);
    var d = ServiceDescriptor.create(D, (p0) {
      expect(p0, isBound(InjectorKey.create(C)));
      return null;
    }, optionalDependencies: [InjectorKey.create(C)], optional: true);
    var unsolved = [a, d, c, b];
    var system = await startSystem(unsolved);
    expect(system, isRunning<A>());
    expect(system, isNotRunning<B>());
    expect(system, isRunning<C>());
    expect(system, isRunning<D>());
  });

  test("Missing dependency", () async {
    var a = ServiceDescriptor.create(A, (p0) => null);
    var b = ServiceDescriptor.create(B, (p0) => null,
        dependencies: [InjectorKey.create(B)]);
    var c = ServiceDescriptor.create(C, (p0) => null,
        dependencies: [InjectorKey.create(Z)]);

    var unsolved = [a, b, c];
    var system = createInfantSystem(services: unsolved);
    expect(() async {
      await system.serviceMixin.startServices();
    }, throwsException);
  });

  test("Missing optional dependency", () async {
    var a = ServiceDescriptor.create(A, (p0) => null);
    var b = ServiceDescriptor.create(B, (p0) => null,
        dependencies: [InjectorKey.create(A)]);
    var c = ServiceDescriptor.create(C, (p0) => null,
        optionalDependencies: [InjectorKey.create(Z)]);

    var unsolved = [a, b, c];
    var system = await startSystem(unsolved);
    expect(system, isRunning<A>());
    expect(system, isRunning<B>());
    expect(system, isRunning<C>());
  });
}
