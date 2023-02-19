import 'package:darwin_test/darwin_test.dart';
import 'package:smoke_test_1/darwin.g.dart';
import 'package:test/test.dart';

import '../bin/test1.dart';

void main() async {
  var system = await startApplication(initialiseDarwin, configureDarwin);
  test('First', () {
    expectResponse(system, isBody("Value"), path: "first/method0");
    expectResponse(system, isBody("Value"), path: "first/method1");
    expectResponse(system, isBody("Value"), path: "first/method2");
    expectResponse(system, isBody("Value"), path: "first/method3");
    expectResponse(system, isStatus(204), path: "first/method4");
    expectResponse(system, isStatus(204), path: "first/method5");
  });
}
