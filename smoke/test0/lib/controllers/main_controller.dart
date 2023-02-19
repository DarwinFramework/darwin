import 'dart:io';

import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:darwin_sdk/darwin_sdk.dart';

@RestController()
@Path("/api")
class ApiController {

  @Profile("debug")
  @GET("/debug")
  @HeaderEqualsInterceptor("X-Debug", "true")
  String getDebugMessage() => "This is an debug only message!";

  @POST("/hello/world")
  Future<String> helloWorld(
      @Body() String body,
      @Named("helloBean") String bean,
      @Header("User-Agent") String agent) async {
    return "Hello $agent, you sent '$body'!";
  }

  @GET("list")
  List<String> getList() => ["a","b","c"];

  @POST("/hello/%name%")
  @Returns("application/json")
  @AlwaysCondition()
  Future<Map> helloName(@PathParam() String name, @QueryParam() String age, HttpConnectionInfo info) async {
    return {
      "name": name,
      "age": age,
      "ip": info.remoteAddress.address
    };
  }

  @POST("/call")
  void call() {
    throw RequestException.gone();
  }

}
