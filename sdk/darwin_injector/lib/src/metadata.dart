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

class InjectorMetadata {
  final InjectorMetadata? _parent;
  final Map<dynamic, dynamic> _data = {};

  InjectorMetadata(this._parent);

  operator []=(dynamic key, dynamic value) => _data[key] = value;

  operator [](dynamic key) {
    var parentState = _parent;
    if (parentState != null) {
      if (parentState.containsKey(key)) parentState[key];
    }
    return _data[key];
  }

  bool containsKey(dynamic key) =>
      _data.containsKey(key) || (_parent?.containsKey(key) ?? false);
}

mixin MetadataMixin {
  InjectorMetadata get metadata;

  operator []=(dynamic key, dynamic value) => metadata[key] = value;

  operator [](dynamic key) => metadata[key];

  bool containsKey(dynamic key) => metadata.containsKey(key);
}
