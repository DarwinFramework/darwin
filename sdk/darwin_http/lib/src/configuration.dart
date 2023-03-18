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

import 'dart:io';

import 'package:darwin_sdk/darwin_sdk.dart';

class HttpConfiguration {

  int port;
  Object address;
  bool openapi;
  bool secure;
  String certFile;
  String keyFile;

  HttpConfiguration(this.port, this.address, this.openapi, this.secure, this.certFile, this.keyFile);

  static Future<HttpConfiguration> load(DarwinSystem system) async {
    var source = system.configurationSource;
    var port = (await source.getInt(["http", "port"])) ?? 8080;
    var address = (await source.getString(["http", "address"])) ?? InternetAddress.anyIPv4;
    var openapi = (await source.getBool(["http", "openapi"])) ?? system.isDebug;
    var secure = (await source.getBool(["http", "secure"])) ?? false;
    var certFile = (await source.getString(["http", "certFile"])) ?? "cert.pem";
    var keyFile = (await source.getString(["http", "keyFile"])) ?? "key.pem";
    return HttpConfiguration(port, address, openapi, secure, certFile, keyFile);
  }
}