import 'dart:io';

import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:darwin_sdk/darwin_sdk.dart';

@RestController()
@RequestMapping("/api")
@HeaderEqualsInterceptor("X-Test", "true")
class ApiController {

  @Profile("debug")
  @GetMapping("/debug")
  @HeaderEqualsInterceptor("X-Debug", "true")
  String getDebugMessage() => "This is an debug only message!";

  @PostMapping("/hello/world")
  Future<String> helloWorld(
      @Body() String body,
      @Named("helloBean") String bean,
      @Header("User-Agent") String agent) async {
    return "Hello $agent, you sent '$body'!";
  }

  @PostMapping("/hello/%name%")
  @Returns("application/json")
  @AlwaysCondition()
  Future<Map> helloName(@PathParameter() String name, @QueryParameter() String age, HttpConnectionInfo info) async {
    return {
      "name": name,
      "age": age,
      "ip": info.remoteAddress.address
    };
  }
}
