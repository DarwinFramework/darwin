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

import 'package:mustache_template/mustache.dart';

import '../darwin_starter.dart';
import '../templates/main.dart';

class MainFactory {
  static String getMain(ProjectType type, String name) {
    var mainContent = "";
    switch (type) {
      case ProjectType.console:
        mainContent = Template(MainTemplates.consoleTemplate)
            .renderString({"name": name});
        break;
      case ProjectType.rest:
        mainContent =
            Template(MainTemplates.restTemplate).renderString({"name": name});
        break;
    }
    return mainContent;
  }
}