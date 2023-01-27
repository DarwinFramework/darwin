import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:test/test.dart';

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
      var matcher = PathUtils.parseMatcher("this/is/a/%variable%");
      var uri =
          Uri.parse("https://myapi.com/this/is/a/value?my=parameter&another=1");
      var match = matcher.match(uri);
      expect(match.result, true);
      expect(match.data["variable"], "value");
    });
  });
}
