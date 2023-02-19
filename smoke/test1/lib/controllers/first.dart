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

import 'dart:convert';

import 'package:darwin_http/darwin_http.dart';
import 'package:shelf/shelf.dart';

@RestController()
@Path("first")
class FirstController {

  @GET("method0")
  String method0() {
    return "Value";
  }

  @GET("method1")
  List<int> method1() {
    return utf8.encode("Value");
  }

  @GET("method2")
  Response method2() {
    return Response.ok("Value");
  }


  @GET("method3")
  dynamic method3() {
    return "Value";
  }

  @GET("method4")
  void method4() {}

  @GET("method5")
  Future method5() async {}

  Stream<String> method6() async* {
    yield "Value";
  }

}
