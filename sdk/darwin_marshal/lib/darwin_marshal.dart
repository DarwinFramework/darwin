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

/// An object serialization library used by the darwin_http package of the darwin framework.
library darwin_marshal;

export 'src/adapters.dart';
export 'src/context.dart';
export 'src/mapper.dart';
export 'src/marshal.dart';
export 'src/plugin.dart';
export 'src/service.dart';
export 'src/utils.dart';

export 'mappers/darwin_marshal_json.dart';
export 'mappers/darwin_marshal_simple.dart';
