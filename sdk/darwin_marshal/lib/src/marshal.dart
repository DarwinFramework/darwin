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

import 'context.dart';
import 'mapper.dart';

class DarwinMarshal {
  Map<Type, List<DarwinMapper>> associatedMappers = {};
  List<DarwinMapper> universalMappers = [];

  void register(DarwinMapper mapper) {
    if (mapper.associatedType != null) {
      registerTypeMapper(mapper);
    } else {
      registerUniversalMapper(mapper);
    }
  }

  void registerMultiple(Iterable<DarwinMapper> mappers) {
    for (var value in mappers) {
      register(value);
    }
  }

  void registerTypeMapper(DarwinMapper mapper) {
    var type = mapper.associatedType!;
    var objectMappers = associatedMappers[type] ?? <DarwinMapper>[];
    objectMappers.add(mapper);
    objectMappers.sort((a, b) => b.priority.compareTo(a.priority));
    associatedMappers[type] = objectMappers;
  }

  void registerUniversalMapper(DarwinMapper mapper) {
    universalMappers.add(mapper);
    universalMappers.sort((a, b) => b.priority.compareTo(a.priority));
  }

  DarwinMapper? findSerializer(SerializationContext context) {
    var foundTypeMappers = associatedMappers[context.target.type.typeArgument]
            ?.where((element) => element.checkSerialize(context))
            .toList() ??
        [];
    if (foundTypeMappers.isNotEmpty) return foundTypeMappers.first;
    var foundUniversalMappers = universalMappers
        .where((element) => element.checkSerialize(context))
        .toList();
    if (foundUniversalMappers.isNotEmpty) return foundUniversalMappers.first;
    return null;
  }

  DarwinMapper? findDeserializer(DeserializationContext context) {
    var foundTypeMappers = associatedMappers[context.target.type.typeArgument]
            ?.where((element) => element.checkDeserialize(context))
            .toList() ??
        [];
    if (foundTypeMappers.isNotEmpty) return foundTypeMappers.first;
    var foundUniversalMappers = universalMappers
        .where((element) => element.checkDeserialize(context))
        .toList();
    if (foundUniversalMappers.isNotEmpty) return foundUniversalMappers.first;
    return null;
  }
}
