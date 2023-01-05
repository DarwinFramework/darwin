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

class ServiceBinding {
  String name;
  String package;
  String descriptorName;
  String descriptorPackage;

  String get key => "$package#$name";

  ServiceBinding(
      {required this.name,
      required this.package,
      required this.descriptorName,
      required this.descriptorPackage});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceBinding &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          package == other.package &&
          descriptorName == other.descriptorName &&
          descriptorPackage == other.descriptorPackage);

  @override
  int get hashCode =>
      name.hashCode ^
      package.hashCode ^
      descriptorName.hashCode ^
      descriptorPackage.hashCode;

  @override
  String toString() {
    return 'ServiceBinding{name: $name, package: $package, descriptorName: $descriptorName, descriptorPackage: $descriptorPackage}';
  }

  ServiceBinding copyWith({
    String? name,
    String? package,
    String? descriptorName,
    String? descriptorPackage,
  }) {
    return ServiceBinding(
      name: name ?? this.name,
      package: package ?? this.package,
      descriptorName: descriptorName ?? this.descriptorName,
      descriptorPackage: descriptorPackage ?? this.descriptorPackage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'package': package,
      'descriptorName': descriptorName,
      'descriptorPackage': descriptorPackage,
    };
  }

  factory ServiceBinding.fromMap(Map<String, dynamic> map) {
    return ServiceBinding(
      name: map['name'] as String,
      package: map['package'] as String,
      descriptorName: map['descriptorName'] as String,
      descriptorPackage: map['descriptorPackage'] as String,
    );
  }
}
