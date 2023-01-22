import 'package:charles/charles.dart';

Future<void> main(List<String> arguments) async {
  var runner = CharlesCommandRunner();
  await runner.run(arguments);
}
