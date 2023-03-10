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


class PathUtils {
  static RegExp variableRegex = RegExp("{([A-z0-9_-]*)}");

  /// Combines the two paths [a] and [b] by adding a / between them.
  static String combinePath(String a, String b) {
    return "$a/$b";
  }

  /// Removes duplicated as well as trailing and leading path separators.
  static String sanitizePath(String path) {
    var str = path;
    // Remove duplicated slashes with a max depth of 255
    for (var depth = 0; depth < 255; depth++) {
      var length = str.length;
      str = str.replaceAll("//", "/");
      if (length == str.length) break;
    }
    // Remove leading and trailing slashes
    if (str.startsWith("/")) str = str.substring(1);
    if (str.endsWith("/")) str = str.substring(0, str.length - 1);
    return str;
  }

  /// Creates a matcher for the specified [path] matcher definition.
  static PathMatcher parseMatcher(String path) {
    List<PathMatcherFragment> fragments = [];
    var sanitized = sanitizePath(path);
    var spliced = splitPath(sanitized);
    for (var element in spliced) {
      // Check if the fragment matches the variable syntax
      var variableMatches = variableRegex.allMatches(element);
      if (variableMatches.isEmpty) {
        // Not a variable so we expected an exact match
        fragments.add(FixedPathMatcherFragment(element));
      } else {
        // Fragment is a valid template definition
        var variableName = variableMatches.first.group(1).toString();
        fragments.add(VariablePathMatcherFragment(variableName));
      }
    }
    return PathMatcher(sanitized, fragments);
  }

  static List<String> splitPath(String path) {
    List<String> fragments = [];
    StringBuffer buffer = StringBuffer();
    bool isEscaped = false;
    for (var i = 0; i < path.length; i++) {
      var char = path[i];
      // Add the escaped char to the buffer and reset the escape flag
      if (isEscaped) {
        buffer.write(char);
        isEscaped = false;
        continue;
      }
      // Begin the next fragment
      if (char == "/") {
        fragments.add(buffer.toString());
        buffer.clear();
        continue;
      }
      // Escape the next char if char equals '\'
      if (char == "\\") {
        isEscaped = true;
        continue;
      }
      buffer.write(char);
    }
    // Add last fragment if buffer is not empty
    if (buffer.isNotEmpty) fragments.add(buffer.toString());
    return fragments;
  }
}

class PathMatcher {
  String sourcePath;
  List<PathMatcherFragment> fragments;

  int get depth => fragments.length;
  int get sortIndex => fragments.isEmpty ? 1 : (fragments.last is VariablePathMatcherFragment ? 1 : -1);

  PathMatcher(this.sourcePath, this.fragments);

  PathMatch match(Uri uri) {
    var segments = uri.pathSegments;
    if (segments.length != fragments.length) return PathMatch(false, {});
    var data = <String, String>{};
    for (var i = 0; i < fragments.length; i++) {
      if (!fragments[i].match(segments[i], data)) {
        return PathMatch(false, data);
      }
    }
    return PathMatch(true, data);
  }

  @override
  String toString() => sourcePath;
}

class PathMatch {
  bool result;
  Map<String, String> data;

  PathMatch(this.result, this.data);
}

abstract class PathMatcherFragment {
  bool match(String input, Map<String, String> variables);
}

class FixedPathMatcherFragment extends PathMatcherFragment {
  String value;

  FixedPathMatcherFragment(this.value);

  @override
  bool match(String input, Map<String, String> variables) => input == value;
}

class VariablePathMatcherFragment extends PathMatcherFragment {
  String variableName;

  VariablePathMatcherFragment(this.variableName);

  @override
  bool match(String input, Map<String, String> variables) {
    variables[variableName] = input;
    return true;
  }
}
