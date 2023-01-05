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

import 'context.dart';
import 'mapper.dart';

class DarwinMarshal {

  Map<Type, List<DarwinMapper<dynamic>>> typeMappers = {};
  List<DarwinMapper<dynamic>> universalMappers = [];

  void registerTypeMapper(Type objType, DarwinMapper<dynamic> mapper) {
    var objectMappers = typeMappers[objType] ?? <DarwinMapper<dynamic>>[];
    objectMappers.add(mapper);
    objectMappers.sort((a,b) => b.priority.compareTo(a.priority));
    typeMappers[objType] = objectMappers;
  }

  void registerTypeMapperWithCollections<T>(DarwinMapper<dynamic> mapper) {
    registerTypeMapper(T, mapper);
    registerTypeMapper(Iterable<T>, mapper);
    registerTypeMapper(List<T>, mapper);
    registerTypeMapper(Set<T>, mapper);
  }

  void registerUniversalMapper(DarwinMapper<dynamic> mapper) {
    universalMappers.add(mapper);
    universalMappers.sort((a,b) => b.priority.compareTo(a.priority));
  }

  DarwinMapper<dynamic>? findSerializer(SerializationContext context) {
    var foundTypeMappers = typeMappers[context.type]?.where((element) => element.checkSerialize(context)).toList() ?? [];
    if (foundTypeMappers.isNotEmpty) return foundTypeMappers.first;
    var foundUniversalMappers = universalMappers.where((element) => element.checkSerialize(context)).toList();
    if (foundUniversalMappers.isNotEmpty) return foundUniversalMappers.first;
    return null;
  }

  DarwinMapper<dynamic>? findDeserializer(DeserializationContext context) {
    var foundTypeMappers = typeMappers[context.target]?.where((element) => element.checkDeserialize(context)).toList() ?? [];
    if (foundTypeMappers.isNotEmpty) return foundTypeMappers.first;
    var foundUniversalMappers = universalMappers.where((element) => element.checkDeserialize(context)).toList();
    if (foundUniversalMappers.isNotEmpty) return foundUniversalMappers.first;
    return null;
  }

}