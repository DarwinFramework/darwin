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

import 'package:lyell/lyell.dart';

import '../darwin_marshal.dart';

/// Describes the target type of the marshalled target.
class MarshalTarget {

  /// Type capture of the defined type.
  final TypeCapture type;

  // Type capture of the extracted serial type.
  // final TypeCapture serial;

  const MarshalTarget(this.type);
}

class SerializationContext {
  MarshalTarget target;
  String? mime;
  Map<dynamic, dynamic> meta;
  DarwinMarshal marshal;

  SerializationContext(this.target, this.mime, this.meta, this.marshal);
}

class DeserializationContext {
  MarshalTarget target;
  String? mime;
  Map<dynamic, dynamic> meta;
  DarwinMarshal marshal;

  DeserializationContext(this.mime, this.target, this.meta, this.marshal);
}
