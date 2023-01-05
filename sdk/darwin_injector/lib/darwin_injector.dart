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

/// Support for doing something awesome.
///
/// More dartdocs go here.
library darwin_injector;

export 'src/activator.dart';
export 'src/binding.dart';
export 'src/injector.dart';
export 'src/key.dart';
export 'src/loading.dart';
export 'src/metadata.dart';
export 'src/module.dart';
export 'src/provider.dart';

class Named {

  final String name;

  const Named(this.name);
}