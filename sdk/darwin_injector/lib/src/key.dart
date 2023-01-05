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

class InjectorKey {
  final Type type;
  final String? name;
  final dynamic data;

  const InjectorKey(this.type, this.name, this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InjectorKey &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          data == other.data;

  @override
  int get hashCode => type.hashCode ^ name.hashCode ^ data.hashCode;

  @override
  String toString() {
    return 'InjectorKey{type: $type, name: $name, data: $data}';
  }

  factory InjectorKey.create(Type type, {String? name, dynamic data}) =>
      InjectorKey(type, name, data);
}
