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

import 'package:conduit_open_api/v3.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_sdk/darwin_sdk.dart';

part 'parameters/body.dart';
part 'parameters/context.dart';
part 'parameters/di.dart';
part 'parameters/header.dart';
part 'parameters/path_parameter.dart';
part 'parameters/query_parameter.dart';

class Accepts extends HandlerAnnotation {
  final String contentType;
  const Accepts(this.contentType);
}

class Returns extends HandlerAnnotation {
  final String contentType;
  const Returns(this.contentType);
}
