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

import 'package:lyell_gen/lyell_gen.dart';

class ServiceBinding {
  String name;
  String package;

  String get key => "$package#$name";

  ServiceBinding({required this.name, this.package = ""});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceBinding &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          package == other.package);

  @override
  int get hashCode =>
      name.hashCode ^
      package.hashCode;

  @override
  String toString() {
    return 'ServiceBinding{name: $name, package: $package}';
  }

  void store(SubjectDescriptor descriptor) {
    descriptor.meta["name"] = name;
  }

  factory ServiceBinding.load(SubjectDescriptor descriptor) {
    var name = descriptor.meta["name"];
    var package = descriptor.uri.toString();
    return ServiceBinding(name: name, package: package);
  }

  ServiceBinding copyWith({
    String? name,
    String? package,
    String? descriptorName,
    String? descriptorPackage,
  }) {
    return ServiceBinding(
      name: name ?? this.name,
      package: package ?? this.package
    );
  }
}
