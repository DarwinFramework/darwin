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

import 'package:darwin_marshal/darwin_marshal.dart';

typedef ToMap<T> = Map<String, dynamic> Function(T);
typedef FromMap<T> = T Function(Map<String, dynamic>);

class JsonMapAdapter<T> extends DarwinMapper<dynamic> {

  final ToMap<T> toMap;
  final FromMap<T> fromMap;

  @override
  final int priority;

  final Type iterableType = Iterable<T>;
  final Type listType = List<T>;
  final Type setType = Set<T>;

  JsonMapAdapter({
    required this.toMap,
    required this.fromMap,
    this.priority = 100
  });

  @override
  bool checkDeserialize(DeserializationContext context) {
    var target = context.target;
    return target == T || target == iterableType || target == listType || target == setType;
  }

  @override
  bool checkSerialize(SerializationContext context) {
    var type = context.type;
    return type == T || type == iterableType || type == listType || type == setType;
  }

  T? _dMap(List<int> data) {
    var map = JsonMapMapper.jsonDeserialize(data);
    if (map == null) return null;
    return fromMap(map);
  }

  List<int> _sMap(T? obj) {
    if (obj == null) return [];
    return JsonMapMapper.jsonSerialize(toMap(obj));
  }

  @override
  dynamic deserialize(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return null;
    var string = utf8.decode(data);
    var decoded = jsonDecode(string);
    if (context.target == listType || context.target == iterableType) {
      if (decoded is! List) throw Exception("Can't decode json list");
      return decoded.map((e) => fromMap(e)).toList();
    }

    if (context.target == setType) {
      if (decoded is! List) throw Exception("Can't decode json list");
      return decoded.map((e) => fromMap(e)).toSet();
    }

    if (decoded is! StringKeyedMap) throw Exception("Can't decode json map");
    return fromMap(decoded);
  }

  @override
  List<int> serialize(dynamic obj, SerializationContext context) {
    if (obj == null) return [];
    if (obj is Iterable<T>) {
      var list = obj.map((e) => toMap(e)).toList();
      var encoded = jsonEncode(list);
      var data = utf8.encode(encoded);
      return data;
    }

    var encoded = jsonEncode(toMap(obj));
    var data = utf8.encode(encoded);
    return data;
  }
}