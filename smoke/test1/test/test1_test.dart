import 'package:darwin_test/darwin_test.dart';
import 'package:smoke_test_1/darwin.g.dart';
import 'package:test/test.dart';

import '../bin/test1.dart';

void main() async {
  var system = await startApplication(initialiseDarwin, configureDarwin);
  test('First | Return Types', () {
    expectResponse(system, hasBody("Value"), path: "first/method0");
    expectResponse(system, hasHeader("Content-Type", "text/plain"), path: "first/method0");
    expectResponse(system, hasBody("Value"), path: "first/method1");
    expectResponse(system, hasBody("Value"), path: "first/method2");
    expectResponse(system, hasStatus(500), path: "first/method3");
    expectResponse(system, hasStatus(204), path: "first/method4");
    expectResponse(system, hasStatus(204), path: "first/method5");
    expectResponse(system, hasBody("""A, B, C"""), path: "first/method6");
    expectResponse(system, hasBody("""A, B, C"""), path: "first/method7");
    expectResponse(system, hasBody("""A, B, C"""), path: "first/method8");
    expectResponse(system, hasStatus(418), path: "first/method9");
    expectResponse(system, hasBody("Value"), path: "first/method10");
    expectResponse(system, hasHeader("Content-Type", "application/octet-stream"), path: "first/method10");
    expectResponse(system, hasBody("""{"name":"Alex","age":18}"""), path: "first/method11");
    expectResponse(system, hasHeader("Content-Type", "application/json"), path: "first/method11");
  });
  test('Second | Parameters', () {
    expectResponse(system, hasStatus(204), path: "second/method0");
    expectResponse(system, hasBody("DarwinTest"), path: "second/method1");
    expectResponse(system, hasBody("true"), path: "second/method2", headers: {
      "Test": "Value"
    });
    expectResponse(system, hasBody("false"), path: "second/method2");
    expectResponse(system, hasBody("Value"), path: "second/method3/Value");
    expectResponse(system, hasBody("Value"), path: "second/method4", query: {
      "test": "Value"
    });
  });
}
