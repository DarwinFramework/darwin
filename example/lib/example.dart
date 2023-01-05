import 'dart:developer';

import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:logging/logging.dart';

import 'darwin.g.dart';

Future main() async {
  await initialiseDarwin();
  application.setLogLevel(Level.ALL);
  application.setProfile("debug");
  // DarwinDefaultLogger.noAnsi = true;
  application.install(MarshalPlugin());
  application.install(HttpPlugin());
  await application.execute();
}