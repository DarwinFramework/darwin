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

class MiscFiles {

  static final String readme = """
A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.
""".trim();

  static final String changelog = """
## 0.0.1

- Initial version.
""".trim();

  static final String gitignore = """
# Files and directories created by pub.
.dart_tool/
.packages

# IntelliJ files
.idea/
*.iml

# Ignore generated dart files
*.g.dart

# dotenv environment variables file
.env*

# Conventional directory for build output.
build/
""".trim();

  static final String analysisOptions = """include: package:lints/recommended.yaml""";

}