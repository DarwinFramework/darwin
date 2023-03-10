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

import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group("Path Combinations", () {
    test("Case 1 - A trailing", () {
      var a = "test/";
      var b = "path";
      var c = PathUtils.combinePath(a, b);
      expect("test/path", PathUtils.sanitizePath(c));
    });
    test("Case 2 - B leading", () {
      var a = "test";
      var b = "/path";
      var c = PathUtils.combinePath(a, b);
      expect("test/path", PathUtils.sanitizePath(c));
    });
    test("Case 3 - default", () {
      var a = "test";
      var b = "path";
      var c = PathUtils.combinePath(a, b);
      expect("test/path", PathUtils.sanitizePath(c));
    });
    test("Case 4 - A trailing, B leading", () {
      var a = "test/";
      var b = "/path";
      var c = PathUtils.combinePath(a, b);
      expect("test/path", PathUtils.sanitizePath(c));
    });
  });
  group("Fixed Matcher", () {
    test("Case 1 - fixed match", () {
      var matcher = PathUtils.parseMatcher("this/is/a/path");
      var uri =
      Uri.parse("https://myapi.com/this/is/a/path?my=parameter&another=1");
      expect(matcher.match(uri).result, true);
    });
    test("Case 2 - invalid length", () {
      var matcher = PathUtils.parseMatcher("this/is/a/path");
      var uri =
      Uri.parse("https://myapi.com/this/is/path?my=parameter&another=1");
      expect(matcher.match(uri).result, false);
    });
    test("Case 3 - escaped chars", () {
      var matcher = PathUtils.parseMatcher("this/is/a/\\p\\a\\t\\h");
      var uri =
      Uri.parse("https://myapi.com/this/is/a/path?my=parameter&another=1");
      expect(matcher.match(uri).result, true);
    });
    test("Case 4 - wrong segment", () {
      var matcher = PathUtils.parseMatcher("this/is/a/unicorn");
      var uri =
      Uri.parse("https://myapi.com/this/is/a/path?my=parameter&another=1");
      expect(matcher.match(uri).result, false);
    });
  });
  group("Variable Matcher", () {
    test("Case 1 - basic", () {
      var matcher = PathUtils.parseMatcher("this/is/a/{variable}");
      var uri =
      Uri.parse("https://myapi.com/this/is/a/value?my=parameter&another=1");
      var match = matcher.match(uri);
      expect(match.result, true);
      expect(match.data["variable"], "value");
    });
  });
  group("Special Cases", ()  {
    test("Root (empty)", ()  {
      var matcher = PathUtils.parseMatcher("");

      var u1 = Uri.parse("https://myapi.com");
      var m1 = matcher.match(u1);
      expect(m1.result, true);

      var u2 = Uri.parse("https://myapi.com/");
      var m2 = matcher.match(u2);
      expect(m2.result, true);

      var u3 = Uri.parse("https://myapi.com/test");
      var m3 = matcher.match(u3);
      expect(m3.result, false);
    });
    test("Root (slash)", ()  {
      var matcher = PathUtils.parseMatcher("/");

      var u1 = Uri.parse("https://myapi.com");
      var m1 = matcher.match(u1);
      expect(m1.result, true);

      var u2 = Uri.parse("https://myapi.com/");
      var m2 = matcher.match(u2);
      expect(m2.result, true);

      var u3 = Uri.parse("https://myapi.com/test");
      var m3 = matcher.match(u3);
      expect(m3.result, false);
    });
    test("Single", ()  {
      var matcher = PathUtils.parseMatcher("test");
      var uri = Uri.parse("https://myapi.com/test");
      var match = matcher.match(uri);
      expect(match.result, true);
    });
  });
}