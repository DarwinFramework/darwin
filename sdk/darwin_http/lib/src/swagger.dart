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

import 'package:conduit_open_api/v3.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:shelf/shelf.dart';

class SwaggerRoute extends DarwinHttpRoute {

  var path = PathUtils.parseMatcher("api/docs");

  @override
  Future<bool> checkRequest(RequestContext context) async {
    return path.match(context.request.url).result && context.method == Method.get;
  }

  @override
  Future<Response?> handle(RequestContext context) async {
    var responseBody = """
<html>
    <head>
        <script src="https://unpkg.com/swagger-ui-dist@3/swagger-ui-bundle.js"></script>
        <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@3/swagger-ui.css"/>
        <title>API Docs</title>
    </head>
    <body>
        <div id="swagger-ui"></div> <!-- Div to hold the UI component -->
        <script>
            window.onload = function () {
                // Begin Swagger UI call region
                const ui = SwaggerUIBundle({
                    url: "docs/swagger.json",
                    dom_id: '#swagger-ui',
                    deepLinking: true,
                    presets: [
                        SwaggerUIBundle.presets.apis,
                        SwaggerUIBundle.SwaggerUIStandalonePreset
                    ],
                    plugins: [
                        SwaggerUIBundle.plugins.DownloadUrl
                    ],
                })
                window.ui = ui
            }
        </script>
    </body>
</html>
    """;
    return Response.ok(responseBody, headers: {
      "Content-Type": "text/html"
    });
  }

}

class SwaggerJsonRoute extends DarwinHttpRoute {

  var path = PathUtils.parseMatcher("api/docs/swagger.json");

  @override
  Future<bool> checkRequest(RequestContext context) async {
    return path.match(context.request.url).result && context.method == Method.get;
  }

  @override
  Future<Response?> handle(RequestContext context) async {
    DarwinHttpServer server = await context.injector.get(DarwinHttpServer);
    var responseBody = jsonEncode(server.apiDocument.asMap());
    return Response.ok(responseBody, headers: {
      "Content-Type": "application/json"
    });
  }
}