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

class MainTemplates {

  static final String consoleTemplate = """import 'package:{{name}}/darwin.g.dart';

Future main(List<String> arguments) async {
  await initialiseDarwin();
  application.watchProcessSignals = true;
  await application.execute();
}""";

  static final String restTemplate = """import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:{{name}}/darwin.g.dart';

Future main(List<String> arguments) async {
  await initialiseDarwin();
  application.watchProcessSignals = true;
  application.install(HttpPlugin());
  application.install(MarshalPlugin((marshal) {
    // TODO: Link your serializers here. Example:
    // DogsMarshal.link(marshal, dogs);
  }));
  await application.execute();
}""";

}