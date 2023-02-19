import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:logging/logging.dart';
import 'package:smoke_test_1/darwin.g.dart';

Future main(List<String> arguments) async {
  await initialiseDarwin();
  await configureDarwin(application);
  await application.execute();
}

Future configureDarwin(DarwinApplication application) async {
  application.watchProcessSignals = true;
  application.setLogLevel(Level.ALL);
  application.install(HttpPlugin());
  application.install(MarshalPlugin((marshal) {}));
}
