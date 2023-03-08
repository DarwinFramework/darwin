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

import 'dart:collection';
import 'dart:convert';

import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:lyell/lyell.dart';

typedef ToMap<T> = Map<String, dynamic> Function(T);
typedef FromMap<T> = T Function(Map<String, dynamic>);

class JsonMapAdapter<T> extends SimpleSerialMultiAdapter {
  final ToMap<T> toMap;
  final FromMap<T> fromMap;

  final Type iterableType = Iterable<T>;
  final Type listType = List<T>;
  final Type setType = Set<T>;

  JsonMapAdapter({required this.toMap, required this.fromMap, super.priority = 100}) : super(mime: "application/json");

  @override
  Iterable? deserializeMultiple(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return null;
    var string = utf8.decode(data);
    var decoded = jsonDecode(string) as Iterable;
    return decoded.map((e) => fromMap(e as Map<String,dynamic>)).toList();
  }

  @override
  deserializeSingle(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return null;
    var string = utf8.decode(data);
    var decoded = jsonDecode(string);
    return fromMap(decoded);
  }

  @override
  List<int> serializeMultiple(Iterable? obj, SerializationContext context) {
    if (obj == null) return [];
    var list = obj.map((e) => toMap(e)).toList();
    var encoded = jsonEncode(list);
    var data = utf8.encode(encoded);
    return data;
  }

  @override
  List<int> serializeSingle(obj, SerializationContext context) {
    if (obj == null) return [];
    var encoded = jsonEncode(toMap(obj));
    var data = utf8.encode(encoded);
    return data;
  }

  @override
  TypeCapture<T> get typeCapture => TypeToken<T>();
}

abstract class SimpleTypeMapperAdapter extends DarwinMapper {

  SimpleTypeMapperAdapter(Type type, {super.priority}): super(associatedType: type);

  @override
  bool checkDeserialize(DeserializationContext context) {
    return context.target.type.typeArgument == associatedType!;
  }

  @override
  bool checkSerialize(SerializationContext context) {
    return context.target.type.typeArgument == associatedType!;
  }
}

abstract class SimpleSerialMultiAdapter with IterableMixin<DarwinMapper> {

  int priority = 0;
  String? mime;
  SimpleSerialMultiAdapter({this.priority = 0, this.mime});

  TypeCapture get typeCapture;

  List<DarwinMapper> get mappers {
    return [
    _SerialSingleMapper(this),
    _SerialListMapper(this),
    _SerialSetMapper(this),
    _SerialIterableMapper(this)
  ];
  }

  @override
  Iterator<DarwinMapper> get iterator => mappers.iterator;
  
  deserializeSingle(List<int> data, DeserializationContext context);
  List<int> serializeSingle(dynamic obj, SerializationContext context);

  Iterable? deserializeMultiple(List<int> data, DeserializationContext context);
  List<int> serializeMultiple(Iterable? obj, SerializationContext context);
}

class _SerialSingleMapper extends SimpleTypeMapperAdapter {
  final SimpleSerialMultiAdapter adapter;

  _SerialSingleMapper(this.adapter) : super(adapter.typeCapture.typeArgument);

  @override
  deserialize(List<int> data, DeserializationContext context) {
    return adapter.deserializeSingle(data, context);
  }

  @override
  List<int> serialize(obj, SerializationContext context) {
    return adapter.serializeSingle(obj, context);
  }

  @override
  String? get outputMime => adapter.mime;
}

class _SerialIterableMapper extends SimpleTypeMapperAdapter {
  
  final SimpleSerialMultiAdapter adapter;
  
  _SerialIterableMapper(this.adapter) : super(adapter.typeCapture.deriveIterable);

  @override
  deserialize(List<int> data, DeserializationContext context) {
    return adapter.deserializeMultiple(data, context);
  }

  @override
  List<int> serialize(obj, SerializationContext context) {
    return adapter.serializeMultiple(obj, context);
  }

  @override
  String? get outputMime => adapter.mime;
}

class _SerialListMapper extends SimpleTypeMapperAdapter {
  final SimpleSerialMultiAdapter adapter;
  
  _SerialListMapper(this.adapter) : super(adapter.typeCapture.deriveList);

  @override
  deserialize(List<int> data, DeserializationContext context) {
    return adapter.deserializeMultiple(data, context)?.toList();
  }

  @override
  List<int> serialize(obj, SerializationContext context) {
    return adapter.serializeMultiple(obj, context);
  }

  @override
  String? get outputMime => adapter.mime;
}

class _SerialSetMapper extends SimpleTypeMapperAdapter {
  final SimpleSerialMultiAdapter adapter;

  _SerialSetMapper(this.adapter) : super(adapter.typeCapture.deriveSet);

  @override
  deserialize(List<int> data, DeserializationContext context) {
    return adapter.deserializeMultiple(data, context)?.toSet();
  }

  @override
  List<int> serialize(obj, SerializationContext context) {
    return adapter.serializeMultiple(obj, context);
  }

  @override
  String? get outputMime => adapter.mime;
}