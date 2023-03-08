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

import 'package:lyell/lyell.dart';

import '../darwin_marshal.dart';

class DarwinMarshalSimple {
  static void register(DarwinMarshal marshal, {bool strictMime = false}) {
    marshal.registerMultiple(SimpleStringMultiMapper());
    marshal.registerMultiple(SimpleIntMultiMapper());
    marshal.registerMultiple(SimpleDoubleMultiMapper());
    marshal.registerMultiple(SimpleBoolMultiMapper());
    marshal.register(SimpleDataMapper());
  }
}

class SimpleBoolMultiMapper extends SimpleSerialMultiAdapter {

  SimpleBoolMultiMapper() : super(mime: "text/plain");

  @override
  Iterable? deserializeMultiple(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return [];
    var str = utf8.decode(data);
    return str.split(RegExp(", |,")).map((e) => e == "true");
  }

  @override
  deserializeSingle(List<int> data, DeserializationContext context) {
    return utf8.decode(data) == "true";
  }

  @override
  List<int> serializeMultiple(Iterable? obj, SerializationContext context) {
    if (obj == null) return [];
    return utf8.encode(obj.map((e) => e.toString()).join(", "));
  }

  @override
  List<int> serializeSingle(obj, SerializationContext context) {
    if (obj == null) return [];
    return utf8.encode(obj.toString());
  }

  @override
  TypeCapture<bool> get typeCapture => TypeToken<bool>();
}

class SimpleDoubleMultiMapper extends SimpleSerialMultiAdapter {

  SimpleDoubleMultiMapper() : super(mime: "text/plain");

  @override
  Iterable? deserializeMultiple(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return [];
    var str = utf8.decode(data);
    return str.split(RegExp(", |,")).map((e) => double.parse(e));
  }

  @override
  deserializeSingle(List<int> data, DeserializationContext context) {
    return double.parse(utf8.decode(data));
  }

  @override
  List<int> serializeMultiple(Iterable? obj, SerializationContext context) {
    if (obj == null) return [];
    return utf8.encode(obj.map((e) => e.toString()).join(", "));
  }

  @override
  List<int> serializeSingle(obj, SerializationContext context) {
    if (obj == null) return [];
    return utf8.encode(obj.toString());
  }

  @override
  TypeCapture<double> get typeCapture => TypeToken<double>();
}

class SimpleIntMultiMapper extends SimpleSerialMultiAdapter {

  SimpleIntMultiMapper() : super(mime: "text/plain");

  @override
  Iterable? deserializeMultiple(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return [];
    var str = utf8.decode(data);
    return str.split(RegExp(", |,")).map((e) => int.parse(e));
  }

  @override
  deserializeSingle(List<int> data, DeserializationContext context) {
    return int.parse(utf8.decode(data));
  }

  @override
  List<int> serializeMultiple(Iterable? obj, SerializationContext context) {
    context.mime ??= "text/plain";
    if (obj == null) return [];
    return utf8.encode(obj.map((e) => e.toString()).join(", "));
  }

  @override
  List<int> serializeSingle(obj, SerializationContext context) {
    context.mime ??= "text/plain";
    if (obj == null) return [];
    return utf8.encode("$obj");
  }
  @override
  TypeCapture<int> get typeCapture => TypeToken<int>();
}

class SimpleStringMultiMapper extends SimpleSerialMultiAdapter {

  SimpleStringMultiMapper() : super(mime: "text/plain");

  @override
  Iterable? deserializeMultiple(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return [];
    var str = utf8.decode(data);
    return str.split(RegExp(", |,"));
  }

  @override
  deserializeSingle(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return "";
    return utf8.decode(data);
  }

  @override
  List<int> serializeMultiple(Iterable? obj, SerializationContext context) {
    context.mime ??= "text/plain";
    if (obj == null) return [];
    return utf8.encode(obj.map((e) => e.toString()).join(", "));
  }

  @override
  List<int> serializeSingle(obj, SerializationContext context) {
    context.mime ??= "text/plain";
    if (obj == null) return [];
    return utf8.encode(obj);
  }
  @override
  TypeCapture<String> get typeCapture => TypeToken<String>();
}

class SimpleDataMapper extends SimpleTypeMapperAdapter {

  SimpleDataMapper() : super(List<int>, priority: 100);

  @override
  List<int>? deserialize(List<int> data, DeserializationContext context) {
    return data;
  }

  @override
  List<int> serialize(dynamic obj, SerializationContext context) {
    if (obj == null) return [];
    return obj;
  }

  @override
  String get outputMime => "application/octet-stream";
}
