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

import 'dart:convert';

import '../darwin_marshal.dart';

class DarwinMarshalSimple {
  static void register(DarwinMarshal marshal, {bool strictMime = false}) {
    marshal.registerTypeMapper(String, SimpleStringMapper());
    marshal.registerTypeMapper(List<int>, SimpleDataMapper());
  }
}

class SimpleStringMapper extends DarwinMapper<String> {
  @override
  bool checkDeserialize(DeserializationContext context) {
    return context.target == String;
  }

  @override
  bool checkSerialize(SerializationContext context) {
    return context.type == String;
  }

  @override
  String? deserialize(List<int> data, DeserializationContext context) {
    return utf8.decode(data);
  }

  @override
  List<int> serialize(String? obj, SerializationContext context) {
    if (obj == null) return [];
    return utf8.encode(obj);
  }
}

class SimpleDataMapper extends DarwinMapper<List<int>> {
  @override
  bool checkDeserialize(DeserializationContext context) {
    return context.target == List<int>;
  }

  @override
  bool checkSerialize(SerializationContext context) {
    return context.type == List<int>;
  }

  @override
  List<int>? deserialize(List<int> data, DeserializationContext context) {
    return data;
  }

  @override
  List<int> serialize(List<int>? obj, SerializationContext context) {
    if (obj == null) return [];
    return obj;
  }
}
