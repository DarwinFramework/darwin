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

typedef StringKeyedMap = Map<String, dynamic>;

class DarwinMarshalJson {
  static String mime = "application/json";

  DarwinMarshalJson._() {
    throw Exception("Utility class can't be constructed");
  }

  static void register(DarwinMarshal marshal, {bool strictMime = false}) {
    // Register Map Serializer
    marshal.registerTypeMapper(StringKeyedMap, JsonMapMapper(strictMime));
    marshal.registerTypeMapper(Map, GenericMapJsonMapper(strictMime));

    // Register Collection Serializers
    var listSerializer = JsonListSerializer(strictMime);
    marshal.registerTypeMapper(Iterable, listSerializer);
    marshal.registerTypeMapper(List, listSerializer);
    marshal.registerTypeMapper(Set, listSerializer);
    marshal.registerUniversalMapper(listSerializer);
  }

  static StringKeyedMap? jsonDeserialize(List<int> data) {
    if (data.isEmpty) return null;
    var string = utf8.decode(data);
    var decoded = jsonDecode(string);
    if (decoded is! StringKeyedMap) throw Exception("Can't decode json map");
    return decoded;
  }

  static List<int> jsonSerialize(StringKeyedMap? obj) {
    if (obj == null) return [];
    var encoded = jsonEncode(obj);
    var data = utf8.encode(encoded);
    return data;
  }
}

class GenericMapJsonMapper extends DarwinMapper<Map> {
  bool strictMime;
  GenericMapJsonMapper(this.strictMime);

  @override
  bool checkDeserialize(DeserializationContext context) {
    if (strictMime &&
        (context.mime == null || context.mime != DarwinMarshalJson.mime)) {
      return false;
    }
    return context.target == Map;
  }

  @override
  bool checkSerialize(SerializationContext context) {
    if (strictMime &&
        (context.mime == null || context.mime != DarwinMarshalJson.mime)) {
      return false;
    }
    return context.type == Map;
  }

  @override
  Map? deserialize(List<int> data, DeserializationContext context) {
    return JsonMapMapper.jsonDeserialize(data);
  }

  @override
  List<int> serialize(Map? obj, SerializationContext context) {
    return JsonMapMapper.jsonSerialize(obj?.cast<String, dynamic>());
  }
}

class JsonMapMapper extends DarwinMapper<StringKeyedMap> {
  bool strictMime;

  JsonMapMapper(this.strictMime);

  static StringKeyedMap? jsonDeserialize(List<int> data) {
    if (data.isEmpty) return null;
    var string = utf8.decode(data);
    var decoded = jsonDecode(string);
    if (decoded is! StringKeyedMap) throw Exception("Can't decode json map");
    return decoded;
  }

  static List<int> jsonSerialize(StringKeyedMap? obj) {
    if (obj == null) return [];
    var encoded = jsonEncode(obj);
    var data = utf8.encode(encoded);
    return data;
  }

  @override
  bool checkDeserialize(DeserializationContext context) {
    if (strictMime &&
        (context.mime == null || context.mime != DarwinMarshalJson.mime)) {
      return false;
    }
    return context.target == StringKeyedMap;
  }

  @override
  bool checkSerialize(SerializationContext context) {
    if (strictMime &&
        (context.mime == null || context.mime != DarwinMarshalJson.mime)) {
      return false;
    }
    return context.type == StringKeyedMap;
  }

  @override
  StringKeyedMap? deserialize(List<int> data, DeserializationContext context) =>
      jsonDeserialize(data);

  @override
  List<int> serialize(StringKeyedMap? obj, SerializationContext context) =>
      jsonSerialize(obj);
}

class JsonListSerializer extends DarwinMapper<Iterable> {
  bool strictMime;

  JsonListSerializer(this.strictMime);

  @override
  int get priority => -1;

  bool checkType(Type t) {
    var commonTypes =
        (t == Iterable<dynamic>) || (t == List<dynamic>) || (t == Set<dynamic>);
    if (commonTypes) return true;
    if (TypeUtils.testClassAnyGeneric(Iterable, t)) return true;
    if (TypeUtils.testClassAnyGeneric(List, t)) return true;
    if (TypeUtils.testClassAnyGeneric(Set, t)) return true;
    return false;
  }

  @override
  bool checkDeserialize(DeserializationContext context) {
    if (strictMime &&
        (context.mime == null || context.mime != DarwinMarshalJson.mime)) {
      return false;
    }
    return checkType(context.target);
  }

  @override
  bool checkSerialize(SerializationContext context) {
    if (strictMime &&
        (context.mime == null || context.mime != DarwinMarshalJson.mime)) {
      return false;
    }
    return checkType(context.type);
  }

  @override
  Iterable? deserialize(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return null;
    var string = utf8.decode(data);
    var decoded = jsonDecode(string);
    if (decoded is! Iterable) throw Exception("Can't decode json list");
    if (TypeUtils.testClassAnyGeneric(context.target, Iterable)) return decoded;
    if (TypeUtils.testClassAnyGeneric(context.target, List)) {
      return decoded.toList();
    }
    if (TypeUtils.testClassAnyGeneric(context.target, Set)) {
      return decoded.toSet();
    }
    return decoded;
  }

  @override
  List<int> serialize(Iterable? obj, SerializationContext context) {
    if (obj == null) return [];
    var encoded = jsonEncode(obj);
    var data = utf8.encode(encoded);
    return data;
  }
}
