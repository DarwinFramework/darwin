
import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:logging/logging.dart';

import 'darwin.g.dart';

Future main() async {
  await initialiseDarwin();
  application.exitProcessOnStop = true;
  application.setLogLevel(Level.ALL);
  application.setProfile("debug");
  application.install(MarshalPlugin((marshal) {}));
  application.install(HttpPlugin());
  application.execute();
}