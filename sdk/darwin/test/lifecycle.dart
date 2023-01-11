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

import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:darwin_test/darwin_test.dart';

void main() {
  test("Descriptor start methods", () async {
    var startCompleter = Completer();
    var stopCompleter = Completer();
    var descriptor = ServiceDescriptor.create(String, (p0) => "Hello World",
        start: (system, str) {
      startCompleter.complete();
    }, stop: (system, str) {
      stopCompleter.complete();
    });

    var system = await startSystem([descriptor]);

    expect(startCompleter.future, completes);
    expect(stopCompleter.future, doesNotComplete);
    expect(system, isRunning<String>());
  });

  test("Descriptor stop methods", () async {
    var startCompleter = Completer();
    var stopCompleter = Completer();
    var descriptor = ServiceDescriptor.create(String, (p0) => "Hello World",
        start: (system, str) {
      startCompleter.complete();
    }, stop: (system, str) {
      stopCompleter.complete();
    });

    var system = await startSystem([descriptor]);
    await system.serviceMixin.stopServices();

    expect(startCompleter.future, completes);
    expect(stopCompleter.future, completes);
    expect(system, isNotRunning<String>());
  });
}
