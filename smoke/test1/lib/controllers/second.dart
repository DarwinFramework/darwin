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

import 'package:darwin_http/darwin_http.dart';

@RestController()
@Path("second")
class SecondController {

  @GET("method0")
  void method0(RequestContext context) {
    context.injector; // Try access, should throw error if wrong
  }

  @GET("method1")
  String method1(@Header("User-Agent") String agent) {
    return agent;
  }

  @GET("method2")
  bool method2(@Header("Test") String? test) {
    return test != null;
  }

  @GET("method3/{test}")
  String method3(@PathParam() String test) {
    return test;
  }

  @GET("method4")
  String method4(@QueryParam() String test) {
    return test;
  }

}